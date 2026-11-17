local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.74 - |, q|	Versao 0.75 - nova aba "Configurar Barra de previsao" no menu: tamanho, opacidade, posicao
	vertical e horizontal da barra (com uma barra de exemplo enquanto a aba esta aberta)
	0.74 - |, "cab");
$s =~ s/versao_mod = "0\.74"/versao_mod = "0.75"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.74 ==/== Defesa Automatica v0.75 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.74"\)/imgui.tree_node("Defesa Automatica v0.75")/ or die "tit";

troca(q|	altura_tela = 0.70,     -- altura da barra na tela (0 = topo, 1 = embaixo)|,
q|	altura_tela = 0.70,     -- altura da barra na tela (0 = topo, 1 = embaixo)
	-- (0.75) aba "Configurar Barra de previsao"
	barra_tamanho = 1.0,    -- tamanho da barra (1 = normal)
	barra_opacidade = 1.0,  -- 0,1 = quase transparente, 1 = solida
	barra_horizontal = 0.5, -- centro da barra na tela (0 = esquerda, 0,5 = meio, 1 = direita)|, "op");

# cancelar SS acompanha a barra
troca(q|		local esc = altura_t / 1080;
		local larg_q, alt_q = 150 * esc, 30 * esc;
		local xq = largura_t / 2 - larg_q / 2;|, q|		local esc = altura_t / 1080 * (op.barra_tamanho or 1); -- (0.75) acompanha a barra
		local larg_q, alt_q = 150 * esc, 30 * esc;
		local xq = largura_t * (op.barra_horizontal or 0.5) - larg_q / 2;|, "cancelar");

troca(q|	op.altura_tela = 0.70; -- (0.74) altura de antes (a 0.73 deixava mudar no menu)
|, q||, "altura_fixa");

troca(q|	if #visiveis == 0 then return; end
	table.sort(visiveis, function(a, b) return a.falta < b.falta; end);

	local largura_tela, altura_tela = tamanho_tela();
	local e = altura_tela / 1080;

	local largura = 900 * e; -- (0.74) mais larga para caber os 4s (era 420 para 1,2s)
	local x0 = largura_tela / 2 - largura / 2;|, q|	-- (0.75) barra de exemplo enquanto a aba "Configurar Barra de previsao" esta aberta
	if estado.barra_exemplo_ate ~= nil and os.clock() < estado.barra_exemplo_ate then
		local ciclo = os.clock() % 4.0;
		visiveis[#visiveis + 1] = { falta = 4.0 - ciclo, guarda = 0 };
		visiveis[#visiveis + 1] = { falta = (6.0 - ciclo) % 4.0, guarda = 2 };
	end
	if #visiveis == 0 then return; end
	table.sort(visiveis, function(a, b) return a.falta < b.falta; end);

	local largura_tela, altura_tela = tamanho_tela();
	local e = altura_tela / 1080 * (op.barra_tamanho or 1); -- (0.75) tamanho ajustavel

	-- (0.75) opacidade: muda so o canal alfa das cores (formato 0xAABBGGRR)
	local opac = math.max(0.1, math.min(1, op.barra_opacidade or 1));
	local function o(cor)
		local alfa = cor // 0x1000000;
		return math.floor(alfa * opac) * 0x1000000 + cor % 0x1000000;
	end
	local function texto_o(txt, x, y, cor)
		draw.text(txt, x + 1, y + 1, o(COR.sombra));
		draw.text(txt, x, y, o(cor));
	end

	local largura = 900 * e; -- (0.74) mais larga para caber os 4s (era 420 para 1,2s)
	local x_centro = largura_tela * (op.barra_horizontal or 0.5); -- (0.75) posicao horizontal
	local x0 = x_centro - largura / 2;|, "inicio");

troca(q|	draw.filled_rect(x0, y0, largura, 10 * e, COR.trilha);
	draw.filled_rect(x_alvo - 2 * e, y0 - 8 * e, 4 * e, 26 * e, COR.alvo);|,
q|	draw.filled_rect(x0, y0, largura, 10 * e, o(COR.trilha));
	draw.filled_rect(x_alvo - 2 * e, y0 - 8 * e, 4 * e, 26 * e, o(COR.alvo));|, "trilha");
troca(q|		draw.filled_rect(xs - 1 * e, y0 + 10 * e, 2 * e, 6 * e, COR.alvo);|,
q|		draw.filled_rect(xs - 1 * e, y0 + 10 * e, 2 * e, 6 * e, o(COR.alvo));|, "marcas");
troca(q|		draw.filled_rect(x - 5 * e, y0 - 6 * e, 10 * e, 22 * e, cor);|,
q|		draw.filled_rect(x - 5 * e, y0 - 6 * e, 10 * e, 22 * e, o(cor));|, "marcador");
troca(q|	texto_com_sombra(texto, x0, y0 - 30 * e, cor);

	-- "AGORA!" pouco antes do impacto
	if proximo.falta <= antecedencia then
		draw.filled_rect(x0, y0 + 16 * e, largura, 22 * e, COR.agora);
		texto_com_sombra("AGORA!", largura_tela / 2 - 24, y0 + 19 * e, COR.sombra);|,
q|	texto_o(texto, x0, y0 - 30 * e, cor);

	-- "AGORA!" pouco antes do impacto
	if proximo.falta <= antecedencia then
		draw.filled_rect(x0, y0 + 16 * e, largura, 22 * e, o(COR.agora));
		texto_o("AGORA!", x_centro - 24, y0 + 19 * e, COR.sombra);|, "agora");

# aba no menu
troca(q|	if alterou_simples then salvar_opcoes(); end
|, q|	if alterou_simples then salvar_opcoes(); end

	-- (0.75) aba da barra de previsao (com uma barra de exemplo enquanto esta aberta)
	if imgui.tree_node("Configurar Barra de previsao") then
		estado.barra_exemplo_ate = os.clock() + 0.3;
		local mudou_barra, m_b = false, false;
		m_b, op.barra_tamanho = imgui.slider_float("Tamanho", op.barra_tamanho or 1, 0.5, 2.0, "%.2f");
		mudou_barra = mudou_barra or m_b;
		m_b, op.barra_opacidade = imgui.slider_float("Opacidade", op.barra_opacidade or 1, 0.1, 1.0, "%.2f");
		mudou_barra = mudou_barra or m_b;
		m_b, op.altura_tela = imgui.slider_float("Posicao vertical (0 = topo, 1 = embaixo)", op.altura_tela or 0.7, 0.05, 0.95, "%.2f");
		mudou_barra = mudou_barra or m_b;
		m_b, op.barra_horizontal = imgui.slider_float("Posicao horizontal (0 = esquerda, 1 = direita)", op.barra_horizontal or 0.5, 0.05, 0.95, "%.2f");
		mudou_barra = mudou_barra or m_b;
		if imgui.button("Voltar ao padrao") then
			op.barra_tamanho, op.barra_opacidade, op.altura_tela, op.barra_horizontal = 1.0, 1.0, 0.70, 0.5;
			mudou_barra = true;
		end
		if mudou_barra then salvar_opcoes(); end
		imgui.tree_pop();
	end
|, "menu");

print $s;
