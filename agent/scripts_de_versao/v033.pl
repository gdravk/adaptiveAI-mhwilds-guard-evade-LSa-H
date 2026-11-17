local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

# --- versao
$s =~ s/Versao 0\.32 - guarda/Versao 0.33 - Long Sword: combo dura 2,5s, Iai com repeticao do M5; 0.32 - guarda/ or die "cab";
$s =~ s/versao_mod = "0\.32"/versao_mod = "0.33"/ or die "vm";
$s =~ s/== Defesa Automatica v0\.32 ==/== Defesa Automatica v0.33 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.32"\)/imgui.tree_node("Defesa Automatica v0.33")/ or die "tit";

# --- opcoes
troca(q|	ls_sheathe_ms = 900,    -- Special Sheathe (M5 + Espaco) este tanto antes do golpe|,
q|	ls_sheathe_ms = 1200,   -- Special Sheathe (M5 + Espaco) este tanto antes do golpe
	ls_janela_combo_ms = 2300, -- (0.33) Foresight e Iai ficam disponiveis ate este tanto depois de um golpe|, "op");

troca(q|	versao_campos = 6,|, q|	versao_campos = 7,|, "versao_campos");
troca(q|	op.versao_campos = 6;|, q|	-- 0.33: na 0.32 o Iai (M5) vinha cedo demais, antes da postura do Special Sheathe ficar
	-- pronta. O Special Sheathe passa a comecar 1200 ms antes (era 900).
	if (salvo.versao_campos or 1) < 7 and op.ls_sheathe_ms == 900 then
		op.ls_sheathe_ms = 1200;
	end
	op.versao_campos = 7;|, "migracao");

# --- combo: janela de 2,5s depois do ultimo golpe (o teste mostrou que o Foresight e o
#     Special Sheathe ficam disponiveis ate ~2,5s depois de um golpe, nao so durante ele)
troca(q|local combo = { ultimo_acerto = -100, animacao = nil };|, q|local combo = { ultimo_acerto = -100, ultimo_ataque_em = -100, animacao = nil };|, "combo_tab");

troca(q|local function em_combo_espada_longa()
	if os.clock() - combo.ultimo_acerto < 0.6 then return true; end
	return combo.animacao ~= nil and op.animacoes_ataque_ls[combo.animacao] == true;
end|, q|--[[
	(0.33) Voce testou: depois de um golpe, o Foresight e o Special Sheathe podem ser usados
	ate ~2,5 segundos depois. Na 0.32 o mod so considerava "em combo" DURANTE a animacao de
	ataque (ou 0,6s depois de acertar), por isso nunca saiam sozinhos.
	Agora: em combo = o ultimo golpe da espada (animacao de ataque ou acerto) foi ha menos
	de "ls_janela_combo_ms" (2300 ms, um pouco abaixo dos 2,5s por seguranca).
]]
local function em_combo_espada_longa()
	if combo.animacao ~= nil and op.animacoes_ataque_ls[combo.animacao] == true then return true; end
	local ultimo = math.max(combo.ultimo_acerto, combo.ultimo_ataque_em);
	return os.clock() - ultimo < op.ls_janela_combo_ms / 1000;
end|, "em_combo");

troca(q|		combo.animacao = tostring(banco) .. ":" .. tostring(id_cacador);|, q|		combo.animacao = tostring(banco) .. ":" .. tostring(id_cacador);
		if op.animacoes_ataque_ls[combo.animacao] then combo.ultimo_ataque_em = os.clock(); end|, "acompanhar");

# --- Iai: repete o M5 enquanto continuar na postura do Special Sheathe
troca(q|		-- 2. Iai Spirit Slash: um toque no M5
		local hora_iai = (op.ls_sheathe_ms - op.ls_iai_ms) / 1000;
		if desde >= hora_iai and desde < hora_iai + 0.1 then marcar("guarda"); end|, q|		--[[
			2. Iai Spirit Slash: toque no M5. (0.33) No teste o Special Sheathe saiu mas o Iai
			nao: o M5 chegou antes de a postura ficar pronta e o jogo ignorou. Agora o mod
			anota as animacoes da postura e, se 0,25s depois do toque ainda estiver nela,
			aperta o M5 de novo (ate o golpe chegar).
		]]
		local e = p.estado_pg;
		local hora_iai = (op.ls_sheathe_ms - op.ls_iai_ms) / 1000;
		if desde >= 0.1 and desde < hora_iai and combo.animacao ~= nil then
			e.postura = e.postura or {};
			e.postura[combo.animacao] = true;
		end
		if desde >= hora_iai then
			e.proximo_m5 = e.proximo_m5 or hora_iai;
			if desde >= e.proximo_m5 then
				local na_postura = e.m5_ate == nil
					or (e.postura ~= nil and combo.animacao ~= nil and e.postura[combo.animacao] == true);
				if na_postura then
					e.m5_ate = desde + 0.1;
					e.proximo_m5 = desde + 0.25;
				else
					e.proximo_m5 = math.huge; -- o Iai saiu
				end
			end
			if e.m5_ate ~= nil and desde < e.m5_ate then marcar("guarda"); end
		end|, "iai");

# --- teste do Iai dura mais (para dar tempo da repeticao)
troca(q|			local duracao = (op[perfil_teste.antecedencia[entrada.alvo]] or 0) / 1000 + 0.3;|,
q|			local duracao = (op[perfil_teste.antecedencia[entrada.alvo]] or 0) / 1000 + ((entrada.alvo == "iai") and 1.5 or 0.3);|, "teste");

# --- menu: janela do combo
troca(q|		tempos_extras = { { opcao = "ls_iai_ms", nome = "Iai Spirit Slash: M5 quantos ms antes do golpe", maximo = 500 } },|,
q|		tempos_extras = {
			{ opcao = "ls_iai_ms", nome = "Iai Spirit Slash: M5 quantos ms antes do golpe", maximo = 500 },
			{ opcao = "ls_janela_combo_ms", nome = "Combo: Foresight e Iai ate quantos ms depois de um golpe seu", maximo = 4000 }
		},|, "menu");

# --- prints: linha da Long Sword e linhas que eram so da lanca
troca(q|		tostring(em_combo_espada_longa()), tostring(combo.animacao), qtd_ataques));|,
q|		tostring(em_combo_espada_longa()), tostring(combo.animacao), qtd_ataques));
	linha(string.format("Long Sword: ultimo golpe seu ha %.1fs (janela do combo %d ms)",
		os.clock() - math.max(combo.ultimo_acerto, combo.ultimo_ataque_em), op.ls_janela_combo_ms));|, "prints_ls");

troca(q|	linha(string.format("Defesa: %s \| agindo: %s \| comeca em: %s \| %s",
		op.guarda_automatica and "ligada" or "desligada",
		estado.motivo_parado == "" and "SIM" or ("nao (" .. estado.motivo_parado .. ")"),
		op.acao_guardavel, (op.usar_power_guard and "power guard ligado" or "power guard desligado") .. (op.esquivar and ", esquiva ligada" or ", esquiva desligada")));
	linha(string.format("Tempos (ms antes): guarda %d \| contra %d \| power %d \| esquiva %d \| segurar depois %d",
		op.antecedencia_guarda_ms, op.antecedencia_contra_ms, op.antecedencia_power_ms,
		op.antecedencia_esquiva_ms, op.segurar_depois_ms));|, q|	-- (0.33) estas duas linhas agora mostram a arma atual (antes eram sempre da lanca)
	linha(string.format("Defesa: %s - agindo: %s - Guard Up: %s",
		op.guarda_automatica and "ligada" or "desligada",
		estado.motivo_parado == "" and "SIM" or ("nao (" .. estado.motivo_parado .. ")"),
		op.tenho_guard_up and "sim" or "nao"));
	local tempos_txt = {};
	if perfil_atual ~= nil then
		for _, acao in ipairs(perfil_atual.niveis) do
			local opcao = perfil_atual.antecedencia[acao];
			if opcao ~= nil then tempos_txt[#tempos_txt + 1] = NOME_ACAO[acao] .. " " .. tostring(op[opcao]); end
		end
		for _, extra in ipairs(perfil_atual.tempos_extras or {}) do
			tempos_txt[#tempos_txt + 1] = extra.opcao .. " " .. tostring(op[extra.opcao]);
		end
	end
	linha("Tempos (ms antes): " .. (#tempos_txt > 0 and table.concat(tempos_txt, " - ") or "-"));|, "prints_lanca");

print $s;
