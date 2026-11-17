local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.76 - |, q|	Versao 0.77 - barra de previsao: opcao "Desligar a barra" (nunca mostra a barra); a aba
	"Configurar Barra de previsao" ja vem aberta na primeira vez
	0.76 - |, "cab");
$s =~ s/versao_mod = "0\.76"/versao_mod = "0.77"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.76 ==/== Defesa Automatica v0.77 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.76"\)/imgui.tree_node("Defesa Automatica v0.77")/ or die "tit";

troca(q|	barra_sempre_visivel = false,|, q|	barra_desligada = false, -- (0.77) true = a barra de previsao nunca aparece
	barra_sempre_visivel = false,|, "op");

troca(q|	if not op.ativado then return; end

	local momento = agora();|, q|	if not op.ativado or op.barra_desligada then return; end -- (0.77) "Desligar a barra"

	local momento = agora();|, "desligar");

troca(q|	if imgui.tree_node("Configurar Barra de previsao") then
		estado.barra_exemplo_ate = os.clock() + 0.3;
		local mudou_barra, m_b = false, false;|, q|	pcall(imgui.set_next_item_open, true, 4); -- (0.77) aberta na primeira vez (se o REFramework tiver)
	if imgui.tree_node("Configurar Barra de previsao") then
		estado.barra_exemplo_ate = os.clock() + 0.3;
		local mudou_barra, m_b = false, false;
		m_b, op.barra_desligada = imgui.checkbox("Desligar a barra (nunca mostra a barra de previsao)", op.barra_desligada == true);
		mudou_barra = mudou_barra or m_b;
		if not op.barra_desligada then
			imgui.text("Enquanto esta aba estiver aberta aparece uma barra de exemplo na tela.");
		end|, "menu");

print $s;
