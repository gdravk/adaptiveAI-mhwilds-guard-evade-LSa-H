local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; die "$nome repetido" if index($s, $velho, $i + length($novo)) >= 0; }
sub troca_todas { my ($velho, $novo, $nome) = @_; my $n = ($s =~ s/\Q$velho\E/$novo/g); die "$nome nao achado" unless $n; return $n; }
troca(q|	Versao 1.37 - 1. OMEGA PLANETES E SAVAGE ZERADOS|,
q|	Versao 1.38 - LANCA: NOVA PRIORIDADE E DEFESAS FORCADAS SEMPRE (pedido do usuario). 1. ORDEM: guarda (perfeita /
	normal) 1, Power Guard 2, contra-ataque 3, esquiva 4 (antes: contra-ataque, guarda, Power Guard, esquiva). As
	regras continuam: de lado / atras vai para o Power Guard; golpe especial de frente = guarda (Guard Up); sequencia
	= Power Guard; com Guard Up o aprendizado para no 3 (agora o contra-ataque). As defesas ja aprendidas da Lanca
	mudam de numero uma vez (Power Guard 3 -> 2). Saiu a opcao "Nos golpes de frente" (contra-ataque / so a guarda).
	2. FORCADAS QUANTAS VEZES FOR PRECISO: o pedido ao jogo (guarda, Power Guard, contra-ataque) e repetido a cada
	0,12s enquanto a defesa nao estiver na tela, ate a hora do golpe (antes: no maximo 2 vezes), por cima de
	qualquer animacao. 3. NA CORRIDA DA LANCA: a corrida e "cGuardDash" e o mod achava que ela ja era a guarda (tinha
	"Guard" no nome): nao pedia a guarda e, no contra-ataque, apertava o M2 (que na corrida vira um golpe seu). Agora
	"ja na guarda" e so a guarda de verdade (cGuard, andando com a guarda, reacao da guarda, Power Guard).
	4. CONTRA-ATAQUE PEDIDO DIRETO AO JOGO (cCounterAttack, 2,83, visto nas suas lutas); se o jogo nao aceitar 3
	vezes seguidas, volta para guarda forcada + M2. Arma guardada: continua sem fazer nada.
	1.37 - 1. OMEGA PLANETES E SAVAGE ZERADOS|, "cabecalho");
troca_todas(q|versao_mod = "1.37"|, q|versao_mod = "1.38"|, "versao");
troca(q|Defesa Automatica v1.37") then|, q|Defesa Automatica v1.38") then|, "menu");
troca(q|linha("== Defesa Automatica v1.37 ==");|, q|linha("== Defesa Automatica v1.38 ==");|, "relatorio");

# 1. ordem
troca(q|		-- defesas na ordem de prioridade
		niveis = { "contra_ataque", "guarda", "power_guard", "esquiva" },|,
q|		-- defesas na ordem de prioridade (1.38: guarda 1, Power Guard 2, contra-ataque 3, esquiva 4)
		niveis = { "guarda", "power_guard", "contra_ataque", "esquiva" },|, "niveis");
troca(q|		-- (0.31) com Guard Up o aprendizado para no Power Guard (nunca vira esquiva)
		teto_com_guard_up = 3,|, q|		-- (0.31) com Guard Up o aprendizado para no nivel 3 (1.38: o contra-ataque; nunca vira esquiva)
		teto_com_guard_up = 3,|, "teto");
troca(q|	return (op.acao_guardavel == "guarda" and posicao_no_perfil(perfil, "guarda")) or 1;|, q|	return 1;|, "nivel inicial");
troca(q|	-- golpes guardaveis: "contra_ataque" ou "guarda"
	acao_guardavel = "contra_ataque",
|, "", "op guardavel");
troca(q|
	if op.acao_guardavel ~= "guarda" and op.acao_guardavel ~= "contra_ataque" then op.acao_guardavel = "contra_ataque"; end
|, "\n", "valida guardavel");
troca(q|		-- lanca: o que fazer nos golpes guardaveis
		if posicao_no_perfil(perfil_menu, "contra_ataque") ~= nil then
			local acoes = { "contra_ataque", "guarda" };
			local nomes_acoes = { "Contra-ataque", "So a guarda" };
			local atual_acao = (op.acao_guardavel == "guarda") and 2 or 1;
			local alterou_acao, nova_acao = imgui.combo("Nos golpes de frente", atual_acao, nomes_acoes);
			if alterou_acao then op.acao_guardavel = acoes[nova_acao] or "contra_ataque"; mudou_arma = true; end
		end

|, "", "menu guardavel");
troca(q|	zerou_omega_137 = false, -- (1.37) o Omega Planetes e o Savage ja foram zerados (uma vez so)
|, q|	zerou_omega_137 = false, -- (1.37) o Omega Planetes e o Savage ja foram zerados (uma vez so)
	lanca_ordem_138 = false, -- (1.38) as defesas aprendidas da Lanca ja mudaram para a ordem nova (uma vez so)
|, "op ordem");

# 2/3. forcar sempre; "ja na guarda" so a guarda de verdade
troca(q|-- (1.35) se o jogo nao aceitou (a acao nao entrou em 0,12s) e o golpe ainda nao chegou, pede mais uma vez
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
end;|,
q|-- (1.38) ja esta na guarda de verdade? (a corrida da Lanca e "cGuardDash": tem "Guard" no nome mas nao guarda)
n78.em_guarda = function(atual)
	atual = atual or estado.acao_nome_ultimo or "";
	return atual == "cGuard" or string.sub(atual, 1, 10) == "cGuardWalk" or string.sub(atual, 1, 14) == "cGuardReaction"
		or string.sub(atual, 1, 11) == "cSuperGuard";
end;
-- (1.35 / 1.38) pede a defesa ao jogo e repete a cada 0,12s enquanto ela nao estiver na tela, ate a hora do golpe
-- (na sequencia, ate o fim dela), por cima de qualquer animacao
n78.forcar_uma_vez = function(p, tipo, nome)
	p.estado_pg = p.estado_pg or {};
	local e = p.estado_pg;
	local chave_t = "forcou_" .. tipo;
	local momento_f = agora();
	if e[chave_t] ~= nil then
		if momento_f - e[chave_t] < 0.12 then return false; end
		if momento_f > (p.janela_fim or ((p.tempo or momento_f) + 0.03)) then return false; end
	end
	e[chave_t] = momento_f;
	if p.teste then return false; end
	local atual = estado.acao_nome_ultimo or "";
	-- ja na defesa (ou num contra-ataque que ja saiu): nada a pedir
	if string.find(atual, "Counter", 1, true) ~= nil then return false; end
	if tipo == "guarda" and n78.em_guarda(atual) then return false; end
	if tipo == "power_guard" and (string.sub(atual, 1, 11) == "cSuperGuard" or string.sub(atual, 1, 14) == "cGuardReaction") then return false; end
	e["vezes_" .. tipo] = (e["vezes_" .. tipo] or 0) + 1;
	if e["vezes_" .. tipo] >= 2 then estado.forcados_de_novo = (estado.forcados_de_novo or 0) + 1; end
	return n78.forcar(tipo, nome);
end;|, "forcar sempre");

# 4. contra-ataque direto
troca(q|	if tipo == "contra_sa" and wt == 8 and not por.contra_sa_padrao_ruim then return 2, 31, true; end|,
q|	if tipo == "contra_sa" and wt == 8 and not por.contra_sa_padrao_ruim then return 2, 31, true; end
	-- (1.38) contra-ataque da Lanca (cCounterAttack, visto nas suas lutas)
	if tipo == "contra_lanca" and wt == 6 and not por.contra_lanca_padrao_ruim then return 2, 83, true; end|, "acao contra");
troca(q|				or (fp.tipo == "power_guard" and string.sub(nome, 1, 11) == "cSuperGuard")|,
q|				or (fp.tipo == "power_guard" and string.sub(nome, 1, 11) == "cSuperGuard")
				or (fp.tipo == "contra_lanca" and string.find(nome, "CounterAttack", 1, true) ~= nil) -- (1.38)|, "confere contra");
troca(q|fp.tipo == "passo" or fp.tipo == "guarda" or fp.tipo == "power_guard") and r.ok == 0|,
q|fp.tipo == "passo" or fp.tipo == "guarda" or fp.tipo == "power_guard" or fp.tipo == "contra_lanca") and r.ok == 0|, "padrao ruim");
troca(q|	-- (1.35) o M2 so depois que a guarda entrou de verdade (sem guarda, o M2 vira uma estocada sua)
	contra_ataque = function(desde, p)
		n78.forcar_uma_vez(p, "guarda", "guarda (contra)");
		local e = p.estado_pg or {};
		p.estado_pg = e;
		marcar("guarda");
		local atual = estado.acao_nome_ultimo or "";
		local guardando = string.find(atual, "Guard", 1, true) ~= nil and atual ~= "cGuardEnd";
		if e.m2_em == nil and guardando and desde >= 0.05 then e.m2_em = desde; end
		if e.m2_em ~= nil and desde - e.m2_em < 0.1 then marcar("especial"); end
	end,|,
q|	contra_ataque = function(desde, p)
		p.estado_pg = p.estado_pg or {};
		local e = p.estado_pg;
		marcar("guarda");
		local atual = estado.acao_nome_ultimo or "";
		if string.find(atual, "CounterAttack", 1, true) ~= nil then return; end -- o contra-ataque ja saiu
		-- (1.38) 1. pedido direto do contra-ataque ao jogo (repetido enquanto ele nao sair)
		if n78.acao_de("contra_lanca") ~= nil then
			n78.forcar_uma_vez(p, "contra_lanca", "contra-ataque");
			return;
		end
		-- 2. o jogo nao aceitou o pedido direto: guarda forcada + M2 so com a guarda na tela (1.35)
		n78.forcar_uma_vez(p, "guarda", "guarda (contra)");
		if e.m2_em == nil and n78.em_guarda(atual) and desde >= 0.05 then e.m2_em = desde; end
		if e.m2_em ~= nil and desde - e.m2_em < 0.1 then marcar("especial"); end
	end,|, "executor contra");

# migracao uma vez so
troca(q|-- (1.37) uma vez so (pedido do usuario): zera o Omega Planetes (34) e o Savage Omega Planetes (34:t)|,
q|-- (1.38) uma vez so: a ordem da Lanca mudou (era contra 1, guarda 2, Power Guard 3, esquiva 4; agora guarda 1,
-- Power Guard 2, contra 3, esquiva 4). Guarda 2 -> 1 e Power Guard 3 -> 2; a esquiva continua 4
if not op.lanca_ordem_138 then
	pcall(function()
		local nova_ordem = { [2] = 1, [3] = 2 };
		for k, v in pairs(defesas_aprendidas) do
			if type(k) == "string" and string.sub(k, 1, 6) == "lanca:" and nova_ordem[v] ~= nil then defesas_aprendidas[k] = nova_ordem[v]; end
		end
		n78.salvar_defesas();
	end);
	op.lanca_ordem_138 = true;
	salvar_opcoes();
end
-- (1.37) uma vez so (pedido do usuario): zera o Omega Planetes (34) e o Savage Omega Planetes (34:t)|, "migracao");
troca(q|	  1. contra-ataque   2. guarda (perfeita ou normal)   3. Power Guard   4. esquiva|, q|	  (1.38) 1. guarda (perfeita ou normal)   2. Power Guard   3. contra-ataque   4. esquiva|, "coment ordem");
troca(q|	  - o resto: contra-ataque (ou guarda, se voce escolheu "so a guarda").|, q|	  - o resto: guarda.|, "coment resto");
print $s;
