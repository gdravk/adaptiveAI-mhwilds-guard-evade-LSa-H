local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.77 - |, q|	Versao 0.78 - APRENDIZADO NOVO (tudo lido no seu proprio jogo, nada pela internet):
	  - CONTATO DO GOLPE: quando o golpe encosta em voce e NAO acerta (esquiva, FS, ISS com
	    invencibilidade), o jogo ainda testa o contato. Agora cada esquiva ensina o tempo do golpe;
	  - AREA DE ATAQUE: o mod ve quando a area de ataque do monstro liga (mesmo errando todo mundo).
	    Quando, numa animacao, a area liga sempre o mesmo tanto antes do golpe chegar (conferido),
	    ela passa a ensinar e a acertar o relogio da previsao na hora;
	  - previsao: golpe repetido (a mesma animacao comecando de novo) agora tambem e previsto;
	  - invencibilidade: mede quando a invencibilidade do FS / esquiva comeca e quanto dura;
	  - FIM DA QUEST / TROCA DE CENA: o mod solta os monstros na hora (travamento no fim da luta);
	  - OUTRAS ARMAS: defesa na hora do golpe para Great Sword, Sword and Shield, Dual Blades,
	    Switch Axe, Charge Blade, Bow, Heavy Bowgun e Light Bowgun;
	  - relatorio com tudo isso
	0.77 - |, "cab");
$s =~ s/versao_mod = "0\.77"/versao_mod = "0.78"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.77 ==/== Defesa Automatica v0.78 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.77"\)/imgui.tree_node("Defesa Automatica v0.78")/ or die "tit";

# ---------------------------------------------------------------- opcoes
troca(q|	barra_desligada = false, -- (0.77) true = a barra de previsao nunca aparece|,
q|	barra_desligada = false, -- (0.77) true = a barra de previsao nunca aparece
	-- (0.78) fontes novas de aprendizado e defesa na hora do golpe (outras armas)
	aprender_por_contato = true,
	aprender_por_ativacao = true,
	defesa_na_hora_ligada = true,
	na_hora_so_sacada = true,
	na_hora = { gs = true, sns = true, db = true, sa = true, cb = true, arco = true, hbg = true, lbg = true },|, "op");

# ---------------------------------------------------------------- fim da quest: nao registra monstros
troca(q|local function conhecer_monstro(contexto)
|, q|local function conhecer_monstro(contexto)
	-- (0.78) fim da quest / troca de cena: nao registra nem atualiza monstros
	if (estado.parar_monstros_ate or 0) > os.clock() then return; end
|, "conhecer");

# ---------------------------------------------------------------- golpe repetido
troca(q|			local id, banco, quadro, fim = animacao_de(m.objeto);
			if id ~= nil then
				m.quadro, m.fim = quadro or 0, fim or 0;
				local animacao = tostring(banco) .. ":" .. tostring(id);

				if animacao ~= m.animacao then|,
q|			local id, banco, quadro, fim = animacao_de(m.objeto);
			if id ~= nil then
				local quadro_antes = m.quadro; -- (0.78)
				m.quadro, m.fim = quadro or 0, fim or 0;
				local animacao = tostring(banco) .. ":" .. tostring(id);

				--[[
					(0.78) GOLPE REPETIDO: a mesma animacao de ataque comecando de novo (o quadro
					voltou para o inicio). Antes o mod so via animacao NOVA quando o nome mudava, e o
					2o golpe igual seguido nao era previsto. So vale para animacoes que tem golpe
					aprendido (as de andar / parado repetem o tempo todo).
				]]
				local reiniciou = animacao == m.animacao and quadro ~= nil and quadro_antes ~= nil
					and quadro + 5 < quadro_antes and momento - (m.animacao_desde or momento) > 0.3
					and grupos_de(m.variante, animacao) ~= nil;
				if reiniciou then estado.reinicios_vistos = (estado.reinicios_vistos or 0) + 1; end

				if animacao ~= m.animacao or reiniciou then|, "reinicio");

# ---------------------------------------------------------------- acompanhar: troca de cena + fila
troca(q|local function acompanhar()
	local momento = agora();
|, q|local function acompanhar()
	local momento = agora();
	pcall(n78.vigiar_troca_de_cena); -- (0.78)
	pcall(n78.processar_ativacoes);  -- (0.78)
|, "acompanhar");

# ---------------------------------------------------------------- bloco novo
troca(q|if funcao_impacto ~= nil then
	pcall(sdk.hook, funcao_impacto, function(argumentos)
		local ok, erro = pcall(ao_impacto, argumentos);
		if not ok then estado.mensagem = "erro impacto: " .. tostring(erro); end
	end, function(retorno)
		return retorno;
	end);
end
|, q|if funcao_impacto ~= nil then
	pcall(sdk.hook, funcao_impacto, function(argumentos)
		local ok, erro = pcall(ao_impacto, argumentos);
		if not ok then estado.mensagem = "erro impacto: " .. tostring(erro); end
	end, function(retorno)
		return retorno;
	end);
end

-- =====================================================================================
-- (0.78) NOVAS FONTES DE APRENDIZADO, FIM DA QUEST E DEFESA NA HORA DO GOLPE
--
-- Tudo aqui e lido no SEU jogo (nada vem pela internet, como os golpes em outros jogadores
-- no SOS, que chegavam atrasados e foram tirados na 0.52).
-- =====================================================================================

local n78 = {}; -- (0.78) o arquivo ja esta no limite de variaveis locais do Lua: tudo da 0.78 fica aqui dentro
(function()
estado.ganchos_078 = {};

local function ponteiro_para_objeto(ponteiro)
	local ok, objeto = pcall(function()
		local valor = sdk.to_valuetype(ponteiro, "System.UInt64");
		local endereco = valor and valor:get_field("m_value");
		if endereco == nil or endereco == 0 then return nil; end
		return sdk.to_managed_object(endereco);
	end);
	return ok and objeto or nil;
end

-- aprende um golpe que chegou em "momento" (pode ser no passado): todas as ultimas animacoes
-- do monstro que comecaram antes dele
local function aprender_golpe_em(m, momento, guarda, contador)
	local usadas = 0;
	for i = #m.historico, 1, -1 do
		local h = m.historico[i];
		local passou = momento - h.inicio;
		if passou >= 0 then
			if passou > AJUSTES.idade_maxima_animacao or usadas >= AJUSTES.animacoes_por_impacto then break; end
			aprender(m.variante, h.chave, passou, guarda or 0, m.distancia or 0);
			usadas = usadas + 1;
		end
	end
	m.ultimo_aprendizado = momento;
	estado[contador] = (estado[contador] or 0) + 1;
end

--[[
	A. INVENCIBILIDADE (esquiva, FS...): o jogo avisa quando ela comeca e de que tipo e.
	Tipos: 0 esquiva rolando, 1 passo, 6 FS, 7 FS vermelho (os outros sao de outras armas).
	A duracao vem do proprio jogo (ja com a skill Evade Window).
]]
local NOMES_INVENCIBILIDADE = { [0] = "esquiva", [1] = "passo", [6] = "FS", [7] = "FS vermelho" };
local invencibilidade = { desde = nil, ate = nil, tipo = nil, stats = {} };

pcall(function()
	local tipo_cacador = sdk.find_type_definition("app.HunterCharacter");
	local metodo = tipo_cacador and tipo_cacador:get_method("beginDodgeNoHit");
	if metodo == nil then return; end
	sdk.hook(metodo, function(args)
		pcall(function()
			local cacador = meu_cacador();
			if cacador == nil or sdk.to_managed_object(args[2]) ~= cacador then return; end
			local tipo = sdk.to_int64(args[3]) & 0xFFFFFFFF;
			local duracao = nil;
			pcall(function() duracao = cacador:call("get_HunterSkill"):call("getDodgeNoHitTime", tipo); end);
			invencibilidade.desde = agora();
			invencibilidade.tipo = tipo;
			invencibilidade.ate = invencibilidade.desde + (tonumber(duracao) or 0.25);
			invencibilidade.duracao = tonumber(duracao);
		end);
	end, function(retorno) return retorno; end);
	estado.ganchos_078.invencibilidade = true;
end);

local function anotar_invencibilidade(momento)
	if invencibilidade.desde == nil or momento > (invencibilidade.ate or 0) + 0.05 or momento < invencibilidade.desde then return; end
	local nome = NOMES_INVENCIBILIDADE[invencibilidade.tipo] or ("tipo " .. tostring(invencibilidade.tipo));
	local s = invencibilidade.stats[nome] or { n = 0, soma = 0, janela = 0 };
	s.n = s.n + 1;
	s.soma = s.soma + (momento - invencibilidade.desde) * 1000;
	s.janela = math.floor((invencibilidade.duracao or 0) * 1000 + 0.5);
	invencibilidade.stats[nome] = s;
end

--[[
	B. CONTATO DO GOLPE. Antes de decidir se um golpe acertou, o jogo testa o CONTATO da area
	de ataque com o corpo (app.HitController.checkHitSuccess). O teste acontece tambem quando
	voce esta invencivel (esquiva, FS, ISS) - so que ai ele "falha". O acerto que passa ja ensina
	pelo caminho de sempre (ao_impacto); aqui entram so os que FALHARAM em voce: as defesas.
	Cuidados (so medicao precisa):
	  - 0,6s depois de um golpe ja aprendido do mesmo monstro, nada (a area continua encostando
	    nos quadros seguintes);
	  - se o monstro ja tem golpe previsto mas o contato veio longe (> 0,3s) de um golpe que o mod
	    conhece bem (5 vezes ou mais), o contato e descartado e so contado no relatorio.
]]
local function contato_falhou(info_ptr, acerto_ptr)
	if not op.aprender or not op.aprender_por_contato then return; end
	local cacador = meu_cacador();
	local meu_objeto = cacador and objeto_de_jogo(cacador);
	if meu_objeto == nil then return; end

	local atacante, alvo, guarda = nil, nil, 0;
	local acerto = acerto_ptr and ponteiro_para_objeto(acerto_ptr);
	if acerto ~= nil then
		pcall(function()
			atacante = acerto:call("getActualAttackOwner");
			alvo = acerto:call("getActualDamageOwner");
		end);
		pcall(function()
			local dados = acerto:call("get_AttackData");
			if dados ~= nil then guarda = dados:get_field("_GuardType") or 0; end
		end);
	end
	if alvo == nil and info_ptr ~= nil then
		pcall(function()
			local info = sdk.to_valuetype(sdk.to_int64(info_ptr) & 0x7FFFFFFFFFFFFFFF, "ace.UNIVERSAL_COLLISION_INFO");
			local a = info:get_field("CollidableA"):call("get_GameObject");
			local b = info:get_field("CollidableB"):call("get_GameObject");
			if b == meu_objeto then atacante, alvo = a, b; elseif a == meu_objeto then atacante, alvo = b, a; end
		end);
	end
	if alvo == nil or alvo ~= meu_objeto or atacante == nil then return; end

	local m = monstro_do_objeto(atacante);
	if m == nil or m.invalido then return; end

	local momento = agora();
	if m.ultimo_aprendizado ~= nil and momento - m.ultimo_aprendizado < 0.6 and momento >= m.ultimo_aprendizado then return; end

	local mais_perto, conhecido = nil, false;
	for _, p in ipairs(m.previstos or {}) do
		local erro = math.abs(momento - p.tempo);
		if mais_perto == nil or erro < mais_perto then mais_perto = erro; end
		if (p.vezes or 0) >= 5 then conhecido = true; end
	end
	if mais_perto ~= nil and mais_perto > 0.3 and conhecido then
		estado.contatos_descartados = (estado.contatos_descartados or 0) + 1;
		m.ultimo_aprendizado = momento; -- os quadros seguintes do mesmo contato tambem nao contam
		return;
	end

	anotar_invencibilidade(momento);
	aprender_golpe_em(m, momento, guarda, "aprendidos_contato");
end

pcall(function()
	local tipo_hit = sdk.find_type_definition("app.HitController");
	local metodo = tipo_hit and tipo_hit:get_method("checkHitSuccess(ace.UNIVERSAL_COLLISION_INFO, app.CollisionFilter.LAYER, app.HitInfo)");
	if metodo == nil then return; end
	sdk.hook(metodo, function(args)
		local guardado = thread.get_hook_storage();
		if guardado == nil then return; end
		if not op.aprender_por_contato then guardado.info_078 = nil; return; end
		guardado.info_078, guardado.acerto_078 = args[3], args[5];
	end, function(retorno)
		local guardado = thread.get_hook_storage();
		if guardado == nil or guardado.info_078 == nil then return retorno; end
		local info_ptr, acerto_ptr = guardado.info_078, guardado.acerto_078;
		guardado.info_078 = nil;
		local passou = false;
		pcall(function() passou = (sdk.to_int64(retorno) & 1) == 1; end);
		if not passou then pcall(contato_falhou, info_ptr, acerto_ptr); end
		return retorno;
	end);
	estado.ganchos_078.contato = true;
end);

--[[
	C. AREA DE ATAQUE LIGANDO (app.ColliderSwitcher.activateAttack): o jogo liga a area de
	ataque do monstro, acertando alguem ou nao. "Ligar" nao e "encostar" (num golpe que anda, a
	area fica ligada um tempo), entao o mod CONFERE antes de usar: para cada animacao ele mede
	quanto tempo depois de a area ligar o golpe chega (pelos golpes ja aprendidos). Quando isso
	e sempre igual (4 medicoes ou mais, variando no maximo 0,08s), a animacao fica CONFIAVEL e:
	  - o relogio do golpe previsto e acertado na hora em que a area liga;
	  - se o golpe errar todo mundo, ele ensina mesmo assim (no tempo conferido).
	Guardado em aviso_lanca_ativacoes.json.
]]
local ativacoes = {};
pcall(function()
	local salvo = json.load_file("aviso_lanca_ativacoes.json");
	if type(salvo) == "table" then ativacoes = salvo; end
end);
local ativacoes_mudou, ativacoes_salvo_em = false, 0;
local fila_ativacoes, golpes_pendentes = {}, {};

pcall(function()
	local tipo_sw = sdk.find_type_definition("app.ColliderSwitcher");
	local metodo = tipo_sw and tipo_sw:get_method("activateAttack(System.Boolean, System.UInt32, System.UInt32, System.Nullable`1<System.Boolean>, app.Hit.HIT_ID_GROUP, System.Nullable`1<System.Single>, System.Nullable`1<System.Single>)");
	if metodo == nil then return; end
	sdk.hook(metodo, function(args)
		if not op.aprender_por_ativacao then return; end
		pcall(function()
			if (sdk.to_int64(args[3]) & 1) ~= 1 then return; end
			local sw = sdk.to_managed_object(args[2]);
			if sw == nil then return; end
			local dono = sw:get_field("_HitController"):call("get_Owner");
			local m = monstro_do_objeto(dono);
			if m == nil or m.invalido then return; end
			local momento = agora();
			if m.ultima_ativacao ~= nil and momento - m.ultima_ativacao < 0.1 then return; end
			m.ultima_ativacao = momento;
			fila_ativacoes[#fila_ativacoes + 1] = {
				m = m, em = momento, rsc = sw:get_field("_RequestSetCollider"),
				res = sdk.to_int64(args[4]) & 0xFFFFFFFF, req = sdk.to_int64(args[5]) & 0xFFFFFFFF
			};
		end);
	end, function(retorno) return retorno; end);
	estado.ganchos_078.ativacao = true;
end);

-- dados do golpe (forca e tipo de guarda) da primeira area ligada
local function dados_da_area(a)
	local ataque, guarda = nil, 0;
	pcall(function()
		local col = a.rsc:call("getCollidable", a.res, a.req, 0);
		local dados = col and col:call("get_UserData");
		dados = dados and dados:call("get_ParentUserData");
		if dados ~= nil and dados:get_type_definition():is_a("app.col_user_data.AttackParamEm") then
			ataque = dados:get_field("_Attack");
			guarda = dados:call("get_GuardType") or 0;
		end
	end);
	return ataque, guarda;
end

local function area_confiavel(reg)
	local d = reg and reg.d;
	if d == nil or #d < 4 then return nil; end
	local menor, maior = math.huge, -math.huge;
	local copia = {};
	for _, v in ipairs(d) do
		if v < menor then menor = v; end
		if v > maior then maior = v; end
		copia[#copia + 1] = v;
	end
	if maior - menor > 0.08 then return nil; end
	table.sort(copia);
	return copia[math.floor((#copia + 1) / 2)];
end

local function processar_ativacoes()
	local momento = agora();

	-- golpes que ligaram a area numa animacao confiavel: se ninguem aprendeu, ensina agora
	local restantes = {};
	for _, g in ipairs(golpes_pendentes) do
		if momento < g.impacto + 0.6 then
			restantes[#restantes + 1] = g;
		elseif op.aprender and not g.m.invalido and not (g.m.ultimo_aprendizado ~= nil
			and math.abs(g.m.ultimo_aprendizado - g.impacto) < 0.35) then
			aprender_golpe_em(g.m, g.impacto, g.guarda, "aprendidos_ativacao");
		end
	end
	golpes_pendentes = restantes;

	local fila = fila_ativacoes;
	fila_ativacoes = {};
	for _, a in ipairs(fila) do
		local m = a.m;
		local ataque, guarda = dados_da_area(a);
		if not m.invalido and (ataque == nil or ataque > 0) then
			estado.ativacoes_vistas = (estado.ativacoes_vistas or 0) + 1;
			ativacoes[m.variante] = ativacoes[m.variante] or {};
			local agendado = false;
			local usadas = 0;
			for i = #m.historico, 1, -1 do
				local h = m.historico[i];
				local ofs = a.em - h.inicio;
				if ofs >= 0 then
					if ofs > AJUSTES.idade_maxima_animacao or usadas >= AJUSTES.animacoes_por_impacto then break; end
					usadas = usadas + 1;
					local reg = ativacoes[m.variante][h.chave] or { n = 0, d = {} };
					ativacoes[m.variante][h.chave] = reg;
					reg.n = reg.n + 1;
					-- confere com os golpes ja aprendidos desta animacao
					local melhor = nil;
					for _, g in ipairs(grupos_de(m.variante, h.chave) or {}) do
						local dif = g.tempo - ofs;
						if g.vezes >= 3 and dif >= -0.05 and dif <= 0.6 and (melhor == nil or math.abs(dif) < math.abs(melhor)) then
							melhor = dif;
						end
					end
					if melhor ~= nil then
						reg.d[#reg.d + 1] = arredondar(melhor, 3);
						while #reg.d > 20 do table.remove(reg.d, 1); end
					end
					ativacoes_mudou = true;

					local d = area_confiavel(reg);
					if d ~= nil and not agendado then
						agendado = true;
						local impacto = a.em + d;
						-- acerta o relogio do golpe previsto
						for _, p in ipairs(m.previstos or {}) do
							if math.abs(p.tempo - impacto) <= 0.2 then
								p.tempo = impacto;
								if (RESTRICAO[guarda] or 0) > (RESTRICAO[p.guarda] or 0) then p.guarda = guarda; end
								estado.relogios_acertados = (estado.relogios_acertados or 0) + 1;
								break;
							end
						end
						golpes_pendentes[#golpes_pendentes + 1] = { m = m, impacto = impacto, guarda = guarda };
					end
				end
			end
		end
	end

	if ativacoes_mudou and os.clock() - ativacoes_salvo_em > 20 then
		ativacoes_mudou, ativacoes_salvo_em = false, os.clock();
		pcall(json.dump_file, "aviso_lanca_ativacoes.json", ativacoes);
	end
end

-- resumo das areas de ataque (relatorio)
local function resumo_ativacoes(variante)
	local vistas, confiaveis, so_area = 0, 0, 0;
	for chave_v, por_anim in pairs(ativacoes) do
		if variante == nil or chave_v == variante then
			for anim, reg in pairs(por_anim) do
				if reg.n >= 3 then
					vistas = vistas + 1;
					if area_confiavel(reg) ~= nil then confiaveis = confiaveis + 1; end
					if grupos_de(chave_v, anim) == nil then so_area = so_area + 1; end
				end
			end
		end
	end
	return vistas, confiaveis, so_area;
end

--[[
	D. FIM DA QUEST E TROCA DE CENA. O jogo avisa quando a quest acaba (qualquer resultado) e
	quando a cena vai trocar. Nesses momentos o mod solta TODOS os monstros na hora (nao chama
	mais nada neles) e nao registra monstros por alguns segundos - era chamando funcoes em
	monstros sendo destruidos que o jogo travava no fim da luta.
]]
local function soltar_monstros(segundos, motivo)
	estado.parar_monstros_ate = math.max(estado.parar_monstros_ate or 0, os.clock() + segundos);
	for _, m in pairs(monstros) do
		m.invalido = true;
		m.previstos = {};
	end
	golpes_pendentes, fila_ativacoes = {}, {};
	if motivo ~= nil then
		estado.solturas = estado.solturas or {};
		estado.solturas[motivo] = (estado.solturas[motivo] or 0) + 1;
	end
end

for _, gancho in ipairs({ { "app.cQuestPlaying", "exit()" }, { "app.cQuestReward", "enter()" } }) do
	pcall(function()
		local tipo = sdk.find_type_definition(gancho[1]);
		local metodo = tipo and (tipo:get_method(gancho[2]) or tipo:get_method(string.gsub(gancho[2], "%(%)", "")));
		if metodo == nil then return; end
		sdk.hook(metodo, function(args)
			pcall(soltar_monstros, 15, "fim da quest");
		end, function(retorno) return retorno; end);
		estado.ganchos_078.fim_quest = true;
	end);
end

local function vigiar_troca_de_cena()
	local ok, proximo = pcall(function()
		local fluxo = sdk.get_managed_singleton("app.GameFlowManager");
		return fluxo and fluxo:call("get_NextGameStateType");
	end);
	if ok and proximo ~= nil then
		if not estado.trocando_cena then soltar_monstros(3, "troca de cena"); end
		estado.trocando_cena = true;
		estado.parar_monstros_ate = math.max(estado.parar_monstros_ate or 0, os.clock() + 3);
	else
		estado.trocando_cena = false;
	end
end

--[[
	E. OUTRAS ARMAS: DEFESA NA HORA DO GOLPE. Para as armas abaixo o jogo aceita que a defesa
	seja pedida no instante em que o golpe chega no cacador: o mod pede a acao (guarda perfeita,
	esquiva...) e o golpe e tratado como defendido. Nao depende de previsao, entao funciona ate
	em golpes que o mod nunca viu. Nao age se voce ja esta invencivel / guardando (o jogo
	resolve sozinho), montado, ou (opcao) com a arma guardada.
	Tipo da arma (get_WeaponType): 0 GS, 1 SnS, 2 DB, 8 SA, 9 CB, 11 Bow, 12 HBG, 13 LBG.
	Sem dados para: Hammer (4), Hunting Horn (5), Lance (6), Gunlance (7), Insect Glaive (10);
	a Long Sword (3) continua com o FS / SS+ISS do mod.
]]
local ARMAS_NA_HORA = {
	[0] = { chave = "gs", nome = "Great Sword", defesa = "guarda" },
	[1] = { chave = "sns", nome = "Sword and Shield", defesa = "guarda" },
	[2] = { chave = "db", nome = "Dual Blades", defesa = "esquiva_db" },
	[8] = { chave = "sa", nome = "Switch Axe", defesa = "contra_sa" },
	[9] = { chave = "cb", nome = "Charge Blade", defesa = "guarda" },
	[11] = { chave = "arco", nome = "Bow", defesa = "esquiva_arco" },
	[12] = { chave = "hbg", nome = "Heavy Bowgun", defesa = "guarda" },
	[13] = { chave = "lbg", nome = "Light Bowgun", defesa = "esquiva" }
};
local ORDEM_ARMAS_NA_HORA = { 0, 1, 2, 8, 9, 11, 12, 13 };
local tipo_id_acao = sdk.find_type_definition("ace.ACTION_ID");
local na_hora_ultima = 0;

local function pedir_acao(cacador, categoria, indice)
	local ok, controle = pcall(function() return cacador:call("get_BaseActionController"); end);
	if not ok or controle == nil then return false; end
	if tipo_id_acao ~= nil then
		local feito = pcall(function()
			local id = ValueType.new(tipo_id_acao);
			id._Category = categoria;
			id._Index = indice;
			controle:call("changeActionRequest(ace.ACTION_ID)", id);
		end);
		if feito then return true; end
	end
	return pcall(function() controle:call("changeActionRequest(System.Int32,System.Int32)", categoria, indice); end);
end

-- a arma desta defesa esta ligada e o cacador pode defender agora?
local function arma_na_hora(cacador)
	if not op.defesa_na_hora_ligada then return nil; end
	local ok_t, tipo = pcall(function() return cacador:call("get_WeaponType"); end);
	local def = ok_t and ARMAS_NA_HORA[tonumber(tipo) or -1] or nil;
	if def == nil or (op.na_hora or {})[def.chave] == false then return nil; end
	local montado = false;
	pcall(function() montado = cacador:call("get_IsPorterRiding") == true; end);
	if montado then return nil; end
	if op.na_hora_so_sacada then
		local sacada = true;
		pcall(function() sacada = cacador:call("get_IsWeaponOn") == true; end);
		if not sacada then return nil; end
	end
	if os.clock() - na_hora_ultima < 0.3 then return nil; end
	return def;
end

local function ja_protegido(cacador)
	local protegido = false;
	pcall(function()
		local seq = cacador:get_field("_HunterMotionSupporter"):get_field("_BaseBasicMotionSeq");
		protegido = seq:get_field("_NoHit") == true;
	end);
	if protegido then return true; end
	pcall(function()
		local flags = cacador:call("get_HunterStatus"):get_field("_HunterStatusFlag");
		for _, f in ipairs({ 2, 3, 4 }) do -- GUARD, POWER_GUARD, TECHNICAL_GUARD
			if flags:call("check(System.UInt32)", f) == true then protegido = true; end
		end
	end);
	return protegido;
end

local function contar_na_hora(nome)
	estado.na_hora_contagem = estado.na_hora_contagem or {};
	estado.na_hora_contagem[nome] = (estado.na_hora_contagem[nome] or 0) + 1;
end

local function defesa_na_hora(args)
	local cacador = meu_cacador();
	if cacador == nil then return nil; end
	local alvo = sdk.to_managed_object(args[2]);
	if alvo == nil or alvo:call("get_IsMaster") ~= true then return nil; end
	local def = arma_na_hora(cacador);
	if def == nil or def.defesa == "contra_sa" then return nil; end

	local acerto = sdk.to_managed_object(args[3]);
	local dono = acerto and acerto:get_field("<AttackOwner>k__BackingField");
	local etiqueta = dono and dono:call("get_Tag");
	if type(etiqueta) ~= "string" or not string.find(etiqueta, "Enemy", 1, true) then return nil; end
	if ja_protegido(cacador) then return nil; end

	na_hora_ultima = os.clock();
	if def.defesa == "guarda" then
		pcall(function() cacador:call("startNoHitTimer(System.Single)", 0.25); end);
		pedir_acao(cacador, 1, 146);
	elseif def.defesa == "esquiva" then
		pedir_acao(cacador, 1, 19);
	elseif def.defesa == "esquiva_arco" then
		pedir_acao(cacador, 2, 9);
	elseif def.defesa == "esquiva_db" then
		pedir_acao(cacador, 2, 53);
		pedir_acao(cacador, 2, 47);
	end
	contar_na_hora(def.nome);
	return sdk.PreHookResult.SKIP_ORIGINAL;
end

pcall(function()
	local tipo_cacador = sdk.find_type_definition("app.HunterCharacter");
	local metodo = tipo_cacador and tipo_cacador:get_method("evHit_Damage");
	if metodo == nil then return; end
	sdk.hook(metodo, function(args)
		local ok, resultado = pcall(defesa_na_hora, args);
		if ok and resultado ~= nil then return resultado; end
	end, function(retorno) return retorno; end);
	estado.ganchos_078.na_hora = true;
end);

-- Switch Axe: contra-ataque (espada) / offset (machado) no instante do golpe
local function contra_sa(args)
	local cacador = meu_cacador();
	if cacador == nil then return; end
	local def = arma_na_hora(cacador);
	if def == nil or def.defesa ~= "contra_sa" then return; end
	local acerto = sdk.to_managed_object(args[3]);
	if acerto == nil then return; end
	local dono_dano = acerto:get_field("<DamageOwner>k__BackingField");
	if dono_dano == nil or dono_dano:call("get_Name") ~= "MasterPlayer" then return; end
	local dono = acerto:get_field("<AttackOwner>k__BackingField");
	local etiqueta = dono and dono:call("get_Tag");
	if type(etiqueta) ~= "string" or not string.find(etiqueta, "Enemy", 1, true) or string.find(etiqueta, "Shell", 1, true) then return; end
	local dados = acerto:get_field("<AttackData>k__BackingField");
	local forca = dados and dados:get_field("_Attack");
	if type(forca) ~= "number" or forca <= 0 then return; end
	if ja_protegido(cacador) then return; end

	local espada = false;
	pcall(function() espada = cacador:call("get_WeaponHandling"):get_field("_Mode") == 1; end);
	na_hora_ultima = os.clock();
	pcall(function()
		acerto:set_field("<CollisionLayer>k__BackingField", 18);
		local parametro = sdk.create_instance("app.cAttackParamPl", true);
		acerto:call("set_DamageAttackData", parametro);
		local dano = acerto:get_field("<DamageAttackData>k__BackingField");
		dano:set_field("_HitEffectType", 18);
		dano:set_field("_ParryDamage", espada and 600 or 150);
		dano:set_field("_HitEffectOverwriteConnectID", -1);
	end);
	pcall(function() cacador:call("startNoHitTimer(System.Single)", 0.4); end);
	if espada then
		pedir_acao(cacador, 2, 54);
		pedir_acao(cacador, 2, 31);
	else
		pedir_acao(cacador, 2, 5);
	end
	contar_na_hora(def.nome);
end

if funcao_impacto ~= nil then
	pcall(sdk.hook, funcao_impacto, function(argumentos)
		pcall(contra_sa, argumentos);
	end, function(retorno) return retorno; end);
end

n78.processar_ativacoes = processar_ativacoes;
n78.vigiar_troca_de_cena = vigiar_troca_de_cena;
n78.resumo_ativacoes = resumo_ativacoes;
n78.invencibilidade = invencibilidade;
n78.ARMAS = ARMAS_NA_HORA;
n78.ORDEM = ORDEM_ARMAS_NA_HORA;
end)();
|, "bloco");


# ---------------------------------------------------------------- relatorio
troca(q|	if estado.mensagem ~= "" then linha("Mensagem: " .. estado.mensagem); end
end|, q|	-- (0.78) fontes novas de aprendizado, invencibilidade, outras armas, fim da quest
	local g78 = estado.ganchos_078 or {};
	local vistas_a, conf_a, so_area = n78.resumo_ativacoes(nil);
	linha(string.format("Aprendizado novo: por contato (esquivas / FS / ISS) %d - contatos descartados %d - pela area de ataque %d (areas vistas %d, relogios acertados %d) - golpes repetidos vistos %d",
		estado.aprendidos_contato or 0, estado.contatos_descartados or 0, estado.aprendidos_ativacao or 0,
		estado.ativacoes_vistas or 0, estado.relogios_acertados or 0, estado.reinicios_vistos or 0));
	linha(string.format("Area de ataque: %d animacoes com area vista, %d confiaveis, %d so com area (golpe nunca chegou em ninguem) - ganchos: contato %s, area %s, invencibilidade %s, fim da quest %s, defesa na hora %s",
		vistas_a, conf_a, so_area, g78.contato and "ok" or "NAO", g78.ativacao and "ok" or "NAO",
		g78.invencibilidade and "ok" or "NAO", g78.fim_quest and "ok" or "NAO", g78.na_hora and "ok" or "NAO"));
	local inv_txt = {};
	for nome, s in pairs(n78.invencibilidade.stats) do
		inv_txt[#inv_txt + 1] = string.format("%s: %d golpes, chegaram em media %d ms depois do inicio (invencibilidade de %d ms)",
			nome, s.n, math.floor(s.soma / math.max(1, s.n) + 0.5), s.janela);
	end
	linha("Invencibilidade: " .. (#inv_txt > 0 and table.concat(inv_txt, " - ") or "nenhum golpe pego na invencibilidade ainda"));
	local nh_txt = {};
	for nome, n in pairs(estado.na_hora_contagem or {}) do nh_txt[#nh_txt + 1] = nome .. " " .. n; end
	linha("Defesa na hora do golpe (outras armas): " .. (#nh_txt > 0 and table.concat(nh_txt, ", ") or "nenhuma nesta sessao"));
	local so_txt = {};
	for motivo, n in pairs(estado.solturas or {}) do so_txt[#so_txt + 1] = motivo .. " " .. n; end
	linha("Monstros soltos (fim da quest / troca de cena): " .. (#so_txt > 0 and table.concat(so_txt, ", ") or "nenhuma vez"));

	if estado.mensagem ~= "" then linha("Mensagem: " .. estado.mensagem); end
end|, "prints");

# ---------------------------------------------------------------- menu
troca(q|	pcall(imgui.set_next_item_open, true, 4); -- (0.77) aberta na primeira vez (se o REFramework tiver)|,
q|	-- (0.78) aprendizado novo e defesa na hora do golpe das outras armas
	if imgui.tree_node("Aprendizado e outras armas") then
		local mudou_78, m78 = false, false;
		m78, op.aprender_por_contato = imgui.checkbox("Aprender pelo contato do golpe (esquivas, FS, ISS)", op.aprender_por_contato);
		mudou_78 = mudou_78 or m78;
		m78, op.aprender_por_ativacao = imgui.checkbox("Aprender pela area de ataque do monstro (so animacoes conferidas)", op.aprender_por_ativacao);
		mudou_78 = mudou_78 or m78;
		m78, op.defesa_na_hora_ligada = imgui.checkbox("Outras armas: defesa na hora do golpe", op.defesa_na_hora_ligada);
		mudou_78 = mudou_78 or m78;
		m78, op.na_hora_so_sacada = imgui.checkbox("... so com a arma sacada", op.na_hora_so_sacada);
		mudou_78 = mudou_78 or m78;
		op.na_hora = op.na_hora or {};
		for _, tipo in ipairs(n78.ORDEM) do
			local def = n78.ARMAS[tipo];
			local ligado = op.na_hora[def.chave] ~= false;
			m78, ligado = imgui.checkbox("   " .. def.nome, ligado);
			if m78 then op.na_hora[def.chave] = ligado; mudou_78 = true; end
		end
		imgui.text("Sem dados ainda: Hammer, Hunting Horn, Lance, Gunlance, Insect Glaive (Long Sword usa FS / SS+ISS)");
		if mudou_78 then salvar_opcoes(); end
		imgui.tree_pop();
	end

	pcall(imgui.set_next_item_open, true, 4); -- (0.77) aberta na primeira vez (se o REFramework tiver)|, "menu");

print $s;
