local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

# --- versao
troca(q|	Versao 0.34 - toque gravado|, q|	Versao 0.35 - Hammer removido; Long Sword continua defendendo na postura do Special Sheathe; historico das defesas no Prints
	(o Hammer foi removido a seu pedido: com ele o mod nao faz nada)
	0.34 - toque gravado|, "cab");
$s =~ s/versao_mod = "0\.34"/versao_mod = "0.35"/ or die "vm";
$s =~ s/== Defesa Automatica v0\.34 ==/== Defesa Automatica v0.35 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.34"\)/imgui.tree_node("Defesa Automatica v0.35")/ or die "tit";

# =====================================================================================
# 1. REMOVE O HAMMER
# =====================================================================================
troca(qq|\tesquiva_ms_martelo = 150,\n|, "", "op1");
troca(q|	-- Martelo (0.29)
	martelo_carga_ms = 900, -- comeca a carregar (M5 segurado) este tanto antes do golpe
	martelo_step_ms = 150,  -- Charged Step (M2 com a carga) este tanto antes do golpe|, "", "op2");
troca(q| charged_step = "CHARGED STEP (M5 segurado, depois M2)",|, "", "nome_alvo");
troca(q|, iai = "Special Sheathe + Iai", charged_step = "Charged Step"|, q|, iai = "Special Sheathe + Iai"|, "nome_acao");
$s =~ s/\t--\[\[\n\t\tMARTELO \(0\.29\).*?\n\t\teventos = \{\}\n\t\},\n\n//s or die "perfil_martelo";
$s =~ s/-- o martelo esta carregando\?.*?\nend\n\n//s or die "carregando";
$s =~ s/--\[\[\n\tMARTELO - Charged Step.*?\n\t\tend\n\tend\n\};\n\n//s or die "exec_martelo";
troca(q|		elseif entrada.alvo == "foresight" or entrada.alvo == "iai" or entrada.alvo == "charged_step" then|,
q|		elseif entrada.alvo == "foresight" or entrada.alvo == "iai" then|, "teste1");
troca(q|			local perfil_teste = (entrada.alvo == "charged_step") and PERFIS.martelo or PERFIS.espada_longa;|,
q|			local perfil_teste = PERFIS.espada_longa;|, "teste2");
$s =~ s/\tpcall\(function\(\)\n\t\tlocal arma = meu_cacador\(\):call\("get_WeaponHandling"\);\n\t\tif string\.find\(arma:get_type_definition\(\):get_full_name\(\), "Wp04".*?\n\tend\);\n//s or die "prints_martelo";
troca(q|				if acao == "iai" or acao == "charged_step" then maximo = 1500; end|, q|				if acao == "iai" then maximo = 1500; end|, "menu1");
troca(q|"foresight", "iai", "charged_step", "toque_m5" };|, q|"foresight", "iai", "toque_m5" };|, "menu2");
troca(q|"Special Sheathe + Iai (Long Sword)", "Charged Step (Hammer)",|, q|"Special Sheathe + Iai (Long Sword)",|, "menu3");
troca(q|			local e_combo = entrada.alvo == "foresight" or entrada.alvo == "iai" or entrada.alvo == "charged_step";|,
q|			local e_combo = entrada.alvo == "foresight" or entrada.alvo == "iai";|, "menu4");
troca(q|(ex.: espada longa fora do combo, martelo
					-- sem carga)|, q|(ex.: espada longa fora do combo ou sem
					-- tempo)|, "coment");

# =====================================================================================
# 2. POSTURA DO SPECIAL SHEATHE: a espada fica guardada, mas o mod precisa continuar
#    (na 0.34 ele parava com "long sword guardada" e o Iai nunca era apertado na luta)
# =====================================================================================
troca(q|	if cacador:call("get_IsWeaponOn") ~= true then return false, string.lower(perfil.nome) .. " guardada"; end|,
q|	if cacador:call("get_IsWeaponOn") ~= true then
		-- (0.35) na postura do Special Sheathe a espada fica na bainha, mas o mod ainda
		-- precisa apertar o M5 do Iai: continua ate a postura acabar
		local na_postura = estado.postura_ls_ate ~= nil and os.clock() < estado.postura_ls_ate;
		if not na_postura then return false, string.lower(perfil.nome) .. " guardada"; end
	end|, "pode_defender");

troca(q|		-- 1. Special Sheathe: M5 + Espaco juntos
		if desde < 0.1 then
			marcar("guarda");|, q|		-- 1. Special Sheathe: M5 + Espaco juntos
		if desde < 0.1 then
			-- (0.35) a espada vai para a bainha: o mod continua ate o Iai (ver pode_defender)
			if not p.teste then
				estado.postura_ls_ate = os.clock() + (op.ls_sheathe_ms / 1000) - desde + 0.6;
			end
			marcar("guarda");|, "postura");

# indisponivel com motivo
troca(q|		if not p.teste and not p.estado_pg.conferiu then
			p.estado_pg.conferiu = true;
			if desde >= 0.1 then return "indisponivel"; end
			if not em_combo_espada_longa() then return "indisponivel"; end
		end
		if desde < 0.1 then marcar("guarda"); marcar("especial"); end|, q|		if not p.teste and not p.estado_pg.conferiu then
			p.estado_pg.conferiu = true;
			if desde >= 0.1 then return "indisponivel", "sem tempo"; end
			if not em_combo_espada_longa() then return "indisponivel", "fora do combo"; end
		end
		if desde < 0.1 then marcar("guarda"); marcar("especial"); end|, "fs_motivo");
troca(q|		if not p.teste and not p.estado_pg.conferiu then
			p.estado_pg.conferiu = true;
			if desde >= 0.1 then return "indisponivel"; end
			if not em_combo_espada_longa() then return "indisponivel"; end
		end
		-- 1. Special Sheathe|, q|		if not p.teste and not p.estado_pg.conferiu then
			p.estado_pg.conferiu = true;
			if desde >= 0.1 then return "indisponivel", "sem tempo"; end
			if not em_combo_espada_longa() then return "indisponivel", "fora do combo"; end
		end
		-- 1. Special Sheathe|, "iai_motivo");

# =====================================================================================
# 3. HISTORICO DAS DEFESAS (aba Prints): o que o mod apertou, quanto antes do golpe,
#    a animacao do cacador antes e 0,25s depois (mostra se o golpe saiu) e o resultado
# =====================================================================================
troca(q|local function decidir_botoes()|, q|--[[
	(0.35) HISTORICO DAS DEFESAS: as ultimas 8, para a aba Prints. Serve para ver, numa
	luta, se o Foresight/Iai/esquiva realmente sairam: a animacao do cacador antes do
	aperto e 0,25s depois (se ficou igual, o jogo ignorou o botao) e se voce levou dano.
]]
local function anotar_defesa(p, defesa, falta)
	if p.diag ~= nil then return; end
	local d = { defesa = defesa, ms = math.floor(falta * 1000 + 0.5), antes = combo.animacao or "?",
		em = os.clock(), depois = nil, resultado = "..." };
	p.diag = d;
	estado.historico = estado.historico or {};
	table.insert(estado.historico, 1, d);
	if #estado.historico > 8 then table.remove(estado.historico); end
end

local function decidir_botoes()|, "anotar");

troca(q|				if not p.esquiva_feita and falta <= antes.esquiva and falta >= antes.esquiva - 0.1 then vai_esquivar = true; end|,
q|				if not p.esquiva_feita and falta <= antes.esquiva and falta >= antes.esquiva - 0.1 then
					vai_esquivar = true;
					anotar_defesa(p, "esquiva", falta);
				end|, "diag_esquiva");

troca(q|				local resultado = executar((antes[defesa] or 0) - falta, p);|, q|				anotar_defesa(p, defesa, falta);
				local resultado, motivo = executar((antes[defesa] or 0) - falta, p);|, "diag_exec");

troca(q|					p.defesa, p.sem_combo, p.estado_pg = reserva, true, {};|, q|					if p.diag ~= nil then p.diag.resultado = "nao deu (" .. tostring(motivo or "?") .. ")"; end
					p.diag = nil;
					p.defesa, p.sem_combo, p.estado_pg = reserva, true, {};|, "diag_indisp");
troca(q|					if reserva == "esquiva" and falta < (antes.esquiva or 0.15) - 0.1 then vai_esquivar = true; p.esquiva_feita = true; end|,
q|					if reserva == "esquiva" and falta < (antes.esquiva or 0.15) - 0.1 then
						vai_esquivar = true; p.esquiva_feita = true;
						anotar_defesa(p, "esquiva", falta);
					end|, "diag_reserva");

troca(q|				sem_combo = casado.sem_combo|, q|				sem_combo = casado.sem_combo, diag = casado.diag|, "registro");

troca(q|			estado.ultimo_resultado = "defendeu com " .. NOME_NIVEL[v.defesa] .. " (" .. v.chave .. ")";|,
q|			estado.ultimo_resultado = "defendeu com " .. NOME_NIVEL[v.defesa] .. " (" .. v.chave .. ")";
			if v.diag ~= nil then v.diag.resultado = "OK (sem dano)"; end|, "diag_ok");
troca(q|		elseif v.sem_combo then
|, q|		elseif v.sem_combo then
			if v.diag ~= nil then v.diag.resultado = "LEVOU DANO"; end
|, "diag_falha1");
troca(q|			local perfil_v = PERFIS[v.perfil] or PERFIS.lanca;
			local proximo = math.min|, q|			if v.diag ~= nil then v.diag.resultado = "LEVOU DANO"; end
			local perfil_v = PERFIS[v.perfil] or PERFIS.lanca;
			local proximo = math.min|, "diag_falha2");

troca(q|		if op.animacoes_ataque_ls[combo.animacao] then combo.ultimo_ataque_em = os.clock(); end|,
q|		if op.animacoes_ataque_ls[combo.animacao] then combo.ultimo_ataque_em = os.clock(); end
		-- (0.35) historico: animacao 0,25s depois de cada defesa
		for _, d in ipairs(estado.historico or {}) do
			if d.depois == nil and os.clock() - d.em >= 0.25 then d.depois = combo.animacao or "?"; end
		end|, "diag_depois");

troca(q|		os.clock() - math.max(combo.ultimo_acerto, combo.ultimo_ataque_em), op.ls_janela_combo_ms));
|, q|		os.clock() - math.max(combo.ultimo_acerto, combo.ultimo_ataque_em), op.ls_janela_combo_ms));

	-- (0.35) historico das defesas
	linha("Ultimas defesas (nova primeiro): defesa - ms antes do golpe - sua animacao antes -> 0,25s depois - resultado");
	if #(estado.historico or {}) == 0 then linha("   (nenhuma ainda)"); end
	for _, d in ipairs(estado.historico or {}) do
		linha(string.format("   %s - %d ms - %s -> %s - %s", NOME_ACAO[d.defesa] or tostring(d.defesa), d.ms,
			tostring(d.antes), tostring(d.depois or "..."), tostring(d.resultado)));
	end
|, "prints");

print $s;
