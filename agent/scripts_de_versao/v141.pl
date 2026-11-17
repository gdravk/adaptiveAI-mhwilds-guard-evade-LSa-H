local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; die "$nome repetido" if index($s, $velho, $i + length($novo)) >= 0; }
sub troca_todas { my ($velho, $novo, $nome) = @_; my $n = ($s =~ s/\Q$velho\E/$novo/g); die "$nome nao achado" unless $n; return $n; }

troca(q|	Versao 1.40 - LANCA SEM CONTRA-ATAQUE|,
q|	Versao 1.41 - (luta 1.40 contra o Omega com a Lanca) DANO NA GUARDA NAO E GOLPE: o jogo disse "acertou" 24
	vezes, mas a lista de danos tinha 52 - o resto era o dano que passa pela guarda / Power Guard (ex.: 14 de vida
	no golpe 2:33 com o Power Guard segurando). Perda maior que 8% da vida sem o aviso do jogo contava como golpe:
	o Power Guard que DEU CERTO virava falha e, com 2, a defesa subia para a esquiva (o passo da Lanca, que levou
	golpes de 14 a 59 de vida). Agora, com o aviso do jogo funcionando, so o "acertou" do jogo e golpe; a perda
	de vida sem ele fica na lista como "dano na guarda / efeito" (vale para todas as armas). As defesas
	aprendidas da Lanca voltam ao inicio uma vez (subiram com essas falhas falsas).
	1.40 - LANCA SEM CONTRA-ATAQUE|, "cabecalho");
troca_todas(q|versao_mod = "1.40"|, q|versao_mod = "1.41"|, "versao");
troca(q|Defesa Automatica v1.40") then|, q|Defesa Automatica v1.41") then|, "menu");
troca(q|linha("== Defesa Automatica v1.40 ==");|, q|linha("== Defesa Automatica v1.41 ==");|, "relatorio");

troca(q|				-- (1.26) o jogo ja marcou o golpe: mantem a hora do golpe (a vida cai um quadro depois)
				if agora() - (estado.golpe_jogo_em or -100) > 0.5 then estado.levou_dano_em = os.clock(); end
				-- (1.06) todos os danos, para achar onde voce morreu
				estado.danos_log = estado.danos_log or {};
				table.insert(estado.danos_log, 1, string.format("%s - vida %.0f -> %.0f - sacada %s|,
q|				-- (1.26) o jogo ja marcou o golpe: mantem a hora do golpe (a vida cai um quadro depois)
				-- (1.41) com o aviso do jogo funcionando, perda de vida sem o "acertou" e dano na guarda / efeito, nao golpe
				local sem_golpe_jogo = jogo_avisa and not golpe_recente;
				if sem_golpe_jogo then
					estado.danos_na_guarda = (estado.danos_na_guarda or 0) + 1;
				elseif agora() - (estado.golpe_jogo_em or -100) > 0.5 then
					estado.levou_dano_em = os.clock();
				end
				-- (1.06) todos os danos, para achar onde voce morreu
				estado.danos_log = estado.danos_log or {};
				table.insert(estado.danos_log, 1, string.format("%s - %svida %.0f -> %.0f - sacada %s|, "hp");
troca(q|					os.date("%H:%M:%S"), estado.vida_anterior, vida, tostring(cacador:call("get_IsWeaponOn") == true),|,
q|					os.date("%H:%M:%S"), sem_golpe_jogo and "DANO NA GUARDA / EFEITO (nao e golpe) - " or "", estado.vida_anterior, vida, tostring(cacador:call("get_IsWeaponOn") == true),|, "log");
troca(q|			.. " - perdas sem golpe ignoradas (veneno / fogo / efeito, sem contato do monstro): " .. tostring(estado.danos_pequenos or 0)); -- (1.21)|,
q|			.. " - perdas sem golpe ignoradas (veneno / fogo / efeito, sem contato do monstro): " .. tostring(estado.danos_pequenos or 0) -- (1.21)
			.. " - dano na guarda / efeito sem golpe do jogo (1.41): " .. tostring(estado.danos_na_guarda or 0));|, "relatorio linha");

troca(q|if not op.lanca_reset_140 then|, q|if not op.lanca_reset_141 then|, "reset if");
troca(q|	op.lanca_reset_140 = true;|, q|	op.lanca_reset_141 = true;|, "reset flag");
troca(q|	lanca_reset_140 = false, -- (1.40) as defesas aprendidas da Lanca ja voltaram ao inicio (uma vez so)|,
q|	lanca_reset_141 = false, -- (1.41) as defesas aprendidas da Lanca ja voltaram ao inicio (uma vez so)|, "op flag");
troca(q|-- geometria; 1.40: saiu o contra-ataque e os numeros mudaram)|, q|-- geometria; 1.40: saiu o contra-ataque e os numeros mudaram; 1.41: o dano na guarda contava como falha)|, "coment");
print $s;
