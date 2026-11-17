local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }
sub troca_todas { my ($velho, $novo, $nome) = @_; my $n = ($s =~ s/\Q$velho\E/$novo/g); die "$nome nao achado" unless $n; return $n; }

troca(q|	Versao 1.24 - VERIFICACAO DA REGRA DOS 3 FS:|,
q|	Versao 1.25 - VERIFICACAO PARA TODOS OS MONSTROS: a regra "perda de ate 2 de vida nao e golpe" (1.21) servia
	para o tique do Gore Magala, mas veneno, fogo e outros efeitos de outros monstros podem tirar mais que 2.
	Agora vale o que o jogo diz: perda de vida SEM contato de golpe do monstro em voce (nos ultimos 0,5s) nao e
	golpe, de qualquer tamanho ate 8% da vida maxima. Com contato, qualquer perda e golpe (ate 1 de vida). Sem
	contato e maior que 8%, conta como golpe (seguranca, se o jogo nao avisar o contato).
	1.24 - VERIFICACAO DA REGRA DOS 3 FS:|, "cabecalho");
troca_todas(q|versao_mod = "1.24"|, q|versao_mod = "1.25"|, "versao");

# contato em voce: marca sempre (antes das opcoes de aprendizado)
troca(q|local function contato_falhou(info_ptr, acerto_ptr, passou)
	if not op.aprender or not op.aprender_por_contato then return; end
	local cacador = meu_cacador();|,
q|local function contato_falhou(info_ptr, acerto_ptr, passou)
	local cacador = meu_cacador();|, "tira op do comeco");
troca(q|	if alvo == nil or alvo ~= meu_objeto or atacante == nil then return; end

	local m = monstro_do_objeto(atacante);
	if m == nil or m.invalido then return; end
|, q|	if alvo == nil or alvo ~= meu_objeto or atacante == nil then return; end
	if passou then estado.contato_em_mim_em = agora(); end -- (1.25) um golpe com dano encostou em voce (perda de vida = golpe)
	if not op.aprender or not op.aprender_por_contato then return; end

	local m = monstro_do_objeto(atacante);
	if m == nil or m.invalido then return; end
|, "marca contato");

troca(q|			-- (1.21) perda de ate 2 de vida (tique de efeito do monstro, veneno, fogo) nao e golpe
			if estado.vida_anterior ~= nil and vida < estado.vida_anterior - 0.5 and vida >= estado.vida_anterior - 2.5 then
				estado.danos_pequenos = (estado.danos_pequenos or 0) + 1;
			elseif|,
q|			-- (1.25) perda de vida sem contato de golpe em voce (veneno, fogo, efeito do monstro) nao e golpe
			estado.vida_maior = math.max(estado.vida_maior or 0, vida);
			local golpe_recente = agora() - math.max(estado.contato_em_mim_em or -100, estado.ultimo_impacto_em or -100) <= 0.5;
			local limite_efeito = math.max(2.5, (estado.vida_maior or 150) * 0.08);
			if estado.vida_anterior ~= nil and vida < estado.vida_anterior - 0.5 and not golpe_recente
				and vida >= estado.vida_anterior - limite_efeito then
				estado.danos_pequenos = (estado.danos_pequenos or 0) + 1;
			elseif|, "regra nova");

troca(q|" - perdas pequenas ignoradas (ate 2 de vida, efeito / veneno / fogo): "|,
q|" - perdas sem golpe ignoradas (veneno / fogo / efeito, sem contato do monstro): "|, "relatorio");
print $s;
