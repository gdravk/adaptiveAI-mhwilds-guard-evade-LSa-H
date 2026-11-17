local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 1.03 - |, q|	Versao 1.04 - LONG SWORD: prioridades SS+ISS 0, FS 1, esquiva 2. O FS so e usado depois de um golpe
	seu (dentro do combo), como no jogo; fora do combo vai direto a esquiva. Dentro do combo o FS continua
	forcado por cima do seu golpe.
	1.03 - |, "cab");
$s =~ s/versao_mod = "1\.03"/versao_mod = "1.04"/g or die "vm";
$s =~ s/== Defesa Automatica v1\.03 ==/== Defesa Automatica v1.04 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v1\.03"\)/imgui.tree_node("Defesa Automatica v1.04")/ or die "tit";

troca(q|			if n78.acao_de("fs") == nil and not em_combo_espada_longa() then return "indisponivel", "fora do combo"; end|,
	q|			if not em_combo_espada_longa() then return "indisponivel", "fora do combo"; end -- (1.04) FS so depois de um golpe seu|, "exec");
troca(q|				elseif not em_combo_espada_longa(somente and "ss" or "fs") and n78.acao_de("fs") == nil then|,
	q|				elseif not em_combo_espada_longa(somente and "ss" or "fs") then -- (1.04) fora do combo: esquiva|, "decide");
print $s;
