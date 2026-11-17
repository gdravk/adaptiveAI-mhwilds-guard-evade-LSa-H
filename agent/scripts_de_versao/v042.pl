local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.41 - |, q|	Versao 0.42 - Long Sword: Foresight e esquiva apertados como um aperto de verdade (com o buffer de entrada)
	0.41 - |, "cab");
$s =~ s/versao_mod = "0\.41"/versao_mod = "0.42"/ or die "vm";
$s =~ s/== Defesa Automatica v0\.41 ==/== Defesa Automatica v0.42 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.41"\)/imgui.tree_node("Defesa Automatica v0.42")/ or die "tit";

# --- gravacoes com apelido: "esquivab" = o toque do Espaco, mas escrito COM o buffer
troca(q|local function campos_da_acao(acao)|, q|--[[
	(0.42) GRAVACOES. As gravacoes dos seus apertos (M5, M2, Espaco) mostram que um aperto
	de verdade e: 1 quadro com "acabou de apertar" e, depois, ~0,6s de BUFFER (o jogo guarda o
	aperto e executa assim que der - por exemplo no fim de um ataque). O mod apertava o
	Foresight por 4 quadros e o Espaco sem o buffer: no meio de um ataque seu o jogo ignorava.
	"esquivab" e a gravacao do Espaco escrita COM o buffer (usada na espada longa).
]]
local function gravacao(nome)
	if nome == "esquivab" then nome = "esquiva"; end
	return op.toques[nome or "esquiva"] or {};
end

local function campos_da_acao(acao)|, "gravacao");

troca(q|		return (op.toques[nome or "esquiva"] or {})[tonumber(quadro or 0)] or {};|,
q|		return gravacao(nome)[tonumber(quadro or 0)] or {};|, "campos");
troca(q|	if toque.quadro == nil and #(op.toques[nome] or {}) > 0 then|, q|	if toque.quadro == nil and #gravacao(nome) > 0 then|, "comecar");
troca(q|		local quadros = op.toques[toque.nome or "esquiva"] or {};|, q|		local quadros = gravacao(toque.nome);|, "replay");

# --- modo seguro: no "esquivab" so o indice fica de fora (o buffer vai)
troca(q|				local pular = modo_seguro and (item.l or item.c == "_LastRawTriggerIndex");|,
q|				local pular = modo_seguro and (item.l or item.c == "_LastRawTriggerIndex");
				-- (0.42) Espaco da espada longa: escreve o buffer; so o indice (suspeito do
				-- travamento da 0.17) continua de fora
				if string.sub(acao, 1, 15) == "toque:esquivab:" and item.c == "_LastRawTriggerIndex" then pular = true; end|, "seguro");

# --- esquiva usa o toque do perfil
troca(q|		if not comecar_toque(true) and toque.quadro == nil then marcar("esquiva"); end|,
q|		if not comecar_toque(true, perfil.toque_esquiva) and toque.quadro == nil then marcar("esquiva"); end|, "esquiva");

troca(q|		niveis = { "foresight", "esquiva" },|, q|		niveis = { "foresight", "esquiva" },
		toque_esquiva = "esquivab", -- (0.42) esquiva com o buffer (sai no fim do seu ataque)|, "perfil");

# --- Foresight: toque gravado do M5 e do M2 no mesmo quadro, com o buffer
troca(q|		-- (0.36) aperta; se a sua animacao nao mudar, o jogo ignorou: aperta de novo
		local e = p.estado_pg;|, q|		--[[
			(0.42) Com os toques gravados do M5 e do M2: os dois no MESMO quadro, como voce
			aperta (1 quadro + buffer). O jogo guarda o aperto e solta o Foresight assim que o
			seu ataque deixar. Sem as gravacoes, usa o jeito antigo (abaixo).
		]]
		local e = p.estado_pg;
		local m5, m2 = op.toques.m5 or {}, op.toques.m2 or {};
		if #m5 > 0 and #m2 > 0 then
			e.quadro = (e.quadro or 0) + 1;
			if e.quadro <= #m5 then marcar("toque:m5:" .. e.quadro); end
			if e.quadro <= #m2 then marcar("toque:m2:" .. e.quadro); end
			if p.diag ~= nil then p.diag.toques = 1; end
			return;
		end

		-- (0.36) aperta; se a sua animacao nao mudar, o jogo ignorou: aperta de novo|, "foresight");

print $s;
