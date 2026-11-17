---@diagnostic disable: undefined-global

--[[
	Aviso de Guarda (Lanca) - Monster Hunter Wilds (REFramework)
	Versao 0.4 - PRIMEIRO AVISO + APRENDIZADO + PESQUISA DOS CONTROLES

	O que faz:
	  - Mostra uma BARRA DE AVISO no centro da tela quando o Arkveld comeca um golpe que o
	    mod conhece. Um marcador anda em direcao a uma linha e chega nela no momento do
	    impacto (como jogo de ritmo). Pouco antes, pisca "AGORA!".
	  - O texto diz o que fazer: GUARDA, POWER GUARD ou IMPOSSIVEL DE GUARDAR (esquive).
	  - APRENDE sozinho: cada golpe do Arkveld que chega em voce vira uma nova medicao.
	    Quanto mais voce luta, mais golpes ele conhece e mais preciso fica.
	  - Ja vem com o que foi medido nas gravacoes (Arkveld normal, lanca, solo).

	Como funciona por dentro:
	  Cada golpe do monstro e uma sequencia de animacoes (preparacao -> golpe). O tempo entre
	  o inicio de cada animacao e o impacto quase nao varia (cerca de 0,05s). Entao, quando o
	  monstro comeca uma animacao conhecida, o mod ja sabe quando o golpe vai chegar.

	Arquivos (em <pasta do jogo>/reframework/data/):
	  - aviso_lanca_opcoes.json       suas opcoes
	  - aviso_lanca_aprendizado.json  tudo o que o mod ja aprendeu
	  - aviso_lanca_estrutura.json    exportacao para pesquisa (botao no menu)
	  - aviso_lanca_gravacao_v4_N.json gravacoes para pesquisa (botao no menu)

	Partes do arquivo:
	  1. Ajustes e opcoes          2. Relogio, jogador e animacoes
	  3. Conhecimento e previsao   4. Monstros (Arkveld)
	  5. Impactos e aprendizado    6. Pesquisa (gravador, exportacao, arma)
	  7. Barra de aviso na tela    8. Menu
]]


-- =====================================================================================
-- 1. AJUSTES E OPCOES
-- =====================================================================================

local AJUSTES = {
	-- monstros cobertos (ID da lista do HunterPie). Normal, temperado, arquitemperado e todas
	-- as dificuldades usam o mesmo ID.
	monstros = { [27] = "Arkveld", [28] = "Arkveld Guardiao" },

	-- enderecos dentro do monstro (conferidos no HunterPie, versoes 1.20 a 1.42.0.2 do jogo)
	dados_basicos = 0x108,
	id_nos_dados_basicos = 0x48,
	inteligencia = 0xE8, -- gerenciador de IA (tem o "objeto de jogo" do monstro)

	-- aprendizado
	historico_animacoes = 4,     -- quantas animacoes recentes de cada monstro guardar
	animacoes_por_impacto = 3,   -- cada impacto ensina as 3 ultimas animacoes
	idade_maxima_animacao = 4.0, -- animacao que comecou ha mais que isso nao conta
	maximo_amostras = 40,        -- medicoes guardadas por animacao
	juntar_ate = 0.12,           -- impactos com diferenca menor que isso sao o mesmo impacto
	confirmar_ate = 0.20,        -- tolerancia para uma animacao nova "confirmar" um aviso
	minimo_amostras = 2,         -- precisa ter visto o golpe pelo menos 2 vezes para avisar
	minimo_antecedencia = 0.20,  -- nao cria aviso para impacto em menos que isso (nao da tempo)

	maximo_eventos = 30000
};

-- Opcoes do jogador (salvas em aviso_lanca_opcoes.json)
local op = {
	ativado = true,
	antecedencia_ms = 120,  -- "AGORA!" aparece este tanto antes do impacto
	janela = 1.2,           -- o marcador aparece este tanto de segundos antes do impacto
	altura_tela = 0.70,     -- altura da barra na tela (0 = topo, 1 = embaixo)
	aprender = true,
	mostrar_painel = false  -- painel de pesquisa (animacao atual, distancia...)
};

local function carregar_opcoes()
	local salvo = json.load_file("aviso_lanca_opcoes.json");
	if type(salvo) ~= "table" then return; end
	for chave, valor in pairs(op) do
		if type(salvo[chave]) == type(valor) then op[chave] = salvo[chave]; end
	end
end

local function salvar_opcoes()
	json.dump_file("aviso_lanca_opcoes.json", op);
end

local estado = {
	mensagem = "",
	ultimo_erro_ms = nil,   -- diferenca entre o impacto previsto e o real (ultimo golpe)
	avisos_certos = 0,
	impactos_vistos = 0
};


-- =====================================================================================
-- 2. RELOGIO, JOGADOR E ANIMACOES
-- =====================================================================================

local relogio = nil;

-- Relogio do proprio jogo (mais preciso); se nao der, usa o do Lua
local function agora()
	if relogio == nil then
		local aplicacao = sdk.get_native_singleton("via.Application");
		local tipo_aplicacao = sdk.find_type_definition("via.Application");
		local relogio_jogo = function()
			return sdk.call_native_func(aplicacao, tipo_aplicacao, "get_UpTimeSecond");
		end;
		local ok, valor = pcall(relogio_jogo);
		relogio = (ok and type(valor) == "number") and relogio_jogo or os.clock;
	end
	return relogio();
end

local function arredondar(valor, casas)
	if type(valor) ~= "number" then return valor; end
	local fator = 10 ^ (casas or 3);
	return math.floor(valor * fator + 0.5) / fator;
end

local function meu_cacador()
	local gerente = sdk.get_managed_singleton("app.PlayerManager");
	local info = gerente and gerente:call("getMasterPlayer");
	return info and info:call("get_Character");
end

local function objeto_de_jogo(personagem)
	local ok, objeto = pcall(personagem.call, personagem, "get_GameObject");
	return ok and objeto or nil;
end

local function posicao(objeto)
	local ok, p = pcall(function() return objeto:call("get_Transform"):call("get_Position"); end);
	if ok and p ~= nil then return p.x, p.y, p.z; end
	return nil;
end

local function distancia(x1, y1, z1, x2, y2, z2)
	if x1 == nil or x2 == nil then return nil; end
	local dx, dy, dz = x1 - x2, y1 - y2, z1 - z2;
	return math.sqrt(dx * dx + dy * dy + dz * dz);
end

local function seguir(objeto, deslocamento)
	if objeto == nil then return nil; end
	local endereco = objeto:read_qword(deslocamento);
	if endereco == nil or endereco == 0 then return nil; end
	return sdk.to_managed_object(endereco);
end

-- Animacao atual: numero, banco (grupo), quadro atual e final
local tipo_motion = sdk.typeof("via.motion.Motion");

local function animacao_de(objeto)
	if objeto == nil or tipo_motion == nil then return nil; end

	local ok, camada = pcall(function()
		local motion = objeto:call("getComponent(System.Type)", tipo_motion);
		return motion and motion:call("getLayer", 0);
	end);
	if not ok or camada == nil then return nil; end

	local ok_dados, id, banco, quadro, fim = pcall(function()
		return camada:call("get_MotionID"), camada:call("get_MotionBankID"),
			camada:call("get_Frame"), camada:call("get_EndFrame");
	end);
	if not ok_dados then return nil; end

	return id, banco, quadro, fim;
end

-- Tamanho da tela (para posicionar a barra)
local tipo_cena = sdk.find_type_definition("via.SceneManager");
local metodo_tamanho = sdk.find_type_definition("via.SceneView"):get_method("get_Size");

local function tamanho_tela()
	local ok, l, a = pcall(function()
		local cena = sdk.get_native_singleton("via.SceneManager");
		local visao = sdk.call_native_func(cena, tipo_cena, "get_MainView");
		local tamanho = metodo_tamanho:call(visao);
		return tamanho.w, tamanho.h;
	end);
	if ok and l and a then return l, a; end
	return 1920, 1080;
end


-- =====================================================================================
-- 3. CONHECIMENTO E PREVISAO
--
-- Para cada monstro e cada animacao ("banco:numero"), guardamos medicoes de quanto tempo
-- depois do inicio daquela animacao veio um impacto. Cada medicao = { segundos, tipo de
-- guarda do golpe, distancia }. Tipo de guarda: 0 normal, 1 qualquer direcao,
-- 2 impossivel de guardar, 3 so com habilidade/Power Guard.
-- =====================================================================================

-- O que ja foi medido nas gravacoes (Arkveld normal, lanca, solo, The Chains of Life)
local CONHECIMENTO_INICIAL = {
	["27"] = {
		["2:108"] = { {1.473,1,10.6}, {3.488,0,10.0} },
		["2:109"] = { {1.743,1,19.3} },
		["2:123"] = { {0.162,0,9.4} },
		["2:136"] = { {0.220,0,6.8}, {0.427,0,5.7}, {0.198,0,8.6}, {0.394,0,7.1}, {3.081,0,7.2}, {0.225,0,7.2}, {0.420,0,7.1} },
		["2:137"] = { {0.393,0,7.2}, {0.186,0,7.0} },
		["2:147"] = { {0.093,0,11.6}, {0.118,0,11.1} },
		["2:172"] = { {1.277,0,3.3}, {1.331,0,3.3}, {1.306,0,3.2}, {1.391,0,3.2}, {1.284,0,2.8}, {1.445,0,2.9} },
		["2:175"] = { {0.094,0,3.3}, {0.148,0,3.3}, {0.134,0,3.2}, {0.219,0,3.2}, {0.078,0,2.8}, {0.239,0,2.9} },
		["2:177"] = { {1.383,0,11.6}, {1.413,0,11.1}, {2.556,1,10.6} },
		["2:178"] = { {0.062,0,2.5}, {0.058,0,2.4}, {0.079,0,2.7}, {0.170,0,3.0} },
		["2:180"] = { {1.326,0,3.8} },
		["2:181"] = { {1.292,0,2.5}, {1.217,0,2.4}, {1.178,0,2.7}, {1.269,0,3.0} },
		["2:191"] = { {0.374,0,5.1}, {0.674,2,2.8}, {0.344,0,2.0}, {0.669,2,0.3}, {0.667,2,15.9}, {0.677,2,5.2}, {0.407,0,10.6}, {0.663,2,10.9} },
		["2:201"] = { {1.358,0,5.2} },
		["2:219"] = { {2.175,0,16.8} },
		["2:221"] = { {3.055,1,19.3} },
		["2:240"] = { {0.130,0,2.9}, {0.167,0,4.4} },
		["2:241"] = { {0.147,0,3.8} },
		["2:26"] = { {0.010,0,3.8}, {0.170,0,3.3} },
		["2:295"] = { {0.110,0,16.8}, {0.064,0,8.9} },
		["2:302"] = { {2.306,0,3.3} },
		["2:305"] = { {0.069,0,11.6}, {0.041,0,10.0} },
		["2:4"] = { {0.160,0,6.5} },
		["2:43"] = { {0.074,0,9.1} },
		["2:50"] = { {1.756,1,6.9} },
		["2:58"] = { {0.011,0,1.7}, {3.092,3,4.7} },
		["2:68"] = { {1.12,1,11.5}, {2.176,2,10.3} },
		["4:106"] = { {1.938,0,7.3} },
		["4:14"] = { {1.542,0,3.6} },
		["5:13"] = { {0.709,3,4.7} },
		["5:14"] = { {1.449,0,8.2} },
		["5:23"] = { {2.110,0,4.1}, {1.386,0,8.2} },
		["50:150"] = { {2.366,0,6.5} },
		["50:160"] = { {0.936,0,3.8} },
		["50:161"] = { {1.593,0,16.8}, {1.529,0,8.9} },
		["50:170"] = { {1.512,0,9.1} },
		["50:174"] = { {1.299,0,1.7} },
		["50:178"] = { {3.613,1,11.5} },
		["50:184"] = { {2.190,1,10.6} },
		["50:185"] = { {2.478,1,19.3} },
		["50:188"] = { {1.622,0,6.8}, {1.829,0,5.7}, {1.624,0,8.6}, {1.820,0,7.1}, {1.687,0,7.2}, {1.882,0,7.1} },
		["50:191"] = { {1.844,0,7.2}, {1.576,0,7.0} },
		["50:195"] = { {1.488,0,11.6}, {1.432,0,10.0} },
		["50:196"] = { {1.015,0,11.6}, {1.040,0,11.1} },
		["50:200"] = { {2.206,0,9.4} },
		["50:210"] = { {0.453,0,3.3}, {0.507,0,3.3}, {0.491,0,3.2}, {0.576,0,3.2}, {0.467,0,2.8}, {0.628,0,2.9} },
		["50:211"] = { {0.480,0,2.5}, {0.468,0,2.4}, {0.454,0,2.7}, {0.545,0,3.0} },
		["50:215"] = { {2.627,0,5.1}, {2.927,2,2.8}, {2.600,0,2.0}, {2.925,2,0.3}, {2.875,2,15.9}, {2.982,2,5.2}, {2.645,0,10.6}, {2.901,2,10.9} },
		["50:217"] = { {2.227,0,5.1}, {2.527,2,2.8}, {2.194,0,2.0}, {2.519,2,0.3}, {2.508,2,15.9}, {2.518,2,5.2}, {2.251,0,10.6}, {2.507,2,10.9} },
		["50:23"] = { {3.069,0,6.5} },
		["50:241"] = { {0.748,0,7.7} },
		["50:244"] = { {0.735,0,8.2} },
		["50:255"] = { {1.412,0,4.1} },
		["50:257"] = { {0.587,0,4.1} },
		["50:266"] = { {2.173,3,4.7} },
		["50:270"] = { {2.182,0,2.9}, {2.226,0,4.4} },
		["50:271"] = { {2.198,0,3.8} },
		["50:272"] = { {1.427,0,2.9}, {1.445,0,4.4} },
		["50:273"] = { {1.437,0,3.8} },
		["50:285"] = { {2.637,0,1.7} },
		["50:300"] = { {2.247,0,5.2} },
		["50:312"] = { {1.598,0,3.3} },
		["50:65"] = { {3.085,0,7.3} }
	}
};

-- conhecimento atual: [id do monstro como texto][animacao] = lista de medicoes
local conhecimento = {};
local grupos_cache = {};    -- impactos ja agrupados, por monstro e animacao
local precisa_salvar = false;
local salvo_em = 0;

local function copiar(tabela)
	local nova = {};
	for chave, valor in pairs(tabela) do
		nova[chave] = (type(valor) == "table") and copiar(valor) or valor;
	end
	return nova;
end

local function carregar_conhecimento()
	conhecimento = copiar(CONHECIMENTO_INICIAL);

	local salvo = json.load_file("aviso_lanca_aprendizado.json");
	if type(salvo) == "table" and type(salvo.monstros) == "table" then
		conhecimento = salvo.monstros;
	end

	grupos_cache = {};
end

local function salvar_conhecimento()
	json.dump_file("aviso_lanca_aprendizado.json", { versao = 1, monstros = conhecimento });
	precisa_salvar = false;
	salvo_em = agora();
end

--[[
	Agrupa as medicoes de uma animacao em "impactos": medicoes com tempos parecidos (ate
	0,12s de diferenca) sao o mesmo impacto. Para cada impacto devolve o tempo tipico
	(mediana), quantas vezes foi visto e o tipo de guarda mais restritivo visto nele.
]]
local RESTRICAO = { [0] = 0, [1] = 0, [3] = 1, [2] = 2 }; -- 2 (impossivel) e o pior

local function agrupar(medicoes)
	local tempos = {};
	for _, m in ipairs(medicoes) do tempos[#tempos + 1] = m; end
	table.sort(tempos, function(a, b) return a[1] < b[1]; end);

	local grupos, atual = {}, nil;

	local function fechar()
		if atual == nil then return; end
		local n = #atual.lista;
		local meio = atual.lista[math.floor((n + 1) / 2)];
		atual.tempo = meio[1];
		atual.vezes = n;
		grupos[#grupos + 1] = atual;
	end

	for _, m in ipairs(tempos) do
		if atual ~= nil and m[1] - atual.lista[#atual.lista][1] <= AJUSTES.juntar_ate then
			atual.lista[#atual.lista + 1] = m;
		else
			fechar();
			atual = { lista = { m }, guarda = 0 };
		end
		local g = m[2] or 0;
		if (RESTRICAO[g] or 0) > (RESTRICAO[atual.guarda] or 0) then atual.guarda = g; end
	end
	fechar();

	return grupos;
end

local function grupos_de(id, animacao)
	local monstro = conhecimento[tostring(id)];
	local medicoes = monstro and monstro[animacao];
	if medicoes == nil then return nil; end

	local cache_monstro = grupos_cache[tostring(id)];
	if cache_monstro == nil then
		cache_monstro = {};
		grupos_cache[tostring(id)] = cache_monstro;
	end

	if cache_monstro[animacao] == nil then
		cache_monstro[animacao] = agrupar(medicoes);
	end

	return cache_monstro[animacao];
end

local function aprender(id, animacao, segundos, guarda, dist)
	local chave_monstro = tostring(id);
	conhecimento[chave_monstro] = conhecimento[chave_monstro] or {};
	local lista = conhecimento[chave_monstro][animacao] or {};
	conhecimento[chave_monstro][animacao] = lista;

	lista[#lista + 1] = { arredondar(segundos, 3), guarda or 0, arredondar(dist or 0, 1) };
	while #lista > AJUSTES.maximo_amostras do table.remove(lista, 1); end

	if grupos_cache[chave_monstro] then grupos_cache[chave_monstro][animacao] = nil; end
	precisa_salvar = true;
end


-- =====================================================================================
-- 4. MONSTROS (ARKVELD)
-- Acha os monstros cobertos, acompanha a animacao de cada um e, a cada animacao nova,
-- atualiza a lista de impactos previstos daquele monstro.
-- =====================================================================================

local monstros = {}; -- chave: endereco do contexto

local function endereco_de(objeto)
	local ok, endereco = pcall(objeto.get_address, objeto);
	return (ok and endereco) or objeto;
end

local function conhecer_monstro(contexto)
	local chave = endereco_de(contexto);
	local m = monstros[chave];

	if m == nil then
		local dados = seguir(contexto, AJUSTES.dados_basicos);
		local id = dados and dados:read_dword(AJUSTES.id_nos_dados_basicos);
		if AJUSTES.monstros[id] == nil then return; end

		local inteligencia = seguir(contexto, AJUSTES.inteligencia);
		local objeto = inteligencia and inteligencia:get_field("OwnerObject");
		if objeto == nil then return; end

		local legendary = contexto:call("get_LegendaryID");

		m = {
			id = id,
			nome = AJUSTES.monstros[id],
			variacao = (legendary == 2 and "arquitemperado") or (legendary == 1 and "temperado") or "normal",
			objeto = objeto,
			animacao = nil, animacao_desde = 0, quadro = 0, fim = 0,
			historico = {},  -- ultimas animacoes: { chave, inicio }
			previstos = {},  -- impactos previstos: { tempo, guarda }
			distancia = nil,
			visto_em = 0
		};
		monstros[chave] = m;
	end

	m.visto_em = agora();
end

sdk.hook(sdk.find_type_definition("app.cEnemyContext"):get_method("get_IsAngry"), function(argumentos)
	pcall(function() conhecer_monstro(sdk.to_managed_object(argumentos[2])); end);
end, function(retorno)
	return retorno;
end);

local function monstro_do_objeto(objeto)
	for _, m in pairs(monstros) do
		if m.objeto == objeto then return m; end
	end
	return nil;
end

local function monstro_mais_perto()
	local melhor = nil;
	for _, m in pairs(monstros) do
		if m.distancia ~= nil and (melhor == nil or m.distancia < melhor.distancia) then melhor = m; end
	end
	return melhor;
end

--[[
	Uma animacao nova comecou. Regras:
	  - impactos ja previstos continuam so se a nova animacao "confirma" (ela tambem tem um
	    impacto medido perto daquele momento). O tempo e corrigido pela medicao mais nova.
	    Isso derruba avisos de golpes que o monstro interrompeu (ex.: levou um derrube);
	  - impactos da nova animacao vistos pelo menos 2 vezes viram avisos novos.
]]
local function nova_animacao(m, animacao, momento)
	local grupos = grupos_de(m.id, animacao);
	local novos = {};
	local usados = {};

	if grupos ~= nil then
		for _, p in ipairs(m.previstos) do
			if p.tempo > momento - 0.1 then
				local relativo = p.tempo - momento;
				for i, g in ipairs(grupos) do
					if not usados[i] and math.abs(g.tempo - relativo) <= AJUSTES.confirmar_ate then
						usados[i] = true;
						p.tempo = momento + g.tempo;
						if (RESTRICAO[g.guarda] or 0) > (RESTRICAO[p.guarda] or 0) then p.guarda = g.guarda; end
						novos[#novos + 1] = p;
						break;
					end
				end
			end
		end

		for i, g in ipairs(grupos) do
			if not usados[i] and g.vezes >= AJUSTES.minimo_amostras and g.tempo >= AJUSTES.minimo_antecedencia then
				novos[#novos + 1] = { tempo = momento + g.tempo, guarda = g.guarda, vezes = g.vezes };
			end
		end
	end

	m.previstos = novos;
end


-- =====================================================================================
-- 5. IMPACTOS E APRENDIZADO
-- Quando um golpe do monstro acerta VOCE (guardando ou nao), o mod anota quanto tempo
-- passou desde cada uma das ultimas animacoes do monstro. E assim que ele aprende.
-- =====================================================================================

local registrar; -- gravador (parte 6)

local function ao_impacto(argumentos)
	local monstro_char = sdk.to_managed_object(argumentos[2]);
	local acerto = sdk.to_managed_object(argumentos[3]);
	if monstro_char == nil or acerto == nil then return; end

	local cacador = meu_cacador();
	local alvo = acerto:call("get_DamageOwner");
	if cacador == nil or alvo == nil or alvo ~= objeto_de_jogo(cacador) then return; end

	local m = monstro_do_objeto(monstro_char:call("get_GameObject"));
	if m == nil then return; end

	local momento = agora();

	local guarda, forca = 0, nil;
	local golpe = acerto:call("get_AttackData");
	if golpe ~= nil then
		guarda = golpe:get_field("_GuardType") or 0;
		forca = golpe:get_field("_VersusGuardPower");
	end

	-- confere a previsao: qual impacto previsto estava mais perto do real?
	estado.impactos_vistos = estado.impactos_vistos + 1;
	local menor = nil;
	for _, p in ipairs(m.previstos) do
		local erro = momento - p.tempo;
		if menor == nil or math.abs(erro) < math.abs(menor) then menor = erro; end
	end
	if menor ~= nil and math.abs(menor) <= 0.3 then
		estado.ultimo_erro_ms = math.floor(menor * 1000 + 0.5);
		estado.avisos_certos = estado.avisos_certos + 1;
	else
		estado.ultimo_erro_ms = nil;
	end

	-- aprende: as ultimas animacoes do monstro antes deste impacto
	if op.aprender then
		local usadas = 0;
		for i = #m.historico, 1, -1 do
			local h = m.historico[i];
			local passou = momento - h.inicio;
			if passou > AJUSTES.idade_maxima_animacao or usadas >= AJUSTES.animacoes_por_impacto then break; end
			aprender(m.id, h.chave, passou, guarda, m.distancia);
			usadas = usadas + 1;
		end
	end

	registrar("impacto_em_voce", {
		animacao = m.animacao, tempo_na_animacao = arredondar(momento - m.animacao_desde, 3),
		quadro = arredondar(m.quadro, 1), distancia = arredondar(m.distancia, 2),
		tipo_guarda = guarda, forca_vs_guarda = arredondar(forca, 2),
		erro_previsao_ms = estado.ultimo_erro_ms
	});
end

local tipo_monstro_char = sdk.find_type_definition("app.EnemyCharacter");
local funcao_impacto = tipo_monstro_char and tipo_monstro_char:get_method("evHit_AttackPreProcess");
if funcao_impacto ~= nil then
	pcall(sdk.hook, funcao_impacto, function(argumentos)
		local ok, erro = pcall(ao_impacto, argumentos);
		if not ok then estado.mensagem = "erro impacto: " .. tostring(erro); end
	end, function(retorno)
		return retorno;
	end);
end


-- =====================================================================================
-- 6. PESQUISA (gravador, exportacao, arma)
-- Ferramentas para continuar medindo. Ficam escondidas num submenu.
-- =====================================================================================

local pesquisa = {
	gravando = false, numero = 0, eventos = {}, inicio = 0, ultimo_por_nome = {},
	arma_tipo = nil,         -- classe real da sua arma (ex.: lanca)
	arma_ganchos = {}        -- funcoes da arma com gancho ligado
};

registrar = function(tipo_evento, dados)
	if not pesquisa.gravando or #pesquisa.eventos >= AJUSTES.maximo_eventos then return; end
	local momento = agora();

	local nome = tipo_evento .. (dados.funcao or "");
	if dados.funcao ~= nil and pesquisa.ultimo_por_nome[nome] ~= nil
		and momento - pesquisa.ultimo_por_nome[nome] < 0.03 then
		return;
	end
	pesquisa.ultimo_por_nome[nome] = momento;

	dados.t = arredondar(momento - pesquisa.inicio, 3);
	dados.evento = tipo_evento;
	pesquisa.eventos[#pesquisa.eventos + 1] = dados;
end

local function comecar_gravacao()
	pesquisa.numero = pesquisa.numero + 1;
	pesquisa.eventos, pesquisa.ultimo_por_nome = {}, {};
	pesquisa.inicio = agora();
	pesquisa.gravando = true;
	estado.mensagem = "Gravando...";
end

local function parar_gravacao()
	pesquisa.gravando = false;
	local arquivo = string.format("aviso_lanca_gravacao_v4_%d.json", pesquisa.numero);
	json.dump_file(arquivo, { versao_mod = "0.4", arma = pesquisa.arma_tipo,
		ganchos_arma = pesquisa.arma_ganchos, eventos = pesquisa.eventos });
	estado.mensagem = string.format("Gravacao salva: %s (%d eventos).", arquivo, #pesquisa.eventos);
end

-- Descreve uma classe (campos, funcoes e classes-mae) para a exportacao
local function descrever_tipo(tipo)
	local d = { nome = tipo:get_full_name(), pais = {}, campos = {}, funcoes = {} };

	local pai = tipo:get_parent_type();
	while pai ~= nil do d.pais[#d.pais + 1] = pai:get_full_name(); pai = pai:get_parent_type(); end

	for _, campo in ipairs(tipo:get_fields() or {}) do
		pcall(function()
			local t = campo:get_type();
			local extra = "";
			if campo:is_static() then
				local ok_v, v = pcall(campo.get_data, campo, nil);
				extra = " (estatico" .. ((ok_v and type(v) == "number") and (" = " .. v) or "") .. ")";
			end
			d.campos[#d.campos + 1] = string.format("0x%X %s %s%s", campo:get_offset_from_base() or 0,
				t and t:get_full_name() or "?", campo:get_name(), extra);
		end);
	end

	for _, funcao in ipairs(tipo:get_methods() or {}) do
		pcall(function()
			local params = {};
			local ok_p, tipos = pcall(funcao.get_param_types, funcao);
			if ok_p and type(tipos) == "table" then
				for _, t in ipairs(tipos) do params[#params + 1] = t:get_full_name(); end
			end
			local r = funcao:get_return_type();
			d.funcoes[#d.funcoes + 1] = string.format("%s %s(%s)", r and r:get_full_name() or "void",
				funcao:get_name(), table.concat(params, ", "));
		end);
	end

	return d;
end

-- Exporta a classe real da sua arma e todas as classes-mae dela (onde fica a guarda)
local function exportar_estrutura()
	local resultado = { arma = {} };
	local cacador = meu_cacador();
	local arma = cacador and cacador:call("get_WeaponHandling");

	if arma ~= nil then
		local tipo = arma:get_type_definition();
		while tipo ~= nil do
			resultado.arma[#resultado.arma + 1] = descrever_tipo(tipo);
			tipo = tipo:get_parent_type();
			if tipo ~= nil and string.sub(tipo:get_full_name(), 1, 4) ~= "app." then break; end
		end
	end

	json.dump_file("aviso_lanca_estrutura.json", resultado);
	estado.mensagem = string.format("Estrutura exportada: %d classes da arma.", #resultado.arma);
end

--[[
	Exporta as classes de CONTROLE do jogo (como ele le os botoes). E o que falta para o
	modo automatico: para "apertar" a guarda pelo jogador, o mod precisa entrar no ponto
	onde o jogo le os botoes. O REFramework permite percorrer TODAS as classes do jogo;
	guardamos so os nomes ligados a controle/botoes e descrevemos as mais provaveis.
]]
local PALAVRAS_CONTROLE_FORTES = { "Pad", "Input", "Keyboard", "Mouse", "Button", "Command", "Hid", "KeyBind", "KeyConfig" };
local PALAVRAS_CONTROLE_FRACAS = { "Avoid", "Dodge", "Emergency", "Guard", "Key", "Action" };

local function tem_palavra(nome, palavras)
	for _, palavra in ipairs(palavras) do
		if string.find(nome, palavra, 1, true) then return true; end
	end
	return false;
end

local function exportar_controles()
	local resultado = { nomes = {}, descritas = {}, ligadas_ao_cacador = {}, erro_lista = nil };
	local descritas = 0;

	-- 1) todas as classes do jogo (pela tabela de tipos do REFramework)
	local ok_lista, erro = pcall(function()
		local tdb = sdk.get_tdb();
		local total = tdb:get_num_types();
		resultado.total_classes = total;

		for i = 0, total - 1 do
			local tipo = tdb:get_type(i);
			local ok_nome, nome = pcall(tipo.get_full_name, tipo);
			if ok_nome and nome ~= nil then
				local espaco_ok = string.sub(nome, 1, 4) == "app." or string.sub(nome, 1, 4) == "ace."
					or string.sub(nome, 1, 7) == "via.hid";
				if espaco_ok then
					local forte = tem_palavra(nome, PALAVRAS_CONTROLE_FORTES);
					if forte or tem_palavra(nome, PALAVRAS_CONTROLE_FRACAS) then
						resultado.nomes[#resultado.nomes + 1] = nome;
					end
					if forte and descritas < 250 then
						descritas = descritas + 1;
						resultado.descritas[#resultado.descritas + 1] = descrever_tipo(tipo);
					end
				end
			end
		end
	end);
	if not ok_lista then resultado.erro_lista = tostring(erro); end

	-- 2) objetos ligados ao seu cacador agora (tipo real), quando o nome lembra controle
	local cacador = meu_cacador();
	if cacador ~= nil then
		for _, campo in ipairs(cacador:get_type_definition():get_fields() or {}) do
			pcall(function()
				local valor = campo:get_data(cacador);
				if type(valor) == "userdata" then
					local tipo_real = valor:get_type_definition();
					local nome_real = tipo_real:get_full_name();
					if tem_palavra(nome_real .. campo:get_name(), PALAVRAS_CONTROLE_FORTES) then
						local d = descrever_tipo(tipo_real);
						d.campo_no_cacador = campo:get_name();
						resultado.ligadas_ao_cacador[#resultado.ligadas_ao_cacador + 1] = d;
					end
				end
			end);
		end
	end

	json.dump_file("aviso_lanca_controles.json", resultado);
	estado.mensagem = string.format("Controles exportados: %d nomes, %d descritas, %d ligadas ao cacador%s.",
		#resultado.nomes, #resultado.descritas, #resultado.ligadas_ao_cacador,
		resultado.erro_lista and (" (erro na lista: " .. resultado.erro_lista .. ")") or "");
end

-- Liga ganchos nas funcoes de guarda/contra-ataque da sua arma (para achar a guarda perfeita)
local PREFIXOS_IGNORADOS = { "get_", "set_", "is", "check", "update", "can", "calc", "late", "on" };
local PALAVRAS_ARMA = { "Guard", "Just", "Counter", "Parry", "Clash", "Perfect" };

local function ligar_ganchos_da_arma(arma)
	local tipo = arma:get_type_definition();
	pesquisa.arma_tipo = tipo:get_full_name();

	while tipo ~= nil and string.sub(tipo:get_full_name(), 1, 4) == "app." do
		for _, funcao in ipairs(tipo:get_methods() or {}) do
			local nome = funcao:get_name();
			local ignorar = false;
			for _, prefixo in ipairs(PREFIXOS_IGNORADOS) do
				if string.sub(nome, 1, #prefixo) == prefixo then ignorar = true; break; end
			end

			local interessa = false;
			if not ignorar then
				for _, palavra in ipairs(PALAVRAS_ARMA) do
					if string.find(nome, palavra, 1, true) then interessa = true; break; end
				end
			end

			if interessa then
				local nome_completo = tipo:get_full_name() .. "." .. nome;
				local ok = pcall(sdk.hook, funcao, function()
					if pesquisa.gravando then
						local m = monstro_mais_perto();
						registrar("arma", { funcao = nome_completo,
							animacao = m and m.animacao,
							tempo_na_animacao = m and arredondar(agora() - m.animacao_desde, 3) });
					end
				end, function(retorno) return retorno; end);
				if ok then pesquisa.arma_ganchos[#pesquisa.arma_ganchos + 1] = nome_completo; end
			end
		end
		tipo = tipo:get_parent_type();
	end
end


-- =====================================================================================
-- ACOMPANHAMENTO A CADA QUADRO
-- =====================================================================================

local minha_animacao = nil;

local function acompanhar()
	local momento = agora();
	local cacador = meu_cacador();
	local objeto_cacador = cacador and objeto_de_jogo(cacador);
	local cx, cy, cz;
	if objeto_cacador ~= nil then cx, cy, cz = posicao(objeto_cacador); end

	-- liga os ganchos da arma uma vez, quando o cacador ja existe
	if cacador ~= nil and pesquisa.arma_tipo == nil then
		local arma = cacador:call("get_WeaponHandling");
		if arma ~= nil then pcall(ligar_ganchos_da_arma, arma); end
	end

	for chave, m in pairs(monstros) do
		if momento - m.visto_em > 1 then
			monstros[chave] = nil;
		else
			local mx, my, mz = posicao(m.objeto);
			m.distancia = distancia(mx, my, mz, cx, cy, cz);

			local id, banco, quadro, fim = animacao_de(m.objeto);
			if id ~= nil then
				m.quadro, m.fim = quadro or 0, fim or 0;
				local animacao = tostring(banco) .. ":" .. tostring(id);

				if animacao ~= m.animacao then
					m.animacao, m.animacao_desde = animacao, momento;

					m.historico[#m.historico + 1] = { chave = animacao, inicio = momento };
					while #m.historico > AJUSTES.historico_animacoes do table.remove(m.historico, 1); end

					nova_animacao(m, animacao, momento);

					registrar("animacao_monstro", { animacao = animacao, variacao = m.variacao,
						fim = arredondar(fim, 1), distancia = arredondar(m.distancia, 2),
						previstos = #m.previstos });
				end
			end

			-- tira avisos que ja passaram
			local restantes = {};
			for _, p in ipairs(m.previstos) do
				if p.tempo > momento - 0.25 then restantes[#restantes + 1] = p; end
			end
			m.previstos = restantes;
		end
	end

	-- suas animacoes (so para a gravacao de pesquisa)
	if pesquisa.gravando and objeto_cacador ~= nil then
		local id, banco = animacao_de(objeto_cacador);
		local chave = tostring(banco) .. ":" .. tostring(id);
		if id ~= nil and chave ~= minha_animacao then
			minha_animacao = chave;
			local m = monstro_mais_perto();
			registrar("minha_animacao", { minha = chave, animacao_monstro = m and m.animacao,
				tempo_na_animacao = m and arredondar(momento - m.animacao_desde, 3) });
		end
	end

	-- salva o aprendizado de vez em quando (nao a cada golpe, para nao pesar)
	if precisa_salvar and momento - salvo_em > 10 then
		pcall(salvar_conhecimento);
	end
end


-- =====================================================================================
-- 7. BARRA DE AVISO NA TELA
--
-- Uma trilha horizontal com uma linha-alvo na esquerda. Cada impacto previsto e um
-- marcador que anda da direita para a esquerda e chega na linha no momento do impacto.
-- Em cima, o que fazer (cor pelo tipo de golpe). Pouco antes do impacto, pisca "AGORA!".
-- =====================================================================================

-- cores no formato do REFramework (0xAABBGGRR)
local COR = {
	trilha = 0xA0000000,
	alvo = 0xFFFFFFFF,
	sombra = 0xFF000000,
	texto = 0xFFFFFFFF,
	guarda = 0xFF00D7FF,       -- amarelo
	power_guard = 0xFF0080FF,  -- laranja
	impossivel = 0xFF2020FF,   -- vermelho
	agora = 0xFF40FF40         -- verde
};

local function estilo_do_golpe(guarda)
	if guarda == 2 then return "IMPOSSIVEL DE GUARDAR - ESQUIVE", COR.impossivel; end
	if guarda == 3 then return "POWER GUARD", COR.power_guard; end
	return "GUARDA", COR.guarda;
end

local function texto_com_sombra(texto, x, y, cor)
	draw.text(texto, x + 1, y + 1, COR.sombra);
	draw.text(texto, x, y, cor);
end

local function desenhar_aviso()
	if not op.ativado then return; end

	local momento = agora();
	local janela = op.janela;
	local antecedencia = op.antecedencia_ms / 1000;

	-- junta os impactos visiveis de todos os monstros cobertos
	local visiveis = {};
	for _, m in pairs(monstros) do
		for _, p in ipairs(m.previstos) do
			local falta = p.tempo - momento;
			if falta <= janela and falta >= -0.15 then visiveis[#visiveis + 1] = { falta = falta, guarda = p.guarda }; end
		end
	end
	if #visiveis == 0 then return; end
	table.sort(visiveis, function(a, b) return a.falta < b.falta; end);

	local largura_tela, altura_tela = tamanho_tela();
	local e = altura_tela / 1080;

	local largura = 420 * e;
	local x0 = largura_tela / 2 - largura / 2;
	local y0 = altura_tela * op.altura_tela;
	local x_alvo = x0 + 30 * e;
	local x_fim = x0 + largura;

	-- trilha e linha-alvo
	draw.filled_rect(x0, y0, largura, 10 * e, COR.trilha);
	draw.filled_rect(x_alvo - 2 * e, y0 - 8 * e, 4 * e, 26 * e, COR.alvo);

	-- marcadores
	for _, v in ipairs(visiveis) do
		local _, cor = estilo_do_golpe(v.guarda);
		local fracao = math.max(0, math.min(1, v.falta / janela));
		local x = x_alvo + fracao * (x_fim - x_alvo);
		draw.filled_rect(x - 5 * e, y0 - 6 * e, 10 * e, 22 * e, cor);
	end

	-- o que fazer (pelo proximo impacto)
	local proximo = visiveis[1];
	local texto, cor = estilo_do_golpe(proximo.guarda);
	texto_com_sombra(texto, x0, y0 - 30 * e, cor);

	-- "AGORA!" pouco antes do impacto
	if proximo.falta <= antecedencia then
		draw.filled_rect(x0, y0 + 16 * e, largura, 22 * e, COR.agora);
		texto_com_sombra("AGORA!", largura_tela / 2 - 24, y0 + 19 * e, COR.sombra);
	end
end

-- painel de pesquisa (opcional)
local function desenhar_painel()
	local m = monstro_mais_perto();
	local linhas = {};
	if m ~= nil then
		linhas[#linhas + 1] = string.format("%s (%s) | animacao %s | quadro %.0f/%.0f | %.2fs | %.1f m | avisos %d",
			m.nome, m.variacao, tostring(m.animacao), m.quadro or 0, m.fim or 0,
			agora() - m.animacao_desde, m.distancia or -1, #m.previstos);
	else
		linhas[#linhas + 1] = "Nenhum Arkveld por perto";
	end
	if pesquisa.gravando then linhas[#linhas + 1] = string.format("GRAVANDO - %d eventos", #pesquisa.eventos); end

	local y = 200;
	for _, linha in ipairs(linhas) do texto_com_sombra(linha, 20, y, COR.texto); y = y + 18; end
end

re.on_frame(function()
	local ok, erro = pcall(acompanhar);
	if not ok then estado.mensagem = "erro: " .. tostring(erro); end

	pcall(desenhar_aviso);
	if op.mostrar_painel then pcall(desenhar_painel); end
end);


-- =====================================================================================
-- 8. MENU (REFramework > Script Generated UI > "Aviso de Guarda (Lanca)")
-- =====================================================================================

local function contar_conhecimento()
	local animacoes, medicoes = 0, 0;
	for _, lista in pairs(conhecimento["27"] or {}) do
		animacoes = animacoes + 1;
		medicoes = medicoes + #lista;
	end
	return animacoes, medicoes;
end

re.on_draw_ui(function()
	if not imgui.tree_node("Aviso de Guarda (Lanca) v0.4") then return; end

	local mudou, alterado = false, false;

	alterado, op.ativado = imgui.checkbox("Mostrar aviso", op.ativado);
	mudou = mudou or alterado;

	alterado, op.antecedencia_ms = imgui.slider_int("\"AGORA!\" quantos ms antes do impacto", op.antecedencia_ms, 0, 400);
	mudou = mudou or alterado;

	alterado, op.janela = imgui.slider_float("Mostrar o golpe quantos segundos antes", op.janela, 0.5, 3.0, "%.1f");
	mudou = mudou or alterado;

	alterado, op.altura_tela = imgui.slider_float("Altura da barra na tela", op.altura_tela, 0.1, 0.95, "%.2f");
	mudou = mudou or alterado;

	alterado, op.aprender = imgui.checkbox("Aprender com os golpes que chegam em voce", op.aprender);
	mudou = mudou or alterado;

	if mudou then salvar_opcoes(); end

	local animacoes, medicoes = contar_conhecimento();
	imgui.text(string.format("Conhecimento do Arkveld: %d animacoes, %d medicoes", animacoes, medicoes));

	if estado.ultimo_erro_ms ~= nil then
		imgui.text(string.format("Ultimo golpe: previsao errou por %d ms (%s)", estado.ultimo_erro_ms,
			estado.ultimo_erro_ms < 0 and "chegou antes" or "chegou depois"));
	end
	imgui.text(string.format("Golpes previstos: %d de %d que chegaram em voce", estado.avisos_certos, estado.impactos_vistos));

	if imgui.button("Salvar aprendizado agora") then pcall(salvar_conhecimento); estado.mensagem = "Aprendizado salvo."; end
	imgui.same_line();
	if imgui.button("Apagar aprendizado (volta ao inicial)") then
		conhecimento = copiar(CONHECIMENTO_INICIAL);
		grupos_cache = {};
		pcall(salvar_conhecimento);
		estado.mensagem = "Aprendizado apagado.";
	end

	if imgui.tree_node("Pesquisa") then
		alterado, op.mostrar_painel = imgui.checkbox("Mostrar painel de pesquisa", op.mostrar_painel);
		if alterado then salvar_opcoes(); end

		if imgui.button("Exportar estrutura da arma") then
			local ok, erro = pcall(exportar_estrutura);
			if not ok then estado.mensagem = "Erro: " .. tostring(erro); end
		end

		-- pode demorar alguns segundos (percorre todas as classes do jogo)
		if imgui.button("Exportar controles do jogo (para o modo automatico)") then
			local ok, erro = pcall(exportar_controles);
			if not ok then estado.mensagem = "Erro: " .. tostring(erro); end
		end

		if not pesquisa.gravando then
			if imgui.button("Comecar gravacao") then comecar_gravacao(); end
		elseif imgui.button("Parar e salvar gravacao") then
			local ok, erro = pcall(parar_gravacao);
			if not ok then estado.mensagem = "Erro: " .. tostring(erro); end
		end

		imgui.text("Arma: " .. tostring(pesquisa.arma_tipo) .. " | ganchos: " .. #pesquisa.arma_ganchos);
		imgui.tree_pop();
	end

	if estado.mensagem ~= "" then imgui.text(estado.mensagem); end

	imgui.tree_pop();
end);


-- =====================================================================================
-- INICIO
-- =====================================================================================

pcall(carregar_opcoes);
pcall(carregar_conhecimento);
