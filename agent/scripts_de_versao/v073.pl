local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.72 - |, q|	Versao 0.73 - barra de previsao: ajustes no menu ("Barra de previsao"): quanto tempo ela mostra
	(1,2s a 4s; padrao agora 3s - o mod ja previa golpes ate 4s a frente, a barra so mostrava 1,2s),
	largura, altura na tela, segundos que faltam em cada golpe e marcas de 1 em 1 segundo
	0.72 - |, "cab");
$s =~ s/versao_mod = "0\.72"/versao_mod = "0.73"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.72 ==/== Defesa Automatica v0.73 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.72"\)/imgui.tree_node("Defesa Automatica v0.73")/ or die "tit";

troca(q|	altura_tela = 0.70,     -- altura da barra na tela (0 = topo, 1 = embaixo)|,
q|	altura_tela = 0.70,     -- altura da barra na tela (0 = topo, 1 = embaixo)
	largura_barra = 420,    -- (0.73) largura da barra (em tela 1080p)
	mostrar_segundos = true, -- (0.73) segundos que faltam embaixo de cada golpe
	janela_073 = false,     -- (0.73) mudanca unica da janela de 1,2s para 3s|, "op");

troca(q|	op.versao_campos = 9;
|, q|	op.versao_campos = 9;
	-- (0.73) a barra mostrava so 1,2s; o mod preve ate 4s a frente. Uma vez so: passa para 3s
	if not op.janela_073 then
		op.janela_073 = true;
		if op.janela <= 1.2 then op.janela = 3.0; end
	end
|, "migra");

troca(q|	local largura = 420 * e;|, q|	local largura = (op.largura_barra or 420) * e; -- (0.73) ajustavel no menu|, "larg");

troca(q|	draw.filled_rect(x_alvo - 2 * e, y0 - 8 * e, 4 * e, 26 * e, COR.alvo);
|, q|	draw.filled_rect(x_alvo - 2 * e, y0 - 8 * e, 4 * e, 26 * e, COR.alvo);
	-- (0.73) marcas de 1 em 1 segundo (para ler quanto falta)
	for s = 1, math.floor(janela) do
		local xs = x_alvo + (s / janela) * (x_fim - x_alvo);
		draw.filled_rect(xs - 1 * e, y0 + 10 * e, 2 * e, 6 * e, COR.alvo);
	end
|, "marcas");

troca(q|		draw.filled_rect(x - 5 * e, y0 - 6 * e, 10 * e, 22 * e, cor);
|, q|		draw.filled_rect(x - 5 * e, y0 - 6 * e, 10 * e, 22 * e, cor);
		if op.mostrar_segundos and v.falta >= 0 then -- (0.73)
			texto_com_sombra(string.format("%.1f", v.falta), x - 9 * e, y0 + 42 * e, cor);
		end
|, "segundos");

troca(q|	if alterou_simples then salvar_opcoes(); end
|, q|	-- (0.73) ajustes da barra de previsao no meio da tela
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

	if alterou_simples then salvar_opcoes(); end
|, "menu");

print $s;
