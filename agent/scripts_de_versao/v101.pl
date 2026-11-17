local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 1.00 - |, q|	Versao 1.01 - LONG SWORD (luta contra a Lagiacrus): o SS nao e mais pedido durante uma esquiva ou um
	dano (o jogo ignorava e saia "SS nao saiu (saiu esquiva)"); o mod espera a esquiva / o dano acabar e
	faz o SS+ISS em seguida, se ainda der tempo.
	1.00 - |, "cab");
$s =~ s/versao_mod = "1\.00"/versao_mod = "1.01"/g or die "vm";
$s =~ s/== Defesa Automatica v1\.00 ==/== Defesa Automatica v1.01 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v1\.00"\)/imgui.tree_node("Defesa Automatica v1.01")/ or die "tit";

troca(q|			if not op.usar_ss_iss or #m5 == 0 or #espaco == 0 then return false; end
			local p, m = golpe_mais_proximo(momento);|, q|			if not op.usar_ss_iss or #m5 == 0 or #espaco == 0 then return false; end
			-- (1.01) numa esquiva ou num dano o SS pedido e ignorado: espera acabar (o FS / esquiva seguem livres)
			local atual_ss = estado.acao_nome_ultimo or "";
			if anim == "20:61" or string.sub(anim, 1, 3) == "14:" or string.sub(atual_ss, 1, 7) == "cDamage"
				or (string.sub(atual_ss, 1, 6) == "cDodge" and string.find(atual_ss, "To", 7, true) == nil) then
				return false;
			end
			local p, m = golpe_mais_proximo(momento);|, "ls_esquiva");
print $s;
