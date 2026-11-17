local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.57 - |, q|	Versao 0.58 - revisao do SS+ISS e mais aprendizado: aprende o tempo do golpe tambem quando o FS
	ou o ISS DEFENDEM (antes so aprendia levando dano); o tempo do ISS se ajusta sozinho pelos
	contra-ataques certos; golpe que o FS defende volta a ser do FS; varias correcoes
	0.57 - |, "cab");
$s =~ s/versao_mod = "0\.57"/versao_mod = "0.58"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.57 ==/== Defesa Automatica v0.58 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.57"\)/imgui.tree_node("Defesa Automatica v0.58")/ or die "tit";

troca(q|	ls_iss_ms = 150,        -- ISS (M5) quantos ms antes do golpe|,
q|	ls_iss_ms = 150,        -- ISS (M5) quantos ms antes do golpe (0.58: se ajusta sozinho)
	iss_ajuste_auto = true, -- (0.58) ajusta o ls_iss_ms pelos contra-ataques certos do ISS|, "op");

# =====================================================================================
# 1. APRENDER QUANDO A DEFESA DA CERTO (FS / ISS)
# =====================================================================================
troca(q|local tipo_monstro_char = sdk.find_type_definition("app.EnemyCharacter");|, q|--[[
	(0.58) APRENDER TAMBEM QUANDO VOCE DEFENDE. Nas leituras do SS+ISS, quando o contra-ataque
	do ISS deu certo o jogo NAO chamou o "golpe acertou" (por isso o mod so aprendia golpes com
	a Long Sword quando voce LEVAVA o golpe). Agora, quando o jogo avisa que o FS ou o ISS
	defendeu, o momento do aviso e o momento do golpe: se algum golpe estava previsto para
	ate 0,25s dali, vira uma medicao nova (reforca e corrige o tempo daquele golpe).
]]
local function aprender_por_contra_ataque()
	if not op.aprender then return; end
	local momento = agora();
	local melhor_m, melhor_p, menor = nil, nil, nil;
	for _, m in pairs(monstros) do
		if not m.invalido then
			for _, p in ipairs(m.previstos or {}) do
				local erro = momento - p.tempo;
				if math.abs(erro) <= 0.25 and (menor == nil or math.abs(erro) < math.abs(menor)) then
					melhor_m, melhor_p, menor = m, p, erro;
				end
			end
		end
	end
	if melhor_m == nil then return; end
	if melhor_m.ultimo_aprendizado ~= nil and math.abs(momento - melhor_m.ultimo_aprendizado) < 0.3 then return; end
	melhor_m.ultimo_aprendizado = momento;
	local usadas = 0;
	for i = #melhor_m.historico, 1, -1 do
		local h = melhor_m.historico[i];
		local passou = momento - h.inicio;
		if passou > AJUSTES.idade_maxima_animacao or usadas >= AJUSTES.animacoes_por_impacto then break; end
		aprender(melhor_m.variante, h.chave, passou, melhor_p.guarda or 0, melhor_m.distancia or 0);
		usadas = usadas + 1;
	end
	estado.aprendidos_contra = (estado.aprendidos_contra or 0) + 1;
	estado.ultimo_erro_ms = math.floor(menor * 1000 + 0.5);
end

local tipo_monstro_char = sdk.find_type_definition("app.EnemyCharacter");|, "aprender_contra");

troca(q|		local ok = pcall(sdk.hook, funcao, function()
			-- algumas destas funcoes|, q|		local ok = pcall(sdk.hook, funcao, function(args)
			-- (0.58) FS da Long Sword deu certo: aprende o tempo do golpe (so a SUA espada)
			-- (so na primeira chamada: o jogo repete esta funcao enquanto o efeito dura)
			if d.funcao == "doSuccessMikiri" and os.clock() - (ultima_chamada_defesa[d.conta] or -10) >= 0.5 then
				pcall(function()
					local cacador = meu_cacador();
					local minha_arma = cacador and cacador:call("get_WeaponHandling");
					if minha_arma ~= nil and sdk.to_int64(args[2]) == minha_arma:get_address() then
						estado.fs_certo_em = os.clock();
						aprender_por_contra_ataque();
					end
				end);
			end
			-- algumas destas funcoes|, "hook_fs");

# ISS: aprende + ajusta o tempo
troca(q|			estado.iss_certo_em = os.clock(); -- (0.56) usado no resultado do SS+ISS|, q|			estado.iss_certo_em = os.clock(); -- (0.56) usado no resultado do SS+ISS
			pcall(aprender_por_contra_ataque); -- (0.58)
			--[[
				(0.58) TEMPO DO ISS SE AJUSTA SOZINHO: nas leituras o contra-ataque deu certo com o
				golpe chegando de 50 a 300 ms depois do M5. O mod mede, em cada ISS certo apertado
				por ele, quanto tempo depois do M5 o golpe chegou e puxa o "ls_iss_ms" para o golpe
				cair no MEIO dessa janela (160 ms): golpe chegou cedo (perto de 50) = aperta antes;
				chegou tarde (perto de 300) = aperta depois.
			]]
			if op.iss_ajuste_auto and ssiss ~= nil and ssiss.mod_apertou and ssiss.iss_em ~= nil then
				local depois_ms = (estado.iss_certo_em - ssiss.iss_em) * 1000;
				if depois_ms >= 0 and depois_ms <= 450 then
					local novo = op.ls_iss_ms + (160 - depois_ms) * 0.25;
					op.ls_iss_ms = math.floor(math.max(80, math.min(300, novo)) + 0.5);
					estado.iss_medidas = estado.iss_medidas or {};
					table.insert(estado.iss_medidas, 1, math.floor(depois_ms + 0.5));
					if #estado.iss_medidas > 8 then table.remove(estado.iss_medidas); end
					salvar_opcoes();
				end
			end|, "hook_iss");

# =====================================================================================
# 2. CORRECOES DO CONTROLADOR
# =====================================================================================
# vermelho: nao confundir "PRE_RED" (quase vermelho) com o vermelho
troca(q|				if AURA_VERMELHA == nil and string.find(string.upper(nome), "RED", 1, true) then AURA_VERMELHA = valor; end|,
q|				local maiusculo = string.upper(nome);
				-- (0.58) o jogo tem um "quase vermelho" (isPreRedAura): nomes com "PRE" nao contam
				if string.find(maiusculo, "RED", 1, true) and not string.find(maiusculo, "PRE", 1, true)
					and (AURA_VERMELHA == nil or valor < AURA_VERMELHA) then AURA_VERMELHA = valor; end|, "vermelho");

# o mod apertou o ISS (para o ajuste do tempo)
troca(q|				ssiss.fase, ssiss.iss_em, ssiss.quadro = "iss", os.clock(), 0;|,
q|				ssiss.fase, ssiss.iss_em, ssiss.quadro, ssiss.mod_apertou = "iss", os.clock(), 0, true;|, "mod_apertou");

# SS seu: "sem golpe" e "saiu da postura" nao sao resultado (voce saiu / fez outra coisa);
# antes, depois de liberar a postura o mod readotava o SS a cada 1,5s e contava resultados repetidos
troca(q|			terminar_ss_iss((estado.levou_dano_em ~= ssiss.dano_antes) and "LEVOU DANO na postura" or "saiu da postura");|,
q|			local levou = estado.levou_dano_em ~= ssiss.dano_antes;
			terminar_ss_iss((levou and "LEVOU DANO na postura") or ((not ssiss.manual) and "saiu da postura" or nil));|, "saiu");
troca(q|					terminar_ss_iss("sem golpe: postura liberada");|,
q|					terminar_ss_iss((not ssiss.manual) and "sem golpe: postura liberada" or nil);|, "liberada");

# =====================================================================================
# 3. FS: golpe que o FS defende sai da lista "FS nao defende"
# =====================================================================================
troca(q|			if v.perfil == "espada_longa" and v.defesa == "foresight" then aprender_bloqueio(v.diag, true); end|,
q|			if v.perfil == "espada_longa" and v.defesa == "foresight" then
				aprender_bloqueio(v.diag, true);
				-- (0.58) o FS defendeu: este golpe conta uma falha a menos
				if (fs_falhas[v.chave] or 0) > 0 then
					fs_falhas[v.chave] = fs_falhas[v.chave] - 1;
					if fs_falhas[v.chave] <= 0 then fs_falhas[v.chave] = nil; end
					mudou = true;
				end
			end|, "fs_ok");

# =====================================================================================
# 4. PRINTS E MENU
# =====================================================================================
troca(q|- ultimo erro: %s - aprendidos no seu Palico: %d",
		quantos, animacoes, medicoes, estado.avisos_certos, estado.impactos_vistos,
		estado.ultimo_erro_ms and (estado.ultimo_erro_ms .. " ms") or "-", estado.aprendidos_outros or 0));|,
q|- ultimo erro: %s - aprendidos no seu Palico: %d - aprendidos defendendo (FS/ISS): %d",
		quantos, animacoes, medicoes, estado.avisos_certos, estado.impactos_vistos,
		estado.ultimo_erro_ms and (estado.ultimo_erro_ms .. " ms") or "-", estado.aprendidos_outros or 0, estado.aprendidos_contra or 0));|, "prints_conh");

troca(q|		linha(string.format("Leitura do SS+ISS: %s|, q|		linha(string.format("ISS: %d ms antes do golpe (%s) - golpe chegou depois do M5 nos ultimos ISS certos: %s",
			op.ls_iss_ms, op.iss_ajuste_auto and "ajusta sozinho" or "fixo",
			#(estado.iss_medidas or {}) > 0 and (table.concat(estado.iss_medidas, ", ") .. " ms") or "-"));
		linha(string.format("Leitura do SS+ISS: %s|, "prints_iss");

# resumo da sessao: conta tambem os resultados do SS+ISS
troca(q|		if d.resultado == "OK (sem dano)" then certas = certas + 1; total_def = total_def + 1;
		elseif d.resultado == "LEVOU DANO" then total_def = total_def + 1; end|,
q|		local r = tostring(d.resultado);
		if string.sub(r, 1, 2) == "OK" then certas = certas + 1; total_def = total_def + 1;
		elseif string.find(r, "LEVOU DANO", 1, true) then total_def = total_def + 1; end|, "resumo");

troca(q|			if imgui.button("Esquecer os golpes que o FS nao defende") then|,
q|			alterado, op.iss_ajuste_auto = imgui.checkbox("Tempo do ISS se ajusta sozinho", op.iss_ajuste_auto);
			mudou_arma = mudou_arma or alterado;
			if imgui.button("Esquecer os golpes que o FS nao defende") then|, "menu");

print $s;
