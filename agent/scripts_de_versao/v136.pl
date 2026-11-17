local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; die "$nome repetido" if index($s, $velho, $i + length($novo)) >= 0; }
sub troca_todas { my ($velho, $novo, $nome) = @_; my $n = ($s =~ s/\Q$velho\E/$novo/g); die "$nome nao achado" unless $n; return $n; }
troca(q|	Versao 1.35 - (lutas 1.34 no SOS com a Lanca)|,
q|	Versao 1.36 - NOME DO SAVAGE OMEGA PLANETES: o jogo da o mesmo nome ("Omega Planetes") para o normal e para o
	Savage; o Savage vem com a marca de dificuldade 1 e o mod o chamava de "Tempered Omega Planetes" (nao existe
	Tempered Omega no jogo). O aprendizado ja era separado (34 = normal, 34:t = Savage); so o nome muda.
	1.35 - (lutas 1.34 no SOS com a Lanca)|, "cabecalho");
troca_todas(q|versao_mod = "1.35"|, q|versao_mod = "1.36"|, "versao");
troca(q|Defesa Automatica v1.35") then|, q|Defesa Automatica v1.36") then|, "menu");
troca(q|linha("== Defesa Automatica v1.35 ==");|, q|linha("== Defesa Automatica v1.36 ==");|, "relatorio");
troca(q|		m.nome_completo = prefixo .. tostring(m.nome);
|, q|		m.nome_completo = prefixo .. tostring(m.nome);
		-- (1.36) o Savage Omega Planetes vem com o mesmo nome do normal e a marca 1 (nao existe Tempered Omega)
		if m.variante == "34:t" then m.nome_completo = "Savage Omega Planetes"; end
|, "savage");
print $s;
