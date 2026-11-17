# Verificador de sintaxe Lua 5.4 (analisador descendente recursivo, sem executar nada)
use strict; use warnings;
local $/; my $src = <STDIN>;
my @t; my $linha = 1; my $i = 0; my $n = length $src;
sub erro_lex { die "linha $linha: $_[0]\n"; }
while ($i < $n) {
	my $c = substr($src, $i, 1);
	if ($c eq "\n") { $linha++; $i++; next; }
	if ($c =~ /\s/) { $i++; next; }
	if (substr($src, $i, 2) eq '--') {
		if (substr($src, $i + 2, 200) =~ /^\[(=*)\[/) {
			my $eq = $1; my $fim = index($src, "]$eq]", $i); erro_lex("comentario longo sem fim") if $fim < 0;
			my $txt = substr($src, $i, $fim + length($eq) + 2 - $i); $linha += ($txt =~ tr/\n//); $i = $fim + length($eq) + 2; next;
		}
		my $fim = index($src, "\n", $i); $fim = $n if $fim < 0; $i = $fim; next;
	}
	if ($c eq '[' && substr($src, $i, 200) =~ /^\[(=*)\[/) {
		my $eq = $1; my $fim = index($src, "]$eq]", $i); erro_lex("texto longo sem fim") if $fim < 0;
		my $l0 = $linha; my $txt = substr($src, $i, $fim + length($eq) + 2 - $i); $linha += ($txt =~ tr/\n//);
		push @t, ['str', 'STR', $l0]; $i = $fim + length($eq) + 2; next;
	}
	if ($c eq '"' || $c eq "'") {
		my $j = $i + 1; my $l0 = $linha;
		while (1) {
			erro_lex("texto sem fim") if $j >= $n;
			my $d = substr($src, $j, 1);
			if ($d eq '\\') { $linha++ if substr($src, $j + 1, 1) eq "\n"; $j += 2; next; }
			last if $d eq $c;
			erro_lex("quebra de linha dentro de texto") if $d eq "\n";
			$j++;
		}
		push @t, ['str', 'STR', $l0]; $i = $j + 1; next;
	}
	if (substr($src, $i, 100) =~ /^([A-Za-z_][A-Za-z0-9_]*)/) { push @t, ['nome', $1, $linha]; $i += length $1; next; }
	if (substr($src, $i, 100) =~ /^(0[xX][0-9a-fA-F]+(?:\.[0-9a-fA-F]*)?(?:[pP][-+]?\d+)?|\d+\.?\d*(?:[eE][-+]?\d+)?|\.\d+(?:[eE][-+]?\d+)?)/) { push @t, ['num', 'NUM', $linha]; $i += length $1; next; }
	if (substr($src, $i, 3) =~ /^(\.\.\.|\.\.|==|~=|<=|>=|::|<<|>>|\/\/)/) { push @t, ['sim', $1, $linha]; $i += length $1; next; }
	erro_lex("caractere estranho '$c'") unless $c =~ /[-+*\/%^#&~|<>=(){}\[\];:,.]/;
	push @t, ['sim', $c, $linha]; $i++;
}
push @t, ['fim', 'FIM', $linha];
my %kw = map { $_ => 1 } qw(and break do else elseif end false for function goto if in local nil not or repeat return then true until while);
my $p = 0;
sub v { return $t[$p][1]; } sub tp { return $t[$p][0]; }
sub e_kw { my $x = shift; return tp() eq 'nome' && v() eq $x; }
sub e_sim { my $x = shift; return tp() eq 'sim' && v() eq $x; }
sub falha { die "linha $t[$p][2]: $_[0] (encontrou '" . v() . "')\n"; }
sub espera_kw { my $x = shift; falha("esperava '$x'") unless e_kw($x); $p++; }
sub espera_sim { my $x = shift; falha("esperava '$x'") unless e_sim($x); $p++; }
sub nome { falha("esperava um nome") unless tp() eq 'nome' && !$kw{v()}; $p++; }
sub fim_bloco { return tp() eq 'fim' || e_kw('end') || e_kw('else') || e_kw('elseif') || e_kw('until'); }
sub bloco {
	while (!fim_bloco()) {
		if (e_kw('return')) {
			$p++;
			if (!fim_bloco() && !e_sim(';')) { lista_exp(); }
			$p++ if e_sim(';');
			falha("'return' tem que ser a ultima instrucao do bloco") unless fim_bloco();
			return;
		}
		instrucao();
	}
}
sub instrucao {
	if (e_sim(';')) { $p++; return; }
	if (e_sim('::')) { $p++; nome(); espera_sim('::'); return; }
	if (e_kw('break')) { $p++; return; }
	if (e_kw('goto')) { $p++; nome(); return; }
	if (e_kw('do')) { $p++; bloco(); espera_kw('end'); return; }
	if (e_kw('while')) { $p++; expr(); espera_kw('do'); bloco(); espera_kw('end'); return; }
	if (e_kw('repeat')) { $p++; bloco(); espera_kw('until'); expr(); return; }
	if (e_kw('if')) {
		$p++; expr(); espera_kw('then'); bloco();
		while (e_kw('elseif')) { $p++; expr(); espera_kw('then'); bloco(); }
		if (e_kw('else')) { $p++; bloco(); }
		espera_kw('end'); return;
	}
	if (e_kw('for')) {
		$p++; nome();
		if (e_sim('=')) { $p++; expr(); espera_sim(','); expr(); if (e_sim(',')) { $p++; expr(); } }
		else { while (e_sim(',')) { $p++; nome(); } espera_kw('in'); lista_exp(); }
		espera_kw('do'); bloco(); espera_kw('end'); return;
	}
	if (e_kw('function')) {
		$p++; nome(); while (e_sim('.')) { $p++; nome(); } if (e_sim(':')) { $p++; nome(); }
		corpo_funcao(); return;
	}
	if (e_kw('local')) {
		$p++;
		if (e_kw('function')) { $p++; nome(); corpo_funcao(); return; }
		nome(); atributo();
		while (e_sim(',')) { $p++; nome(); atributo(); }
		if (e_sim('=')) { $p++; lista_exp(); }
		return;
	}
	# expressao-instrucao: chamada ou atribuicao
	my $ultimo = sufixada();
	if (e_sim('=') || e_sim(',')) {
		falha("nao da para atribuir a uma chamada") if $ultimo eq 'chamada';
		while (e_sim(',')) { $p++; my $u = sufixada(); falha("nao da para atribuir a uma chamada") if $u eq 'chamada'; }
		espera_sim('='); lista_exp(); return;
	}
	falha("instrucao incompleta (nao e chamada nem atribuicao)") unless $ultimo eq 'chamada';
}
sub atributo { if (e_sim('<')) { $p++; nome(); espera_sim('>'); } }
sub corpo_funcao {
	espera_sim('(');
	if (!e_sim(')')) {
		while (1) {
			if (e_sim('...')) { $p++; last; }
			nome();
			last unless e_sim(','); $p++;
		}
	}
	espera_sim(')'); bloco(); espera_kw('end');
}
sub lista_exp { expr(); while (e_sim(',')) { $p++; expr(); } }
my %binop = map { $_ => 1 } ('+', '-', '*', '/', '//', '%', '^', '..', '==', '~=', '<', '<=', '>', '>=', '&', '|', '~', '<<', '>>');
sub expr {
	while (e_kw('not') || e_sim('-') || e_sim('#') || e_sim('~')) { $p++; }
	simples();
	while ((tp() eq 'sim' && $binop{v()}) || e_kw('and') || e_kw('or')) {
		$p++;
		while (e_kw('not') || e_sim('-') || e_sim('#') || e_sim('~')) { $p++; }
		simples();
	}
}
sub simples {
	if (tp() eq 'num' || tp() eq 'str') { $p++; return; }
	if (e_kw('nil') || e_kw('true') || e_kw('false') || e_sim('...')) { $p++; return; }
	if (e_kw('function')) { $p++; corpo_funcao(); return; }
	if (e_sim('{')) { tabela(); return; }
	sufixada();
}
sub tabela {
	espera_sim('{');
	while (!e_sim('}')) {
		if (e_sim('[')) { $p++; expr(); espera_sim(']'); espera_sim('='); expr(); }
		elsif (tp() eq 'nome' && !$kw{v()} && $t[$p+1][1] eq '=' && $t[$p+1][0] eq 'sim') { $p += 2; expr(); }
		else { expr(); }
		last unless e_sim(',') || e_sim(';');
		$p++;
	}
	espera_sim('}');
}
sub sufixada {
	my $ultimo;
	if (e_sim('(')) { $p++; expr(); espera_sim(')'); $ultimo = 'paren'; }
	elsif (tp() eq 'nome' && !$kw{v()}) { $p++; $ultimo = 'nome'; }
	else { falha("esperava uma expressao"); }
	while (1) {
		if (e_sim('.')) { $p++; nome(); $ultimo = 'campo'; }
		elsif (e_sim('[')) { $p++; expr(); espera_sim(']'); $ultimo = 'campo'; }
		elsif (e_sim(':')) { $p++; nome(); argumentos(); $ultimo = 'chamada'; }
		elsif (e_sim('(') || e_sim('{') || tp() eq 'str') { argumentos(); $ultimo = 'chamada'; }
		else { last; }
	}
	falha("um parentese sozinho nao pode ser atribuido") if 0;
	return $ultimo;
}
sub argumentos {
	if (tp() eq 'str') { $p++; return; }
	if (e_sim('{')) { tabela(); return; }
	espera_sim('(');
	lista_exp() unless e_sim(')');
	espera_sim(')');
}
eval { bloco(); falha("sobrou codigo depois do fim") unless tp() eq 'fim'; };
if ($@) { print "ERRO DE SINTAXE: $@"; exit 1; }
print "sintaxe OK (" . scalar(@t) . " pedacos lidos)\n";
