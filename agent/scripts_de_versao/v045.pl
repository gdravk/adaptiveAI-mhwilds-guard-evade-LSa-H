local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.44 - |, q|	Versao 0.45 - aprende tambem com golpes no Palico e em outros jogadores; cobertura do
	conhecimento por monstro (Prints e relatorio); 80 medicoes por animacao
	0.44 - |, "cab");
$s =~ s/versao_mod = "0\.44"/versao_mod = "0.45"/ or die "vm";
$s =~ s/== Defesa Automatica v0\.44 ==/== Defesa Automatica v0.45 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.44"\)/imgui.tree_node("Defesa Automatica v0.45")/ or die "tit";

# --- ajustes
troca(q|	  5. Impactos e aprendizado    6. Pesquisa (gravador, exportacao, arma)|,
q|	  5. Impactos e aprendizado    6. Arma atual|, "partes");
troca(q|	maximo_amostras = 40,        -- medicoes guardadas por animacao|,
q|	maximo_amostras = 80,        -- medicoes guardadas por animacao (0.45: era 40; com 40, golpes raros
	                             -- de animacoes com muitos golpes eram esquecidos)|, "amostras");
troca(q|	minimo_antecedencia = 0.20,  -- nao cria aviso para impacto em menos que isso (nao da tempo)

	maximo_eventos = 30000
};|, q|	minimo_antecedencia = 0.20   -- nao cria aviso para impacto em menos que isso (nao da tempo)
};|, "eventos");

troca(q|	aprender = true,|, q|	aprender = true,
	-- (0.45) aprende tambem com golpes do monstro no Palico, em outros jogadores e em objetos
	-- (o tempo do golpe depois da animacao e o mesmo, nao importa quem ele acerta)
	aprender_com_outros = true,|, "op");

# --- impacto: aprende com qualquer alvo; confere/conta so os golpes em voce
troca(q|	local cacador = meu_cacador();
	local alvo = acerto:call("get_DamageOwner");
	if cacador == nil or alvo == nil or alvo ~= objeto_de_jogo(cacador) then return; end

	local m = monstro_do_objeto(monstro_char:call("get_GameObject"));
	if m == nil then return; end

	local momento = agora();
	estado.ultimo_impacto_em = momento; -- (0.32) usado para manter a guarda em golpes seguidos
|, q|	local cacador = meu_cacador();
	local alvo = acerto:call("get_DamageOwner");
	if cacador == nil or alvo == nil then return; end

	local m = monstro_do_objeto(monstro_char:call("get_GameObject"));
	if m == nil then return; end

	--[[
		(0.45) Antes so os golpes em VOCE ensinavam. Agora os golpes no Palico, em outros
		jogadores e em objetos tambem ensinam o TEMPO do golpe (ele nao depende de quem e
		acertado). So nao contam golpes em outro monstro (briga entre monstros). A conferencia
		das defesas, a guarda de golpes seguidos e as estatisticas continuam so com voce.
	]]
	local em_mim = (alvo == objeto_de_jogo(cacador));
	if not em_mim then
		if not op.aprender_com_outros then return; end
		if monstro_do_objeto(alvo) ~= nil then return; end
	end

	local momento = agora();
	-- um golpe que acerta varios alvos no mesmo instante ensina uma vez so
	local repetido = m.ultimo_aprendizado ~= nil and math.abs(momento - m.ultimo_aprendizado) < 0.05;

	if not em_mim then
		if op.aprender and not repetido then
			local guarda_o = 0;
			pcall(function()
				local golpe_o = acerto:call("get_AttackData");
				if golpe_o ~= nil then guarda_o = golpe_o:get_field("_GuardType") or 0; end
			end);
			local usadas = 0;
			for i = #m.historico, 1, -1 do
				local h = m.historico[i];
				local passou = momento - h.inicio;
				if passou > AJUSTES.idade_maxima_animacao or usadas >= AJUSTES.animacoes_por_impacto then break; end
				aprender(m.id, h.chave, passou, guarda_o, 0); -- distancia 0: nao mexe no alcance ate voce
				usadas = usadas + 1;
			end
			m.ultimo_aprendizado = momento;
			estado.aprendidos_outros = (estado.aprendidos_outros or 0) + 1;
		end
		return;
	end

	estado.ultimo_impacto_em = momento; -- (0.32) usado para manter a guarda em golpes seguidos

	-- (0.45) previsao por monstro (para saber quanto o mod ja conhece de cada um)
	estado.por_monstro = estado.por_monstro or {};
	local stat = estado.por_monstro[m.id] or { nome = m.nome, vistos = 0, certos = 0 };
	estado.por_monstro[m.id] = stat;
	stat.vistos = stat.vistos + 1;
|, "impacto1");

troca(q|		estado.ultimo_erro_ms = math.floor(menor * 1000 + 0.5);
		estado.avisos_certos = estado.avisos_certos + 1;|, q|		estado.ultimo_erro_ms = math.floor(menor * 1000 + 0.5);
		estado.avisos_certos = estado.avisos_certos + 1;
		stat.certos = stat.certos + 1;|, "impacto2");

troca(q|	-- aprende: as ultimas animacoes do monstro antes deste impacto
	if op.aprender then|, q|	-- aprende: as ultimas animacoes do monstro antes deste impacto
	if op.aprender and not repetido then
		m.ultimo_aprendizado = momento;|, "impacto3");

# --- cobertura do conhecimento
troca(q|local function contar_conhecimento(id)|, q|--[[
	(0.45) COBERTURA: de todas as medicoes de um monstro, quantas estao em golpes vistos pelo
	menos 2 vezes (os que o mod ja consegue prever). E uma estimativa de quantos golpes
	daquele monstro o mod ja conhece.
]]
local function cobertura(id)
	local total, cobertas = 0, 0;
	for animacao in pairs(conhecimento[tostring(id)] or {}) do
		for _, g in ipairs(grupos_de(id, animacao) or {}) do
			total = total + g.vezes;
			if g.vezes >= AJUSTES.minimo_amostras then cobertas = cobertas + g.vezes; end
		end
	end
	if total == 0 then return 0; end
	return math.floor(100 * cobertas / total + 0.5);
end

local function contar_conhecimento(id)|, "cobertura");

troca(q|		linha(string.format("Conhecimento deste monstro (ID %d): %d animacoes, %d medicoes", m.id, a_m, med_m));
	end|, q|		local stat = (estado.por_monstro or {})[m.id] or { vistos = 0, certos = 0 };
		linha(string.format("Conhecimento deste monstro (ID %d): %d animacoes, %d medicoes - cobertura %d%% - previstos nesta sessao: %d de %d",
			m.id, a_m, med_m, cobertura(m.id), stat.certos, stat.vistos));
	end
	linha(string.format("Aprendizado com golpes no Palico / outros jogadores nesta sessao: %d", estado.aprendidos_outros or 0));|, "prints");

# --- relatorio: cobertura de todos os monstros
troca(q|	json.dump_file(r.arquivo, {
		versao_mod = "0.45", salvo_as = ok_hora and hora or nil,
		prints = linhas, defesas = defesas
	});|, q|	local por_monstro = {};
	for chave_monstro in pairs(conhecimento) do
		local id = tonumber(chave_monstro);
		local stat = (estado.por_monstro or {})[id] or {};
		local a_m, med_m = contar_conhecimento(chave_monstro);
		por_monstro[#por_monstro + 1] = {
			id = id, nome = stat.nome, animacoes = a_m, medicoes = med_m, cobertura = cobertura(chave_monstro),
			golpes_em_voce_sessao = stat.vistos, previstos_sessao = stat.certos
		};
	end

	json.dump_file(r.arquivo, {
		versao_mod = "0.45", salvo_as = ok_hora and hora or nil,
		aprendidos_com_outros = estado.aprendidos_outros or 0,
		monstros = por_monstro, prints = linhas, defesas = defesas
	});|, "relatorio");

print $s;
