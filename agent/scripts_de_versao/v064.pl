local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.63 - |, q|	Versao 0.64 - Long Sword: TRAVA PELO TEMPO DOS SEUS GOLPES. O mod aprende quanto tempo cada golpe
	seu prende o personagem e qual golpe vem depois no combo; um ataque seu so e aceito se ele (e o
	que ja esta saindo) acabar antes da hora em que o SS, o FS ou a esquiva precisam sair
	0.63 - |, "cab");
$s =~ s/versao_mod = "0\.63"/versao_mod = "0.64"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.63 ==/== Defesa Automatica v0.64 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.63"\)/imgui.tree_node("Defesa Automatica v0.64")/ or die "tit";

troca(q|local janela_combo_dados = { fs = {}, ss = {} };|, q|local janela_combo_dados = { fs = {}, ss = {} };
-- (0.64) [seu golpe] = { ms = quanto tempo ele prende o personagem, n = medicoes, prox = { [golpe seguinte] = true } }
local duracao_golpes = {};|, "tabela");
troca(q|	if type(salvo) == "table" and type(salvo.anim_fs) == "table" then|,
q|	if type(salvo) == "table" and type(salvo.duracao_golpes) == "table" then duracao_golpes = salvo.duracao_golpes; end
	if type(salvo) == "table" and type(salvo.anim_fs) == "table" then|, "load");
$s =~ s/anim_iss = ANIM_ISS \}\);/anim_iss = ANIM_ISS, duracao_golpes = duracao_golpes });/g or die "save";

troca(q|-- este golpe e do SS+ISS (o resto da defesa nao mexe nele)|, q|--[[
	(0.64) TRAVA PELO TEMPO DOS SEUS GOLPES
	Problema: spamando M1 / M2 / M5, cada golpe novo prende o personagem de novo e o SS, o FS e a
	esquiva nao conseguem sair quando o monstro ataca. Solucao:
	  1. o mod mede quanto tempo cada golpe seu PRENDE o personagem: do inicio da animacao ate a
	     proxima acao sair (outro golpe, FS, SS, ISS ou esquiva). Fica a MENOR medida (o ponto
	     mais cedo em que da para sair do golpe). Tambem anota qual golpe vem depois de qual
	     (o combo: o 1o M2 e uma estocada, o 2o e de baixo para cima...);
	  2. quando um golpe do monstro esta vindo, o mod calcula a hora em que o personagem precisa
	     estar livre (a ultima hora para o SS, ou a hora do FS / esquiva);
	  3. um ataque seu so passa se o golpe atual (o que falta dele) + o proximo golpe do combo
	     acabarem antes dessa hora. Se nao, M1, M2 e M5 ficam soltos ate a defesa sair.
	Ainda sem medida de um golpe: usa 700 ms.
]]
local golpe_atual = { anim = nil, inicio = 0 };

local function trava_do_golpe(anim)
	local g = duracao_golpes[anim];
	return g and g.ms and (g.ms / 1000) or nil;
end

-- o golpe que viria se voce apertasse agora: o mais longo dos que ja vieram depois deste
local function proximo_golpe_s(anim)
	local g = duracao_golpes[anim];
	local maior = nil;
	for seguinte in pairs((g and g.prox) or {}) do
		local t = trava_do_golpe(seguinte);
		if t ~= nil and (maior == nil or t > maior) then maior = t; end
	end
	if maior ~= nil then return maior; end
	-- sem combo conhecido: o mais longo de todos os seus golpes medidos (ou 700 ms)
	for _, outro in pairs(duracao_golpes) do
		if outro.ms ~= nil and (maior == nil or outro.ms / 1000 > maior) then maior = outro.ms / 1000; end
	end
	return maior or 0.7;
end

-- quanto falta para o golpe atual soltar o personagem
local function resto_do_golpe_atual()
	local anim = golpe_atual.anim;
	if anim == nil or not op.animacoes_ataque_ls[anim] then return 0; end
	local t = trava_do_golpe(anim) or 0.7;
	return math.max(0, t - (os.clock() - golpe_atual.inicio));
end

-- mede os seus golpes (chamado a cada quadro com a Long Sword)
local function medir_golpes(anim)
	if anim == golpe_atual.anim then return; end
	local antes, durou = golpe_atual.anim, os.clock() - golpe_atual.inicio;
	golpe_atual.anim, golpe_atual.inicio = anim, os.clock();
	if antes == nil or not op.animacoes_ataque_ls[antes] or durou < 0.08 or durou > 3 then return; end
	-- so conta quando saiu uma ACAO sua (nao dano nem fim natural do golpe)
	local acao = op.animacoes_ataque_ls[anim] or ANIM_FS[anim] or ANIM_SS[anim] or ANIM_ISS[anim] or anim == "20:61";
	if not acao then return; end
	local g = duracao_golpes[antes] or { n = 0 };
	local ms = math.floor(durou * 1000 + 0.5);
	g.ms = (g.ms == nil) and ms or math.min(g.ms, ms);
	g.n = (g.n or 0) + 1;
	if op.animacoes_ataque_ls[anim] then
		g.prox = g.prox or {};
		g.prox[anim] = true;
	end
	duracao_golpes[antes] = g;
	estado.bloqueio_mudou = true; -- salva junto com as defesas
end

-- decide se os seus ataques ficam soltos agora
local function travar_por_golpe(momento, chave_perfil)
	estado.trava_golpe = nil;
	local p, m = golpe_mais_proximo(momento);
	if p == nil then return; end
	local falta = p.tempo - momento;
	if falta > 4 or falta < -0.1 then return; end

	local somente = op.somente_ss_iss and op.usar_ss_iss;
	local chave = chave_do_golpe(chave_perfil, m, p);
	local ss_vale = op.usar_ss_iss and (somente or not barra_vermelha() or (fs_falhas[chave] or 0) >= FS_FALHAS_PARA_SS);
	local ss_minimo = math.max(op.ls_ss_min_ms / 1000, 1.55);

	-- hora (daqui a quantos segundos) em que o personagem precisa estar livre
	local livre_em;
	if ss_vale and falta >= ss_minimo and em_combo_espada_longa("ss") then
		livre_em = falta - ss_minimo;          -- a ultima hora para o SS
	elseif somente and em_combo_espada_longa("ss") then
		return;                                 -- somente SS+ISS e sem tempo para ele: nada a fazer
	else
		livre_em = falta - math.max(op.ls_foresight_ms, op.esquiva_ms_espada_longa) / 1000 - 0.05; -- FS / esquiva
	end

	-- apertar agora: o que falta do golpe atual + o proximo golpe do combo (+ 0,1s de margem)
	local fim = resto_do_golpe_atual() + proximo_golpe_s(golpe_atual.anim) + 0.1;
	if fim > livre_em then
		estado.bloquear_ataques_ate = math.max(estado.bloquear_ataques_ate or 0, momento + 0.1);
		estado.trava_golpe = string.format("golpe daqui a %d ms: seus ataques soltos (um golpe seu agora acabaria em %d ms, a defesa precisa de voce livre em %d ms)",
			math.floor(falta * 1000 + 0.5), math.floor(fim * 1000 + 0.5), math.floor(livre_em * 1000 + 0.5));
	end
end

-- este golpe e do SS+ISS (o resto da defesa nao mexe nele)|, "funcoes");

troca(q|	-- (0.56) SS+ISS primeiro (prioridade 1 da Long Sword)
	if perfil == PERFIS.espada_longa then|, q|	-- (0.64) seus ataques so passam se acabarem antes da defesa
	if perfil == PERFIS.espada_longa then pcall(travar_por_golpe, momento, chave_perfil); end

	-- (0.56) SS+ISS primeiro (prioridade 1 da Long Sword)
	if perfil == PERFIS.espada_longa then|, "chamada");

troca(q|	-- (0.60) cada FS apertado: saiu|, q|	pcall(medir_golpes, combo.animacao or "?"); -- (0.64)

	-- (0.60) cada FS apertado: saiu|, "medir");

troca(q|		linha(string.format("Leitura do SS+ISS: %s|, q|		local qtd_golpes, maior_golpe = 0, 0;
		for _, g in pairs(duracao_golpes) do
			qtd_golpes = qtd_golpes + 1;
			if (g.ms or 0) > maior_golpe then maior_golpe = g.ms; end
		end
		linha(string.format("Seus golpes: %d medidos (o mais longo prende %d ms) - golpe atual %s prende %s ms - %s",
			qtd_golpes, maior_golpe, tostring(golpe_atual.anim), tostring(duracao_golpes[golpe_atual.anim or "?"] and duracao_golpes[golpe_atual.anim].ms or "-"),
			estado.trava_golpe or "ataques livres"));
		linha(string.format("Leitura do SS+ISS: %s|, "prints");

print $s;
