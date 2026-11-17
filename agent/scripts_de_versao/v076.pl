local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.75 - |, q|	Versao 0.76 - barra de previsao: opcao "Sempre visivel" (a barra fica na tela mesmo sem golpe
	vindo; desligada = automatico, como antes: aparece so quando um golpe vem)
	0.75 - |, "cab");
$s =~ s/versao_mod = "0\.75"/versao_mod = "0.76"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.75 ==/== Defesa Automatica v0.76 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.75"\)/imgui.tree_node("Defesa Automatica v0.76")/ or die "tit";

troca(q|	barra_horizontal = 0.5, -- centro|, q|	barra_sempre_visivel = false, -- (0.76) false = automatico (so aparece com golpe vindo)
	barra_horizontal = 0.5, -- centro|, "op");

troca(q|	if #visiveis == 0 then return; end
	table.sort(visiveis|, q|	if #visiveis == 0 and not op.barra_sempre_visivel then return; end -- (0.76)
	table.sort(visiveis|, "vazio");

troca(q|	local proximo = visiveis[1];
	local texto, cor = estilo_do_golpe(proximo.guarda);|, q|	local proximo = visiveis[1];
	if proximo == nil then return; end -- (0.76) sempre visivel e nenhum golpe vindo: so a trilha
	local texto, cor = estilo_do_golpe(proximo.guarda);|, "proximo");

troca(q|		m_b, op.barra_tamanho = imgui.slider_float(|, q|		m_b, op.barra_sempre_visivel = imgui.checkbox("Sempre visivel (desligado = automatico: so aparece com golpe vindo)", op.barra_sempre_visivel == true);
		mudou_barra = mudou_barra or m_b;
		m_b, op.barra_tamanho = imgui.slider_float(|, "menu");

print $s;
