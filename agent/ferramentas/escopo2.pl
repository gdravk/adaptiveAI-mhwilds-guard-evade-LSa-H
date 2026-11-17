# Checagem de escopo de Lua (simplificada): acha nomes usados que nao sao locais visiveis nem globais conhecidos.
use strict; use warnings;
local $/; my $src = <STDIN>;
my @t; # [tipo, valor, linha]
my $linha = 1; my $i = 0; my $n = length $src;
while ($i < $n) {
	my $c = substr($src, $i, 1);
	if ($c eq "\n") { $linha++; $i++; next; }
	if ($c =~ /\s/) { $i++; next; }
	if (substr($src, $i, 2) eq '--') {
		if (substr($src, $i + 2) =~ /^\[(=*)\[/) {
			my $eq = $1; my $fim = index($src, "]$eq]", $i);
			my $txt = substr($src, $i, $fim + length($eq) + 2 - $i); $linha += ($txt =~ tr/\n//); $i = $fim + length($eq) + 2; next;
		}
		my $fim = index($src, "\n", $i); $fim = $n if $fim < 0; $i = $fim; next;
	}
	if ($c eq '[' && substr($src, $i) =~ /^\[(=*)\[/) {
		my $eq = $1; my $fim = index($src, "]$eq]", $i);
		my $txt = substr($src, $i, $fim + length($eq) + 2 - $i); $linha += ($txt =~ tr/\n//);
		push @t, ['str', '', $linha]; $i = $fim + length($eq) + 2; next;
	}
	if ($c eq '"' || $c eq "'") {
		my $j = $i + 1;
		while ($j < $n) { my $d = substr($src, $j, 1); if ($d eq '\\') { $j += 2; next; } last if $d eq $c; $linha++ if $d eq "\n"; $j++; }
		push @t, ['str', '', $linha]; $i = $j + 1; next;
	}
	if (substr($src, $i) =~ /^([A-Za-z_][A-Za-z0-9_]*)/) { push @t, ['nome', $1, $linha]; $i += length $1; next; }
	if (substr($src, $i) =~ /^(0[xX][0-9a-fA-F]+|\d+\.?\d*(?:[eE][-+]?\d+)?|\.\d+)/) { push @t, ['num', $1, $linha]; $i += length $1; next; }
	if (substr($src, $i) =~ /^(\.\.\.|\.\.|==|~=|<=|>=|::|<<|>>|\/\/)/) { push @t, ['sim', $1, $linha]; $i += length $1; next; }
	push @t, ['sim', $c, $linha]; $i++;
}
my %kw = map { $_ => 1 } qw(and break do else elseif end false for function goto if in local nil not or repeat return then true until while);
my %glob = map { $_ => 1 } qw(sdk re imgui json string table math os pairs ipairs tostring tonumber type pcall next print ValueType log draw require select error setmetatable getmetatable unpack collectgarbage thread fs rawget rawset assert xpcall utf8 coroutine io debug package _G _ENV Vector3f Vector2f Vector4f self);
my @esc = ({__raiz => "chunk"}); my %maxloc; # pilha de escopos
my @pilha; # contexto: '{', '(', '[', 'blk'
my %glob_def; my @usos;
sub declara { $esc[-1]{$_[0]} = 1; my $n = 0; my $r = "?"; for my $e (reverse @esc) { $n += scalar(grep { $_ ne "__raiz" } keys %$e); if ($e->{__raiz}) { $r = $e->{__raiz}; last; } } $maxloc{$r} = $n if !defined $maxloc{$r} || $n > $maxloc{$r}; }
sub visivel { my $x = shift; for my $e (reverse @esc) { return 1 if $e->{$x}; } return 0; }
my @pend; my $modo = ''; # declaracoes pendentes (for / function params)
for (my $k = 0; $k < @t; $k++) {
	my ($tp, $v, $l) = @{$t[$k]};
	my $ant = $k > 0 ? $t[$k-1][1] : '';
	my $prox = $k + 1 < @t ? $t[$k+1][1] : '';
	if ($tp eq 'sim') {
		if ($v eq '{' || $v eq '(' || $v eq '[') { push @pilha, $v; }
		elsif ($v eq '}' || $v eq ')' || $v eq ']') { pop @pilha; }
		next;
	}
	next unless $tp eq 'nome';
	if ($kw{$v}) {
		if ($v eq "function") {
			push @esc, {__raiz => "funcao linha $l"}; push @pilha, 'blk';
			# nome da funcao (function a.b:c / function nome)
			my $m = $k + 1;
			if ($t[$m][1] ne '(') {
				my $primeiro = $t[$m][1]; my $metodo = 0; my $simples = 1;
				while ($t[$m][1] ne '(') { $metodo = 1 if $t[$m][1] eq ':'; $simples = 0 if $t[$m][1] eq '.' || $t[$m][1] eq ':'; $m++; }
				if ($ant eq 'local') { $esc[-2]{$primeiro} = 1; }
				elsif ($simples) { $glob_def{$primeiro} = 1 unless visivel($primeiro); }
				else { my $vis = 0; for my $e (@esc[0..$#esc-1]) { $vis = 1 if $e->{$primeiro}; } push @usos, [$primeiro, $t[$k+1][2]] unless $vis || $glob{$primeiro}; }
				declara('self') if $metodo;
			}
			$m++; # depois do (
			while ($t[$m][1] ne ')') { declara($t[$m][1]) if $t[$m][0] eq 'nome'; $m++; }
			$k = $m; pop @pilha; push @pilha, 'blk'; # o ( foi pulado
			next;
		}
		if ($v eq 'local') {
			next if $prox eq 'function';
			my $m = $k + 1; my @nomes;
			while (1) { push @nomes, $t[$m][1]; $m++; if ($t[$m][1] eq '<') { $m += 3; } last unless $t[$m][1] eq ','; $m++; }
			# usos na expressao antes de declarar: processa normal, declara no fim da instrucao (aprox.: ja declara)
			declara($_) for @nomes; $k = $m - 1; next;
		}
		if ($v eq 'for') {
			my $m = $k + 1; @pend = ();
			while ($t[$m][1] ne '=' && $t[$m][1] ne 'in') { push @pend, $t[$m][1] if $t[$m][0] eq 'nome'; $m++; }
			$k = $m; $modo = 'for'; next;
		}
		if ($v eq 'do') { push @esc, {}; push @pilha, 'blk'; if ($modo eq 'for') { declara($_) for @pend; @pend = (); $modo = ''; } next; }
		if ($v eq 'then') { push @esc, {}; push @pilha, 'blk'; next; }
		if ($v eq 'repeat') { push @esc, {}; push @pilha, 'blk'; next; }
		if ($v eq 'elseif' || $v eq 'else') { pop @esc; pop @pilha; if ($v eq 'else') { push @esc, {}; push @pilha, 'blk'; } next; }
		if ($v eq 'end' || $v eq 'until') { pop @esc; pop @pilha; next; }
		next;
	}
	next if $ant eq '.' || $ant eq ':' || $ant eq '::';
	next if $ant eq 'goto';
	# chave de tabela: { nome = ...
	if ($prox eq '=' && $t[$k+2][1] ne '=' && @pilha && $pilha[-1] eq '{') { next; }
	if (visivel($v) || $glob{$v}) { next; }
	# atribuicao global: nome = ... (instrucao)
	if ($prox eq '=' && (!@pilha || $pilha[-1] eq 'blk')) { $glob_def{$v} = 1; next; }
	push @usos, [$v, $l, undef];
}
my %vistos;
for my $u (@usos) {
	my ($v, $l) = @$u;
	next if $glob_def{$v};
	next if $kw{$v};
	print "linha $l: '$v' nao e local visivel nem global conhecido\n" unless $vistos{"$v:$l"}++;
}
my @top = sort { $maxloc{$b} <=> $maxloc{$a} } keys %maxloc; print "mais locais ativos: ", join(", ", map { "$_=$maxloc{$_}" } @top[0..4]), "
"; print "globais definidas: ", join(", ", sort keys %glob_def), "\n";
