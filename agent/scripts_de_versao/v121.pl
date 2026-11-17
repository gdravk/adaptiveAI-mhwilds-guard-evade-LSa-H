local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }
sub troca_todas { my ($velho, $novo, $nome) = @_; my $n = ($s =~ s/\Q$velho\E/$novo/g); die "$nome nao achado" unless $n; return $n; }

troca(q|	Versao 1.20 - (lutas no SOS com Lance, Hunting Horn e Long Sword) APRENDER PELA AREA SOZINHA:|,
q|	Versao 1.21 - (lutas 1.20 contra o Gore Magala e a Congalala) DANO PEQUENO NAO E GOLPE: o Gore Magala
	tirava 1 de vida por segundo (efeito do monstro, nao golpe) e cada tique contava como "levou dano". As 3
	falhas do SS+ISS foram isso: o tique cancelava a postura ("LEVOU DANO na postura") e o golpe de verdade
	chegava logo depois (130 -> 2 de vida). Os tiques tambem enchiam a lista de danos do relatorio (60 de 60).
	Agora perda de ate 2 de vida nao conta como dano (so e contada a parte no relatorio). Os 2 golpes do Gore
	Magala tirados do SS+ISS por esses tiques (50:124 e 50:295) voltam a valer, uma vez so.
	1.20 - (lutas no SOS com Lance, Hunting Horn e Long Sword) APRENDER PELA AREA SOZINHA:|, "cabecalho");
troca_todas(q|versao_mod = "1.20"|, q|versao_mod = "1.21"|, "versao");

troca(q|			if estado.vida_anterior ~= nil and vida < estado.vida_anterior - 0.5 then
				estado.levou_dano_em = os.clock();|,
q|			-- (1.21) perda de ate 2 de vida (tique de efeito do monstro, veneno, fogo) nao e golpe
			if estado.vida_anterior ~= nil and vida < estado.vida_anterior - 0.5 and vida >= estado.vida_anterior - 2.5 then
				estado.danos_pequenos = (estado.danos_pequenos or 0) + 1;
			elseif estado.vida_anterior ~= nil and vida < estado.vida_anterior - 0.5 then
				estado.levou_dano_em = os.clock();|, "tique");

troca(q|		linha("Todos os danos levados (novo primeiro): " .. #(estado.danos_log or {}));|,
q|		linha("Todos os danos levados (novo primeiro): " .. #(estado.danos_log or {})
			.. " - perdas pequenas ignoradas (ate 2 de vida, efeito / veneno / fogo): " .. tostring(estado.danos_pequenos or 0)); -- (1.21)|, "relatorio");

# limpeza unica dos 2 golpes do Gore Magala
troca(q|	if type(salvo) == "table" and type(salvo.ss_sem_golpe) == "table" then ss_sem_golpe = salvo.ss_sem_golpe; end|,
q|	if type(salvo) == "table" and type(salvo.ss_sem_golpe) == "table" then ss_sem_golpe = salvo.ss_sem_golpe; end
	-- (1.21) uma vez so: os danos desses 2 golpes eram tiques de 1 de vida, nao golpes
	if type(salvo) == "table" and salvo.limpeza_121 == nil then
		for _, chave_l in ipairs({ "espada_longa:10:t:50:124", "espada_longa:10:t:50:295" }) do
			local s_l = ss_sem_golpe[chave_l];
			if type(s_l) == "table" and (s_l.ok or 0) == 0 then s_l.dano = 0; end
		end
	end|, "limpeza");
my $n = troca_todas(q|duracao_golpes = duracao_golpes });|, q|duracao_golpes = duracao_golpes, limpeza_121 = true });|, "marca limpeza");
die "esperava 2 gravacoes, achou $n" unless $n == 2;
print $s;
