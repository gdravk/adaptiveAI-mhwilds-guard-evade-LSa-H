local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

# --- cabecalho: historico longo vira um resumo curto ---
$s =~ s/\tVersao 0\.89 - FORCAR.*?(\n\n\tO que faz:)/\tVersao 0.90 - LIMPEZA: menu do REFramework mais simples (so o que voce usa) e codigo sem as partes
\tque nao servem mais (limpezas unicas que ja rodaram, opcao sem uso).
\t0.89 - FORCAR: FS, SS, ISS e esquiva pedidos direto ao jogo na hora da defesa (sem anular golpe e sem
\tinvencibilidade); os numeros das acoes sao aprendidos das suas proprias acoes.
\tVersoes anteriores (resumo): 0.88 travamento no "Saving..."; 0.85-0.87 trava dos seus golpes e M2
\tautomatico; 0.78-0.82 aprendizado pelo contato, pela area de ataque e pela geometria; 0.73-0.77 barra
\tde previsao configuravel; 0.29-0.72 Long Sword (FS, SS+ISS), outras armas e o aprendizado dos golpes.$1/s or die "cab";
troca(q|	  - Ja vem com o que foi medido nas gravacoes (Arkveld normal, lanca, solo).
|, q|	  - Long Sword: FS, SS+ISS e esquiva saem sozinhos na hora certa (pedidos direto ao jogo).
|, "oquefaz");
troca(q|	  - aviso_lanca_estrutura.json    exportacao para pesquisa (botao no menu)
	  - aviso_lanca_gravacao_v27_N.json gravacoes para pesquisa (botao no menu)
|, q|	  - aviso_lanca_defesas.json      defesas aprendidas de cada golpe
|, "arquivos");

$s =~ s/versao_mod = "0\.89"/versao_mod = "0.90"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.89 ==/== Defesa Automatica v0.90 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.89"\)/imgui.tree_node("Defesa Automatica v0.90")/ or die "tit";

# --- opcoes sem uso ---
troca(q|	limpeza_bots_054 = false, -- (0.54) limpeza unica de medicoes que podem ter vindo de bots
	limpeza_sos_053 = false, -- (0.53) limpeza unica e completa dos monstros enfrentados no SOS
|, q||, "op_limp");
troca(q|	ls_acao_direta = true, -- (0.87) FS / ISS pedidos direto ao jogo, so nas janelas em que o jogo aceita
|, q||, "op_direta");
troca(q|	reset_postura_062 = false,
	limpeza_golpes_065 = false, -- (0.65) tira FS / SS / ISS / esquiva das medidas dos seus golpes -- (0.62) apaga a postura maxima medida errado na 0.61
	reset_iss_059 = false,  -- (0.59) volta o ls_iss_ms a 150 uma vez (o ajuste da 0.58 usava o aviso atrasado) -- (0.58) ajusta o ls_iss_ms pelos contra-ataques certos do ISS
|, q||, "op_reset");

# --- menu ---
troca(q|	mudou_simples, op.tenho_guard_up = imgui.checkbox("Tenho Guard Up (guardar golpes \"impossiveis\")", op.tenho_guard_up);
	alterou_simples = alterou_simples or mudou_simples;
|, q|	-- (0.90) Guard Up so aparece nas armas que guardam
	local p_menu = estado.perfil;
	if p_menu ~= nil and (p_menu.teto_com_guard_up or posicao_no_perfil(p_menu, "guarda") ~= nil) then
		mudou_simples, op.tenho_guard_up = imgui.checkbox("Tenho Guard Up (guardar golpes \"impossiveis\")", op.tenho_guard_up);
		alterou_simples = alterou_simples or mudou_simples;
	end
|, "guardup");

troca(q|	-- (0.75) aba da barra de previsao (com uma barra de exemplo enquanto esta aberta)
	-- (0.78) aprendizado novo e defesa na hora do golpe das outras armas
	if imgui.tree_node("Aprendizado") then
		local mudou_78, m78 = false, false;
		m78, op.aprender_por_contato = imgui.checkbox("Aprender pelo contato do golpe (esquivas, FS, ISS)", op.aprender_por_contato);
		mudou_78 = mudou_78 or m78;
		m78, op.aprender_por_ativacao = imgui.checkbox("Aprender pela area de ataque do monstro (so animacoes conferidas)", op.aprender_por_ativacao);
		mudou_78 = mudou_78 or m78;
		m78, op.defesa_geometria = imgui.checkbox("Defesa pela geometria (golpe que o mod nao conhece, vindo em voce)", op.defesa_geometria);
		mudou_78 = mudou_78 or m78;
		imgui.text("O mod so le o jogo e aperta botoes reais: nada do jogo e modificado.");
		if mudou_78 then salvar_opcoes(); end
		imgui.tree_pop();
	end

	pcall(imgui.set_next_item_open, true, 4); -- (0.77) aberta na primeira vez (se o REFramework tiver)
	if imgui.tree_node("Configurar Barra de previsao") then|, q|	-- aba da barra de previsao (com uma barra de exemplo enquanto esta aberta)
	if imgui.tree_node("Configurar Barra de previsao") then|, "aprend");

troca(q|		local _;
		_, estado.leitura_ss_iss = imgui.checkbox("Leitura do SS+ISS (o mod NAO defende, so le os seus SS+ISS)", estado.leitura_ss_iss == true);
		if estado.leitura_ss_iss then
			imgui.text(string.format("  %s - %d leituras salvas (pasta Prints)", leitura.atual and "LENDO AGORA" or "esperando M5 + Espaco",
				leitura.salvas));
			if leitura.ultima then imgui.text("  Ultima: " .. leitura.ultima); end
		end
|, q||, "leitura");

# Ajustes da arma: so liga/desliga; tempos vao para o Diagnostico
troca(q|			alterado, op.ls_m2_automatico = imgui.checkbox("Parado: M2 automatico para soltar o SS+ISS", op.ls_m2_automatico);
			mudou_arma = mudou_arma or alterado;
			alterado, op.ls_acao_direta = imgui.checkbox("FS / ISS pedidos direto ao jogo (so quando o jogo aceita)", op.ls_acao_direta);
			mudou_arma = mudou_arma or alterado;
			local qtd_fs_nao = 0;
			for _, n in pairs(fs_falhas) do if n >= FS_FALHAS_PARA_SS then qtd_fs_nao = qtd_fs_nao + 1; end end
			imgui.text(string.format("Golpes que o FS nao defende (usam SS+ISS com a barra vermelha): %d", qtd_fs_nao));
			alterado, op.iss_ajuste_auto = imgui.checkbox("Tempo do ISS se ajusta sozinho", op.iss_ajuste_auto);
			mudou_arma = mudou_arma or alterado;
			mudou_arma = mudou_arma or alterado;
			if imgui.button|, q|			local qtd_fs_nao = 0;
			for _, n in pairs(fs_falhas) do if n >= FS_FALHAS_PARA_SS then qtd_fs_nao = qtd_fs_nao + 1; end end
			imgui.text(string.format("Golpes que o FS nao defende (usam SS+ISS com a barra vermelha): %d", qtd_fs_nao));
			if imgui.button|, "ls_menu");

troca(q|		-- tempo de cada defesa da arma (quanto antes do golpe ela comeca)
		for _, acao in ipairs(perfil_menu.niveis) do|, q|		if mudou_arma then salvar_opcoes(); end
		imgui.tree_pop();
	end

	if imgui.tree_node("Diagnostico (so se eu pedir)") then
		if estado.n82 ~= nil then pcall(estado.n82.desenhar_pesquisa); end -- (0.82)
		pcall(desenhar_aba_prints);

		-- (0.90) ajustes finos (tempos das defesas): so mexer se eu pedir
		if perfil_menu ~= nil and imgui.tree_node("Ajustes finos (" .. perfil_menu.nome .. ")") then
		local mudou_arma, alterado = false, false;
		if perfil_menu == PERFIS.espada_longa then
			alterado, op.ls_m2_automatico = imgui.checkbox("Parado: M2 automatico para soltar o SS+ISS", op.ls_m2_automatico);
			mudou_arma = mudou_arma or alterado;
			alterado, op.iss_ajuste_auto = imgui.checkbox("Tempo do ISS se ajusta sozinho", op.iss_ajuste_auto);
			mudou_arma = mudou_arma or alterado;
		end
		-- tempo de cada defesa da arma (quanto antes do golpe ela comeca)
		for _, acao in ipairs(perfil_menu.niveis) do|, "finos");

troca(q|		if mudou_arma then salvar_opcoes(); end
		imgui.tree_pop();
	end

	if imgui.tree_node("Diagnostico (so se eu pedir)") then
		if estado.n82 ~= nil then pcall(estado.n82.desenhar_pesquisa); end -- (0.82)
		pcall(desenhar_aba_prints);

		-- testar os botoes|, q|		if mudou_arma then salvar_opcoes(); end
		imgui.tree_pop();
		end

		-- testar os botoes|, "fim_finos");

# --- limpezas unicas que ja rodaram ---
my $i = index($s, "pcall(function()\n\tif op.limpeza_golpes_065 == true then return; end");
die "migr" if $i < 0;
my $j = index($s, "\top.limpeza_bots_054 = true;\n\tsalvar_opcoes();\nend);\n", $i);
die "migr2" if $j < 0;
substr($s, $i, $j + length("\top.limpeza_bots_054 = true;\n\tsalvar_opcoes();\nend);\n") - $i) = "";

print $s;
