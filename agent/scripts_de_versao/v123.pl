local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }
sub troca_todas { my ($velho, $novo, $nome) = @_; my $n = ($s =~ s/\Q$velho\E/$novo/g); die "$nome nao achado" unless $n; return $n; }

troca(q|	Versao 1.22 - VERIFICACAO:|,
q|	Versao 1.23 - (luta 1.22 contra o Gore Magala) NO MAXIMO 3 FS SEGUIDOS: no golpe 3:31 sairam 9 FS um
	por cima do outro. Agora, depois de 3 FS seguidos, o 4o vira esquiva normal. A contagem zera com uma
	esquiva normal, com o SS+ISS ou com 3s sem FS. Exemplo: 3 FS, esquiva, 3 FS, SS+ISS, 3 FS = OK. A regra
	vale so para o FS (esquivas e outros combos nao mudam). O FS e contado pela invencibilidade dele
	(o jogo avisa cada FS que sai, ate um FS por cima de outro).
	1.22 - VERIFICACAO:|, "cabecalho");
troca_todas(q|versao_mod = "1.22"|, q|versao_mod = "1.23"|, "versao");

# contagem pela invencibilidade
troca(q|			invencibilidade.duracao = tonumber(duracao);
|, q|			invencibilidade.duracao = tonumber(duracao);
			-- (1.23) FS seguidos: cada FS soma; a esquiva normal zera; 3s sem FS tambem zera
			if tipo == 6 or tipo == 7 then
				if invencibilidade.desde - (estado.fs_seguido_em or -100) > 3 then estado.fs_seguidos = 0; end
				estado.fs_seguidos = (estado.fs_seguidos or 0) + 1;
				estado.fs_seguido_em = invencibilidade.desde;
			elseif tipo == 0 or tipo == 1 then
				estado.fs_seguidos = 0;
			end
|, "contagem");

# SS+ISS zera
troca(q|				if wt_v == "3" and string.sub(nome, 1, 4) == "cIai" and string.find(nome, "Slash", 1, true) ~= nil|,
q|				if wt_v == "3" and string.sub(nome, 1, 4) == "cIai" then estado.fs_seguidos = 0; end -- (1.23) SS+ISS zera os FS seguidos
				if wt_v == "3" and string.sub(nome, 1, 4) == "cIai" and string.find(nome, "Slash", 1, true) ~= nil|, "zera ss");

# funcao do limite
troca(q|-- (1.02) o FS atual ainda cobre o golpe? (contra do FS ativo nos primeiros 0,4s da animacao)
|, q|-- (1.23) ja sairam 3 FS seguidos? (o 4o vira esquiva)
n78.fs_limite = function()
	return (estado.fs_seguidos or 0) >= 3 and agora() - (estado.fs_seguido_em or -100) <= 3;
end;

-- (1.02) o FS atual ainda cobre o golpe? (contra do FS ativo nos primeiros 0,4s da animacao)
|, "funcao");

# executor
troca(q|			if barra_agora ~= nil and barra_agora <= 0.1 then return "indisponivel", "sem barra"; end
|, q|			if barra_agora ~= nil and barra_agora <= 0.1 then return "indisponivel", "sem barra"; end
			-- (1.23) no maximo 3 FS seguidos: o 4o vira esquiva normal
			if n78.fs_limite() then
				estado.fs_limite_vezes = (estado.fs_limite_vezes or 0) + 1;
				return "indisponivel", "ja sairam 3 FS seguidos";
			end
|, "executor");

# relatorio
troca(q|			.. " - SOS, monstro de costas (sem SS+ISS): " .. tostring(estado.ss_sos_costas or 0) .. " golpes"); -- (1.18 / 1.19)|,
q|			.. " - SOS, monstro de costas (sem SS+ISS): " .. tostring(estado.ss_sos_costas or 0) .. " golpes"
			.. " - 4o FS seguido trocado por esquiva: " .. tostring(estado.fs_limite_vezes or 0)); -- (1.18 / 1.19 / 1.23)|, "relatorio");
print $s;
