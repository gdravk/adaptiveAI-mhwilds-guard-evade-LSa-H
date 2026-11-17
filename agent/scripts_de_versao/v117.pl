local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 1.16 - |, q|	Versao 1.17 - VERIFICACAO: o dano na postura so conta contra o golpe alvo do SS se chegou perto da hora
	dele (ate 0,8s) - antes um golpe nao previsto no meio da postura tirava do SS+ISS um golpe que funcionava.
	O dano no ISS conta contra o golpe em que o ISS foi solto. Contra do ISS arredondado no relatorio.
	1.16 - |, "cab");
$s =~ s/versao_mod = "1\.16"/versao_mod = "1.17"/g or die "vm";
$s =~ s/== Defesa Automatica v1\.16 ==/== Defesa Automatica v1.17 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v1\.16"\)/imgui.tree_node("Defesa Automatica v1.17")/ or die "tit";

troca(q|			if levou and not ssiss.manual then n78.anotar_dano_ss(ssiss.chave); end -- (1.15)|,
q|			-- (1.15 / 1.17) so conta contra o golpe alvo se o dano veio perto da hora dele
			if levou and not ssiss.manual and ssiss.alvo ~= nil and math.abs(ssiss.alvo.tempo - momento) <= 0.8 then
				n78.anotar_dano_ss(ssiss.chave);
			end|, "postura");
troca(q|			if not ssiss.manual then n78.anotar_dano_ss(ssiss.chave); end -- (1.15)|,
	q|			if not ssiss.manual then n78.anotar_dano_ss(ssiss.chave_iss or ssiss.chave); end -- (1.17) o golpe do ISS|, "iss");
troca(q|				r_iss.n, tostring((n78.janelas_jogo or {}).contra and n78.janelas_jogo.contra[1] or "-"), r_iss.com_inv,|,
	q|				r_iss.n, tostring((n78.janelas_jogo or {}).contra and n78.janelas_jogo.contra[1] and arredondar(n78.janelas_jogo.contra[1], 2) or "-"), r_iss.com_inv,|, "arred");
print $s;
