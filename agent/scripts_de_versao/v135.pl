local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; die "$nome repetido" if index($s, $velho, $i + length($novo)) >= 0; }
sub troca_todas { my ($velho, $novo, $nome) = @_; my $n = ($s =~ s/\Q$velho\E/$novo/g); die "$nome nao achado" unless $n; return $n; }

troca(q|	Versao 1.34 - VERIFICACAO 1.28 A 1.33 E LIMPEZA:|,
q|	Versao 1.35 - (lutas 1.34 no SOS com a Lanca) 1. A LANCA ACHAVA QUE TINHA DEFENDIDO QUANDO VOCE APANHAVA: ela era a
	unica arma que conferia a defesa pelo "efeito de guarda" do jogo, mas o efeito do Power Guard e chamado a cada
	quadro enquanto a postura esta ligada (chegou a 9 mil vezes). Qualquer golpe na postura virava "OK (sem dano)",
	ate com voce caindo (animacoes de dano 14:44 / 14:46 / 14:50 logo depois) - e como a defesa so sobe de nivel
	quando falha, a Lanca nunca aprendia com os golpes que levava. Agora ela confere como as outras 13 armas: o
	jogo disse que guardou (evHit_Damage) ou voce nao levou golpe. 2. GUARDA / POWER GUARD FORCADOS DE NOVO: o
	pedido ao jogo era feito uma vez so; quando o jogo nao aceitava (16 guardas e 21 Power Guards nesta luta), so
	sobravam os botoes. Agora, se a guarda nao entrou em 0,12s e o golpe ainda nao chegou, o mod pede mais uma vez
	(vale para todas as armas com guarda forcada; nunca por cima de um contra-ataque que ja saiu). 3. CONTRA-ATAQUE
	DA LANCA: o M2 era apertado de 0,05 a 0,15s depois do inicio, estivesse a guarda na tela ou nao - sem a guarda,
	o M2 vira uma estocada (golpe seu, sem defesa). Agora o M2 so e apertado depois que a guarda entrou de verdade
	(por 0,1s), inclusive quando ela entra no 2o pedido. 4. O relatorio mostrava "v1.19" no titulo.
	1.34 - VERIFICACAO 1.28 A 1.33 E LIMPEZA:|, "cabecalho");
troca_todas(q|versao_mod = "1.34"|, q|versao_mod = "1.35"|, "versao");
troca(q|	if not imgui.tree_node("Defesa Automatica v1.34") then return; end|, q|	if not imgui.tree_node("Defesa Automatica v1.35") then return; end|, "titulo menu");
troca(q|	linha("== Defesa Automatica v1.19 ==");|, q|	linha("== Defesa Automatica v1.35 ==");|, "titulo relatorio");

# 1. Lanca confere pelo dano, como as outras armas
troca(q|	lanca = {
		nome = "Lanca",
		classe = "app.cHunterWp06Handling",
|, q|	lanca = {
		nome = "Lanca",
		classe = "app.cHunterWp06Handling",
		-- (1.35) sucesso = o jogo disse que guardou ou voce nao levou golpe (o efeito do Power Guard e chamado
		-- a cada quadro da postura e marcava "OK" ate com voce apanhando)
		confere_por_dano = true,
|, "lanca confere");

# 2. forcar de novo (uma vez) se o jogo nao aceitou
troca(q|n78.forcar_uma_vez = function(p, tipo, nome)
	p.estado_pg = p.estado_pg or {};
	if p.estado_pg["forcou_" .. tipo] then return false; end
	p.estado_pg["forcou_" .. tipo] = true;
	if p.teste then return false; end
	local atual = estado.acao_nome_ultimo or "";
	if tipo == "guarda" and string.find(atual, "Guard", 1, true) ~= nil and atual ~= "cGuardEnd" then return false; end
	if tipo == "power_guard" and string.sub(atual, 1, 11) == "cSuperGuard" then return false; end
	return n78.forcar(tipo, nome);
end;|,
q|-- (1.35) se o jogo nao aceitou (a acao nao entrou em 0,12s) e o golpe ainda nao chegou, pede mais uma vez
n78.forcar_uma_vez = function(p, tipo, nome)
	p.estado_pg = p.estado_pg or {};
	local e = p.estado_pg;
	local chave_t = "forcou_" .. tipo;
	local momento_f = agora();
	if e[chave_t] ~= nil then
		if (e["vezes_" .. tipo] or 0) >= 2 or momento_f - e[chave_t] < 0.12 then return false; end
		if p.tempo == nil or momento_f >= p.tempo then return false; end
	end
	e[chave_t] = momento_f;
	if p.teste then e["vezes_" .. tipo] = 2; return false; end
	local atual = estado.acao_nome_ultimo or "";
	-- ja na defesa (ou num contra-ataque que ja saiu): nada a pedir
	if string.find(atual, "Counter", 1, true) ~= nil then return false; end
	if tipo == "guarda" and string.find(atual, "Guard", 1, true) ~= nil and atual ~= "cGuardEnd" then return false; end
	if tipo == "power_guard" and (string.sub(atual, 1, 11) == "cSuperGuard" or string.find(atual, "Reaction", 1, true) ~= nil) then return false; end
	e["vezes_" .. tipo] = (e["vezes_" .. tipo] or 0) + 1;
	if e["vezes_" .. tipo] == 2 then estado.forcados_de_novo = (estado.forcados_de_novo or 0) + 1; end
	return n78.forcar(tipo, nome);
end;|, "forcar de novo");

# 3. M2 do contra-ataque so com a guarda na tela
troca(q|	contra_ataque = function(desde, p) n78.forcar_uma_vez(p, "guarda", "guarda (contra)"); marcar_contra_ataque(desde); end,|,
q|	-- (1.35) o M2 so depois que a guarda entrou de verdade (sem guarda, o M2 vira uma estocada sua)
	contra_ataque = function(desde, p)
		n78.forcar_uma_vez(p, "guarda", "guarda (contra)");
		local e = p.estado_pg or {};
		p.estado_pg = e;
		marcar("guarda");
		local atual = estado.acao_nome_ultimo or "";
		local guardando = string.find(atual, "Guard", 1, true) ~= nil and atual ~= "cGuardEnd";
		if e.m2_em == nil and guardando and desde >= 0.05 then e.m2_em = desde; end
		if e.m2_em ~= nil and desde - e.m2_em < 0.1 then marcar("especial"); end
	end,|, "contra lanca");

# relatorio: quantos pedidos de novo
troca(q|		linha("Forcados: " .. (#fz > 0 and table.concat(fz, ", ") or "nenhum") .. " - acoes aprendidas: "|,
q|		linha("Forcados: " .. (#fz > 0 and table.concat(fz, ", ") or "nenhum") .. " - pedidos de novo (1.35): " .. tostring(estado.forcados_de_novo or 0) .. " - acoes aprendidas: "|, "relatorio");
print $s;
