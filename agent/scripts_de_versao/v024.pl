local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

# 1. perfis (dados) antes dos ganchos de defesa
troca(q{estado.defesas.contra = 0;

local ultima_chamada_defesa = {};

local DEFESAS_DA_LANCA = {
	{ classe = "app.cHunterWp06Handling", funcao = "callJustGuardSuccessEffect", conta = "perfeita" },
	{ classe = "app.cHunterWp06Handling", funcao = "callGuardSuccessEffect", conta = "normal" },
	{ classe = "app.cHunterWp06Handling", funcao = "callPowerGuardEffect", conta = "power" },
	{ classe = "app.cHunterWeaponHandlingBase", funcao = "onParrySuccess", conta = "contra" }
};

for _, d in ipairs(DEFESAS_DA_LANCA) do}, q{estado.defesas.contra = 0;

local ultima_chamada_defesa = {};

--[[
	PERFIS DE ARMA (versao 0.24)

	O mod tem duas partes:
	  - NUCLEO, igual para todas as armas: previsao dos golpes, aprendizado dos monstros,
	    escrita de botoes, toque gravado, aviso na tela e aba Prints. O conhecimento dos
	    golpes e por MONSTRO e vale para qualquer arma;
	  - PERFIL DE ARMA, um para cada arma: a classe da arma no jogo, as defesas que ela tem
	    (na ordem de prioridade), quais so protegem de frente, qual defesa usar nos golpes
	    fortes/de lado e nas sequencias, os tempos de cada defesa, os eventos do jogo que
	    confirmam cada defesa e como executar cada uma (definido mais abaixo, em "executar").

	Para criar o perfil de uma arma nova, basta adicionar outra entrada aqui.
]]
local NOME_ACAO = {
	contra_ataque = "contra-ataque", guarda = "guarda", power_guard = "Power Guard", esquiva = "esquiva"
};

local PERFIS = {
	lanca = {
		nome = "Lanca",
		classe = "app.cHunterWp06Handling",

		-- defesas na ordem de prioridade
		niveis = { "contra_ataque", "guarda", "power_guard", "esquiva" },

		-- defesas que so protegem de frente
		so_de_frente = { contra_ataque = true, guarda = true },

		-- defesa para golpes impossiveis de guardar, que exigem guarda forte ou que vem de lado
		forte = "power_guard",

		-- defesa para sequencias de golpes (segurada do primeiro ao ultimo)
		sequencia = "power_guard",

		-- opcao (em "op") com quantos ms antes do impacto cada defesa comeca
		antecedencia = {
			contra_ataque = "antecedencia_contra_ms", guarda = "antecedencia_guarda_ms",
			power_guard = "antecedencia_power_ms", esquiva = "antecedencia_esquiva_ms"
		},

		-- opcao (em "op") que liga/desliga cada defesa (as que nao estao aqui estao sempre ligadas)
		desligavel = { power_guard = "usar_power_guard", esquiva = "esquivar" },

		-- funcoes do jogo chamadas quando cada defesa da certo
		eventos = {
			{ classe = "app.cHunterWp06Handling", funcao = "callJustGuardSuccessEffect", conta = "perfeita" },
			{ classe = "app.cHunterWp06Handling", funcao = "callGuardSuccessEffect", conta = "normal" },
			{ classe = "app.cHunterWp06Handling", funcao = "callPowerGuardEffect", conta = "power" },
			{ classe = "app.cHunterWeaponHandlingBase", funcao = "onParrySuccess", conta = "contra" }
		}
	}
};

-- todos os eventos de defesa de todos os perfis (sem repetir)
local EVENTOS_DE_DEFESA, eventos_vistos = {}, {};
for _, perfil in pairs(PERFIS) do
	for _, d in ipairs(perfil.eventos) do
		local chave_evento = d.classe .. "." .. d.funcao;
		if not eventos_vistos[chave_evento] then
			eventos_vistos[chave_evento] = true;
			EVENTOS_DE_DEFESA[#EVENTOS_DE_DEFESA + 1] = d;
		end
	end
end

-- perfil da arma que o cacador esta usando (nil se a arma ainda nao tem perfil)
local function perfil_da_arma(cacador)
	local ok, classe = pcall(function()
		return cacador:call("get_WeaponHandling"):get_type_definition():get_full_name();
	end);
	if not ok or classe == nil then return nil, nil, nil; end
	for chave_perfil, perfil in pairs(PERFIS) do
		if perfil.classe == classe then return chave_perfil, perfil, classe; end
	end
	return nil, nil, classe;
end

for _, d in ipairs(EVENTOS_DE_DEFESA) do}, "perfis");

# 2. pode_defender usa o perfil
troca(q{	local arma = cacador:call("get_WeaponHandling");
	local tipo_arma = arma and arma:get_type_definition():get_full_name() or "";
	if not string.find(tipo_arma, "Wp06", 1, true) then return false, "nao esta de lanca"; end

	if cacador:call("get_IsWeaponOn") ~= true then return false, "lanca guardada"; end}, q{	local chave_perfil, perfil, classe = perfil_da_arma(cacador);
	estado.perfil, estado.chave_perfil = perfil, chave_perfil;
	if perfil == nil then return false, "arma sem perfil ainda (" .. tostring(classe) .. ")"; end

	if cacador:call("get_IsWeaponOn") ~= true then return false, string.lower(perfil.nome) .. " guardada"; end}, "pode");

# 3. prioridade generica
troca(q{local NIVEIS = { "contra_ataque", "guarda", "power_guard", "esquiva" };
local NOME_NIVEL = { contra_ataque = "contra-ataque", guarda = "guarda", power_guard = "Power Guard", esquiva = "esquiva" };

local function nivel_inicial(p, m)
	if p.guarda == 2 or p.guarda == 3 then return 3; end
	if p.guarda ~= 1 and m.angulo ~= nil and m.angulo > op.angulo_frontal then return 3; end
	return (op.acao_guardavel == "guarda") and 2 or 1;
end

-- primeiro nivel disponivel a partir de "nivel" (pula Power Guard ou esquiva desligados)
local function nivel_disponivel(nivel)
	for n = nivel, 4 do
		local nome = NIVEIS[n];
		if nome == "power_guard" and not op.usar_power_guard then
		elseif nome == "esquiva" and not op.esquivar then
		else
			return n;
		end
	end
	return nil;
end

local function chave_do_golpe(m, p)
	return tostring(m.id) .. ":" .. tostring(p.origem);
end

local function escolher_defesa(p, m)
	local nivel = nivel_inicial(p, m);
	local aprendido = defesas_aprendidas[chave_do_golpe(m, p)] or 1;
	if aprendido > nivel then nivel = aprendido; end
	return nivel_disponivel(nivel);
end}, q{local NOME_NIVEL = NOME_ACAO;

-- posicao de uma defesa na lista de prioridade do perfil
local function posicao_no_perfil(perfil, acao)
	for i, nome in ipairs(perfil.niveis) do
		if nome == acao then return i; end
	end
	return nil;
end

local function nivel_inicial(p, m, perfil)
	local forte = perfil.forte and posicao_no_perfil(perfil, perfil.forte);
	if forte and (p.guarda == 2 or p.guarda == 3) then return forte; end

	-- golpe de lado/tras: pula as defesas que so protegem de frente
	if p.guarda ~= 1 and m.angulo ~= nil and m.angulo > op.angulo_frontal then
		for i, nome in ipairs(perfil.niveis) do
			if not perfil.so_de_frente[nome] then return i; end
		end
	end

	return (op.acao_guardavel == "guarda" and posicao_no_perfil(perfil, "guarda")) or 1;
end

-- primeiro nivel disponivel a partir de "nivel" (pula as defesas desligadas no menu)
local function nivel_disponivel(nivel, perfil)
	for n = nivel, #perfil.niveis do
		local opcao = perfil.desligavel[perfil.niveis[n]];
		if opcao == nil or op[opcao] then return n; end
	end
	return nil;
end

-- chave do golpe no aprendizado das defesas: arma, monstro e animacao que previu o golpe
local function chave_do_golpe(chave_perfil, m, p)
	return chave_perfil .. ":" .. tostring(m.id) .. ":" .. tostring(p.origem);
end

local function escolher_defesa(p, m, chave_perfil, perfil)
	local nivel = nivel_inicial(p, m, perfil);
	local aprendido = defesas_aprendidas[chave_do_golpe(chave_perfil, m, p)] or 1;
	if aprendido > nivel then nivel = aprendido; end
	return nivel_disponivel(nivel, perfil);
end}, "prioridade");
print $s;
