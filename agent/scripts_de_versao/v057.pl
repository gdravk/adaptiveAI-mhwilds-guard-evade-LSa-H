local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.56 - |, q|	Versao 0.57 - Long Sword: prioridade pelo Spirit Gauge. Barra abaixo do vermelho: SS+ISS (sobe a
	barra) > FS > esquiva. Barra VERMELHA: FS > esquiva, e SS+ISS so nos golpes que o FS nao defende
	(aprendidos: FS levou dano 2 vezes no mesmo golpe). Opcao "Somente SS+ISS" (sem FS e sem esquiva)
	0.56 - |, "cab");
$s =~ s/versao_mod = "0\.56"/versao_mod = "0.57"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.56 ==/== Defesa Automatica v0.57 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.56"\)/imgui.tree_node("Defesa Automatica v0.57")/ or die "tit";

troca(q|	usar_ss_iss = true,|, q|	usar_ss_iss = true,
	-- (0.57) so SS+ISS: sem FS e sem esquiva (o SS+ISS serve em todos os golpes; o FS e a esquiva nao)
	somente_ss_iss = false,|, "op");

# golpes que o FS nao defende (aprendido), salvo junto das defesas
troca(q|local bloqueios_ls = {};|, q|local bloqueios_ls = {};

--[[
	(0.57) GOLPES QUE O FS NAO DEFENDE (ex.: os trovoes seguidos da ult do Lagiacrus): quando o FS
	leva dano no mesmo golpe 2 vezes, ele entra nesta lista. Com a barra vermelha (onde o FS e a
	prioridade 1), esses golpes usam o SS+ISS. Chave: "espada_longa:monstro:banco:animacao".
	Fica salvo em aviso_lanca_defesas.json.
]]
local fs_falhas = {};
local FS_FALHAS_PARA_SS = 2;|, "tabela");

troca(q|	if type(salvo) == "table" and type(salvo.bloqueios) == "table" then bloqueios_ls = salvo.bloqueios; end|,
q|	if type(salvo) == "table" and type(salvo.bloqueios) == "table" then bloqueios_ls = salvo.bloqueios; end
	if type(salvo) == "table" and type(salvo.fs_falhas) == "table" then fs_falhas = salvo.fs_falhas; end|, "load");

$s =~ s/json\.dump_file\("aviso_lanca_defesas\.json", \{ golpes = defesas_aprendidas, bloqueios = bloqueios_ls \}\);/json.dump_file("aviso_lanca_defesas.json", { golpes = defesas_aprendidas, bloqueios = bloqueios_ls, fs_falhas = fs_falhas });/g or die "save";

# aprende a falha do FS
troca(q|			if v.perfil == "espada_longa" and v.defesa == "foresight" then aprender_bloqueio(v.diag, false); end|,
q|			if v.perfil == "espada_longa" and v.defesa == "foresight" then
				aprender_bloqueio(v.diag, false);
				fs_falhas[v.chave] = (fs_falhas[v.chave] or 0) + 1; -- (0.57)
				mudou = true;
			end|, "falha");

# Spirit Gauge + decisao no controlador
troca(q|-- o proximo golpe previsto que alcanca voce (de qualquer monstro)|, q|--[[
	(0.57) SPIRIT GAUGE: nivel da barra da Long Sword (app.Wp03Def.AURA_LEVEL, lido do jogo).
	O nivel "vermelho" e achado pelo nome no proprio jogo (o nome que tem "RED"); se nao achar, 3.
]]
local NOMES_AURA, AURA_VERMELHA = {}, nil;
pcall(function()
	local tipo_aura = sdk.find_type_definition("app.Wp03Def.AURA_LEVEL");
	for _, campo in ipairs(tipo_aura:get_fields()) do
		if campo:is_static() then
			local ok, valor = pcall(campo.get_data, campo, nil);
			local nome = campo:get_name();
			if ok and type(valor) == "number" then
				NOMES_AURA[valor] = nome;
				if AURA_VERMELHA == nil and string.find(string.upper(nome), "RED", 1, true) then AURA_VERMELHA = valor; end
			end
		end
	end
end);

local function nivel_spirit_gauge()
	local cacador = meu_cacador();
	local ok, nivel = pcall(function()
		local arma = cacador:call("get_WeaponHandling");
		local n = arma:call("get_AuraLevel");
		if n == nil then n = arma:get_field("<AuraLevel>k__BackingField"); end
		return n;
	end);
	if ok and type(nivel) == "number" then return nivel; end
	return nil;
end

local function barra_vermelha()
	local nivel = nivel_spirit_gauge();
	return nivel ~= nil and nivel >= (AURA_VERMELHA or 3);
end

-- o proximo golpe previsto que alcanca voce (de qualquer monstro)|, "aura");

troca(q|			if not em_combo_espada_longa() then return false; end
			reservar_golpe(p, m, chave_perfil);|, q|			if not em_combo_espada_longa() then return false; end
			--[[
				(0.57) PRIORIDADE PELA BARRA:
				  - "Somente SS+ISS": sempre SS+ISS;
				  - barra abaixo do vermelho: SS+ISS (o ISS certo sobe a barra);
				  - barra VERMELHA: o FS volta a ser o 1 (mais dano); SS+ISS so nos golpes que o FS
				    nao defende.
			]]
			if not op.somente_ss_iss and barra_vermelha()
				and (fs_falhas[chave_do_golpe(chave_perfil, m, p)] or 0) < FS_FALHAS_PARA_SS then
				return false;
			end
			reservar_golpe(p, m, chave_perfil);|, "prioridade");

# somente SS+ISS: o FS e a esquiva nao agem
troca(q|		elseif no_comando then
			return;
		end|, q|		elseif no_comando then
			return;
		end
		-- (0.57) "Somente SS+ISS": sem FS e sem esquiva
		if op.somente_ss_iss and op.usar_ss_iss then
			return;
		end|, "somente");

# Prints
troca(q|		linha(string.format("Leitura do SS+ISS: %s|, q|		local nivel_barra = nivel_spirit_gauge();
		local qtd_fs_nao = 0;
		for _, n in pairs(fs_falhas) do if n >= FS_FALHAS_PARA_SS then qtd_fs_nao = qtd_fs_nao + 1; end end
		linha(string.format("Spirit Gauge: nivel %s (%s) - vermelho a partir de %s - %s - modo: %s - golpes que o FS nao defende: %d",
			tostring(nivel_barra), tostring(NOMES_AURA[nivel_barra or -1] or "?"), tostring(AURA_VERMELHA or "3 (padrao)"),
			barra_vermelha() and "VERMELHA: FS > esquiva (SS+ISS so onde o FS falha)" or "abaixo do vermelho: SS+ISS > FS > esquiva",
			(op.somente_ss_iss and op.usar_ss_iss) and "SOMENTE SS+ISS" or "normal", qtd_fs_nao));
		linha(string.format("Leitura do SS+ISS: %s|, "prints");

# menu: Somente SS+ISS (no menu principal, so na Long Sword) e esquecer
troca(q|	if estado.perfil == PERFIS.espada_longa then
		local _;|, q|	if estado.perfil == PERFIS.espada_longa then
		local mudou_somente;
		mudou_somente, op.somente_ss_iss = imgui.checkbox("Somente SS+ISS (sem FS e sem esquiva)", op.somente_ss_iss);
		if mudou_somente then
			if op.somente_ss_iss then op.usar_ss_iss = true; end
			salvar_opcoes();
		end
		local _;|, "menu");

troca(q|			alterado, op.usar_ss_iss = imgui.checkbox("Usar SS+ISS (prioridade 1; sem tempo para ele: FS)", op.usar_ss_iss);
			mudou_arma = mudou_arma or alterado;|, q|			alterado, op.usar_ss_iss = imgui.checkbox("Usar SS+ISS (barra abaixo do vermelho: prioridade 1)", op.usar_ss_iss);
			mudou_arma = mudou_arma or alterado;
			local qtd_fs_nao = 0;
			for _, n in pairs(fs_falhas) do if n >= FS_FALHAS_PARA_SS then qtd_fs_nao = qtd_fs_nao + 1; end end
			imgui.text(string.format("Golpes que o FS nao defende (usam SS+ISS com a barra vermelha): %d", qtd_fs_nao));
			if imgui.button("Esquecer os golpes que o FS nao defende") then
				fs_falhas = {};
				json.dump_file("aviso_lanca_defesas.json", { golpes = defesas_aprendidas, bloqueios = bloqueios_ls, fs_falhas = fs_falhas });
			end|, "menu2");

print $s;
