local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.71 - |, q|	Versao 0.72 - trava: o FS e o ISS tambem sao medidos (quanto prendem e o que vem depois deles: o M1
	no lugar ou os 2 golpes pulando para frente do M5); antes, depois de um FS o mod nao sabia quanto
	tempo o seu proximo aperto ia prender
	0.71 - |, "cab");
$s =~ s/versao_mod = "0\.71"/versao_mod = "0.72"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.71 ==/== Defesa Automatica v0.72 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.71"\)/imgui.tree_node("Defesa Automatica v0.72")/ or die "tit";

troca(q|	if not e_golpe_seu(anim) then return 0; end|, q|	-- (0.72) o FS e o ISS tambem prendem o personagem (medidos a parte)
	if not (e_golpe_seu(anim) or ANIM_FS[anim] or ANIM_ISS[anim]) then return 0; end|, "resto");

troca(q|	if not e_golpe_seu(antes) or durou < 0.08 or durou > 3 then return; end|,
q|	--[[
		(0.72) SEGUIMENTOS DO FS / ISS: depois do FS (esquiva curta para tras) o M1 da um golpe no
		lugar e o M5 da 2 golpes pulando para frente (otimo para reposicionar). O FS e o ISS agora
		tambem sao medidos: quanto prendem e quais golpes vem depois deles. Eles NAO entram como
		"proximo golpe" dos seus ataques (isso travava demais na 0.64).
	]]
	if not (e_golpe_seu(antes) or ANIM_FS[antes] or ANIM_ISS[antes]) or durou < 0.08 or durou > 3 then return; end|, "medir");

print $s;
