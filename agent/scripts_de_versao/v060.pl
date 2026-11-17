local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.59 - |, q|	Versao 0.60 - Long Sword: JANELA DO COMBO APRENDIDA (ate quanto tempo depois do seu golpe o FS e o
	SS saem, medido em cada tentativa); passou da janela = esquiva normal (tambem no "Somente SS+ISS");
	na postura do SS o seu M1 fica livre (cancelar com o Iai Slash) e, se o golpe nao vier, o proprio
	mod cancela com o M1
	0.59 - |, "cab");
$s =~ s/versao_mod = "0\.59"/versao_mod = "0.60"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.59 ==/== Defesa Automatica v0.60 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.59"\)/imgui.tree_node("Defesa Automatica v0.60")/ or die "tit";

troca(q|	postura_medida_ms = 0, |, q|	cancelar_postura_m1 = true, -- (0.60) golpe nao veio: o mod cancela a postura do SS com o M1 (Iai Slash)
	postura_medida_ms = 0, |, "op");

# dados da janela (salvos com as defesas)
troca(q|local ss_sem_golpe = {};|, q|local ss_sem_golpe = {};
-- (0.60) tentativas de FS e SS: { idade do combo em segundos, 1 = saiu / 0 = nao saiu }
local janela_combo_dados = { fs = {}, ss = {} };
-- (0.60) animacoes do FS (dos relatorios: 20:226 e 20:290; aprende outras pelo sinal da espada)
local ANIM_FS = { ["20:226"] = true, ["20:290"] = true };|, "tabela");
troca(q|	if type(salvo) == "table" and type(salvo.ss_sem_golpe) == "table" then ss_sem_golpe = salvo.ss_sem_golpe; end|,
q|	if type(salvo) == "table" and type(salvo.ss_sem_golpe) == "table" then ss_sem_golpe = salvo.ss_sem_golpe; end
	if type(salvo) == "table" and type(salvo.janela_combo) == "table" then
		janela_combo_dados.fs = type(salvo.janela_combo.fs) == "table" and salvo.janela_combo.fs or {};
		janela_combo_dados.ss = type(salvo.janela_combo.ss) == "table" and salvo.janela_combo.ss or {};
	end
	if type(salvo) == "table" and type(salvo.anim_fs) == "table" then
		for anim_fs in pairs(salvo.anim_fs) do ANIM_FS[anim_fs] = true; end
	end|, "load");
$s =~ s/ss_sem_golpe = ss_sem_golpe \}\);/ss_sem_golpe = ss_sem_golpe, janela_combo = janela_combo_dados, anim_fs = ANIM_FS });/g or die "save";

# janela aprendida
troca(q|local function em_combo_espada_longa()
	if combo.animacao ~= nil and op.animacoes_ataque_ls[combo.animacao] == true then return true; end
	local ultimo = math.max(combo.ultimo_acerto, combo.ultimo_ataque_em);
	return os.clock() - ultimo < op.ls_janela_combo_ms / 1000;
end|, q|--[[
	(0.60) JANELA DO COMBO APRENDIDA. "Idade do combo" = quanto tempo faz que o seu ultimo golpe
	acabou (0 enquanto voce esta numa animacao de ataque). Cada FS e cada SS que o mod aperta
	vira uma tentativa: idade naquela hora e se saiu (FS: sua animacao virou 20:226 / 20:290;
	SS: a bainha 20:249 comecou). A janela fica no meio entre a MAIOR idade em que saiu e a
	2a MENOR idade (acima dela) em que nao saiu (2, para uma falha por outro motivo nao
	encolher a janela). Sem dados, usa "ls_janela_combo_ms". Fora da janela: esquiva normal.
]]
local function idade_combo()
	if combo.animacao ~= nil and op.animacoes_ataque_ls[combo.animacao] == true then return 0; end
	return math.max(0, os.clock() - math.max(combo.ultimo_acerto, combo.ultimo_ataque_em));
end

local function janela_combo(tipo)
	local lista = janela_combo_dados[tipo or "fs"] or {};
	local saiu = nil;
	for _, t in ipairs(lista) do
		if t[2] == 1 and (saiu == nil or t[1] > saiu) then saiu = t[1]; end
	end
	local falhas = {};
	for _, t in ipairs(lista) do
		if t[2] == 0 and t[1] > (saiu or 0) then falhas[#falhas + 1] = t[1]; end
	end
	table.sort(falhas);
	local falhou = falhas[2];
	local padrao = op.ls_janela_combo_ms / 1000;
	if saiu ~= nil and falhou ~= nil then return (saiu + falhou) / 2, saiu, falhou, #lista; end
	if falhou ~= nil then return math.min(padrao, falhou), saiu, falhou, #lista; end
	if saiu ~= nil then return math.max(padrao, saiu + 0.1), saiu, falhou, #lista; end
	return padrao, saiu, falhou, #lista;
end

local function anotar_janela(tipo, idade, saiu)
	if idade == nil then return; end
	local lista = janela_combo_dados[tipo];
	lista[#lista + 1] = { math.floor(idade * 1000 + 0.5) / 1000, saiu and 1 or 0 };
	while #lista > 40 do table.remove(lista, 1); end
	estado.bloqueio_mudou = true; -- salva junto com as defesas
end

-- FS apertado agora: confere nos proximos 0,5s se saiu
local tentativas_fs = {};
local function registrar_fs()
	tentativas_fs[#tentativas_fs + 1] = { idade = idade_combo(), em = os.clock(), dano_antes = estado.levou_dano_em };
end

local function em_combo_espada_longa(tipo)
	return idade_combo() < janela_combo(tipo or "fs");
end|, "janela");

troca(q|		if #m5 > 0 and #m2 > 0 then
			e.quadro = (e.quadro or 0) + 1;|, q|		if #m5 > 0 and #m2 > 0 then
			e.quadro = (e.quadro or 0) + 1;
			if e.quadro == 1 and not p.teste then registrar_fs(); end -- (0.60) janela do combo|, "fs_reg");

# SS: janela propria
troca(q|			if not em_combo_espada_longa() or not pode then return false; end|,
q|			if not em_combo_espada_longa("ss") or not pode then return false; end|, "ss_combo");
troca(q|				alvo = p, chave = chave, anim_inicio = anim };|, q|				alvo = p, chave = chave, anim_inicio = anim, idade = idade_combo() };|, "ss_idade");
troca(q|			anotar_ss(ssiss.anim_inicio, true, math.floor(desde * 1000 + 0.5));|,
q|			anotar_ss(ssiss.anim_inicio, true, math.floor(desde * 1000 + 0.5));
			if not ssiss.manual then anotar_janela("ss", ssiss.idade, true); end|, "ss_ok");
troca(q|				if not dano then anotar_ss(ssiss.anim_inicio, false); end|,
q|				if not dano then anotar_ss(ssiss.anim_inicio, false); anotar_janela("ss", ssiss.idade, false); end|, "ss_falha1");
troca(q|					anotar_ss(ssiss.anim_inicio, false);
					terminar_ss_iss("SS nao saiu");|, q|					anotar_ss(ssiss.anim_inicio, false);
					anotar_janela("ss", ssiss.idade, false);
					terminar_ss_iss("SS nao saiu");|, "ss_falha2");

# postura: M1 livre e cancelamento pelo mod
troca(q|			terminar_ss_iss((levou and "LEVOU DANO na postura") or ((not ssiss.manual) and "saiu da postura" or nil));|,
q|			local iai_slash = anim == "20:251" or anim == "20:252";
			terminar_ss_iss((levou and "LEVOU DANO na postura") or (iai_slash and "cancelado por voce (M1)")
				or ((not ssiss.manual) and "saiu da postura" or nil));|, "saiu");
troca(q|			local p, m = golpe_mais_proximo(momento);
			local limite = (ssiss.postura_em or ssiss.inicio) + postura_maxima() - 0.25;|, q|			-- (0.60) na postura o seu M1 fica livre: voce cancela com o Iai Slash quando ve que o golpe nao vem
			estado.liberar_m1_ate = momento + 0.1;
			local p, m = golpe_mais_proximo(momento);
			local limite = (ssiss.postura_em or ssiss.inicio) + postura_maxima() - 0.25;|, "m1_livre");
troca(q|					if not ssiss.manual then anotar_sem_golpe(ssiss.chave, false); end
					terminar_ss_iss((not ssiss.manual) and "sem golpe: postura liberada" or nil);
					estado.bloquear_acoes_ate = nil;
					return false;|, q|					if not ssiss.manual then anotar_sem_golpe(ssiss.chave, false); end
					-- (0.60) o golpe nao vem: cancela a postura com o M1 (Iai Slash), mais rapido que esperar
					if not ssiss.manual and op.cancelar_postura_m1 and #(op.toques.m1 or {}) > 0 then
						ssiss.fase, ssiss.quadro, ssiss.cancelar_em = "cancelar", 0, momento;
						return true;
					end
					terminar_ss_iss((not ssiss.manual) and "sem golpe: postura liberada" or nil);
					estado.bloquear_acoes_ate = nil;
					return false;|, "cancelar");
troca(q|	if ssiss.fase == "iss" then
		if ANIM_ISS[anim] then ssiss.viu_iss = true; end|, q|	if ssiss.fase == "cancelar" then
		if not ANIM_SS[anim] then
			terminar_ss_iss("sem golpe: cancelou com M1");
			estado.bloquear_acoes_ate = nil;
			return false;
		end
		if momento - ssiss.cancelar_em > 0.8 then
			terminar_ss_iss("sem golpe: postura liberada");
			estado.bloquear_acoes_ate = nil;
			return false;
		end
		ssiss.quadro = ssiss.quadro + 1;
		if ssiss.quadro <= #(op.toques.m1 or {}) then marcar("toque:m1:" .. ssiss.quadro); end
		return true;
	end

	if ssiss.fase == "iss" then
		if ANIM_ISS[anim] then ssiss.viu_iss = true; end|, "fase_cancelar");

# bloqueio dos botoes: M1 do mod / M1 livre na postura
troca(q|		local usa_m2, usa_m5, usa_espaco = false, false, false;
		for acao in pairs(teclas_agora) do
			if acao == "guarda" or acao == "especial" then|, q|		local usa_m2, usa_m5, usa_espaco = false, false, false;
		local usa_m1 = estado.liberar_m1_ate ~= nil and agora() < estado.liberar_m1_ate; -- (0.60) postura do SS
		for acao in pairs(teclas_agora) do
			if string.sub(acao, 1, 9) == "toque:m1:" then
				usa_m1 = true;
			elseif acao == "guarda" or acao == "especial" then|, "usa_m1");
troca(q|		marcar("bloquear:m1");|, q|		if not usa_m1 then marcar("bloquear:m1"); end|, "bloq_m1");

# somente SS+ISS: o loop roda (para a esquiva fora da janela), mas sem FS
troca(q|		if op.somente_ss_iss and op.usar_ss_iss then
			return;
		end|, q|		-- (0.60) agora segue: fora da janela do SS sai a esquiva normal; dentro dela, nada de FS|, "somente");
troca(q|				p.combo_conferido = true;
				if not em_combo_espada_longa() then|, q|				p.combo_conferido = true;
				local somente = op.somente_ss_iss and op.usar_ss_iss;
				if somente and em_combo_espada_longa("ss") then
					-- (0.60) "Somente SS+ISS": dentro da janela do SS nao usa FS nem esquiva
					p.defesa = nil;
					estado.ultima_decisao = "somente SS+ISS: golpe sem tempo para o SS";
				elseif not em_combo_espada_longa(somente and "ss" or "fs") then|, "combo_check");
troca(q|			if perfil == PERFIS.espada_longa and not longe and p.defesa == "foresight" and falta >= -depois then|,
q|			if perfil == PERFIS.espada_longa and not longe and p.defesa == "foresight" and falta >= -depois
				and not (op.somente_ss_iss and op.usar_ss_iss) then|, "bloq_fs");

# confere os FS apertados e aprende animacoes do FS pelo sinal
troca(q|	for _, nome in ipairs({ "IsIaiKijinMikiriSuccessed", "IsMikiriSuccessed" }) do
		local ligado = arma:get_field(nome) == true;
		if ligado and not sinais_ls[nome] then
			local agora_lua = os.clock();|, q|	-- (0.60) cada FS apertado: saiu (animacao do FS em ate 0,5s) ou nao (sem dano no meio)
	local anim_agora = combo.animacao or "?";
	local restantes = {};
	for _, t in ipairs(tentativas_fs) do
		if ANIM_FS[anim_agora] then
			anotar_janela("fs", t.idade, true);
		elseif os.clock() - t.em > 0.5 then
			if estado.levou_dano_em == t.dano_antes then anotar_janela("fs", t.idade, false); end
		else
			restantes[#restantes + 1] = t;
		end
	end
	tentativas_fs = restantes;

	for _, nome in ipairs({ "IsIaiKijinMikiriSuccessed", "IsMikiriSuccessed" }) do
		local ligado = arma:get_field(nome) == true;
		if ligado and not sinais_ls[nome] then
			local agora_lua = os.clock();
			if nome == "IsMikiriSuccessed" and anim_agora ~= "?" and not ANIM_FS[anim_agora] then
				ANIM_FS[anim_agora] = true; -- (0.60) o FS deu certo nesta animacao: e animacao do FS
				estado.bloqueio_mudou = true;
			end|, "vigia");

# Prints
troca(q|		linha(string.format("Leitura do SS+ISS: %s|, q|		local j_fs, s_fs, f_fs, n_fs = janela_combo("fs");
		local j_ss, s_ss, f_ss, n_ss = janela_combo("ss");
		local function ms(v) return v and tostring(math.floor(v * 1000 + 0.5)) or "-"; end
		linha(string.format("Janela do combo (aprendida): FS ate %s ms (saiu ate %s, nao saiu a partir de %s, %d tentativas) - SS ate %s ms (saiu ate %s, nao saiu %s, %d) - idade do combo agora %s ms",
			ms(j_fs), ms(s_fs), ms(f_fs), n_fs, ms(j_ss), ms(s_ss), ms(f_ss), n_ss, ms(idade_combo())));
		linha(string.format("Leitura do SS+ISS: %s|, "prints");

# menu
troca(q|			alterado, op.iss_ajuste_auto = imgui.checkbox("Tempo do ISS se ajusta sozinho", op.iss_ajuste_auto);|,
q|			alterado, op.iss_ajuste_auto = imgui.checkbox("Tempo do ISS se ajusta sozinho", op.iss_ajuste_auto);
			mudou_arma = mudou_arma or alterado;
			alterado, op.cancelar_postura_m1 = imgui.checkbox("Golpe nao veio: cancelar a postura com M1 (Iai Slash)", op.cancelar_postura_m1);|, "menu");

print $s;
