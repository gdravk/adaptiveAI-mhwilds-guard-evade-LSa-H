--[[
	(0.59) O SS PODE SAIR DESTA SUA ANIMACAO? (aprendido)
	Na luta do teste, 55 SS nao sairam: o mod apertava M5 + Espaco em animacoes onde o SS nao
	existe (neutro 20:0, recuperacao do ISS 20:263/264/265, levando dano...) e as vezes saia
	uma esquiva (20:61). Agora, para cada animacao SUA, o mod anota:
	  - ok / falha: quantas vezes o SS saiu ou nao saiu apertando nela;
	  - atraso: quanto tempo o personagem ficou "travado" no seu golpe antes de a bainha
	    (20:249) comecar (o tempo que o seu ataque ainda segura o personagem).
	Animacao nunca vista: so tenta se for um ATAQUE da espada (aprendido nos seus golpes).
]]
local function ss_permitido(anim)
	local a = ss_animacoes[anim];
	if a ~= nil and (a.ok or 0) > 0 then return (a.falha or 0) <= (a.ok or 0) * 3, a; end
	if a ~= nil and (a.falha or 0) >= 2 then return false, a; end
	return op.animacoes_ataque_ls[anim] == true, a;
end

local function anotar_ss(anim, deu_certo, atraso_ms)
	if anim == nil or anim == "?" then return; end
	local a = ss_animacoes[anim] or { ok = 0, falha = 0 };
	if deu_certo then
		a.ok = (a.ok or 0) + 1;
		if atraso_ms ~= nil then
			a.atraso = a.atraso and math.floor(a.atraso * 0.7 + atraso_ms * 0.3 + 0.5) or atraso_ms;
		end
	else
		a.falha = (a.falha or 0) + 1;
	end
	ss_animacoes[anim] = a;
	estado.bloqueio_mudou = true; -- salva junto com as defesas
end

-- (0.59) golpe que ja "sumiu" depois do SS (o monstro mudou de golpe): conta para nao gastar SS nele
local function anotar_sem_golpe(chave, deu_certo)
	if chave == nil then return; end
	local s = ss_sem_golpe[chave] or { sem = 0, ok = 0 };
	if deu_certo then s.ok = s.ok + 1; else s.sem = s.sem + 1; end
	ss_sem_golpe[chave] = s;
	estado.bloqueio_mudou = true;
end

local function golpe_bom_para_ss(chave)
	local s = ss_sem_golpe[chave];
	return s == nil or s.sem < 2 or s.sem <= s.ok * 2;
end

-- (0.59) quanto tempo a postura dura sozinha (medido quando ela acaba sem ninguem apertar nada)
local function postura_maxima()
	local medida = op.postura_medida_ms or 0;
	if medida > 0 then return math.min(medida, op.ls_postura_max_ms) / 1000; end
	return op.ls_postura_max_ms / 1000;
end

-- devolve true enquanto o SS+ISS esta no comando (o FS / esquiva nao agem neste quadro)
local function controlar_ss_iss(momento, chave_perfil)
	local anim = combo.animacao or "?";
	local m5, espaco = op.toques.m5 or {}, op.toques.esquiva or {};

	if ssiss == nil then
		if ANIM_SS[anim] then
			-- voce fez o SS: o mod solta o ISS na hora certa
			ssiss = { fase = "postura", manual = true, inicio = momento, postura_em = momento, dano_antes = estado.levou_dano_em };
			estado.ultima_decisao = "SS seu -> o mod solta o ISS no golpe";
		else
			if not op.usar_ss_iss or #m5 == 0 or #espaco == 0 then return false; end
			local p, m = golpe_mais_proximo(momento);
			if p == nil or p.nivel ~= nil then return false; end
			local falta = p.tempo - momento;
			-- (0.59) o golpe precisa vir depois do seu ataque acabar (atraso aprendido) + bainha + ISS
			local pode, info = ss_permitido(anim);
			local atraso = (info and info.atraso or 0) / 1000;
			if falta < math.max(op.ls_ss_min_ms / 1000, 1.55 + atraso) or falta > op.ls_ss_max_ms / 1000 then return false; end
			if not em_combo_espada_longa() or not pode then return false; end
			local chave = chave_do_golpe(chave_perfil, m, p);
			if not golpe_bom_para_ss(chave) then return false; end
			--[[
				(0.57) PRIORIDADE PELA BARRA:
				  - "Somente SS+ISS": sempre SS+ISS;
				  - barra abaixo do vermelho: SS+ISS (o ISS certo sobe a barra);
				  - barra VERMELHA: o FS volta a ser o 1 (mais dano); SS+ISS so nos golpes que o FS
				    nao defende.
			]]
			if not op.somente_ss_iss and barra_vermelha() and (fs_falhas[chave] or 0) < FS_FALHAS_PARA_SS then
				return false;
			end
			reservar_golpe(p, m, chave_perfil);
			anotar_defesa(p, "ss_iss", falta);
			ssiss = { fase = "ss", inicio = momento, quadro = 0, dano_antes = estado.levou_dano_em, diag = p.diag,
				alvo = p, chave = chave, anim_inicio = anim };
			estado.ultima_decisao = string.format("SS+ISS em %s (golpe daqui a %d ms, sua animacao %s)",
				tostring(p.origem), math.floor(falta * 1000 + 0.5), anim);
		end
	end

	local desde = momento - ssiss.inicio;
	-- (0.59) do SS ao fim do ISS os seus botoes de ATAQUE (M1, M2, M5) e o Espaco ficam soltos: o
	-- seu golpe atual termina e o SS sai (antes so o M1 era solto e o M2 / M5 continuavam o combo)
	if not ssiss.manual then estado.bloquear_acoes_ate = math.max(estado.bloquear_acoes_ate or 0, momento + 0.1); end

	if ssiss.fase == "ss" then
		if ANIM_SS[anim] then
			anotar_ss(ssiss.anim_inicio, true, math.floor(desde * 1000 + 0.5));
			ssiss.fase, ssiss.postura_em = "postura", momento; -- o jogo ja usou o aperto: para de escrever
		else
			local falta = ssiss.alvo and (ssiss.alvo.tempo - momento) or 0;
			local dano = string.sub(anim, 1, 3) == "14:";
			local esquivou = anim == "20:61";
			-- tarde demais para o SS (o golpe chegaria na bainha), levou dano, saiu esquiva ou 2s sem sair
			if dano or esquivou or desde > 2.0 or falta < op.ls_ss_min_ms / 1000 - 0.35 then
				if not dano then anotar_ss(ssiss.anim_inicio, false); end
				terminar_ss_iss(esquivou and "SS nao saiu (saiu esquiva)" or "SS nao saiu");
				estado.bloquear_acoes_ate = nil;
				return false;
			end
			ssiss.quadro = ssiss.quadro + 1;
			-- (0.59) o aperto (com buffer) dura ~0,6s; se o seu golpe ainda segura o personagem,
			-- aperta de novo enquanto der tempo
			if ssiss.quadro > math.max(#m5, #espaco) then
				if not ss_permitido(anim) then
					anotar_ss(ssiss.anim_inicio, false);
					terminar_ss_iss("SS nao saiu");
					estado.bloquear_acoes_ate = nil;
					return false;
				end
				ssiss.quadro = 1;
				ssiss.repeticoes = (ssiss.repeticoes or 0) + 1;
			end
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
			local levou = estado.levou_dano_em ~= ssiss.dano_antes;
			--[[
				(0.59) TEMPO MAXIMO DA POSTURA: a postura acaba sozinha depois de um tempo. Quando o
				mod faz o SS, os seus botoes ficam soltos; se a postura acabar sem ISS, sem Iai Slash
				(20:251/252) e sem dano, o tempo dela e medido e passa a ser o limite.
			]]
			if not ssiss.manual and not levou and string.sub(anim, 1, 3) ~= "14:" and anim ~= "20:251" and anim ~= "20:252" then
				local dur_ms = math.floor((momento - (ssiss.postura_em or momento)) * 1000 + 0.5);
				if dur_ms >= 1500 then
					op.postura_medida_ms = (op.postura_medida_ms or 0) > 0 and math.min(op.postura_medida_ms, dur_ms) or dur_ms;
					estado.postura_ultima_ms = dur_ms;
					salvar_opcoes();
				end
			end
			terminar_ss_iss((levou and "LEVOU DANO na postura") or ((not ssiss.manual) and "saiu da postura" or nil));
			estado.bloquear_acoes_ate = nil;
			return false;
		else
			local p, m = golpe_mais_proximo(momento);
			local limite = (ssiss.postura_em or ssiss.inicio) + postura_maxima() - 0.25;
			if p == nil or p.tempo > limite then
				if momento - (ssiss.postura_em or ssiss.inicio) > 1.3 and (p == nil or momento > limite - 0.3) then
					if not ssiss.manual then anotar_sem_golpe(ssiss.chave, false); end
					terminar_ss_iss((not ssiss.manual) and "sem golpe: postura liberada" or nil);
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
				ssiss.fase, ssiss.iss_em, ssiss.quadro, ssiss.mod_apertou = "iss", os.clock(), 0, true;
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
		if not ssiss.manual and resultado == "OK (contra-ataque do ISS)" then anotar_sem_golpe(ssiss.chave, true); end
		if ssiss.diag ~= nil and ssiss.diag.depois == nil then ssiss.diag.depois = anim; end
		terminar_ss_iss(resultado);
		estado.bloquear_acoes_ate = nil;
		return false;
	end
	return false;
end

