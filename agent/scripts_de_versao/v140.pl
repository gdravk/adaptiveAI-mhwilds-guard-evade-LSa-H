local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; die "$nome repetido" if index($s, $velho, $i + length($novo)) >= 0; }
sub troca_todas { my ($velho, $novo, $nome) = @_; my $n = ($s =~ s/\Q$velho\E/$novo/g); die "$nome nao achado" unless $n; return $n; }
sub corta { my ($ini_txt, $fim_txt, $nome) = @_; my $i = index($s, $ini_txt); die "$nome ini" if $i < 0; my $f = index($s, $fim_txt, $i); die "$nome fim" if $f < 0; substr($s, $i, $f + length($fim_txt) - $i) = ""; }

troca(q|	Versao 1.39 - (luta 1.38 contra o Omega Planetes com a Lanca)|,
q|	Versao 1.40 - LANCA SEM CONTRA-ATAQUE (pedido do usuario): a ordem agora e guarda (perfeita / normal) 1, Power
	Guard 2, esquiva 3. Com Guard Up o aprendizado para no Power Guard (nunca vira esquiva); nos monstros com golpes
	que nem o Guard Up segura (ex.: Omega) pode chegar na esquiva. Sairam o pedido direto do contra-ataque (1.38),
	a regra "contra-ataque em golpes seguidos vira guarda" e o tempo do contra-ataque. As defesas aprendidas da
	Lanca voltam ao inicio uma vez (os numeros mudaram: 3 era contra-ataque e agora e a esquiva).
	1.39 - (luta 1.38 contra o Omega Planetes com a Lanca)|, "cabecalho");
troca_todas(q|versao_mod = "1.39"|, q|versao_mod = "1.40"|, "versao");
troca(q|Defesa Automatica v1.39") then|, q|Defesa Automatica v1.40") then|, "menu");
troca(q|linha("== Defesa Automatica v1.39 ==");|, q|linha("== Defesa Automatica v1.40 ==");|, "relatorio");

troca(q|		-- defesas na ordem de prioridade (1.38: guarda 1, Power Guard 2, contra-ataque 3, esquiva 4)
		niveis = { "guarda", "power_guard", "contra_ataque", "esquiva" },

		-- defesas que so protegem de frente
		so_de_frente = { contra_ataque = true, guarda = true },|,
q|		-- defesas na ordem de prioridade (1.40: guarda 1, Power Guard 2, esquiva 3 - sem contra-ataque)
		niveis = { "guarda", "power_guard", "esquiva" },

		-- defesas que so protegem de frente
		so_de_frente = { guarda = true },|, "niveis");
troca(q|		-- (0.31) com Guard Up o aprendizado para no nivel 3 (1.38: o contra-ataque; nunca vira esquiva)
		teto_com_guard_up = 3,|, q|		-- (0.31) com Guard Up o aprendizado para no Power Guard (nunca vira esquiva)
		teto_com_guard_up = 2,|, "teto");
troca(q|			contra_ataque = "antecedencia_contra_ms", guarda = "antecedencia_guarda_ms",
			power_guard = "antecedencia_power_ms", esquiva = "antecedencia_esquiva_ms"|,
q|			guarda = "antecedencia_guarda_ms", power_guard = "antecedencia_power_ms", esquiva = "antecedencia_esquiva_ms"|, "antecedencia");
troca(q|	antecedencia_contra_ms = 250,  -- o contra-ataque entra este tanto antes do impacto
|, "", "op contra");

troca(q|-- (0.99) Lance: guarda / Power Guard forcados por cima de qualquer animacao; o contra-ataque sai da
-- guarda forcada com o toque do M2
PERFIS.lanca.executar = {
	contra_ataque = function(desde, p)
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
	end,
	guarda = n78.guarda_forcada,|,
q|-- (0.99) Lance: guarda / Power Guard forcados por cima de qualquer animacao (1.40: sem contra-ataque)
PERFIS.lanca.executar = {
	guarda = n78.guarda_forcada,|, "executor");
troca(q|
	-- (1.38) contra-ataque da Lanca (cCounterAttack, visto nas suas lutas)
	if tipo == "contra_lanca" and wt == 6 and not por.contra_lanca_padrao_ruim then return 2, 83, true; end|, "", "acao contra");
troca(q|
				or (fp.tipo == "contra_lanca" and string.find(nome, "CounterAttack", 1, true) ~= nil) -- (1.38)|, "", "confere contra");
troca(q| or fp.tipo == "power_guard" or fp.tipo == "contra_lanca") and r.ok == 0|, q| or fp.tipo == "power_guard") and r.ok == 0|, "padrao ruim");
corta("\t\t\t\t\t-- (0.32) contra-ataque no meio de golpes seguidos vira guarda\n", "\t\t\t\t\t\t\tp.nivel, p.defesa = pos_guarda, \"guarda\";\n\t\t\t\t\t\tend\n\t\t\t\t\tend\n", "regra seguido");

troca(q|-- (1.39) uma vez so: as defesas aprendidas da Lanca subiram com 1 falha e com a chave da geometria; voltam ao inicio
if not op.lanca_reset_139 then|, q|-- (1.39 / 1.40) uma vez so: as defesas aprendidas da Lanca voltam ao inicio (1.39: subiram com 1 falha e pela
-- geometria; 1.40: saiu o contra-ataque e os numeros mudaram)
if not op.lanca_reset_140 then|, "reset");
troca(q|	op.lanca_reset_139 = true;|, q|	for k in pairs(n78.falhas_seguidas) do
		if type(k) == "string" and string.sub(k, 1, 6) == "lanca:" then n78.falhas_seguidas[k] = nil; end
	end
	op.lanca_reset_140 = true;|, "reset flag");
troca(q|	lanca_reset_139 = false, -- (1.39) as defesas aprendidas da Lanca ja voltaram ao inicio (uma vez so)|,
q|	lanca_reset_140 = false, -- (1.40) as defesas aprendidas da Lanca ja voltaram ao inicio (uma vez so)|, "op flag");
troca(q|	  (1.38) 1. guarda (perfeita ou normal)   2. Power Guard   3. contra-ataque   4. esquiva|, q|	  (1.40) 1. guarda (perfeita ou normal)   2. Power Guard   3. esquiva (sem contra-ataque)|, "coment");
print $s;
