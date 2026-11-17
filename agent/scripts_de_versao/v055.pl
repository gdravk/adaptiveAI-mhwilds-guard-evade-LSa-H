local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.54 - |, q|	Versao 0.55 - Long Sword: LEITURA DO SS+ISS (Special Sheathe + Iai Spirit Slash). Com a leitura
	ligada o mod nao defende: so le, quadro a quadro, os seus SS+ISS manuais (botoes, buffer, suas
	animacoes, golpes do monstro, dano e contra-ataque do ISS) e salva um arquivo por SS+ISS
	0.54 - |, "cab");
$s =~ s/versao_mod = "0\.54"/versao_mod = "0.55"/ or die "vm";
$s =~ s/== Defesa Automatica v0\.54 ==/== Defesa Automatica v0.55 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.54"\)/imgui.tree_node("Defesa Automatica v0.55")/ or die "tit";

# 1. a defesa fica parada durante a leitura (como no M4)
troca(q|	decidir_botoes();

	-- toque gravado em andamento|, q|	-- (0.55) LEITURA DO SS+ISS: o mod nao aperta nada (para ler so os SEUS apertos)
	if estado.leitura_ss_iss and estado.perfil == PERFIS.espada_longa then
		toque.quadro = nil;
		estado.bloquear_acoes_ate = nil;
		estado.motivo_parado = "leitura do SS+ISS (so lendo os seus apertos)";
		preparar_escrita();
		estado.escreveu = false;
		return;
	end

	decidir_botoes();

	-- toque gravado em andamento|, "pausa");

# 2. o leitor
troca(q|local salvar_relatorio; -- (0.44) definido depois da aba Prints|, q|--[[
	(0.55) LEITURA DO SS+ISS (Special Sheathe + Iai Spirit Slash)
	Em vez de testar o Iai as cegas (nas versoes 0.33 a 0.40 ele nunca saiu), o mod LE os seus
	SS+ISS feitos na mao. Com a leitura ligada (menu, so na Long Sword) e a espada sacada:
	  - a cada quadro anota os campos dos seus botoes (M1, M2, M5, Espaco e M4: estado do botao
	    e buffer de entrada), a sua animacao, o monstro mais perto (animacao, distancia, quanto
	    falta para o proximo golpe previsto), golpes em voce, dano e os sinais da espada
	    (contra-ataque do ISS deu certo, ISS acertou...);
	  - guarda sempre os ultimos 1,5s. Quando voce aperta M5 + Espaco juntos (o SS), comeca uma
	    leitura com esse 1,5s de antes e continua ate 4s depois do seu ultimo M5 (o ISS), no
	    maximo 12s;
	  - salva em reframework/data/aviso_lanca_prints/ss_iss_<data>_<N>.json (pasta Prints).
	Com isso da para montar o SS e o ISS como toques gravados de verdade (com o buffer), como foi
	feito com o FS na 0.42, e saber o tempo certo do ISS em relacao ao golpe do monstro.
]]
local leitura = {
	campos = nil, campos_em = -100, -- lista dos campos lidos { t, l, c } (refeita a cada 5s)
	anterior = {},                  -- valores do quadro anterior (para anotar so o que mudou)
	ultimos = {},                   -- os ultimos quadros (1,5s), antes de o SS comecar
	atual = nil,                    -- leitura em andamento
	salvas = 0, ultima = nil,
	m5_em = -100, espaco_em = -100,
	sinais = {}, eventos = {},
	dano_visto = nil, impacto_visto = nil
};

local SINAIS_ESPADA = { "IsIaiKijinMikiriSuccessed", "IsIaiKijinSlashHitted", "IsIaiSlashHitted",
	"IsRedIaiKijinHitted", "IsMikiriSuccessed", "IsMikiriHitSuccessed" };

-- o contra-ataque do ISS deu certo (funcao do jogo)
local iss_certo = tipo_espada_longa and tipo_espada_longa:get_method("doOnIaiKijinMikiriSuccessed");
if iss_certo ~= nil then
	pcall(sdk.hook, iss_certo, function(args)
		pcall(function()
			if not estado.leitura_ss_iss then return; end
			local cacador = meu_cacador();
			local minha_arma = cacador and cacador:call("get_WeaponHandling");
			if minha_arma == nil or sdk.to_int64(args[2]) ~= minha_arma:get_address() then return; end
			leitura.eventos[#leitura.eventos + 1] = "ISS: CONTRA-ATAQUE DEU CERTO";
		end);
	end, function(retorno) return retorno; end);
end

-- campos lidos: os mesmos que mudaram nas suas gravacoes (M5, M2, Espaco, M4) + estado de
-- todos os comandos dos grupos de botoes
local function campos_da_leitura()
	if leitura.campos ~= nil and os.clock() - leitura.campos_em < 5 then return leitura.campos; end
	local lista, vistos = {}, {};
	local function por(t, l, c)
		local chave = tostring(t) .. (l and "L" or "") .. c;
		if not vistos[chave] then vistos[chave] = true; lista[#lista + 1] = { t = t, l = l, c = c }; end
	end
	for _, quadros in pairs(op.toques or {}) do
		for _, itens in ipairs(quadros) do
			for _, item in ipairs(itens) do por(item.t, item.l == true, item.c); end
		end
	end
	local comandos = {};
	for _, grupo in pairs(GRUPOS_DE_BOTOES) do for _, n in ipairs(grupo) do comandos[#comandos + 1] = n; end end
	for _, n in ipairs(comandos_do_m4()) do comandos[#comandos + 1] = n; end
	for _, n in ipairs(comandos) do
		for _, c in ipairs({ "_On", "_RawOn", "_OnTrigger", "_OffTrigger", "_Repeat" }) do por(n, false, c); end
		por(n, true, "_LagFrameCounter");
		por(n, true, "_LagTimer");
	end
	leitura.campos, leitura.campos_em = lista, os.clock();
	return lista;
end

local function texto_valor(v)
	if type(v) == "number" then
		if v == math.floor(v) then return tostring(math.floor(v)); end
		return string.format("%.3f", v);
	end
	return tostring(v);
end

-- qual botao (grupo) cada comando e
local GRUPO_DO_COMANDO = {};
for nome_grupo, grupo in pairs(GRUPOS_DE_BOTOES) do for _, n in ipairs(grupo) do GRUPO_DO_COMANDO[n] = nome_grupo; end end

local function ler_ss_iss()
	if not estado.leitura_ss_iss or estado.perfil ~= PERFIS.espada_longa then
		leitura.ultimos, leitura.anterior = {}, {};
		return;
	end
	local cacador = meu_cacador();
	if cacador == nil then return; end
	local momento = agora();

	-- 1. botoes: o que mudou desde o quadro anterior
	local mudou, apertados, soltos_agora = {}, {}, {};
	local campos = campos_da_leitura();
	for _, entrada_jogador in ipairs(entradas_ativas()) do
		local teclas = entrada_jogador:get_field("_Keys");
		if teclas ~= nil then
			for _, item in ipairs(campos) do
				local ok, valor = pcall(function()
					local alvo = teclas:get_element(item.t);
					if alvo ~= nil and item.l then
						local buffer = alvo:get_field("<LagWorker>k__BackingField");
						alvo = buffer and buffer:get_element(0);
					end
					return alvo and alvo:get_field(item.c);
				end);
				if ok and valor ~= nil then
					local chave = tostring(item.t) .. (item.l and ".buffer." or ".") .. item.c;
					local texto = texto_valor(valor);
					if leitura.anterior[chave] ~= texto then
						mudou[#mudou + 1] = chave .. "=" .. texto;
						leitura.anterior[chave] = texto;
					end
					if item.c == "_OnTrigger" and not item.l and valor == true then
						apertados[GRUPO_DO_COMANDO[item.t] or ("cmd" .. item.t)] = true;
					end
					if item.c == "_On" and not item.l and valor == true then
						soltos_agora[GRUPO_DO_COMANDO[item.t] or ("cmd" .. item.t)] = true;
					end
				end
			end
		end
	end

	-- M5 = comandos 15 e 22 (grupo m2_m5 junta M2 e M5: separa pelo numero)
	local m5_agora, espaco_agora = false, false;
	pcall(function()
		for _, entrada_jogador in ipairs(entradas_ativas()) do
			local teclas = entrada_jogador:get_field("_Keys");
			for _, n in ipairs({ 15, 22 }) do
				local tecla = teclas and teclas:get_element(n);
				if tecla ~= nil and tecla:get_field("_OnTrigger") == true then m5_agora = true; end
			end
			for _, n in ipairs(GRUPOS_DE_BOTOES.espaco or {}) do
				local tecla = teclas and teclas:get_element(n);
				if tecla ~= nil and tecla:get_field("_OnTrigger") == true then espaco_agora = true; end
			end
		end
	end);
	if m5_agora then leitura.m5_em = momento; end
	if espaco_agora then leitura.espaco_em = momento; end

	-- 2. sinais da espada (o que mudou)
	local eventos = leitura.eventos;
	leitura.eventos = {};
	pcall(function()
		local arma = cacador:call("get_WeaponHandling");
		for _, nome in ipairs(SINAIS_ESPADA) do
			local v = arma and arma:get_field(nome);
			if v ~= nil and leitura.sinais[nome] ~= v then
				if leitura.sinais[nome] ~= nil or v == true then eventos[#eventos + 1] = nome .. "=" .. tostring(v); end
				leitura.sinais[nome] = v;
			end
		end
	end);
	if estado.levou_dano_em ~= leitura.dano_visto then
		if leitura.dano_visto ~= nil then eventos[#eventos + 1] = "LEVOU DANO"; end
		leitura.dano_visto = estado.levou_dano_em;
	end
	if estado.ultimo_impacto_em ~= leitura.impacto_visto then
		if leitura.impacto_visto ~= nil then eventos[#eventos + 1] = "golpe do monstro em voce"; end
		leitura.impacto_visto = estado.ultimo_impacto_em;
	end

	-- 3. sua animacao e o monstro mais perto
	local objeto_cacador = objeto_de_jogo(cacador);
	local id_c, banco_c, quadro_c = animacao_de(objeto_cacador);
	local perto, falta = nil, nil;
	for _, m in pairs(monstros) do
		if not m.invalido and m.distancia ~= nil and (perto == nil or m.distancia < perto.distancia) then perto = m; end
	end
	if perto ~= nil then
		for _, p in ipairs(perto.previstos or {}) do
			local f = p.tempo - momento;
			if f > -0.3 and (falta == nil or f < falta) then falta = f; end
		end
	end

	local quadro = {
		a = tostring(banco_c) .. ":" .. tostring(id_c), q = quadro_c and math.floor(quadro_c) or nil,
		arma = cacador:call("get_IsWeaponOn") == true,
		m = perto and perto.animacao or nil, dist = perto and perto.distancia and arredondar(perto.distancia, 1) or nil,
		golpe_em_ms = falta and math.floor(falta * 1000 + 0.5) or nil,
		apertou = next(apertados) and apertados or nil, segura = next(soltos_agora) and soltos_agora or nil,
		mudou = #mudou > 0 and mudou or nil, ev = #eventos > 0 and eventos or nil,
		_em = momento
	};

	-- 4. comeca / continua / termina a leitura
	local ss = m5_agora and espaco_agora
		or (m5_agora and momento - leitura.espaco_em < 0.15) or (espaco_agora and momento - leitura.m5_em < 0.15);
	local atual = leitura.atual;
	if atual == nil then
		leitura.ultimos[#leitura.ultimos + 1] = quadro;
		while #leitura.ultimos > 0 and momento - leitura.ultimos[1]._em > 1.5 do table.remove(leitura.ultimos, 1); end
		if ss then
			atual = { inicio = momento, quadros = leitura.ultimos, fim = momento + 4,
				monstro = perto and perto.nome_completo or nil };
			leitura.atual, leitura.ultimos = atual, {};
		end
		return;
	end
	atual.quadros[#atual.quadros + 1] = quadro;
	if m5_agora then atual.fim = math.max(atual.fim, momento + 4); end
	if momento < atual.fim and momento - atual.inicio < 12 then return; end

	-- 5. salva (tempos em ms a partir do SS)
	leitura.atual = nil;
	local resumo = { apertos = {}, suas_animacoes = {}, monstro_animacoes = {}, eventos = {} };
	local anim_c, anim_m = nil, nil;
	local m5_iss = nil;
	for _, q in ipairs(atual.quadros) do
		q.t = math.floor((q._em - atual.inicio) * 1000 + 0.5);
		q._em = nil;
		for botao in pairs(q.apertou or {}) do resumo.apertos[#resumo.apertos + 1] = string.format("%d ms: %s", q.t, botao); end
		if q.a ~= anim_c then anim_c = q.a; resumo.suas_animacoes[#resumo.suas_animacoes + 1] = string.format("%d ms: %s", q.t, q.a); end
		if q.m ~= anim_m then
			anim_m = q.m;
			resumo.monstro_animacoes[#resumo.monstro_animacoes + 1] = string.format("%d ms: %s (proximo golpe previsto em %s ms)",
				q.t, tostring(q.m), tostring(q.golpe_em_ms));
		end
		for _, e in ipairs(q.ev or {}) do
			resumo.eventos[#resumo.eventos + 1] = string.format("%d ms: %s", q.t, e);
			if e == "ISS: CONTRA-ATAQUE DEU CERTO" then resumo.iss_deu_certo = true; end
			if e == "LEVOU DANO" then resumo.levou_dano = true; end
		end
	end

	leitura.salvas = leitura.salvas + 1;
	local ok_nome, nome = pcall(os.date, "%Y-%m-%d_%H-%M-%S");
	local arquivo = string.format("aviso_lanca_prints/ss_iss_%s_%d.json", ok_nome and nome or "x", leitura.salvas);
	json.dump_file(arquivo, {
		versao_mod = "0.55", monstro = atual.monstro, ss_em_ms = 0,
		explicacao = "t = ms desde o SS (M5 + Espaco). a = sua animacao (banco:id), q = quadro dela. m = animacao do monstro mais perto, golpe_em_ms = quanto faltava para o proximo golpe previsto. mudou = campos dos botoes que mudaram (comando.campo=valor; buffer = buffer de entrada). apertou = botao apertado neste quadro. ev = eventos.",
		resumo = resumo, quadros = atual.quadros
	});
	leitura.ultima = string.format("%s - %s%s - %d quadros", arquivo, resumo.iss_deu_certo and "ISS deu certo" or "sem contra-ataque do ISS",
		resumo.levou_dano and ", levou dano" or "", #atual.quadros);
	estado.mensagem = "Leitura do SS+ISS salva: " .. arquivo;
end

local salvar_relatorio; -- (0.44) definido depois da aba Prints|, "leitor");

troca(q|	pcall(desenhar_aviso);
|, q|	pcall(desenhar_aviso);

	local ok_leitura, erro_leitura = pcall(ler_ss_iss);
	if not ok_leitura then estado.mensagem = "erro leitura SS+ISS: " .. tostring(erro_leitura); end
|, "frame");

# 3. Prints
troca(q|			bloqueios_ls[combo.animacao or "?"] or op.ls_bloqueio_ms, qtd_bloqueios, maior));
	end|, q|			bloqueios_ls[combo.animacao or "?"] or op.ls_bloqueio_ms, qtd_bloqueios, maior));
		linha(string.format("Leitura do SS+ISS: %s - %d leituras salvas nesta sessao%s",
			estado.leitura_ss_iss and (leitura.atual and "LENDO AGORA" or "ligada") or "desligada", leitura.salvas,
			leitura.ultima and (" - ultima: " .. leitura.ultima) or ""));
	end|, "prints");

# 4. menu (so na Long Sword; nao fica salvo: desliga sozinha ao reabrir o jogo)
troca(q|	if alterou_simples then salvar_opcoes(); end
|, q|	if alterou_simples then salvar_opcoes(); end

	if estado.perfil == PERFIS.espada_longa then
		local _;
		_, estado.leitura_ss_iss = imgui.checkbox("Leitura do SS+ISS (o mod NAO defende, so le os seus SS+ISS)", estado.leitura_ss_iss == true);
		if estado.leitura_ss_iss then
			imgui.text(string.format("  %s - %d leituras salvas (pasta Prints)", leitura.atual and "LENDO AGORA" or "esperando M5 + Espaco",
				leitura.salvas));
			if leitura.ultima then imgui.text("  Ultima: " .. leitura.ultima); end
		end
	end
|, "menu");

print $s;
