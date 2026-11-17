#!/usr/bin/perl
# Atualiza a "Lista de monstros.txt" com a porcentagem de conhecimento de cada monstro.
# Le o aprendizado do mod (so le, nao altera nada na pasta do jogo) e escreve " - XX%"
# na frente de TODOS os monstros e variantes (95% ou mais = o mod ja conhece bem).
#
# Uso: perl atualizar_lista.pl
use strict; use warnings;
use JSON::PP;

my $pasta_mod = "D:/Claude outros/MOD Evade Block MH Wilds";
my $aprendizado = "E:/SteamLibrary/steamapps/common/MonsterHunterWilds/reframework/data/aviso_lanca_aprendizado.json";
my $lista = "$pasta_mod/Lista de monstros.txt";
my $minimo = 95;

# nomes conhecidos antes da versao 0.47 (a partir dela o mod salva os nomes sozinho)
my %nomes_reserva = (19 => "Chatacabra", 26 => "Ajarakan", 27 => "Arkveld");

local $/;
open(my $f, "<", $aprendizado) or die "nao abri o aprendizado: $!";
my $dados = decode_json(<$f>);
close $f;

my %nomes = %nomes_reserva;
if (ref $dados->{nomes} eq "HASH") { $nomes{$_} = $dados->{nomes}{$_} for keys %{$dados->{nomes}}; }
# o jogo da o mesmo nome ao Omega normal e ao Savage; o Savage vem com a marca 1 (":t") - nao existe Tempered Omega
$nomes{"34:t"} = "Savage Omega Planetes";

# cobertura = medicoes em golpes vistos 2+ vezes / todas as medicoes (mesma conta do mod)
my %cobertura;
for my $id (keys %{$dados->{monstros} || {}}) {
	my ($total, $cobertas) = (0, 0);
	for my $animacao (values %{$dados->{monstros}{$id}}) {
		my @t = sort { $a->[0] <=> $b->[0] } @$animacao;
		my @grupos;
		for my $m (@t) {
			if (@grupos && $m->[0] - $grupos[-1][-1][0] <= 0.12) { push @{$grupos[-1]}, $m; }
			else { push @grupos, [$m]; }
		}
		for my $g (@grupos) { $total += @$g; $cobertas += @$g if @$g >= 2; }
	}
	next unless $total;
	$cobertura{$id} = int(100 * $cobertas / $total + 0.5);
}

# (mod 0.49+) cada variante tem o seu aprendizado: "27" = normal, "27:t" = Tempered,
# "27:at" = Arch-tempered. Se o nome nao estiver salvo, monta a partir do nome normal.
my %por_nome;
for my $id (keys %cobertura) {
	my $nome = $nomes{$id};
	if (!defined $nome && $id =~ /^(\d+):(t|at)$/ && defined $nomes{$1}) {
		$nome = ($2 eq "t" ? "Tempered " : "Arch-tempered ") . $nomes{$1};
	}
	next unless defined $nome;
	$nome =~ s/^(Tempered |Arch-tempered )\1/$1/i; # o jogo ja escreve "Tempered" no nome
	$por_nome{lc $nome} = $cobertura{$id};
	printf "%-28s (ID %s): %d%%\n", $nome, $id, $cobertura{$id};
}

open($f, "<:raw", $lista) or die "nao abri a lista: $!";
my $texto = <$f>;
close $f;

# Todas as 71 linhas recebem a porcentagem, cada monstro e variante separado (normal,
# Tempered, Arch-tempered e Guardian tem golpes e velocidades diferentes).
# Monstro / variante ainda nao enfrentado = 0%.
$texto =~ s{^(\d+\.\s+)(.+?)(?:\s+-\s+\d+%)?(\r?)$}{
	my ($num, $nome, $cr) = ($1, $2, $3);
	my $pct = $por_nome{lc $nome};
	$pct = 0 unless defined $pct;
	"$num$nome - $pct%$cr";
}gme;

open($f, ">:raw", $lista) or die "nao gravei a lista: $!";
print $f $texto;
close $f;
print "Lista atualizada.\n";
