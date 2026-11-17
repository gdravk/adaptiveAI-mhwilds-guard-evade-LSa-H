---@diagnostic disable: undefined-global

--[[
	Aviso de Guarda (Lanca) - Monster Hunter Wilds (REFramework)
	Versao 0.20 - DEFESA COM PRIORIDADE + DIRECAO + POWER GUARD NA ORDEM CERTA

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
	  - aviso_lanca_gravacao_v20_N.json gravacoes para pesquisa (botao no menu)

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
	mostrar_painel = false, -- painel de pesquisa (animacao atual, distancia...)

	-- defesa automatica
	guarda_automatica = true,
	somente_solo = true,          -- so age quando voce esta sozinho na cacada
	antecedencia_guarda_ms = 120, -- levanta a guarda este tanto antes do impacto
	segurar_depois_ms = 250,      -- continua segurando este tanto depois do impacto
	esquivar = true,              -- esquiva nos golpes impossiveis de guardar (se a esquiva foi aprendida)
	antecedencia_esquiva_ms = 150,

	--[[
		As defesas da lanca (como voce explicou):
		  - guarda: M5;
		  - contra-ataque: M5 e depois M2. Fica numa postura que defende e, ao receber o
		    golpe, ataca na hora;
		  - Power Guard: M5, depois M2 e por ultimo Espaco, os tres segurados. Guarda
		    plantada no chao, gasta stamina e bloqueia em 360 graus;
		  - esquiva: Espaco.
	]]
	-- golpes guardaveis: "contra_ataque" ou "guarda"
	acao_guardavel = "contra_ataque",
	antecedencia_contra_ms = 250,  -- o contra-ataque entra este tanto antes do impacto
	-- golpes impossiveis de guardar: "esquiva" ou "power_guard"
	acao_impossivel = "esquiva",

	-- Power Guard na defesa automatica (desligado: o teste da 0.17 fechou o jogo; os golpes
	-- tipo 3 usam o contra-ataque ate o Power Guard ser confirmado em modo seguro)
	usar_power_guard = true,

	-- golpe vindo de lado/tras: se o angulo entre para onde o cacador olha e o monstro
	-- passar disso (graus), a guarda e o contra-ataque (so de frente) sao pulados
	angulo_frontal = 70,

	-- Power Guard: o toque do Espaco vem este tanto (ms) depois de o M5 ser apertado
	-- (o M2 vem aos 50 ms; o Espaco precisa vir ja na postura do contra-ataque)
	pg_espaco_ms = 200,
	antecedencia_power_ms = 300,   -- o Power Guard entra este tanto antes do impacto

	-- escrever tambem na entrada de controle (desligado: pode fazer o jogo trocar a interface e travar)
	escrever_controle = false,

	-- escrever tambem DENTRO do processamento paralelo dos botoes (como ate a 0.11).
	-- Desligado: era o que travava. So ligue se a defesa nao funcionar sem isso.
	escrever_no_paralelo = false,

	-- numero do comando de cada botao (so para mostrar no menu)
	botoes = { guarda = {}, contra_ataque = {}, power_guard = {}, esquiva = {} },

	-- O QUE ESCREVER para "apertar" cada acao: lista de { t = numero do comando,
	-- l = se o campo fica no buffer de entrada (LagWorker), c = campo, v = valor }.
	-- Preenchido pelo "Aprender botoes"; os valores abaixo vieram das suas capturas.
	campos = {},

	-- versao do formato dos campos (2 = contra-ataque e Power Guard separados)
	versao_campos = 3,

	-- TOQUE GRAVADO (versao 0.17): sequencia quadro a quadro do que muda nos botoes quando
	-- voce aperta e solta uma tecla (usado na esquiva). E o "segurado" e o quadro do meio
	-- desse toque (usado para segurar o Espaco no Power Guard).
	toques = {},
	espaco_segurado = {}
};

--[[
	Valores padrao, vindos das suas capturas no teclado/mouse:
	  - guarda: comandos 15 e 22 (botao M5);
	  - contra_ataque: M5 + M2: comandos 13, 15, 22, 36 e 43 (a captura que na 0.8 a 0.12
	    eu chamava de "power_guard" - era na verdade o contra-ataque);
	  - power_guard: sem padrao. Se nao for aprendido, o mod monta com guarda + especial
	    (a parte do M2 no contra-ataque) + Espaco (da captura da esquiva);
	  - esquiva: comandos 24, 25, 32, 42 e 51 (so usam o buffer de entrada).
	"Apertado" = ligado (_On), apertado de verdade (_RawOn), totalmente (_AnalogValue),
	acabou de ser apertado (_LastRawTriggerIndex) e o buffer de entrada (_LagFrameCounter
	e _LagTimer). Sem o buffer, o jogo nao reconhece o aperto (foi o erro da versao 0.8).
]]
local function aperto_completo(lista, comando)
	lista[#lista + 1] = { t = comando, l = false, c = "_On", v = true };
	lista[#lista + 1] = { t = comando, l = false, c = "_RawOn", v = true };
	lista[#lista + 1] = { t = comando, l = false, c = "_AnalogValue", v = 1.0 };
	lista[#lista + 1] = { t = comando, l = false, c = "_LastRawTriggerIndex", v = 0 };
	lista[#lista + 1] = { t = comando, l = true, c = "_LagFrameCounter", v = -1 };
	lista[#lista + 1] = { t = comando, l = true, c = "_LagTimer", v = -0.06666667 };
end

local function aperto_so_buffer(lista, comando)
	lista[#lista + 1] = { t = comando, l = false, c = "_LastRawTriggerIndex", v = 0 };
	lista[#lista + 1] = { t = comando, l = true, c = "_LagFrameCounter", v = -1 };
	lista[#lista + 1] = { t = comando, l = true, c = "_LagTimer", v = -0.06666667 };
end

local function campos_padrao(alvo)
	local lista = {};
	if alvo == "guarda" then
		aperto_completo(lista, 15); aperto_completo(lista, 22);
	elseif alvo == "contra_ataque" then
		for _, n in ipairs({ 13, 15, 22, 43 }) do aperto_completo(lista, n); end
		lista[#lista + 1] = { t = 36, l = false, c = "_On", v = true };
		lista[#lista + 1] = { t = 36, l = false, c = "_RawOn", v = true };
		lista[#lista + 1] = { t = 36, l = false, c = "_AnalogValue", v = 1.0 };
		lista[#lista + 1] = { t = 36, l = false, c = "_Success", v = true };
	elseif alvo == "esquiva" then
		for _, n in ipairs({ 24, 25, 32, 42, 51 }) do aperto_so_buffer(lista, n); end
	end
	return lista;
end

-- numeros de comando usados por uma lista de campos (para mostrar no menu)
local function comandos_de(lista)
	local vistos, numeros = {}, {};
	for _, item in ipairs(lista or {}) do
		if not vistos[item.t] then vistos[item.t] = true; numeros[#numeros + 1] = item.t; end
	end
	table.sort(numeros);
	return numeros;
end

local function garantir_campos()
	if type(op.botoes) ~= "table" then op.botoes = {}; end
	if type(op.campos) ~= "table" then op.campos = {}; end

	for _, alvo in ipairs({ "guarda", "contra_ataque", "esquiva" }) do
		if type(op.campos[alvo]) ~= "table" or #op.campos[alvo] == 0 then
			op.campos[alvo] = campos_padrao(alvo);
		end
	end
	if type(op.campos.power_guard) ~= "table" then op.campos.power_guard = {}; end

	for _, alvo in ipairs({ "guarda", "contra_ataque", "power_guard", "esquiva" }) do
		op.botoes[alvo] = comandos_de(op.campos[alvo]);
	end

	if op.acao_guardavel ~= "guarda" and op.acao_guardavel ~= "contra_ataque" then op.acao_guardavel = "contra_ataque"; end
	if op.acao_impossivel ~= "esquiva" and op.acao_impossivel ~= "power_guard" then op.acao_impossivel = "esquiva"; end
end

garantir_campos();

local function carregar_opcoes()
	local salvo = json.load_file("aviso_lanca_opcoes.json");
	if type(salvo) ~= "table" then return; end
	for chave, valor in pairs(op) do
		if type(salvo[chave]) == type(valor) then op[chave] = salvo[chave]; end
	end

	-- opcoes salvas pela 0.8 a 0.12: o que se chamava "power_guard" era o contra-ataque
	if (salvo.versao_campos or 1) < 2 then
		if type(op.campos) == "table" and type(op.campos.power_guard) == "table" and #op.campos.power_guard > 0 then
			op.campos.contra_ataque = op.campos.power_guard;
		end
		if type(op.campos) == "table" then op.campos.power_guard = {}; end
		op.acao_guardavel = "contra_ataque";
		op.versao_campos = 2;
	end

	-- 0.19: Power Guard e o nivel 3 da prioridade; liga uma vez (o modo seguro da 0.18
	-- nao fechou o jogo)
	if (salvo.versao_campos or 1) < 3 then
		op.usar_power_guard = true;
		op.versao_campos = 3;
	end

	garantir_campos();
end

local function salvar_opcoes()
	json.dump_file("aviso_lanca_opcoes.json", op);
end

local estado = {
	mensagem = "",
	ultimo_erro_ms = nil,   -- diferenca entre o impacto previsto e o real (ultimo golpe)
	avisos_certos = 0,
	impactos_vistos = 0,
	defesas = { perfeita = 0, normal = 0, power = 0 }, -- contadas pelos eventos da lanca
	motivo_parado = ""      -- por que a defesa automatica nao esta agindo agora
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
				-- "origem": a animacao que previu o golpe (identifica o golpe no aprendizado das defesas)
				novos[#novos + 1] = { tempo = momento + g.tempo, guarda = g.guarda, vezes = g.vezes, origem = animacao };
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

-- defesas aprendidas por golpe ("id do monstro:animacao que previu" = nivel 1 a 4) e
-- golpes esperando a conferencia (o jogo confirmou a defesa?)
local defesas_aprendidas = {};
local verificacoes_defesa = {};

pcall(function()
	local salvo = json.load_file("aviso_lanca_defesas.json");
	if type(salvo) == "table" and type(salvo.golpes) == "table" then defesas_aprendidas = salvo.golpes; end
end);

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
	local menor, casado = nil, nil;
	for _, p in ipairs(m.previstos) do
		local erro = momento - p.tempo;
		if menor == nil or math.abs(erro) < math.abs(menor) then menor, casado = erro, p; end
	end
	if menor ~= nil and math.abs(menor) <= 0.3 then
		estado.ultimo_erro_ms = math.floor(menor * 1000 + 0.5);
		estado.avisos_certos = estado.avisos_certos + 1;

		-- o mod defendeu este golpe? confere daqui a 0,3s se o jogo confirmou a defesa
		if casado.defesa ~= nil and not casado.conferido then
			casado.conferido = true;
			verificacoes_defesa[#verificacoes_defesa + 1] = {
				chave = tostring(m.id) .. ":" .. tostring(casado.origem),
				nivel = casado.nivel, defesa = casado.defesa, em = os.clock()
			};
		end
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
	local arquivo = string.format("aviso_lanca_gravacao_v20_%d.json", pesquisa.numero);
	json.dump_file(arquivo, { versao_mod = "0.20", arma = pesquisa.arma_tipo,
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
	Exporta as classes de CONTROLE do jogo (como ele le os botoes), para o modo automatico.

	A versao 0.4 tentava listar todas as classes do jogo, mas essa funcao nao existe no seu
	REFramework. Aqui o caminho e outro:
	  1) testamos os nomes de classes de controle achados dentro do executavel do jogo,
	     com os "sobrenomes" (namespaces) mais provaveis;
	  2) pegamos os gerenciadores de controle que estao rodando agora;
	  3) olhamos os objetos ligados ao seu jogador e ao seu cacador que lembram controle.
	Para cada classe achada, descrevemos tambem as classes dos campos dela que lembram
	controle (um nivel abaixo).
]]
local NOMES_DE_CONTROLE = {
	"PlayerInput", "PcPlayerInput", "PadPlayerInput", "MkbPlayerInput", "EmptyPlayerInput",
	"cPlayerInput", "cPlayerCommand", "PlayerCommand", "GameInputManager", "PadManager",
	"MouseKeyboardManager", "AppMouseKeyboardManager", "GameInputUtil", "cNpcInputController",
	"NpcInputController", "cInputCtrlParam", "cInputInfo", "cInputParam", "InputData",
	"SingleInputData", "cInputCtrlOwnerAccessor", "cPadInfo", "VirtualMouseManager",
	"cSyncInputCtrl", "SyncInputCtrl", "cInputCtrl", "InputCtrl", "HunterInput", "cHunterInput",
	"cHunterCommand", "HunterCommand", "cPlayerInputCtrl", "InputManager", "cGamePad", "GamePad"
};
local ESPACOS = { "app.", "ace.", "via.hid.", "via.", "app.cHunterCharacter.", "app.HunterCharacter." };
local PALAVRAS_CONTROLE = { "Input", "Command", "Pad", "Ctrl", "Button", "Key", "Mkb", "Mouse" };

local function lembra_controle(nome)
	for _, palavra in ipairs(PALAVRAS_CONTROLE) do
		if string.find(nome, palavra, 1, true) then return true; end
	end
	return false;
end

local function exportar_controles()
	local resultado = { classes = {}, gerenciadores = {}, ligadas_ao_jogador = {}, nao_achadas = 0 };
	local descritas = {};
	local total = 0;

	-- descreve uma classe (uma vez so) e, um nivel abaixo, as classes dos campos que lembram controle
	local function descrever(tipo, origem, nivel)
		if tipo == nil or total >= 200 then return; end
		local nome = tipo:get_full_name();
		if descritas[nome] then return; end
		descritas[nome] = true;
		total = total + 1;

		local d = descrever_tipo(tipo);
		d.origem = origem;
		resultado.classes[#resultado.classes + 1] = d;

		if (nivel or 0) < 1 then
			for _, campo in ipairs(tipo:get_fields() or {}) do
				pcall(function()
					local tipo_campo = campo:get_type();
					local nome_campo = tipo_campo and tipo_campo:get_full_name() or "";
					if (string.sub(nome_campo, 1, 4) == "app." or string.sub(nome_campo, 1, 4) == "ace.")
						and lembra_controle(nome_campo .. campo:get_name()) then
						descrever(tipo_campo, "campo " .. campo:get_name() .. " de " .. nome, 1);
					end
				end);
			end
		end
	end

	-- 1) nomes achados no executavel, com os namespaces provaveis
	for _, nome in ipairs(NOMES_DE_CONTROLE) do
		for _, espaco in ipairs(ESPACOS) do
			local tipo = sdk.find_type_definition(espaco .. nome);
			if tipo ~= nil then
				descrever(tipo, "nome achado no executavel", 0);
			else
				resultado.nao_achadas = resultado.nao_achadas + 1;
			end
		end
	end

	-- 2) gerenciadores de controle rodando agora
	for _, nome in ipairs(NOMES_DE_CONTROLE) do
		for _, espaco in ipairs({ "app.", "ace." }) do
			local ok, objeto = pcall(sdk.get_managed_singleton, espaco .. nome);
			if ok and objeto ~= nil then
				local item = { nome = espaco .. nome, campos_ao_vivo = {} };
				for _, campo in ipairs(objeto:get_type_definition():get_fields() or {}) do
					pcall(function()
						local valor = campo:get_data(objeto);
						local tipo_valor = (type(valor) == "userdata") and valor:get_type_definition():get_full_name() or type(valor);
						item.campos_ao_vivo[#item.campos_ao_vivo + 1] = campo:get_name() .. " = " .. tostring(tipo_valor);
						if type(valor) == "userdata" and lembra_controle(tipo_valor .. campo:get_name()) then
							descrever(valor:get_type_definition(), "objeto vivo em " .. espaco .. nome .. "." .. campo:get_name(), 0);
						end
					end);
				end
				resultado.gerenciadores[#resultado.gerenciadores + 1] = item;
			end
		end
	end

	-- 3) objetos ligados ao seu jogador (informacoes do jogador e o cacador)
	local gerente = sdk.get_managed_singleton("app.PlayerManager");
	local info = gerente and gerente:call("getMasterPlayer");
	local cacador = info and info:call("get_Character");

	for _, par in ipairs({ { "informacoes do jogador", info }, { "cacador", cacador } }) do
		local rotulo, objeto = par[1], par[2];
		if objeto ~= nil then
			local item = { de = rotulo, tipo = objeto:get_type_definition():get_full_name(), campos = {} };
			local tipo = objeto:get_type_definition();
			while tipo ~= nil and (string.sub(tipo:get_full_name(), 1, 4) == "app." or string.sub(tipo:get_full_name(), 1, 4) == "ace.") do
				for _, campo in ipairs(tipo:get_fields() or {}) do
					pcall(function()
						if campo:is_static() then return; end
						local valor = campo:get_data(objeto);
						if type(valor) ~= "userdata" then return; end
						local tipo_valor = valor:get_type_definition():get_full_name();
						if lembra_controle(tipo_valor .. campo:get_name()) then
							item.campos[#item.campos + 1] = campo:get_name() .. " = " .. tipo_valor;
							descrever(valor:get_type_definition(), rotulo .. "." .. campo:get_name(), 0);
						end
					end);
				end
				tipo = tipo:get_parent_type();
			end
			resultado.ligadas_ao_jogador[#resultado.ligadas_ao_jogador + 1] = item;
		end
	end

	json.dump_file("aviso_lanca_controles.json", resultado);
	estado.mensagem = string.format("Controles exportados: %d classes, %d gerenciadores ativos.",
		#resultado.classes, #resultado.gerenciadores);
end

--[[
	TESTE DA GUARDA AUTOMATICA (2)

	Na versao 0.6 o mod escutava "perguntas" do tipo "o botao esta apertado?", mas o jogo
	quase nao faz essas perguntas: ele guarda o estado dos botoes em CAMPOS (numeros e bits)
	dentro dos objetos de entrada e le esses campos direto.

	Entao agora o mod tira uma "foto" de todos os numeros dentro desses objetos, a cada
	quadro, em duas capturas de 3 segundos:
	  1) parado, com a lanca sacada, sem apertar nada;
	  2) parado, segurando a guarda.
	O que ficou sempre igual na captura 1 e mudou na captura 2 e o botao de guarda.

	No teste, o mod ESCREVE esses valores a cada quadro, como se voce estivesse apertando.

	Objetos fotografados:
	  - app.GameInputManager (entrada do controle e de mouse/teclado);
	  - as marcacoes de comando do seu cacador (_HunterBTableCommandFlag).
]]
local entrada = {
	fase = "parado",       -- parado | esperando | capturando
	captura_numero = 0,    -- 1 = parado, 2 = segurando a guarda
	fase_ate = 0,
	valores = { {}, {} },  -- por captura: [caminho] = { [valor] = vezes }
	onde = {},             -- [caminho] = { objeto, campo ou indice } (para escrever no teste)
	achados = {},          -- campos da guarda: { caminho, valor }
	forcar_de = 0,          -- o teste comeca aqui (4 segundos depois do clique)
	forcar_ate = 0,
	forcando = false,
	nos_ultima_foto = 0
};

local LIMITE_NOS = 4000; -- limite de valores por foto (evita pesar o jogo)

-- percorre um objeto e anota todos os numeros e verdadeiro/falso dentro dele
local function fotografar(objeto, caminho, profundidade, foto, visitados)
	if objeto == nil or foto.nos >= LIMITE_NOS then return; end

	local ok_end, endereco = pcall(objeto.get_address, objeto);
	if ok_end and endereco ~= nil then
		if visitados[endereco] then return; end
		visitados[endereco] = true;
	end

	-- lista (array): anota cada item
	local ok_tam, tamanho = pcall(function() return objeto:get_size(); end);
	if ok_tam and type(tamanho) == "number" then
		for i = 0, math.min(tamanho, 64) - 1 do
			local ok_item, item = pcall(objeto.get_element, objeto, i);
			if ok_item then
				local caminho_item = caminho .. "[" .. i .. "]";
				if type(item) == "number" or type(item) == "boolean" then
					foto.valores[caminho_item] = item;
					foto.onde[caminho_item] = { objeto = objeto, indice = i };
					foto.nos = foto.nos + 1;
				elseif type(item) == "userdata" and profundidade > 0 then
					fotografar(item, caminho_item, profundidade - 1, foto, visitados);
				end
			end
		end
		return;
	end

	-- objeto comum: anota os campos dele e das classes-mae
	local ok_tipo, tipo = pcall(objeto.get_type_definition, objeto);
	while ok_tipo and tipo ~= nil do
		local nome_tipo = tipo:get_full_name();
		if nome_tipo == "System.Object" or nome_tipo == "System.ValueType" then break; end

		for _, campo in ipairs(tipo:get_fields() or {}) do
			if not campo:is_static() then
				local ok_v, valor = pcall(campo.get_data, campo, objeto);
				if ok_v then
					local caminho_campo = caminho .. "." .. campo:get_name();
					if type(valor) == "number" or type(valor) == "boolean" then
						foto.valores[caminho_campo] = valor;
						foto.onde[caminho_campo] = { objeto = objeto, campo = campo:get_name() };
						foto.nos = foto.nos + 1;
					elseif type(valor) == "userdata" and profundidade > 0 then
						fotografar(valor, caminho_campo, profundidade - 1, foto, visitados);
					end
				end
			end
		end

		tipo = tipo:get_parent_type();
	end
end

local function tirar_foto()
	local foto = { valores = {}, onde = {}, nos = 0 };
	local visitados = {};

	local gerente = sdk.get_managed_singleton("app.GameInputManager");
	if gerente ~= nil then
		for _, nome in ipairs({ "_PadPlayerInput", "_MkbPlayerInput", "_PlayerButtonMaskBit", "_PlayerButtonMaskFlagStore" }) do
			local ok, valor = pcall(gerente.get_field, gerente, nome);
			if ok and type(valor) == "userdata" then
				fotografar(valor, "Entrada." .. nome, 5, foto, visitados);
			elseif ok and type(valor) == "number" then
				foto.valores["Entrada." .. nome] = valor;
				foto.onde["Entrada." .. nome] = { objeto = gerente, campo = nome };
			end
		end
	end

	local cacador = meu_cacador();
	local marcas = cacador and cacador:get_field("_HunterBTableCommandFlag");
	if marcas ~= nil then fotografar(marcas, "Cacador.Comandos", 4, foto, visitados); end

	entrada.nos_ultima_foto = foto.nos;
	return foto;
end

-- qual botao esta sendo aprendido: "guarda", "esquiva" ou "power_guard"
entrada.alvo = "guarda";

local NOME_DO_ALVO = { guarda = "GUARDA (M5)", contra_ataque = "CONTRA-ATAQUE (M5 e depois M2)", power_guard = "POWER GUARD (M5, M2 e Espaco)", esquiva = "ESQUIVA (Espaco)" };

local function comecar_captura(numero)
	entrada.captura_numero = numero;
	entrada.valores[numero] = {};
	entrada.fase = "esperando";
	entrada.fase_ate = agora() + 3;

	-- esquiva: o passo 2 grava um TOQUE. Para saber o que mudou em cada quadro, guardamos
	-- o valor "parado" (da captura 1) de cada campo que nao variou nela.
	entrada.base, entrada.quadros = nil, {};
	if numero == 2 and entrada.alvo == "esquiva" then
		entrada.base = {};
		for caminho, vistos in pairs(entrada.valores[1] or {}) do
			local unico, quantos = nil, 0;
			for valor in pairs(vistos) do unico = valor; quantos = quantos + 1; end
			if quantos == 1 then entrada.base[caminho] = unico; end
		end
	end
end

-- transforma um caminho de foto ("..._Keys[N]...Campo") num item de escrita { t, l, c, v }
local function item_de_caminho(caminho, texto_valor)
	local n, resto = string.match(caminho, "_Keys%[(%d+)%]%.(.+)$");
	if n == nil then return nil; end
	local campo = string.match(resto, "([%w_]+)$");
	local valor = texto_valor;
	if valor == "true" then valor = true; elseif valor == "false" then valor = false; else valor = tonumber(valor); end
	if campo == nil or valor == nil then return nil; end
	return { t = tonumber(n), l = string.find(resto, "LagWorker", 1, true) ~= nil, c = campo, v = valor };
end

--[[
	TOQUE GRAVADO (esquiva)
	Do primeiro quadro em que algo mudou ate o ultimo (no maximo 1,5s), guarda a lista de
	mudancas de cada quadro. Na hora de esquivar, o mod repete essa sequencia quadro a
	quadro, como uma macro. O quadro com mais mudancas vira o "Espaco segurado" do Power Guard.
]]
local function calcular_toque()
	local primeiro, ultimo = nil, nil;
	for i, diferentes in ipairs(entrada.quadros) do
		if next(diferentes) ~= nil then
			primeiro = primeiro or i;
			ultimo = i;
		end
	end
	if primeiro == nil then
		estado.mensagem = "Toque nao gravado: nenhuma mudanca. Aperte e solte o Espaco durante a captura.";
		return;
	end
	ultimo = math.min(ultimo, primeiro + 90);

	local quadros, maior = {}, {};
	for i = primeiro, ultimo do
		local itens = {};
		for caminho, texto in pairs(entrada.quadros[i]) do
			local item = item_de_caminho(caminho, texto);
			if item ~= nil then itens[#itens + 1] = item; end
		end
		quadros[#quadros + 1] = itens;
		if #itens > #maior then maior = itens; end
	end

	op.toques.esquiva = quadros;
	op.espaco_segurado = maior;
	json.dump_file("aviso_lanca_opcoes.json", op);
	json.dump_file("aviso_lanca_toque_esquiva.json", { quadros = quadros, segurado = maior });
	estado.mensagem = string.format("Toque da esquiva gravado: %d quadros.", #quadros);
end

-- O que foi sempre igual parado e ficou diferente segurando a guarda
local function calcular_achados()
	entrada.achados = {};
	local parado, segurando = entrada.valores[1], entrada.valores[2];

	for caminho, vistos2 in pairs(segurando) do
		local vistos1 = parado[caminho];
		if vistos1 ~= nil then
			local distintos1, unico1 = 0, nil;
			for valor in pairs(vistos1) do distintos1 = distintos1 + 1; unico1 = valor; end

			-- parado: sempre o mesmo valor. Segurando: o valor mais visto e outro.
			if distintos1 == 1 then
				local melhor, vezes_melhor, total = nil, 0, 0;
				for valor, vezes in pairs(vistos2) do
					total = total + vezes;
					if vezes > vezes_melhor then melhor, vezes_melhor = valor, vezes; end
				end
				if melhor ~= nil and melhor ~= unico1 and vezes_melhor >= total * 0.6 then
					entrada.achados[#entrada.achados + 1] = {
						caminho = caminho, parado = unico1, segurando = melhor
					};
				end
			end
		end
	end

	table.sort(entrada.achados, function(a, b) return a.caminho < b.caminho; end);

	--[[
		Cada campo achado vira uma instrucao de escrita. Os caminhos tem a forma
		  Entrada._MkbPlayerInput[0]._Keys[N]._Campo                         (no botao)
		  Entrada._MkbPlayerInput[0]._Keys[N].<LagWorker>k__BackingField[0]._Campo (no buffer)
		N e o numero do comando. Guardamos tudo nas opcoes: e o que a defesa "aperta".
	]]
	local campos = {};
	for _, a in ipairs(entrada.achados) do
		local n, resto = string.match(a.caminho, "_Keys%[(%d+)%]%.(.+)$");
		if n ~= nil then
			local no_buffer = string.find(resto, "LagWorker", 1, true) ~= nil;
			local campo = string.match(resto, "([%w_]+)$");
			local valor = a.segurando;
			if valor == "true" then valor = true; elseif valor == "false" then valor = false; else valor = tonumber(valor); end
			if campo ~= nil and valor ~= nil then
				campos[#campos + 1] = { t = tonumber(n), l = no_buffer, c = campo, v = valor };
			end
		end
	end

	local indices = comandos_de(campos);
	if #campos > 0 then
		op.campos[entrada.alvo] = campos;
		op.botoes[entrada.alvo] = indices;
		json.dump_file("aviso_lanca_opcoes.json", op);
	end

	local lista = {};
	for _, a in ipairs(entrada.achados) do lista[#lista + 1] = a.caminho .. " : " .. a.parado .. " -> " .. a.segurando; end
	json.dump_file("aviso_lanca_botao_" .. entrada.alvo .. ".json",
		{ comandos = indices, achados = lista, valores_por_foto = entrada.nos_ultima_foto });
end

local function atualizar_captura()
	local momento = agora();
	entrada.forcando = momento >= entrada.forcar_de and momento < entrada.forcar_ate;

	if entrada.fase == "esperando" and momento >= entrada.fase_ate then
		entrada.fase = "capturando";
		entrada.fase_ate = momento + 3;
	elseif entrada.fase == "capturando" then
		-- foto deste quadro: conta quantas vezes cada valor apareceu em cada campo
		local foto = tirar_foto();
		local destino = entrada.valores[entrada.captura_numero];
		for caminho, valor in pairs(foto.valores) do
			local chave = tostring(valor);
			destino[caminho] = destino[caminho] or {};
			destino[caminho][chave] = (destino[caminho][chave] or 0) + 1;
		end

		-- esquiva (toque): guarda, quadro a quadro, so o que esta diferente do "parado"
		if entrada.captura_numero == 2 and entrada.alvo == "esquiva" and entrada.base ~= nil then
			local diferentes = {};
			for caminho, valor in pairs(foto.valores) do
				local base = entrada.base[caminho];
				if base ~= nil and tostring(valor) ~= base and string.find(caminho, "_Keys[", 1, true) then
					diferentes[caminho] = tostring(valor);
				end
			end
			entrada.quadros[#entrada.quadros + 1] = diferentes;
		end

		if momento >= entrada.fase_ate then
			entrada.fase = "parado";
			if entrada.captura_numero == 2 and entrada.alvo == "esquiva" then
				pcall(calcular_toque);
			end
			if entrada.captura_numero == 2 then
				pcall(calcular_achados);

				-- libera a memoria das capturas (milhares de valores) e avisa que os campos
				-- mudaram, para a escrita rapida refazer a lista de posicoes
				entrada.capturou_2 = true;
				entrada.valores = { {}, {} };
				entrada.onde = {};
				entrada.campos_mudaram = true;
				collectgarbage("collect");
			end
			estado.mensagem = string.format("Captura %d terminada (%d valores por foto).",
				entrada.captura_numero, entrada.nos_ultima_foto);
		end
	end
end

--[[
	"APERTAR" BOTOES
	Cada botao do jogo vira um objeto em "_Keys[N]" (N = numero do comando), dentro da
	entrada de mouse/teclado e da entrada de controle. Para "apertar" uma acao, o mod
	escreve exatamente os valores que o jogo tinha quando VOCE apertou de verdade (vieram
	das capturas): o estado do botao e o buffer de entrada (LagWorker), que e onde o jogo
	anota "acabou de ser apertado". A versao 0.8 nao escrevia o buffer, por isso a guarda
	so funcionava junto com o seu M5 e a esquiva nao funcionava.

	"teclas_agora" diz quais acoes ("guarda", "especial", "esquiva") estao apertadas
	neste quadro. Quem decide e o planejador da defesa (mais abaixo) ou o botao de teste.
	A escrita vai POR CIMA da sua entrada: voce pode continuar atacando normalmente.

	Versao 0.11 (contra o travamento):
	  - escreve SO na entrada de mouse/teclado (opcao no menu para incluir o controle).
	    Escrever no controle pode fazer o jogo trocar a interface para "modo controle" e
	    voltar logo depois, o que costuma travar;
	  - os objetos dos botoes sao achados UMA vez por quadro ("preparar_escrita"); os
	    ganchos so repetem os valores, sem procurar nada;
	  - mede o tempo gasto escrevendo e quantas vezes o jogo trocou de controle/teclado.
]]
local teclas_agora = {};
local escrita = {};       -- preparada a cada quadro: lista de { objeto, campo, valor }

local diagnostico_escrita = {
	ms_quadro = 0, chamadas_quadro = 0,   -- do ultimo quadro
	ms_acumulado = 0, chamadas = 0,       -- do quadro atual
	ms_maximo = 0,                        -- maior tempo num quadro desde que zerou
	trocas_de_dispositivo = 0, estilo = nil
};

-- comandos de uma lista de campos, como conjunto
local function conjunto_de_comandos(lista)
	local c = {};
	for _, item in ipairs(lista or {}) do c[item.t] = true; end
	return c;
end

-- campos que cada acao escreve
local function campos_da_acao(acao)
	if acao == "guarda" then
		return op.campos.guarda or {};

	elseif acao == "especial" then
		-- o "especial" (M2) e o que a captura do contra-ataque (M5 + M2) tem a mais que a guarda
		local da_guarda = conjunto_de_comandos(op.campos.guarda);
		local lista = {};
		for _, item in ipairs(op.campos.contra_ataque or {}) do
			if not da_guarda[item.t] then lista[#lista + 1] = item; end
		end
		return lista;

	elseif string.sub(acao, 1, 6) == "toque:" then
		-- um quadro do toque gravado da esquiva
		local quadro = tonumber(string.sub(acao, 7));
		return (op.toques.esquiva or {})[quadro] or {};

	elseif acao == "espaco" and #(op.espaco_segurado or {}) > 0 then
		-- Espaco segurado (Power Guard): o quadro com mais mudancas do toque gravado
		return op.espaco_segurado;

	elseif acao == "esquiva" or acao == "espaco" then
		-- a captura da esquiva so pegou o buffer; somamos o aperto completo do botao
		local lista = {};
		for _, item in ipairs(op.campos.esquiva or {}) do lista[#lista + 1] = item; end
		for n in pairs(conjunto_de_comandos(op.campos.esquiva)) do
			lista[#lista + 1] = { t = n, l = false, c = "_On", v = true };
			lista[#lista + 1] = { t = n, l = false, c = "_RawOn", v = true };
			lista[#lista + 1] = { t = n, l = false, c = "_AnalogValue", v = 1.0 };
		end
		return lista;
	end

	return op.campos[acao] or {};
end

--[[
	ESCRITA SEGURA (versao 0.15)

	Historico:
	  - 0.7 a 0.11: escrita pelo nome do campo ("set_field"), feita dentro de ganchos em
	    onApplyFromMouseKeyboard/onApplyFromPad. Funcionava, mas TRAVAVA;
	  - 0.12 a 0.14: escrita direta na memoria. O jogo FECHOU: o log mostrou o erro dentro
	    de app.PressController, que processa os botoes em VARIAS linhas de execucao ao mesmo
	    tempo ("executeParallel"). Escrever ali sem protecao, enquanto o jogo le, derruba.

	A causa mais provavel do travamento: aqueles ganchos rodam DENTRO do processamento
	paralelo dos botoes. Cada vez que um gancho do Lua roda numa dessas linhas, ela espera
	o Lua ficar livre, e o jogo todo espera junto.

	Agora:
	  - escrita segura do REFramework (pelo campo ja encontrado, sem buscar pelo nome toda
	    vez e sem escrever direto na memoria);
	  - SO na linha principal do jogo: logo depois de ler mouse/teclado ("UpdateHID") e antes
	    de os personagens agirem ("UpdateBehavior");
	  - os ganchos dentro do processamento paralelo ficam DESLIGADOS. Ha uma opcao no menu
	    para religar (precisa reiniciar os scripts), caso a guarda nao funcione sem eles.
]]
local cache_escrita = { chave_entrada = nil, conferido_em = 0, acoes = {} };

-- acha o campo (procurando tambem nas classes-mae)
local function campo_do_objeto(objeto, nome)
	local tipo = objeto:get_type_definition();
	while tipo ~= nil do
		local campo = tipo:get_field(nome);
		if campo ~= nil then return campo; end
		tipo = tipo:get_parent_type();
	end
	return nil;
end

-- objetos de entrada (mouse/teclado e, se ligado, controle)
local function entradas_ativas()
	local gerente = sdk.get_managed_singleton("app.GameInputManager");
	if gerente == nil then return {}; end

	local nomes = { "_MkbPlayerInput" };
	if op.escrever_controle then nomes[#nomes + 1] = "_PadPlayerInput"; end

	local lista_entradas = {};
	for _, nome in ipairs(nomes) do
		local ok, entrada_jogador = pcall(function()
			local lista = gerente:get_field(nome);
			return lista and lista:get_element(0);
		end);
		if ok and entrada_jogador ~= nil then lista_entradas[#lista_entradas + 1] = entrada_jogador; end
	end
	return lista_entradas;
end

-- monta (uma vez) a lista de escritas de uma acao: { objeto, campo, nome do campo, valor }
local function montar_escritas(acao, lista_entradas)
	local escritas = {};
	for _, entrada_jogador in ipairs(lista_entradas) do
		pcall(function()
			local teclas = entrada_jogador:get_field("_Keys");
			if teclas == nil then return; end

			-- MODO SEGURO do Espaco (versao 0.18): o teste do Power Guard da 0.17 fechou o jogo
			-- dentro da interface (GUIBase.update). Suspeita: "_LastRawTriggerIndex" e um
			-- INDICE para uma lista ligada a tecla fisica; fingindo o aperto, ele aponta para
			-- uma lista vazia e a interface le fora dela. Nas acoes do Espaco (esquiva, Espaco
			-- do Power Guard e o toque gravado) o mod nao escreve esse indice nem o buffer.
			local modo_seguro = (acao == "esquiva" or acao == "espaco" or string.sub(acao, 1, 6) == "toque:");

			for _, item in ipairs(campos_da_acao(acao)) do
				local pular = modo_seguro and (item.l or item.c == "_LastRawTriggerIndex");
				if not pular then

				local alvo = teclas:get_element(item.t);
				if alvo ~= nil and item.l then
					local buffer = alvo:get_field("<LagWorker>k__BackingField");
					alvo = buffer and buffer:get_element(0);
				end
				if alvo ~= nil then
					local campo = campo_do_objeto(alvo, item.c);
					if campo ~= nil then escritas[#escritas + 1] = { alvo, campo, item.c, item.v }; end
				end

				end
			end
		end);
	end
	return escritas;
end

-- confere (no maximo a cada meio segundo) se o objeto de entrada ainda e o mesmo
local function conferir_cache()
	local momento = os.clock();
	if momento - cache_escrita.conferido_em < 0.5 and cache_escrita.chave_entrada ~= nil then return; end
	cache_escrita.conferido_em = momento;

	local lista_entradas = entradas_ativas();
	local chave = tostring(op.escrever_controle);
	for _, e in ipairs(lista_entradas) do
		local ok, endereco = pcall(e.get_address, e);
		chave = chave .. ":" .. tostring(ok and endereco or "?");
	end

	if chave ~= cache_escrita.chave_entrada then
		cache_escrita.chave_entrada = chave;
		cache_escrita.acoes = {};
		cache_escrita.entradas = lista_entradas;
	end
end

-- escolhe as escritas deste quadro (chamado uma vez por quadro)
local function preparar_escrita()
	escrita = {};

	-- campos aprendidos de novo: refaz a lista
	if entrada.campos_mudaram then
		entrada.campos_mudaram = false;
		cache_escrita.acoes = {};
	end

	if next(teclas_agora) == nil then return; end

	conferir_cache();
	for acao in pairs(teclas_agora) do
		local lista = cache_escrita.acoes[acao];
		if lista == nil then
			lista = montar_escritas(acao, cache_escrita.entradas or {});
			cache_escrita.acoes[acao] = lista;
		end
		for i = 1, #lista do escrita[#escrita + 1] = lista[i]; end
	end
end

-- escreve os valores (chamado na linha principal do jogo, 2 vezes por quadro)
local function apertar_teclas()
	if #escrita == 0 then return; end
	local inicio = os.clock();

	for i = 1, #escrita do
		local e = escrita[i];
		local ok = pcall(e[2].set_data, e[2], e[1], e[4]);
		if not ok then pcall(e[1].set_field, e[1], e[3], e[4]); end
	end

	diagnostico_escrita.ms_acumulado = diagnostico_escrita.ms_acumulado + (os.clock() - inicio) * 1000;
	diagnostico_escrita.chamadas = diagnostico_escrita.chamadas + 1;
end

-- fecha o diagnostico do quadro e confere se o jogo trocou entre controle e teclado
local function fechar_diagnostico_do_quadro()
	local d = diagnostico_escrita;
	d.ms_quadro, d.chamadas_quadro = d.ms_acumulado, d.chamadas;
	if d.ms_quadro > d.ms_maximo then d.ms_maximo = d.ms_quadro; end
	d.ms_acumulado, d.chamadas = 0, 0;

	pcall(function()
		local gerente = sdk.get_managed_singleton("app.GameInputManager");
		local estilo = gerente and gerente:get_field("_DeviceStyle");
		if estilo ~= nil then
			if d.estilo ~= nil and estilo ~= d.estilo then d.trocas_de_dispositivo = d.trocas_de_dispositivo + 1; end
			d.estilo = estilo;
		end
	end);
end

-- Liga os pontos onde a escrita acontece (chamado no INICIO, depois de ler as opcoes)
local pontos_de_escrita = {};

local function ligar_pontos_de_escrita()
	--[[
		Versao 0.16: na 0.15 o mod escrevia em "UpdateHID" e antes de "UpdateBehavior", mas
		o jogo recalculava os botoes a partir do mouse DEPOIS disso e apagava a escrita
		(nao travava, mas nao fazia nada).

		O GameInputManager atualiza a entrada do jogador em "updatePlayerInput", uma vez por
		quadro, na linha principal (ele e um componente normal do jogo). Escrevendo logo
		DEPOIS dessa funcao, o mod fica depois da leitura do mouse e antes de o cacador
		agir, sem entrar no processamento paralelo. "update" fica como reserva.
	]]
	local gerente_tipo = sdk.find_type_definition("app.GameInputManager");
	for _, nome_funcao in ipairs({ "updatePlayerInput", "update" }) do
		local funcao = gerente_tipo and gerente_tipo:get_method(nome_funcao);
		if funcao ~= nil and pcall(sdk.hook, funcao, nil, function(retorno)
			apertar_teclas();
			return retorno;
		end) then
			pontos_de_escrita[#pontos_de_escrita + 1] = "depois de GameInputManager." .. nome_funcao;
		end
	end

	-- dentro do processamento paralelo dos botoes (desligado por padrao: pode travar)
	if op.escrever_no_paralelo then
		for _, nome in ipairs({ "app.cPcPlayerGameInput", "app.cPlayerGameInput" }) do
			local tipo = sdk.find_type_definition(nome);
			for _, nome_funcao in ipairs({ "onApplyFromMouseKeyboard", "onApplyFromPad" }) do
				local funcao = tipo and tipo:get_method(nome_funcao);
				if funcao ~= nil and pcall(sdk.hook, funcao, nil, function(retorno)
					apertar_teclas();
					return retorno;
				end) then
					pontos_de_escrita[#pontos_de_escrita + 1] = nome_funcao;
				end
			end
		end
	end
end


-- mensagem grande no meio da tela durante a captura e o teste
local function desenhar_status_entrada()
	local texto = nil;
	local momento = agora();
	local acao = "FIQUE PARADO (sem apertar nada)";
	if entrada.captura_numero == 2 then
		acao = (entrada.alvo == "esquiva") and "APERTE E SOLTE O ESPACO UMA VEZ" or ("SEGURE " .. NOME_DO_ALVO[entrada.alvo]);
	end

	if entrada.fase == "esperando" then
		texto = string.format("Prepare-se: %s em %.0f...", acao, math.max(0, entrada.fase_ate - momento));
	elseif entrada.fase == "capturando" then
		texto = string.format("CAPTURANDO: %s (%.1fs)", acao, math.max(0, entrada.fase_ate - momento));
	elseif entrada.forcando then
		texto = string.format("TESTE: o mod esta apertando %s (%.1fs)", NOME_DO_ALVO[entrada.alvo], entrada.forcar_ate - momento);
	elseif momento < entrada.forcar_de then
		texto = string.format("Feche o menu: o teste de %s comeca em %.0f...", NOME_DO_ALVO[entrada.alvo], entrada.forcar_de - momento);
	end

	if texto ~= nil then
		local largura, altura = tamanho_tela();
		draw.text(texto, largura / 2 - 150 + 1, altura * 0.3 + 1, 0xFF000000);
		draw.text(texto, largura / 2 - 150, altura * 0.3, 0xFF00FFFF);
	end
end

--[[
	CONTAGEM DE DEFESAS
	Ganchos em 4 funcoes da lanca, que o jogo chama quando cada defesa da certo:
	  - callJustGuardSuccessEffect: GUARDA PERFEITA ("Just Guard");
	  - callGuardSuccessEffect: guarda normal;
	  - callPowerGuardEffect: Power Guard;
	  - onParrySuccess: contra-ataque.
	IMPORTANTE: os ganchos sao ligados AGORA, quando o mod carrega (antes de entrar no
	save). Ate a versao 0.9 eles eram ligados com o jogo rodando, em 14 funcoes, e isso
	fez o jogo fechar ao entrar no save.
]]
estado.defesas.contra = 0;

local ultima_chamada_defesa = {};

local DEFESAS_DA_LANCA = {
	{ classe = "app.cHunterWp06Handling", funcao = "callJustGuardSuccessEffect", conta = "perfeita" },
	{ classe = "app.cHunterWp06Handling", funcao = "callGuardSuccessEffect", conta = "normal" },
	{ classe = "app.cHunterWp06Handling", funcao = "callPowerGuardEffect", conta = "power" },
	{ classe = "app.cHunterWeaponHandlingBase", funcao = "onParrySuccess", conta = "contra" }
};

for _, d in ipairs(DEFESAS_DA_LANCA) do
	local tipo = sdk.find_type_definition(d.classe);
	local funcao = tipo and tipo:get_method(d.funcao);
	if funcao ~= nil then
		local ok = pcall(sdk.hook, funcao, function()
			-- algumas destas funcoes sao chamadas a cada quadro enquanto o efeito dura (o Power
			-- Guard chegou a 9 mil). So conta quando passou meio segundo desde a ultima chamada.
			local agora_lua = os.clock();
			estado.ultimo_sucesso_defesa = agora_lua; -- usado na conferencia das defesas
			local ultima = ultima_chamada_defesa[d.conta] or -10;
			ultima_chamada_defesa[d.conta] = agora_lua;
			if agora_lua - ultima < 0.5 then return; end
			estado.defesas[d.conta] = (estado.defesas[d.conta] or 0) + 1;

			if pesquisa.gravando then
				local m = monstro_mais_perto();
				registrar("defesa", { funcao = d.funcao,
					animacao = m and m.animacao,
					tempo_na_animacao = m and arredondar(agora() - m.animacao_desde, 3) });
			end
		end, function(retorno) return retorno; end);
		if ok then pesquisa.arma_ganchos[#pesquisa.arma_ganchos + 1] = d.classe .. "." .. d.funcao; end
	end
end


-- =====================================================================================
-- DEFESA AUTOMATICA
-- A cada quadro decide quais botoes apertar, olhando os impactos previstos:
--   - golpe guardavel (tipo 0 ou 1): segura a GUARDA de um pouco antes ate um pouco depois;
--   - golpe so com Power Guard (tipo 3): POWER GUARD, se aprendido (senao, guarda normal);
--   - golpe impossivel de guardar (tipo 2): toque rapido na ESQUIVA, se aprendida.
-- So age com a lanca sacada e, por padrao, so quando voce esta sozinho na cacada.
-- =====================================================================================

local contagem_jogadores = { valor = 1, lida_em = -10 };

-- quantos jogadores estao na cacada (lido a cada 2 segundos)
local function jogadores_na_cacada()
	local momento = agora();
	if momento - contagem_jogadores.lida_em < 2 then return contagem_jogadores.valor; end
	contagem_jogadores.lida_em = momento;

	local total = 0;
	pcall(function()
		local gerente = sdk.get_managed_singleton("app.PlayerManager");
		local lista = gerente and gerente:get_field("_PlayerList");
		if lista == nil then return; end

		local ok_t, tamanho = pcall(function() return lista:get_size(); end);
		if not ok_t or type(tamanho) ~= "number" then tamanho = lista:call("get_Count"); end

		for i = 0, (tamanho or 0) - 1 do
			local ok_i, item = pcall(lista.get_element, lista, i);
			if not ok_i or item == nil then item = lista:call("get_Item", i); end
			local info = item and item:get_field("_PlayerInfo");
			if info and info:get_field("<Character>k__BackingField") ~= nil then total = total + 1; end
		end
	end);

	contagem_jogadores.valor = math.max(total, 1);
	return contagem_jogadores.valor;
end

-- pode agir agora? (devolve verdadeiro/falso e o motivo quando nao pode)
local function pode_defender()
	local cacador = meu_cacador();
	if cacador == nil then return false, "sem cacador"; end

	local arma = cacador:call("get_WeaponHandling");
	local tipo_arma = arma and arma:get_type_definition():get_full_name() or "";
	if not string.find(tipo_arma, "Wp06", 1, true) then return false, "nao esta de lanca"; end

	if cacador:call("get_IsWeaponOn") ~= true then return false, "lanca guardada"; end

	if op.somente_solo and jogadores_na_cacada() > 1 then return false, "tem outros jogadores na cacada"; end

	return true, "";
end

local function marcar(acao)
	if #campos_da_acao(acao) > 0 then teclas_agora[acao] = true; end
end

--[[
	CONTRA-ATAQUE = M5 e depois M2: guarda desde o inicio e, de 0,05s a 0,15s depois,
	um toque no especial. (Apertar os dois juntos e segurar so faz a guarda.)
]]
local function marcar_contra_ataque(desde_inicio)
	marcar("guarda");
	if desde_inicio >= 0.05 and desde_inicio < 0.15 then marcar("especial"); end
end

--[[
	TOQUE GRAVADO: reproduz a gravacao do Espaco quadro a quadro.
	  - exclusivo (esquiva): nada mais e apertado enquanto toca;
	  - junto (Power Guard): toca por cima da guarda + especial que estao segurados.
]]
local toque = { quadro = nil, exclusivo = true };

local function comecar_toque(exclusivo)
	if toque.quadro == nil and #(op.toques.esquiva or {}) > 0 then
		toque.quadro = 1;
		toque.exclusivo = exclusivo;
		return true;
	end
	return false;
end

--[[
	POWER GUARD (versao 0.20, como voce explicou): igual ao contra-ataque e, ja na postura
	do contra-ataque, um TOQUE no Espaco.
	  1. M5 (guarda) segurado o tempo todo;
	  2. de 0,05s a 0,15s: toque no M2 (igual ao contra-ataque, que funciona);
	  3. a partir de "pg_espaco_ms" (padrao 200 ms): toque do Espaco (a gravacao), com o
	     M5 ainda segurado. Depois disso o Espaco NAO fica segurado.
	Na 0.19 o M2 ficava segurado (sem a postura do contra-ataque o Espaco virava esquiva)
	e o Espaco ficava ligado depois do toque (outra esquiva).
	"estado_pg" guarda, para cada golpe, se o toque ja foi feito.
]]
local function marcar_power_guard(desde_inicio, estado_pg)
	marcar("guarda");
	if desde_inicio >= 0.05 and desde_inicio < 0.15 then marcar("especial"); end

	if desde_inicio >= op.pg_espaco_ms / 1000 and not estado_pg.tocou then
		estado_pg.tocou = true;
		-- sem toque gravado, usa o aperto antigo do Espaco so por este quadro
		if not comecar_toque(false) then marcar("espaco"); end
	end
end

--[[
	PRIORIDADE DAS DEFESAS (como voce pediu):
	  1. contra-ataque   2. guarda (perfeita ou normal)   3. Power Guard   4. esquiva

	Por onde comecar em cada golpe:
	  - golpe impossivel de guardar (tipo 2) ou que exige guarda forte (tipo 3): Power Guard;
	  - golpe vindo de LADO ou de TRAS (o cacador nao esta virado para o monstro): a guarda e
	    o contra-ataque da lanca so protegem de frente, entao comeca no Power Guard (360
	    graus). Golpes que podem ser guardados de qualquer direcao (tipo 1) nao contam;
	  - o resto: contra-ataque (ou guarda, se voce escolheu "so a guarda").

	APRENDIZADO: depois de cada golpe que chega em voce, o mod confere se o jogo confirmou a
	defesa (guarda perfeita, guarda, contra-ataque ou Power Guard). Se nao confirmou, aquele
	golpe sobe um nivel e, da proxima vez, ja comeca no nivel de cima. Fica salvo em
	aviso_lanca_defesas.json.
]]
local NIVEIS = { "contra_ataque", "guarda", "power_guard", "esquiva" };
local NOME_NIVEL = { contra_ataque = "contra-ataque", guarda = "guarda", power_guard = "Power Guard", esquiva = "esquiva" };

local function nivel_inicial(p, m)
	if p.guarda == 2 or p.guarda == 3 then return 3; end
	if p.guarda ~= 1 and m.angulo ~= nil and m.angulo > op.angulo_frontal then return 3; end
	return (op.acao_guardavel == "guarda") and 2 or 1;
end

-- primeiro nivel disponivel a partir de "nivel" (pula Power Guard ou esquiva desligados)
local function nivel_disponivel(nivel)
	for n = nivel, 4 do
		local nome = NIVEIS[n];
		if nome == "power_guard" and not op.usar_power_guard then
		elseif nome == "esquiva" and not op.esquivar then
		else
			return n;
		end
	end
	return nil;
end

local function chave_do_golpe(m, p)
	return tostring(m.id) .. ":" .. tostring(p.origem);
end

local function escolher_defesa(p, m)
	local nivel = nivel_inicial(p, m);
	local aprendido = defesas_aprendidas[chave_do_golpe(m, p)] or 1;
	if aprendido > nivel then nivel = aprendido; end
	return nivel_disponivel(nivel);
end

local function decidir_botoes()
	local momento = agora();

	-- botao de teste do menu: espera 4 segundos (para fechar o menu) e aperta por 5.
	--   esquiva: toca o toque gravado UMA vez;
	--   contra-ataque: faz a sequencia M5 -> M2 UMA vez;
	--   Power Guard: guarda + especial + toque do Espaco, segurado ate o fim do teste.
	if momento >= entrada.forcar_de and momento < entrada.forcar_ate then
		local desde = momento - entrada.forcar_de;
		entrada.teste_estado = entrada.teste_estado or {};
		if entrada.alvo == "esquiva" then
			if not entrada.teste_estado.tocou then
				entrada.teste_estado.tocou = true;
				if not comecar_toque(true) then marcar("esquiva"); end
			end
		elseif entrada.alvo == "contra_ataque" then
			if desde < 1.5 then marcar_contra_ataque(desde); end
		elseif entrada.alvo == "power_guard" then
			marcar_power_guard(desde, entrada.teste_estado);
		else
			marcar(entrada.alvo);
		end
		return;
	end
	if momento < entrada.forcar_ate then return; end -- ainda na espera do teste

	if not op.guarda_automatica then estado.motivo_parado = "desligada"; return; end

	local pode, motivo = pode_defender();
	estado.motivo_parado = motivo;
	if not pode then return; end

	local antes = {
		contra_ataque = op.antecedencia_contra_ms / 1000,
		guarda = op.antecedencia_guarda_ms / 1000,
		power_guard = op.antecedencia_power_ms / 1000,
		esquiva = op.antecedencia_esquiva_ms / 1000
	};
	local depois = op.segurar_depois_ms / 1000;
	local vai_esquivar = false;

	for _, m in pairs(monstros) do
		for _, p in ipairs(m.previstos) do
			local falta = p.tempo - momento;

			-- a defesa e escolhida quando o golpe entra na janela e fica fixa ate o impacto
			if p.nivel == nil and falta <= 1.0 then
				p.nivel = escolher_defesa(p, m);
				p.defesa = p.nivel and NIVEIS[p.nivel] or nil;
				p.estado_pg = {};
				if p.defesa ~= nil then
					estado.ultima_decisao = string.format("%s em %s (nivel %d, angulo %s)",
						NOME_NIVEL[p.defesa], tostring(p.origem), p.nivel,
						m.angulo and string.format("%.0f", m.angulo) or "?");
				end
			end

			local defesa = p.defesa;
			if defesa == "esquiva" then
				-- um toque no tempo certo
				if falta <= antes.esquiva and falta >= antes.esquiva - 0.1 then vai_esquivar = true; end
			elseif defesa ~= nil and falta <= antes[defesa] and falta >= -depois then
				local desde = antes[defesa] - falta;
				if defesa == "power_guard" then
					marcar_power_guard(desde, p.estado_pg);
				elseif defesa == "contra_ataque" then
					marcar_contra_ataque(desde);
				else
					marcar("guarda");
				end
			end
		end
	end

	-- esquiva: solta o resto (senao o jogo pode fazer outra coisa com o Espaco)
	if vai_esquivar then
		teclas_agora = {};
		if not comecar_toque(true) and toque.quadro == nil then marcar("esquiva"); end
	end
end

-- confere as defesas: o jogo confirmou a defesa ate 0,3s depois do impacto?
local function conferir_defesas()
	local agora_lua = os.clock();
	local restantes = {};
	local mudou = false;

	for _, v in ipairs(verificacoes_defesa) do
		if agora_lua - v.em < 0.3 then
			restantes[#restantes + 1] = v;
		elseif (estado.ultimo_sucesso_defesa or -100) >= v.em - 0.05 then
			estado.ultimo_resultado = "defendeu com " .. NOME_NIVEL[v.defesa] .. " (" .. v.chave .. ")";
		else
			local proximo = math.min((v.nivel or 1) + 1, 4);
			if (defesas_aprendidas[v.chave] or 1) < proximo then
				defesas_aprendidas[v.chave] = proximo;
				mudou = true;
			end
			estado.ultimo_resultado = "FALHOU com " .. NOME_NIVEL[v.defesa] .. " (" .. v.chave .. ") -> proxima vez: " .. NOME_NIVEL[NIVEIS[proximo]];
		end
	end

	verificacoes_defesa = restantes;
	if mudou then json.dump_file("aviso_lanca_defesas.json", { golpes = defesas_aprendidas }); end
end

local function planejar_defesa()
	teclas_agora = {};
	fechar_diagnostico_do_quadro();
	pcall(conferir_defesas);
	decidir_botoes();

	-- toque gravado em andamento: um quadro da gravacao por quadro do jogo
	if toque.quadro ~= nil then
		local quadros = op.toques.esquiva or {};
		if toque.quadro > #quadros then
			toque.quadro = nil;
		else
			if toque.exclusivo then teclas_agora = {}; end
			marcar("toque:" .. toque.quadro);
			toque.quadro = toque.quadro + 1;
		end
	end

	preparar_escrita();
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

	-- para onde o cacador esta olhando (vetor "frente", so no chao)
	local frente_x, frente_z = nil, nil;
	if objeto_cacador ~= nil then
		pcall(function()
			local eixo = objeto_cacador:call("get_Transform"):call("get_AxisZ");
			local tamanho = math.sqrt(eixo.x * eixo.x + eixo.z * eixo.z);
			if tamanho > 0.01 then frente_x, frente_z = eixo.x / tamanho, eixo.z / tamanho; end
		end);
	end

	-- so anota qual arma voce esta usando (para o menu). Nenhum gancho e ligado aqui.
	if cacador ~= nil then
		pcall(function()
			local arma = cacador:call("get_WeaponHandling");
			pesquisa.arma_tipo = arma and arma:get_type_definition():get_full_name() or nil;
		end);
	end

	for chave, m in pairs(monstros) do
		if momento - m.visto_em > 1 then
			monstros[chave] = nil;
		else
			local mx, my, mz = posicao(m.objeto);
			m.distancia = distancia(mx, my, mz, cx, cy, cz);

			-- angulo entre para onde o cacador olha e a direcao do monstro (no chao)
			m.angulo = nil;
			if frente_x ~= nil and mx ~= nil and cx ~= nil then
				local dx, dz = mx - cx, mz - cz;
				local tamanho = math.sqrt(dx * dx + dz * dz);
				if tamanho > 0.01 then
					local cosseno = (dx * frente_x + dz * frente_z) / tamanho;
					m.angulo = math.deg(math.acos(math.max(-1, math.min(1, cosseno))));
				end
			end

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

	pcall(atualizar_captura);

	local ok_defesa, erro_defesa = pcall(planejar_defesa);
	if not ok_defesa then teclas_agora = {}; escrita = {}; estado.mensagem = "erro defesa: " .. tostring(erro_defesa); end
	pcall(desenhar_status_entrada);
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

--[[
	ABA "PRINTS"
	Junta num lugar so tudo o que preciso ver para entender um problema. Basta abrir esta
	aba e tirar UM print da tela.
]]
local function desenhar_aba_prints()
	if not imgui.tree_node("Prints (abra esta aba e tire um print)") then return; end

	local momento = agora();
	local function linha(texto) imgui.text(texto); end
	local function lista_texto(l)
		if l == nil or #l == 0 then return "-"; end
		local partes = {};
		for _, n in ipairs(l) do partes[#partes + 1] = tostring(n); end
		return table.concat(partes, ",");
	end

	linha("== Aviso de Guarda (Lanca) v0.20 ==");

	-- cacador e arma
	local cacador = meu_cacador();
	local sacada = cacador and cacador:call("get_IsWeaponOn");
	local animacao_cacador = "-";
	if cacador ~= nil then
		local id, banco = animacao_de(objeto_de_jogo(cacador));
		if id ~= nil then animacao_cacador = tostring(banco) .. ":" .. tostring(id); end
	end
	linha(string.format("Arma: %s | sacada: %s | jogadores na cacada: %d | sua animacao: %s",
		tostring(pesquisa.arma_tipo), tostring(sacada), jogadores_na_cacada(), animacao_cacador));

	-- defesa automatica
	linha(string.format("Defesa: %s | agindo: %s | comeca em: %s | %s",
		op.guarda_automatica and "ligada" or "desligada",
		estado.motivo_parado == "" and "SIM" or ("nao (" .. estado.motivo_parado .. ")"),
		op.acao_guardavel, (op.usar_power_guard and "power guard ligado" or "power guard desligado") .. (op.esquivar and ", esquiva ligada" or ", esquiva desligada")));
	linha(string.format("Tempos (ms antes): guarda %d | contra %d | power %d | esquiva %d | segurar depois %d",
		op.antecedencia_guarda_ms, op.antecedencia_contra_ms, op.antecedencia_power_ms,
		op.antecedencia_esquiva_ms, op.segurar_depois_ms));

	-- o que esta sendo apertado agora e o estado do teste
	local apertando = {};
	for acao in pairs(teclas_agora) do apertando[#apertando + 1] = acao; end
	table.sort(apertando);
	local teste = "nenhum";
	if momento < entrada.forcar_de then
		teste = string.format("%s, comeca em %.1fs", entrada.alvo, entrada.forcar_de - momento);
	elseif momento < entrada.forcar_ate then
		teste = string.format("%s, rodando (%.1fs)", entrada.alvo, entrada.forcar_ate - momento);
	end
	linha(string.format("Apertando agora: %s | teste: %s | escritas por quadro: %d",
		#apertando > 0 and table.concat(apertando, ", ") or "nada", teste, #escrita));
	linha("Pontos de escrita: " .. (#pontos_de_escrita > 0 and table.concat(pontos_de_escrita, ", ") or "NENHUM"));

	-- prioridade das defesas
	local golpes_aprendidos, subiram = 0, 0;
	for _, nivel in pairs(defesas_aprendidas) do
		golpes_aprendidos = golpes_aprendidos + 1;
		if (tonumber(nivel) or 1) > 1 then subiram = subiram + 1; end
	end
	linha(string.format("Prioridade: %d golpes com nivel aprendido (%d subiram de nivel) | angulo de lado: %d graus",
		golpes_aprendidos, subiram, op.angulo_frontal));
	linha("Ultima decisao: " .. (estado.ultima_decisao or "-"));
	linha("Ultimo resultado: " .. (estado.ultimo_resultado or "-"));

	-- travamento
	local d = diagnostico_escrita;
	linha(string.format("Escrita: %.2f ms (maximo %.2f ms) | trocas controle/teclado: %d | memoria do Lua: %.0f KB",
		d.ms_quadro, d.ms_maximo, d.trocas_de_dispositivo, collectgarbage("count")));

	-- defesas que deram certo
	local total = estado.defesas.perfeita + estado.defesas.normal;
	linha(string.format("Defesas: %d perfeitas, %d normais (%s) | Power Guard %d | contra-ataques %d",
		estado.defesas.perfeita, estado.defesas.normal,
		total > 0 and string.format("%.0f%% perfeitas", 100 * estado.defesas.perfeita / total) or "-",
		estado.defesas.power, estado.defesas.contra or 0));

	-- botoes aprendidos
	linha(string.format("Comandos: guarda %s | contra %s | esquiva %s | power: montado (guarda + M2 + Espaco)",
		lista_texto(op.botoes.guarda), lista_texto(op.botoes.contra_ataque), lista_texto(op.botoes.esquiva)));

	-- toque gravado da esquiva
	local quadros_toque = op.toques.esquiva or {};
	local mudancas = 0;
	for _, q in ipairs(quadros_toque) do mudancas = mudancas + #q; end
	local comandos_espaco = {};
	for _, item in ipairs(op.espaco_segurado or {}) do comandos_espaco[#comandos_espaco + 1] = item.t; end
	table.sort(comandos_espaco);
	linha(string.format("Toque da esquiva: %s | Espaco segurado: %s | tocando agora: %s",
		#quadros_toque > 0 and string.format("%d quadros, %d mudancas", #quadros_toque, mudancas) or "NAO GRAVADO",
		#comandos_espaco > 0 and lista_texto(comandos_espaco) or "-",
		toque.quadro and ("quadro " .. toque.quadro) or "nao"));

	-- monstro mais perto e previsoes
	local m = monstro_mais_perto();
	if m ~= nil then
		local proximo = nil;
		for _, p in ipairs(m.previstos) do
			local falta = p.tempo - momento;
			if falta >= 0 and (proximo == nil or falta < proximo.falta) then proximo = { falta = falta, guarda = p.guarda }; end
		end
		linha(string.format("Monstro: %s (%s) | animacao %s ha %.2fs | %.1f m | avisos %d%s",
			m.nome, m.variacao, tostring(m.animacao), momento - m.animacao_desde, m.distancia or -1, #m.previstos,
			proximo and string.format(" | proximo golpe em %.2fs (tipo %d)", proximo.falta, proximo.guarda) or ""));
	else
		linha("Monstro: nenhum Arkveld por perto");
	end

	-- aprendizado e precisao
	local animacoes, medicoes = 0, 0;
	for _, l in pairs(conhecimento["27"] or {}) do animacoes = animacoes + 1; medicoes = medicoes + #l; end
	linha(string.format("Conhecimento: %d animacoes, %d medicoes | golpes previstos: %d de %d | ultimo erro: %s",
		animacoes, medicoes, estado.avisos_certos, estado.impactos_vistos,
		estado.ultimo_erro_ms and (estado.ultimo_erro_ms .. " ms") or "-"));

	if estado.mensagem ~= "" then linha("Mensagem: " .. estado.mensagem); end

	imgui.tree_pop();
end

re.on_draw_ui(function()
	if not imgui.tree_node("Aviso de Guarda (Lanca) v0.20") then return; end

	pcall(desenhar_aba_prints);

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

	-- defesa automatica
	if imgui.tree_node("Defesa automatica") then
		local mudou_defesa = false;

		alterado, op.guarda_automatica = imgui.checkbox("Guarda automatica", op.guarda_automatica);
		mudou_defesa = mudou_defesa or alterado;

		alterado, op.somente_solo = imgui.checkbox("So quando estou sozinho na cacada", op.somente_solo);
		mudou_defesa = mudou_defesa or alterado;

		-- o que fazer nos golpes guardaveis
		local acoes = { "contra_ataque", "guarda" };
		local nomes_acoes = { "Contra-ataque (M5 e depois M2) - prioridade", "So a guarda (M5)" };
		local atual_acao = (op.acao_guardavel == "guarda") and 2 or 1;
		local alterou_acao, nova_acao = imgui.combo("Nos golpes guardaveis", atual_acao, nomes_acoes);
		if alterou_acao then op.acao_guardavel = acoes[nova_acao] or "contra_ataque"; mudou_defesa = true; end

		imgui.text("Prioridade: 1 contra-ataque, 2 guarda, 3 Power Guard, 4 esquiva (sobe sozinho quando uma defesa falha)");

		alterado, op.usar_power_guard = imgui.checkbox("Usar Power Guard (nivel 3 da prioridade)", op.usar_power_guard);
		mudou_defesa = mudou_defesa or alterado;

		alterado, op.pg_espaco_ms = imgui.slider_int("Power Guard: Espaco quantos ms depois do M5 (o M2 vem aos 50 ms)", op.pg_espaco_ms, 100, 600);
		mudou_defesa = mudou_defesa or alterado;

		alterado, op.angulo_frontal = imgui.slider_int("Golpe de lado: angulo a partir do qual pula guarda e contra-ataque", op.angulo_frontal, 30, 180);
		mudou_defesa = mudou_defesa or alterado;

		alterado, op.antecedencia_guarda_ms = imgui.slider_int("Guarda: quantos ms antes do impacto", op.antecedencia_guarda_ms, 0, 500);
		mudou_defesa = mudou_defesa or alterado;

		alterado, op.antecedencia_contra_ms = imgui.slider_int("Contra-ataque: quantos ms antes do impacto", op.antecedencia_contra_ms, 0, 800);
		mudou_defesa = mudou_defesa or alterado;

		alterado, op.antecedencia_power_ms = imgui.slider_int("Power Guard: quantos ms antes do impacto", op.antecedencia_power_ms, 0, 1000);
		mudou_defesa = mudou_defesa or alterado;

		alterado, op.segurar_depois_ms = imgui.slider_int("Segurar quantos ms depois do impacto", op.segurar_depois_ms, 50, 800);
		mudou_defesa = mudou_defesa or alterado;

		alterado, op.esquivar = imgui.checkbox("Esquivar dos golpes impossiveis de guardar", op.esquivar);
		mudou_defesa = mudou_defesa or alterado;

		alterado, op.antecedencia_esquiva_ms = imgui.slider_int("Esquivar quantos ms antes do impacto", op.antecedencia_esquiva_ms, 0, 500);
		mudou_defesa = mudou_defesa or alterado;

		alterado, op.escrever_controle = imgui.checkbox("Apertar tambem na entrada de controle (so se voce joga de controle)", op.escrever_controle);
		mudou_defesa = mudou_defesa or alterado;

		alterado, op.escrever_no_paralelo = imgui.checkbox("Escrever tambem no processamento paralelo (PODE TRAVAR - so se a defesa nao funcionar; depois clique em ScriptRunner > Reset Scripts)", op.escrever_no_paralelo);
		mudou_defesa = mudou_defesa or alterado;

		if mudou_defesa then salvar_opcoes(); end

		if op.guarda_automatica then
			imgui.text(estado.motivo_parado == "" and "Agindo: SIM" or ("Agindo: nao (" .. estado.motivo_parado .. ")"));
		end

		-- diagnostico do travamento
		local d = diagnostico_escrita;
		imgui.text(string.format("Escrita: %.2f ms no ultimo quadro (maximo %.2f ms) | trocas controle/teclado: %d | memoria do Lua: %.0f KB",
			d.ms_quadro, d.ms_maximo, d.trocas_de_dispositivo, collectgarbage("count")));
		if imgui.button("Zerar diagnostico") then
			d.ms_maximo, d.trocas_de_dispositivo = 0, 0;
		end

		local total = estado.defesas.perfeita + estado.defesas.normal;
		imgui.text(string.format("Guardas: %d perfeitas, %d normais (%s perfeitas) | Power Guard: %d | Contra-ataques: %d",
			estado.defesas.perfeita, estado.defesas.normal,
			total > 0 and string.format("%.0f%%", 100 * estado.defesas.perfeita / total) or "-",
			estado.defesas.power, estado.defesas.contra or 0));
		if imgui.button("Zerar contagem de guardas") then
			estado.defesas = { perfeita = 0, normal = 0, power = 0, contra = 0 };
		end

		local function texto_botoes(lista)
			if lista == nil or #lista == 0 then return "nao aprendido"; end
			local partes = {};
			for _, n in ipairs(lista) do partes[#partes + 1] = tostring(n); end
			return "comandos " .. table.concat(partes, ", ");
		end
		imgui.text("Guarda (M5): " .. texto_botoes(op.botoes.guarda));
		imgui.text("Contra-ataque (M5 e depois M2): " .. texto_botoes(op.botoes.contra_ataque));
		imgui.text("Power Guard (M5, M2 e Espaco): " .. ((#(op.botoes.power_guard or {}) > 0)
			and texto_botoes(op.botoes.power_guard) or "montado com guarda + especial + Espaco"));
		imgui.text("Esquiva (Espaco): " .. texto_botoes(op.botoes.esquiva));

		-- aprender botoes (mesmo metodo que descobriu a guarda)
		if imgui.tree_node("Aprender botoes") then
			local alvos = { "guarda", "contra_ataque", "power_guard", "esquiva" };
			local nomes = { "Guarda (M5)", "Contra-ataque (M5 e depois M2)", "Power Guard (M5, M2 e Espaco)", "Esquiva (Espaco)" };
			local atual = 1;
			for i, a in ipairs(alvos) do if a == entrada.alvo then atual = i; end end

			local alterou_alvo, novo = imgui.combo("Botao a aprender", atual, nomes);
			if alterou_alvo then entrada.alvo = alvos[novo] or "guarda"; entrada.achados = {}; end

			imgui.text("Com a lanca SACADA, numa area tranquila (sem monstro perto):");
			if imgui.button("Passo 1: captura PARADO (sem apertar nada)") then comecar_captura(1); end
			local texto_passo2 = (entrada.alvo == "esquiva") and "Passo 2: captura APERTANDO E SOLTANDO O ESPACO UMA VEZ (grava o toque)" or ("Passo 2: captura SEGURANDO " .. NOME_DO_ALVO[entrada.alvo]);
			if imgui.button(texto_passo2) then comecar_captura(2); end

			if #entrada.achados > 0 then
				imgui.text(string.format("Campos que mudaram: %d -> salvo em %s", #entrada.achados, texto_botoes(op.botoes[entrada.alvo])));
			elseif entrada.capturou_2 and entrada.fase == "parado" then
				imgui.text("Nao achei diferenca entre as capturas. Repita o passo 2 segurando o botao o tempo todo.");
			end

			if #(op.botoes[entrada.alvo] or {}) > 0 or entrada.alvo == "power_guard" then
				if imgui.button("Testar: o mod aperta " .. NOME_DO_ALVO[entrada.alvo] .. " por 5 segundos (feche o menu)") then
					entrada.forcar_de = agora() + 4;
					entrada.teste_estado = {};
					entrada.forcar_ate = entrada.forcar_de + 5;
				end
			end

			imgui.tree_pop();
		end

		imgui.tree_pop();
	end

	if estado.mensagem ~= "" then imgui.text(estado.mensagem); end

	imgui.tree_pop();
end);


-- =====================================================================================
-- INICIO
-- =====================================================================================

pcall(carregar_opcoes);
pcall(ligar_pontos_de_escrita);
pcall(carregar_conhecimento);
