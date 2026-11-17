local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 1.07 - |, q|	Versao 1.08 - MEDICAO: em cada FS (seu ou do mod) o relatorio anota quanto tinha de barra de espirito
	e se o jogo deu invencibilidade, separado em "com barra" e "sem barra". Opcao de teste (Long Sword):
	deixar o FS sair sem barra, para medir (desligada).
	1.07 - |, "cab");
$s =~ s/versao_mod = "1\.07"/versao_mod = "1.08"/g or die "vm";
$s =~ s/== Defesa Automatica v1\.07 ==/== Defesa Automatica v1.08 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v1\.07"\)/imgui.tree_node("Defesa Automatica v1.08")/ or die "tit";

troca(q|	ls_m2_automatico = true,|, q|	ls_fs_sem_barra_teste = false, -- (1.08) teste: FS tambem sem barra (para medir a invencibilidade)
	ls_m2_automatico = true,|, "opcao");
troca(q|	if barra ~= nil and barra <= 0.1 then -- (1.07)|, q|	if barra ~= nil and barra <= 0.1 and not op.ls_fs_sem_barra_teste then -- (1.07)|, "regra");
troca(q|			alterado, op.usar_ss_iss = imgui.checkbox("Usar SS+ISS (barra abaixo do vermelho: prioridade 1)", op.usar_ss_iss);|,
q|			alterado, op.usar_ss_iss = imgui.checkbox("Usar SS+ISS (barra abaixo do vermelho: prioridade 1)", op.usar_ss_iss);
			mudou_arma = mudou_arma or alterado;
			alterado, op.ls_fs_sem_barra_teste = imgui.checkbox("TESTE: deixar o FS sair sem barra de espirito (para medir a invencibilidade)", op.ls_fs_sem_barra_teste);|, "menu");

troca(q|		-- (0.94) acoes vistas nesta sessao, por arma (nome, numero e quantas vezes comecou)|,
q|		-- (1.08) MEDICAO: cada FS (seu ou do mod) - barra de espirito no comeco e se veio invencibilidade
		local fm = estado.fs_medida;
		if fm ~= nil and os.clock() - fm.em > 0.4 then
			estado.fs_medida = nil;
			local grupo = (fm.barra ~= nil and fm.barra <= 0.1) and "sem barra" or "com barra";
			estado.fs_barra = estado.fs_barra or {};
			local g = estado.fs_barra[grupo] or { n = 0, inv = 0, dano = 0, soma_barra = 0 };
			estado.fs_barra[grupo] = g;
			g.n = g.n + 1;
			g.soma_barra = g.soma_barra + (fm.barra or 0);
			if invencibilidade.desde ~= nil and invencibilidade.desde ~= fm.inv_antes
				and (invencibilidade.tipo == 6 or invencibilidade.tipo == 7) then g.inv = g.inv + 1; end
			if estado.levou_dano_em ~= fm.dano_antes then g.dano = g.dano + 1; end
		end
		if nome == "cMikiriSlash" and estado.acao_nome_ultimo ~= "cMikiriSlash" then
			estado.fs_medida = { em = os.clock(), barra = barra_de_espirito(cacador), inv_antes = invencibilidade.desde,
				dano_antes = estado.levou_dano_em };
		end
		-- (0.94) acoes vistas nesta sessao, por arma (nome, numero e quantas vezes comecou)|, "medida");

troca(q|		linha("Forcados com a stamina zerada: " .. (#zs > 0 and table.concat(zs, ", ") or "nenhum"));|,
q|		linha("Forcados com a stamina zerada: " .. (#zs > 0 and table.concat(zs, ", ") or "nenhum"));
		-- (1.08) FS x barra de espirito x invencibilidade
		local fb = {};
		for grupo, g in pairs(estado.fs_barra or {}) do
			fb[#fb + 1] = string.format("%s: %d FS, %d com invencibilidade, %d levaram dano (barra media %.2f)",
				grupo, g.n, g.inv, g.dano, g.n > 0 and g.soma_barra / g.n or 0);
		end
		linha("FS e barra de espirito: " .. (#fb > 0 and table.concat(fb, " - ") or "nenhum FS ainda")
			.. (op.ls_fs_sem_barra_teste and " - TESTE LIGADO (FS sai sem barra)" or ""));|, "linha");
print $s;
