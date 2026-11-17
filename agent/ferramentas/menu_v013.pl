local $/; my $s = <STDIN>;
my $old1 = q{		-- o que fazer nos golpes guardaveis
		local acoes = { "power_guard", "guarda" };
		local nomes_acoes = { "Guarda + especial (M5 + M2) - prioridade", "So a guarda (M5)" };
		local atual_acao = (op.acao_guardavel == "guarda") and 2 or 1;
		local alterou_acao, nova_acao = imgui.combo("Nos golpes guardaveis", atual_acao, nomes_acoes);
		if alterou_acao then op.acao_guardavel = acoes[nova_acao] or "power_guard"; mudou_defesa = true; end

		alterado, op.antecedencia_guarda_ms = imgui.slider_int("Levantar a guarda quantos ms antes do impacto", op.antecedencia_guarda_ms, 0, 500);
		mudou_defesa = mudou_defesa or alterado;};
my $new1 = q{		-- o que fazer nos golpes guardaveis
		local acoes = { "contra_ataque", "guarda" };
		local nomes_acoes = { "Contra-ataque (M5 e depois M2) - prioridade", "So a guarda (M5)" };
		local atual_acao = (op.acao_guardavel == "guarda") and 2 or 1;
		local alterou_acao, nova_acao = imgui.combo("Nos golpes guardaveis", atual_acao, nomes_acoes);
		if alterou_acao then op.acao_guardavel = acoes[nova_acao] or "contra_ataque"; mudou_defesa = true; end

		-- o que fazer nos golpes impossiveis de guardar
		local acoes_imp = { "esquiva", "power_guard" };
		local nomes_imp = { "Esquiva (Espaco)", "Power Guard (M5, M2 e Espaco) - testar se segura" };
		local atual_imp = (op.acao_impossivel == "power_guard") and 2 or 1;
		local alterou_imp, nova_imp = imgui.combo("Nos golpes impossiveis de guardar", atual_imp, nomes_imp);
		if alterou_imp then op.acao_impossivel = acoes_imp[nova_imp] or "esquiva"; mudou_defesa = true; end

		alterado, op.antecedencia_guarda_ms = imgui.slider_int("Guarda: quantos ms antes do impacto", op.antecedencia_guarda_ms, 0, 500);
		mudou_defesa = mudou_defesa or alterado;

		alterado, op.antecedencia_contra_ms = imgui.slider_int("Contra-ataque: quantos ms antes do impacto", op.antecedencia_contra_ms, 0, 800);
		mudou_defesa = mudou_defesa or alterado;

		alterado, op.antecedencia_power_ms = imgui.slider_int("Power Guard: quantos ms antes do impacto", op.antecedencia_power_ms, 0, 1000);
		mudou_defesa = mudou_defesa or alterado;};
die "menu1 nao achado" unless index($s, $old1) >= 0;
substr($s, index($s, $old1), length($old1)) = $new1;

my $old2 = q{		imgui.text("Guarda: " .. texto_botoes(op.botoes.guarda));
		imgui.text("Esquiva: " .. texto_botoes(op.botoes.esquiva));
		imgui.text("Guarda + especial (M5 + M2): " .. texto_botoes(op.botoes.power_guard));};
my $new2 = q{		imgui.text("Guarda (M5): " .. texto_botoes(op.botoes.guarda));
		imgui.text("Contra-ataque (M5 e depois M2): " .. texto_botoes(op.botoes.contra_ataque));
		imgui.text("Power Guard (M5, M2 e Espaco): " .. ((#(op.botoes.power_guard or {}) > 0)
			and texto_botoes(op.botoes.power_guard) or "montado com guarda + especial + Espaco"));
		imgui.text("Esquiva (Espaco): " .. texto_botoes(op.botoes.esquiva));};
die "menu2 nao achado" unless index($s, $old2) >= 0;
substr($s, index($s, $old2), length($old2)) = $new2;

my $old3 = q{			local alvos = { "guarda", "esquiva", "power_guard" };
			local nomes = { "Guarda", "Esquiva", "Guarda + especial (M5 + M2)" };};
my $new3 = q{			local alvos = { "guarda", "contra_ataque", "power_guard", "esquiva" };
			local nomes = { "Guarda (M5)", "Contra-ataque (M5 e depois M2)", "Power Guard (M5, M2 e Espaco)", "Esquiva (Espaco)" };};
die "menu3 nao achado" unless index($s, $old3) >= 0;
substr($s, index($s, $old3), length($old3)) = $new3;
print $s;
