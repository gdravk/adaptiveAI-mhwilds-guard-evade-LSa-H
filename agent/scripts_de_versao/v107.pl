local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 1.06 - |, q|	Versao 1.07 - LONG SWORD: FS com a barra de espirito vazia NAO tem invencibilidade (pesquisa): sem barra
	o mod nunca usa o FS, nem no vermelho (antes o vermelho era excecao) - vai para o SS+ISS (se der tempo)
	ou a esquiva.
	1.06 - |, "cab");
$s =~ s/versao_mod = "1\.06"/versao_mod = "1.07"/g or die "vm";
$s =~ s/== Defesa Automatica v1\.06 ==/== Defesa Automatica v1.07 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v1\.06"\)/imgui.tree_node("Defesa Automatica v1.07")/ or die "tit";

troca(q|	if barra ~= nil and barra <= 0.1 and not (n78.barra_vermelha and n78.barra_vermelha()) then|,
	q|	if barra ~= nil and barra <= 0.1 then -- (1.07) sem barra o FS nao tem invencibilidade, tambem no vermelho|, "barra");
print $s;
