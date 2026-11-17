local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

# --- versao
$s =~ s/Versao 0\.30 - revisao/Versao 0.31 - Guard Up: golpes "impossiveis" sao guardados; 0.30 - revisao/ or die "cab";
$s =~ s/versao_mod = "0\.30"/versao_mod = "0.31"/ or die "vm";
$s =~ s/== Defesa Automatica v0\.30 ==/== Defesa Automatica v0.31 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.30"\)/imgui.tree_node("Defesa Automatica v0.31")/ or die "tit";

# --- opcao Guard Up
troca(q|	acao_impossivel = "esquiva",|, q|	acao_impossivel = "esquiva",

	--[[
		GUARD UP (0.31): com a habilidade Guard Up, os golpes que o jogo marca como
		"impossiveis de guardar" (correntes e explosoes do Arkveld, agarroes, explosoes do
		chao do Ajarakan, ondas do Uth Duna, gases do Gravios...) PODEM ser guardados: basta
		segurar a guarda. Com esta opcao ligada:
		  - esses golpes usam a GUARDA SEGURADA (sem contra-ataque);
		  - nas armas de guarda o aprendizado nunca desce para a esquiva. A esquiva so fica
		    para os golpes de lado (Espada e Escudo) e para os ataques de arena inteira que nem
		    o Guard Up segura (Zoh Shia, Jin Dahaad e o Delta Attack do Omega Planetes).
	]]
	tenho_guard_up = true,|, "op");

# --- tipo 4 (visto no Ajarakan) conta como o 3
troca(q|local RESTRICAO = { [0] = 0, [1] = 0, [3] = 1, [2] = 2 };|, q|local RESTRICAO = { [0] = 0, [1] = 0, [3] = 1, [4] = 1, [2] = 2 };|, "restricao");

# --- monstros com ataques que nem o Guard Up segura
troca(q|local function nivel_inicial(p, m, perfil)
	local forte = perfil.forte and posicao_no_perfil(perfil, perfil.forte);
	if forte and (p.guarda == 2 or p.guarda == 3) then return forte; end
|, q|-- (0.31) monstros com ataques de arena inteira que nem o Guard Up segura (pesquisa: Game8)
local IMBLOQUEAVEIS = { "zoh shia", "jin dahaad", "omega" };

local function monstro_imbloqueavel(nome)
	local texto = string.lower(tostring(nome or ""));
	for _, parte in ipairs(IMBLOQUEAVEIS) do
		if string.find(texto, parte, 1, true) then return true; end
	end
	return false;
end

-- golpe que o jogo marca como "especial" (2 impossivel, 3 e 4 guarda forte)
local function golpe_especial(p)
	return p.guarda == 2 or p.guarda == 3 or p.guarda == 4;
end

-- (0.31) maior nivel que o aprendizado pode alcancar nesta arma e neste monstro
local function teto_do_aprendizado(perfil, nome_monstro)
	local teto = perfil.nivel_maximo_aprendido or #perfil.niveis;
	if op.tenho_guard_up and perfil.teto_com_guard_up and not monstro_imbloqueavel(nome_monstro) then
		teto = math.min(teto, perfil.teto_com_guard_up);
	end
	return teto;
end

local function nivel_inicial(p, m, perfil)
	local de_lado = p.guarda ~= 1 and m.angulo ~= nil and m.angulo > op.angulo_frontal;

	if golpe_especial(p) then
		local guarda = posicao_no_perfil(perfil, "guarda");
		if op.tenho_guard_up and guarda ~= nil and not de_lado and not monstro_imbloqueavel(m.nome) then
			-- com Guard Up: e so segurar a guarda
			return guarda;
		end
		local forte = perfil.forte and posicao_no_perfil(perfil, perfil.forte);
		if forte then return forte; end
	end
|, "nivel_inicial");

troca(q|	if perfil.nivel_maximo_aprendido and aprendido > perfil.nivel_maximo_aprendido then
		aprendido = perfil.nivel_maximo_aprendido;
	end
	if aprendido > nivel then nivel = aprendido; end|, q|	local teto = teto_do_aprendizado(perfil, m.nome);
	if aprendido > teto then aprendido = teto; end
	-- (0.31) golpe especial com Guard Up: fica na guarda segurada (o contra-ataque aprendido
	-- para este golpe nao vale; so sobe se a propria guarda falhar)
	if aprendido > nivel then nivel = aprendido; end
	if nivel > teto and nivel_inicial(p, m, perfil) <= teto then nivel = teto; end|, "escolher");

# --- conferencia com teto por monstro
troca(q|				perfil = casado.perfil, nivel = casado.nivel, defesa = casado.defesa, em = os.clock(),|,
q|				perfil = casado.perfil, nivel = casado.nivel, defesa = casado.defesa, em = os.clock(),
				monstro = m.nome,|, "registro");
troca(q|			local proximo = math.min((v.nivel or 1) + 1, perfil_v.nivel_maximo_aprendido or #perfil_v.niveis);|,
q|			local proximo = math.min((v.nivel or 1) + 1, teto_do_aprendizado(perfil_v, v.monstro));|, "conferir");

# --- teto das armas de guarda
troca(q|		so_de_frente = { contra_ataque = true, guarda = true },|, q|		so_de_frente = { contra_ataque = true, guarda = true },

		-- (0.31) com Guard Up o aprendizado para no Power Guard (nunca vira esquiva)
		teto_com_guard_up = 3,|, "lanca_teto");
troca(q|		so_de_frente = { guarda = true },
		forte = "esquiva",|, q|		so_de_frente = { guarda = true },
		forte = "esquiva",
		-- (0.31) com Guard Up a frente e sempre guarda (a esquiva fica para os golpes de lado)
		teto_com_guard_up = 1,|, "sns_teto");

# --- aviso na tela
troca(q|	if guarda == 2 then return "IMPOSSIVEL DE GUARDAR - ESQUIVE", COR.impossivel; end
	if guarda == 3 then return "POWER GUARD", COR.power_guard; end|, q|	if guarda == 2 or guarda == 3 or guarda == 4 then
		if op.tenho_guard_up then return "SEGURE A GUARDA (Guard Up)", COR.power_guard; end
		if guarda == 2 then return "IMPOSSIVEL DE GUARDAR - ESQUIVE", COR.impossivel; end
		return "POWER GUARD", COR.power_guard;
	end|, "aviso");

# --- menu: checkbox Guard Up
troca(q|	mudou_simples, op.ativado = imgui.checkbox("Mostrar aviso na tela", op.ativado);
	alterou_simples = alterou_simples or mudou_simples;|, q|	mudou_simples, op.ativado = imgui.checkbox("Mostrar aviso na tela", op.ativado);
	alterou_simples = alterou_simples or mudou_simples;

	mudou_simples, op.tenho_guard_up = imgui.checkbox("Tenho Guard Up (guardar golpes \"impossiveis\")", op.tenho_guard_up);
	alterou_simples = alterou_simples or mudou_simples;|, "menu");

print $s;
