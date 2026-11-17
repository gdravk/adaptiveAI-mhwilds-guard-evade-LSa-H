local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.55 - |, q|	Versao 0.56 - Long Sword: SS+ISS automatico (Special Sheathe + Iai Spirit Slash), montado com as
	suas 18 leituras manuais. Prioridade: 1. SS+ISS (quando o golpe vem com tempo para o SS)
	2. FS (golpe em cima da hora) 3. esquiva. Se VOCE fizer o SS, o mod solta o ISS na hora do golpe
	0.55 - |, "cab");
$s =~ s/versao_mod = "0\.55"/versao_mod = "0.56"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.55 ==/== Defesa Automatica v0.56 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.55"\)/imgui.tree_node("Defesa Automatica v0.56")/ or die "tit";

# opcoes
troca(q|	ls_janela_combo_ms = 2300, |, q|	--[[
		(0.56) SS+ISS. Das suas leituras (Chatacabra, 14/11):
		  - SS = M5 + Espaco juntos; a bainha (animacao 20:249) comeca ~0,12s depois e o ISS so
		    fica disponivel ~1,38s depois do SS (antes disso o M5 fica no buffer);
		  - ISS = M5 na postura (20:247 / 248 / 250); o ISS (20:264 / 265) sai no mesmo quadro;
		  - o contra-ataque deu certo com o golpe chegando de 50 a 300 ms depois do M5;
		  - na bainha e na postura voce NAO esta protegido (golpes aos 0,3s e 1,1s acertaram).
		Por isso o SS so e feito quando o PROXIMO golpe vem entre "ls_ss_min_ms" e "ls_ss_max_ms"
		(nenhum golpe antes dele). Golpe mais em cima da hora: FS (prioridade 2).
	]]
	usar_ss_iss = true,
	ls_iss_ms = 150,        -- ISS (M5) quantos ms antes do golpe
	ls_ss_min_ms = 1700,    -- SS so se o golpe vier pelo menos este tanto depois
	ls_ss_max_ms = 3000,    -- ... e no maximo este tanto depois
	ls_postura_max_ms = 4000, -- sem golpe ate este tanto depois do SS: a postura e liberada para voce
	ls_janela_combo_ms = 2300, |, "op");

troca(q|	foresight = "Foresight Slash"
};|, q|	foresight = "Foresight Slash", ss_iss = "SS+ISS"
};|, "nome");

troca(q|		tempos_extras = {
			{ opcao = "ls_janela_combo_ms",|, q|		tempos_extras = {
			{ opcao = "ls_iss_ms", nome = "SS+ISS: ISS (M5) quantos ms antes do golpe", maximo = 400 },
			{ opcao = "ls_ss_min_ms", nome = "SS+ISS: SS so se o golpe vier daqui a pelo menos (ms)", maximo = 4000 },
			{ opcao = "ls_ss_max_ms", nome = "SS+ISS: ... e no maximo (ms)", maximo = 5000 },
			{ opcao = "ls_janela_combo_ms",|, "extras");

# controlador, antes de decidir_botoes
troca(q|local function decidir_botoes()
	local momento = agora();|, q|--[[
	(0.56) SS+ISS - PRIORIDADE 1 DA LONG SWORD
	O FS tem poucos quadros de invencibilidade e falha em golpes rapidos seguidos (ex.: os
	trovoes da ult do Lagiacrus); o ISS tem muito mais e ainda sobe o Spirit Gauge quando o
	contra-ataque da certo. Fases:
	  1. "ss": o proximo golpe vem com tempo (ls_ss_min_ms a ls_ss_max_ms) e voce esta no
	     combo: M5 + Espaco juntos (toques gravados, com o buffer). Para de escrever assim que a
	     bainha (20:249) comeca. Se a bainha nao vier em 0,8s, desiste (o FS / esquiva assumem);
	  2. "postura": espera o golpe. Se surgir um golpe antes, o alvo passa a ser ele. Sem golpe
	     ate "ls_postura_max_ms" depois do SS, a postura e liberada para voce;
	  3. "iss": M5 "ls_iss_ms" antes do golpe. Resultado: contra-ataque do ISS deu certo (o jogo
	     avisa), levou dano, ou o ISS saiu sem golpe.
	Do SS ao fim do ISS os seus botoes de acao ficam soltos (como no FS); o M4 continua acima
	de tudo. Se VOCE fizer o SS na mao, o mod so solta o ISS na hora certa (sem bloquear nada).
]]
local ANIM_SS = { ["20:249"] = true, ["20:247"] = true, ["20:248"] = true, ["20:250"] = true };
local ANIM_ISS = { ["20:264"] = true, ["20:265"] = true };
local ssiss = nil;

-- o proximo golpe previsto que alcanca voce (de qualquer monstro)
local function golpe_mais_proximo(momento)
	local melhor, melhor_m = nil, nil;
	for _, m in pairs(monstros) do
		if not m.invalido then
			for _, p in ipairs(m.previstos) do
				local falta = p.tempo - momento;
				local fora = op.checar_distancia and m.distancia ~= nil and (p.dist_max or 0) > 0
					and m.distancia > p.dist_max + op.margem_distancia;
				if (estado.jogadores or 1) > 1 and (p.dist_max or 0) <= 0 then fora = true; end
				if falta > -0.05 and not fora and (melhor == nil or p.tempo < melhor.tempo) then melhor, melhor_m = p, m; end
			end
		end
	end
	return melhor, melhor_m;
end

-- este golpe e do SS+ISS (o resto da defesa nao mexe nele)
local function reservar_golpe(p, m, chave_perfil)
	p.nivel, p.defesa, p.perfil, p.conferido, p.ss_iss = 1, "ss_iss", chave_perfil, true, true;
	p.chave = chave_do_golpe(chave_perfil, m, p);
	p.estado_pg = p.estado_pg or {};
end

local function terminar_ss_iss(resultado)
	if ssiss ~= nil and resultado ~= nil then
		if ssiss.diag ~= nil and ssiss.diag.resultado == "..." then ssiss.diag.resultado = resultado; end
		estado.ultimo_resultado = "SS+ISS: " .. resultado;
		estado.ss_iss_resultados = estado.ss_iss_resultados or {};
		local r = estado.ss_iss_resultados;
		r[resultado] = (r[resultado] or 0) + 1;
	end
	ssiss = nil;
end

-- devolve true enquanto o SS+ISS esta no comando (o FS / esquiva nao agem neste quadro)
local function controlar_ss_iss(momento, chave_perfil)
	local anim = combo.animacao or "?";
	local m5, espaco = op.toques.m5 or {}, op.toques.esquiva or {};

	if ssiss == nil then
		if ANIM_SS[anim] then
			-- voce fez o SS: o mod solta o ISS na hora certa
			ssiss = { fase = "postura", manual = true, inicio = momento, dano_antes = estado.levou_dano_em };
			estado.ultima_decisao = "SS seu -> o mod solta o ISS no golpe";
		else
			if not op.usar_ss_iss or #m5 == 0 or #espaco == 0 then return false; end
			local p, m = golpe_mais_proximo(momento);
			if p == nil or p.nivel ~= nil then return false; end
			local falta = p.tempo - momento;
			if falta < op.ls_ss_min_ms / 1000 or falta > op.ls_ss_max_ms / 1000 then return false; end
			if not em_combo_espada_longa() then return false; end
			reservar_golpe(p, m, chave_perfil);
			anotar_defesa(p, "ss_iss", falta);
			ssiss = { fase = "ss", inicio = momento, quadro = 0, dano_antes = estado.levou_dano_em, diag = p.diag };
			estado.ultima_decisao = string.format("SS+ISS em %s (golpe daqui a %d ms)", tostring(p.origem), math.floor(falta * 1000 + 0.5));
		end
	end

	local desde = momento - ssiss.inicio;
	if not ssiss.manual then estado.bloquear_acoes_ate = math.max(estado.bloquear_acoes_ate or 0, momento + 0.1); end

	if ssiss.fase == "ss" then
		if ANIM_SS[anim] then
			ssiss.fase = "postura"; -- o jogo ja usou o aperto: para de escrever
		elseif desde > 0.8 then
			terminar_ss_iss("SS nao saiu");
			estado.bloquear_acoes_ate = nil;
			return false;
		else
			ssiss.quadro = ssiss.quadro + 1;
			if ssiss.quadro <= #m5 then marcar("toque:m5:" .. ssiss.quadro); end
			if ssiss.quadro <= #espaco then marcar("toque:esquivab:" .. ssiss.quadro); end
			return true;
		end
	end

	if ssiss.fase == "postura" then
		if ANIM_ISS[anim] then
			-- o ISS saiu (por voce): so acompanha o resultado
			ssiss.fase, ssiss.iss_em, ssiss.quadro, ssiss.viu_iss = "iss", os.clock(), math.huge, true;
		elseif not ANIM_SS[anim] then
			terminar_ss_iss((estado.levou_dano_em ~= ssiss.dano_antes) and "LEVOU DANO na postura" or "saiu da postura");
			estado.bloquear_acoes_ate = nil;
			return false;
		else
			local p, m = golpe_mais_proximo(momento);
			local limite = ssiss.inicio + op.ls_postura_max_ms / 1000;
			if p == nil or p.tempo > limite then
				if desde > 1.5 and (p == nil or momento > limite - 0.3) then
					terminar_ss_iss("sem golpe: postura liberada");
					estado.bloquear_acoes_ate = nil;
					return false;
				end
				return true;
			end
			if p.tempo - momento <= op.ls_iss_ms / 1000 then
				if not p.ss_iss then reservar_golpe(p, m, estado.chave_perfil); end
				if ssiss.manual then
					anotar_defesa(p, "ss_iss", p.tempo - momento);
					ssiss.diag = p.diag;
				end
				ssiss.fase, ssiss.iss_em, ssiss.quadro = "iss", os.clock(), 0;
			else
				return true;
			end
		end
	end

	if ssiss.fase == "iss" then
		if ANIM_ISS[anim] then ssiss.viu_iss = true; end
		if not ssiss.viu_iss and ssiss.quadro < #m5 then
			ssiss.quadro = ssiss.quadro + 1;
			marcar("toque:m5:" .. ssiss.quadro);
		end
		if os.clock() - ssiss.iss_em < 0.6 then return true; end
		local resultado;
		if (estado.iss_certo_em or -100) >= ssiss.iss_em - 0.05 then resultado = "OK (contra-ataque do ISS)";
		elseif estado.levou_dano_em ~= ssiss.dano_antes then resultado = "LEVOU DANO";
		elseif ssiss.viu_iss then resultado = "ISS saiu, sem contra-ataque";
		else resultado = "ISS nao saiu"; end
		if ssiss.diag ~= nil and ssiss.diag.depois == nil then ssiss.diag.depois = anim; end
		terminar_ss_iss(resultado);
		estado.bloquear_acoes_ate = nil;
		return false;
	end
	return false;
end

local function decidir_botoes()
	local momento = agora();|, "controlador");

# liga o controlador
troca(q|	local pode, motivo = pode_defender();
	estado.motivo_parado = motivo;
	if not pode then estado.bloquear_acoes_ate = nil; return; end

	-- perfil da arma atual (definido em pode_defender)
	local perfil, chave_perfil = estado.perfil, estado.chave_perfil;
|, q|	local pode, motivo = pode_defender();
	estado.motivo_parado = motivo;
	if not pode then estado.bloquear_acoes_ate = nil; ssiss = nil; return; end

	-- perfil da arma atual (definido em pode_defender)
	local perfil, chave_perfil = estado.perfil, estado.chave_perfil;

	-- (0.56) SS+ISS primeiro (prioridade 1 da Long Sword)
	if perfil == PERFIS.espada_longa then
		local ok_ss, no_comando = pcall(controlar_ss_iss, momento, chave_perfil);
		if not ok_ss then
			ssiss = nil;
			estado.mensagem = "erro SS+ISS: " .. tostring(no_comando);
		elseif no_comando then
			return;
		end
	else
		ssiss = nil;
	end
|, "liga");

troca(q|	if not op.guarda_automatica then estado.motivo_parado = "desligada"; estado.bloquear_acoes_ate = nil; return; end|,
q|	if not op.guarda_automatica then estado.motivo_parado = "desligada"; estado.bloquear_acoes_ate = nil; ssiss = nil; return; end|, "desligada");

# M4 e leitura param o SS+ISS
troca(q|	if estado.m4_ate ~= nil and os.clock() < estado.m4_ate then
		toque.quadro = nil;|, q|	if estado.m4_ate ~= nil and os.clock() < estado.m4_ate then
		toque.quadro = nil;
		if ssiss ~= nil then terminar_ss_iss("parado pelo seu M4"); end|, "m4");
troca(q|	if estado.leitura_ss_iss and estado.perfil == PERFIS.espada_longa then
		toque.quadro = nil;|, q|	if estado.leitura_ss_iss and estado.perfil == PERFIS.espada_longa then
		toque.quadro = nil;
		ssiss = nil;|, "leitura_pausa");

# o aviso de contra-ataque do ISS vale sempre (nao so na leitura)
troca(q|			if not estado.leitura_ss_iss then return; end
			local cacador = meu_cacador();
			local minha_arma = cacador and cacador:call("get_WeaponHandling");
			if minha_arma == nil or sdk.to_int64(args[2]) ~= minha_arma:get_address() then return; end
			leitura.eventos|, q|			local cacador = meu_cacador();
			local minha_arma = cacador and cacador:call("get_WeaponHandling");
			if minha_arma == nil or sdk.to_int64(args[2]) ~= minha_arma:get_address() then return; end
			estado.iss_certo_em = os.clock(); -- (0.56) usado no resultado do SS+ISS
			if not estado.leitura_ss_iss then return; end
			leitura.eventos|, "hook");

# Prints
troca(q|		linha(string.format("Leitura do SS+ISS: %s|, q|		local res = {};
		for nome, n in pairs(estado.ss_iss_resultados or {}) do res[#res + 1] = nome .. ": " .. n; end
		linha(string.format("SS+ISS (prioridade 1, FS 2, esquiva 3): %s - agora: %s - nesta sessao: %s",
			op.usar_ss_iss and "ligado" or "DESLIGADO", ssiss and (ssiss.fase .. (ssiss.manual and " (SS seu)" or "")) or "-",
			#res > 0 and table.concat(res, ", ") or "nenhum ainda"));
		linha(string.format("Leitura do SS+ISS: %s|, "prints");

# menu: liga/desliga o SS+ISS
troca(q|		-- tempo de cada defesa da arma (quanto antes do golpe ela comeca)|, q|		if perfil_menu == PERFIS.espada_longa then
			alterado, op.usar_ss_iss = imgui.checkbox("Usar SS+ISS (prioridade 1; sem tempo para ele: FS)", op.usar_ss_iss);
			mudou_arma = mudou_arma or alterado;
		end

		-- tempo de cada defesa da arma (quanto antes do golpe ela comeca)|, "menu");

print $s;
