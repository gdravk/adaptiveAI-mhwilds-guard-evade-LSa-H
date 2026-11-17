local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.82 - |, q|	Versao 0.83 - Long Sword: M2 AUTOMATICO para o SS+ISS. Parado (fora do combo) o SS nao sai; quando
	o golpe que vem precisa do SS+ISS, o mod trava os seus botoes, aperta um M2 (o golpe mais rapido) e
	solta o SS logo em seguida. Rugido = tipo de golpe "EAR" (visto no relatorio) e vento ("WIND")
	tambem contam como golpe
	0.82 - |, "cab");
$s =~ s/versao_mod = "0\.82"/versao_mod = "0.83"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.82 ==/== Defesa Automatica v0.83 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.82"\)/imgui.tree_node("Defesa Automatica v0.83")/ or die "tit";

troca(q|	ls_sem_fs_abaixo_vermelho = true,|, q|	ls_sem_fs_abaixo_vermelho = true,
	ls_m2_automatico = true, -- (0.83) parado: M2 automatico para abrir o SS+ISS|, "op");

# rugido = EAR, vento = WIND
troca(q|	return string.find(n, "ROAR", 1, true) ~= nil or string.find(n, "HOWL", 1, true) ~= nil|,
q|	-- (0.83) no relatorio o rugido veio como "EAR" (protecao de ouvido) e o vento como "WIND"
	if n == "EAR" or n == "WIND" or string.sub(n, 1, 4) == "EAR_" or string.sub(n, 1, 5) == "WIND_" then return true; end
	return string.find(n, "ROAR", 1, true) ~= nil or string.find(n, "HOWL", 1, true) ~= nil|, "rugido");

# fase M2 no inicio do controle
troca(q|	local m5, espaco = op.toques.m5 or {}, op.toques.esquiva or {};

	if ssiss == nil then|, q|	local m5, espaco = op.toques.m5 or {}, op.toques.esquiva or {};

	--[[
		(0.83) M2 AUTOMATICO: voce estava parado e o golpe precisa do SS+ISS. O mod aperta o M2
		(estocada, o golpe mais rapido) com os seus botoes travados; quando o M2 comeca, o combo
		abre e o SS sai pelo caminho normal logo abaixo.
	]]
	local m2a = estado.m2_auto;
	if m2a ~= nil and ssiss == nil then
		local m2 = op.toques.m2 or {};
		if (momento - m2a.em > 0.12 and (e_golpe_seu(anim) or em_combo_espada_longa("ss"))) then
			estado.m2_auto = nil;
			estado.m2_auto_saiu = (estado.m2_auto_saiu or 0) + 1;
		elseif momento - m2a.em > 0.8 or (m2a.alvo ~= nil and m2a.alvo.tempo - momento < op.ls_ss_min_ms / 1000) then
			estado.m2_auto = nil;
			estado.m2_auto_nao_saiu = (estado.m2_auto_nao_saiu or 0) + 1;
			return false;
		else
			m2a.quadro = m2a.quadro + 1;
			if m2a.quadro <= #m2 then marcar("toque:m2:" .. m2a.quadro); end
			estado.bloquear_acoes_ate = math.max(estado.bloquear_acoes_ate or 0, momento + 0.1);
			estado.ultima_decisao = "M2 automatico para abrir o SS+ISS";
			return true;
		end
	end

	if ssiss == nil then|, "fase_m2");

# decide o M2 quando esta fora do combo
troca(q|			if not em_combo_espada_longa("ss") or not pode then return false; end
			local chave = chave_do_golpe(chave_perfil, m, p);|, q|			if not em_combo_espada_longa("ss") then
				-- (0.83) parado: o SS nao sai -> M2 automatico (se o golpe precisa do SS+ISS e da tempo)
				if not op.ls_m2_automatico or #(op.toques.m2 or {}) == 0 then return false; end
				local chave_m2 = chave_do_golpe(chave_perfil, m, p);
				if not golpe_bom_para_ss(chave_m2) then return false; end
				if not op.somente_ss_iss and barra_vermelha() and not em_sequencia and (fs_falhas[chave_m2] or 0) < FS_FALHAS_PARA_SS then
					return false;
				end
				local dur_m2 = trava_do_golpe("20:199") or 0.3;
				local precisa = math.max(op.ls_ss_min_ms / 1000, 1.55 + dur_m2) + 0.2;
				if falta < precisa or falta > precisa + 0.5 then return false; end
				estado.m2_auto = { em = momento, quadro = 0, alvo = p };
				estado.m2_auto_feitos = (estado.m2_auto_feitos or 0) + 1;
				estado.bloquear_acoes_ate = math.max(estado.bloquear_acoes_ate or 0, momento + 0.1);
				return true;
			end
			if not pode then return false; end
			local chave = chave_do_golpe(chave_perfil, m, p);|, "decide_m2");

# arma guardada / M4 / parado: cancela o M2 pendente
troca(q|	if arma_guardada then
		toque.quadro = nil;
		ssiss = nil;|, q|	if arma_guardada then
		toque.quadro = nil;
		ssiss = nil;
		estado.m2_auto = nil;|, "guardada");

# menu
troca(q|			alterado, op.ls_sem_fs_abaixo_vermelho = imgui.checkbox("Abaixo do vermelho: esquiva no lugar do FS (o FS zera o carregamento da barra)", op.ls_sem_fs_abaixo_vermelho);
			mudou_arma = mudou_arma or alterado;|, q|			alterado, op.ls_sem_fs_abaixo_vermelho = imgui.checkbox("Abaixo do vermelho: esquiva no lugar do FS (o FS zera o carregamento da barra)", op.ls_sem_fs_abaixo_vermelho);
			mudou_arma = mudou_arma or alterado;
			alterado, op.ls_m2_automatico = imgui.checkbox("Parado: M2 automatico para soltar o SS+ISS", op.ls_m2_automatico);
			mudou_arma = mudou_arma or alterado;|, "menu");

# relatorio
troca(q|	local ct = estado.contatos_em_voce or {};|, q|	linha(string.format("M2 automatico (parado -> SS+ISS): %d apertados, %d abriram o combo, %d nao sairam",
		estado.m2_auto_feitos or 0, estado.m2_auto_saiu or 0, estado.m2_auto_nao_saiu or 0));
	local ct = estado.contatos_em_voce or {};|, "prints");

print $s;
