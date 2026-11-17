local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 1.02 - |, q|	Versao 1.03 - LONG SWORD: PRIORIDADE 0 = SS+ISS, nada interrompe ele ate o fim da animacao (nem FS,
	nem esquiva, nem outro SS). PRIORIDADE 1 = FS e esquiva, forcados por cima de qualquer outra acao.
	Assim que a animacao do SS+ISS acaba, os tres ficam livres na hora.
	1.02 - |, "cab");
$s =~ s/versao_mod = "1\.02"/versao_mod = "1.03"/g or die "vm";
$s =~ s/== Defesa Automatica v1\.02 ==/== Defesa Automatica v1.03 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v1\.02"\)/imgui.tree_node("Defesa Automatica v1.03")/ or die "tit";

troca(q|local forcavel = n78.acao_de("fs") ~= nil and motivo ~= "sem barra de espirito"; -- (1.02) ISS tambem|,
	q|local forcavel = n78.acao_de("fs") ~= nil and motivo ~= "sem barra de espirito" and motivo ~= "postura / ISS"; -- (1.03) nunca por cima do SS+ISS|, "forcavel");
troca(q|		-- (1.02) durante o ISS o FS / esquiva tambem podem ser forcados (so o SS+ISS novo espera)|,
q|		-- (1.03) PRIORIDADE 0: o SS+ISS nao e interrompido por nada ate a animacao acabar
		if ANIM_ISS[combo.animacao or "?"] or n78.ls_em_iai() then
			estado.ultima_decisao = "SS+ISS na tela: nada por cima ate acabar";
			return;
		end|, "iss_espera");
troca(q|				estado.ultima_decisao = "SS+ISS ainda na tela: SS novo espera (FS / esquiva livres)";
				return false; -- (1.02) so o SS espera; FS e esquiva seguem|,
q|				estado.ultima_decisao = "SS+ISS na tela: nada por cima ate acabar";
				return true; -- (1.03) prioridade 0: nem SS novo, nem FS, nem esquiva|, "iai");
print $s;
