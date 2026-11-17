local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.73 - |, q|	Versao 0.74 - barra de previsao fixa: mostra sempre 4s (o maximo que o mod preve), mais larga
	para caber os 4s; sem menu e sem numeros (a altura volta a ser a de antes)
	0.73 - |, "cab");
$s =~ s/versao_mod = "0\.73"/versao_mod = "0.74"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.73 ==/== Defesa Automatica v0.74 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.73"\)/imgui.tree_node("Defesa Automatica v0.74")/ or die "tit";

troca(q|
	largura_barra = 420,    -- (0.73) largura da barra (em tela 1080p)
	mostrar_segundos = true, -- (0.73) segundos que faltam embaixo de cada golpe
	janela_073 = false,     -- (0.73) mudanca unica da janela de 1,2s para 3s|, q||, "op");

troca(q|	-- (0.73) a barra mostrava so 1,2s; o mod preve ate 4s a frente. Uma vez so: passa para 3s
	if not op.janela_073 then
		op.janela_073 = true;
		if op.janela <= 1.2 then op.janela = 3.0; end
	end
|, q||, "migra");

troca(q|	local janela = op.janela;|, q|	-- (0.74) a barra mostra sempre 4s (o mod preve golpes ate 4s depois da animacao do monstro)
	local janela = 4.0;
	op.altura_tela = 0.70; -- (0.74) altura de antes (a 0.73 deixava mudar no menu)|, "janela");

troca(q|	local largura = (op.largura_barra or 420) * e; -- (0.73) ajustavel no menu|,
q|	local largura = 900 * e; -- (0.74) mais larga para caber os 4s (era 420 para 1,2s)|, "larg");

troca(q|		if op.mostrar_segundos and v.falta >= 0 then -- (0.73)
			texto_com_sombra(string.format("%.1f", v.falta), x - 9 * e, y0 + 42 * e, cor);
		end
|, q||, "segundos");

troca(q|	-- (0.73) ajustes da barra de previsao no meio da tela
	if imgui.tree_node("Barra de previsao") then
		mudou_simples, op.janela = imgui.slider_float("Quanto tempo a barra mostra (s)", op.janela, 1.2, 4.0, "%.1f");
		alterou_simples = alterou_simples or mudou_simples;
		mudou_simples, op.largura_barra = imgui.slider_int("Largura", op.largura_barra or 420, 300, 1400);
		alterou_simples = alterou_simples or mudou_simples;
		mudou_simples, op.altura_tela = imgui.slider_float("Altura na tela (0 = topo, 1 = embaixo)", op.altura_tela, 0.1, 0.95, "%.2f");
		alterou_simples = alterou_simples or mudou_simples;
		mudou_simples, op.mostrar_segundos = imgui.checkbox("Mostrar os segundos que faltam", op.mostrar_segundos);
		alterou_simples = alterou_simples or mudou_simples;
		imgui.tree_pop();
	end

|, q||, "menu");

print $s;
