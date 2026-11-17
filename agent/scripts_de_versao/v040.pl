local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }
sub todas { my ($velho, $novo, $nome) = @_; my $n = 0; while ((my $i = index($s, $velho)) >= 0) { substr($s, $i, length($velho)) = $novo; $n++; } die "$nome nao achado" if $n == 0; }

troca(q|	Versao 0.39 - |, q|	Versao 0.40 - ATAQUE AUTOMATICO da Long Sword (liga/desliga no menu); toques gravados do M1 e do M2
	0.39 - |, "cab");
$s =~ s/versao_mod = "0\.39"/versao_mod = "0.40"/ or die "vm";
$s =~ s/== Defesa Automatica v0\.39 ==/== Defesa Automatica v0.40 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.39"\)/imgui.tree_node("Defesa Automatica v0.40")/ or die "tit";

# =====================================================================================
# 1. OPCOES
# =====================================================================================
troca(q|	ls_janela_combo_ms = 2300, -- (0.33) Foresight e Iai ficam disponiveis ate este tanto depois de um golpe|,
q|	ls_janela_combo_ms = 2300, -- (0.33) Foresight e Iai ficam disponiveis ate este tanto depois de um golpe

	--[[
		ATAQUE AUTOMATICO (0.40, so na Long Sword). O mod aperta os ataques; voce continua
		andando e mirando. Com o monstro perto ("ataque_distancia"):
		  - nenhum golpe do monstro previsto nos proximos "ataque_m1_livre_ms": M1 (golpes
		    mais lentos e fortes);
		  - golpe previsto entre "ataque_preparo_ms" e "ataque_m1_livre_ms": M2 (estocada,
		    rapida), para nao ficar preso num golpe lento e manter o combo;
		  - golpe previsto logo e voce FORA do combo: um M2 de PREPARACAO (uma vez por golpe),
		    para o Foresight / Special Sheathe ficarem disponiveis;
		  - golpe a menos de 0,4s: nao ataca (hora da defesa).
		Um ataque a cada "ataque_intervalo_ms".
	]]
	ataque_automatico = false,
	ataque_distancia = 5.0,
	ataque_intervalo_ms = 500,
	ataque_m1_livre_ms = 1500,
	ataque_preparo_ms = 800,|, "op");

# =====================================================================================
# 2. TOQUES GRAVADOS DO M1 E DO M2 (como o do M5)
# =====================================================================================
troca(q|local NOME_DO_ALVO = { toque_m5 = "TOQUE DO M5 (Iai da Long Sword)",|, q|-- (0.40) botoes que sao gravados como TOQUE (quadro a quadro): alvo -> nome da gravacao
local ALVO_TOQUE = { toque_m5 = "m5", toque_m1 = "m1", toque_m2 = "m2" };

local function alvo_de_toque(alvo)
	return alvo == "esquiva" or ALVO_TOQUE[alvo] ~= nil;
end

local NOME_DO_ALVO = { toque_m1 = "TOQUE DO M1 (ataque automatico)", toque_m2 = "TOQUE DO M2 (ataque automatico)", toque_m5 = "TOQUE DO M5 (Iai da Long Sword)",|, "nome_alvo");

todas(q|(entrada.alvo == "esquiva" or entrada.alvo == "toque_m5")|, q|alvo_de_toque(entrada.alvo)|, "capturas");

troca(q|	if entrada.alvo == "toque_m5" then
		op.toques.m5 = quadros;
		json.dump_file("aviso_lanca_opcoes.json", op);
		estado.mensagem = string.format("Toque do M5 gravado: %d quadros.", #quadros);
		return;
	end|, q|	local nome_toque = ALVO_TOQUE[entrada.alvo];
	if nome_toque ~= nil then
		op.toques[nome_toque] = quadros;
		json.dump_file("aviso_lanca_opcoes.json", op);
		estado.mensagem = string.format("Toque do %s gravado: %d quadros.", string.upper(nome_toque), #quadros);
		return;
	end|, "calcular_toque");

troca(q|		elseif entrada.alvo == "toque_m5" then acao = "APERTE E SOLTE O M5 UMA VEZ";|,
q|		elseif ALVO_TOQUE[entrada.alvo] then acao = "APERTE E SOLTE O " .. string.upper(ALVO_TOQUE[entrada.alvo]) .. " UMA VEZ";|, "status");

troca(q|		elseif entrada.alvo == "toque_m5" then
			if not entrada.teste_estado.tocou then
				entrada.teste_estado.tocou = true;
				if not comecar_toque(true, "m5") then marcar("guarda"); end
			end|, q|		elseif ALVO_TOQUE[entrada.alvo] then
			if not entrada.teste_estado.tocou then
				entrada.teste_estado.tocou = true;
				comecar_toque(true, ALVO_TOQUE[entrada.alvo]);
			end|, "teste");

troca(q|			local alvos = { "guarda", "contra_ataque", "power_guard", "esquiva", "foresight", "iai", "toque_m5" };|,
q|			local alvos = { "guarda", "contra_ataque", "power_guard", "esquiva", "foresight", "iai", "toque_m5", "toque_m1", "toque_m2" };|, "menu_alvos");
troca(q|				"Gravar toque do M5 (para o Iai da Long Sword)" };|,
q|				"Gravar toque do M5 (para o Iai da Long Sword)",
				"Gravar toque do M1 (ataque automatico)", "Gravar toque do M2 (ataque automatico)" };|, "menu_nomes");
troca(q|			if entrada.alvo == "toque_m5" then texto_passo2 = "Passo 2: captura APERTANDO E SOLTANDO O M5 UMA VEZ"; end|,
q|			if ALVO_TOQUE[entrada.alvo] then texto_passo2 = "Passo 2: captura APERTANDO E SOLTANDO O " .. string.upper(ALVO_TOQUE[entrada.alvo]) .. " UMA VEZ"; end|, "passo2");

# =====================================================================================
# 3. PERFIL DA ESPADA LONGA: ataque e ajustes
# =====================================================================================
troca(q|			{ opcao = "ls_janela_combo_ms", nome = "Combo: Foresight e Iai ate quantos ms depois de um golpe seu", maximo = 4000 }
		},|, q|			{ opcao = "ls_janela_combo_ms", nome = "Combo: Foresight e Iai ate quantos ms depois de um golpe seu", maximo = 4000 },
			{ opcao = "ataque_intervalo_ms", nome = "Ataque automatico: um ataque a cada quantos ms", maximo = 2000 },
			{ opcao = "ataque_m1_livre_ms", nome = "Ataque automatico: M1 so se o golpe do monstro vier depois de (ms)", maximo = 4000 },
			{ opcao = "ataque_preparo_ms", nome = "Ataque automatico: M2 de preparacao quantos ms antes do golpe", maximo = 2000 }
		},
		ataque = true, -- (0.40) tem ataque automatico|, "perfil_ls");

# =====================================================================================
# 4. LOGICA DO ATAQUE (no fim de decidir_botoes, antes da esquiva)
# =====================================================================================
troca(q|	-- esquiva: solta o resto (senao o jogo pode fazer outra coisa com o Espaco)
	if vai_esquivar then|, q|	--[[
		(0.40) ATAQUE AUTOMATICO (veja as opcoes "ataque_*"). Cada ataque e um TOQUE: o
		aperto de 1 quadro + o buffer curto, do toque gravado do M1 / M2. Sem o toque do M2
		gravado, o M2 usa o "especial" (o mesmo do Foresight). Sem o toque do M1, nao usa M1.
		Nunca ataca no mesmo quadro de uma defesa, na postura do Special Sheathe ou longe do
		monstro.
	]]
	local atq = estado.ataque or {};
	estado.ataque = atq;
	if atq.nome == nil and op.ataque_automatico and perfil.ataque and not vai_esquivar
		and next(teclas_agora) == nil and toque.quadro == nil and not espada_na_bainha()
		and momento >= (atq.proximo_em or 0) then
		local perto, proximo, alvo_p = false, nil, nil;
		for _, m in pairs(monstros) do
			if m.distancia ~= nil and m.distancia <= op.ataque_distancia then perto = true; end
			for _, p in ipairs(m.previstos) do
				local falta = p.tempo - momento;
				if falta > -0.05 and (proximo == nil or falta < proximo) then proximo, alvo_p = falta, p; end
			end
		end
		if perto then
			local livre, preparo = op.ataque_m1_livre_ms / 1000, op.ataque_preparo_ms / 1000;
			local qual = nil;
			if proximo == nil or proximo > livre then
				qual = "m1";
			elseif proximo > preparo then
				-- golpe a caminho: M2 (rapido). Nao se o golpe vai ser defendido com o Special
				-- Sheathe (a estocada atrapalharia a postura)
				if not (alvo_p ~= nil and alvo_p.defesa == "iai") then qual = "m2"; end
			elseif proximo > 0.4 and alvo_p ~= nil and not alvo_p.preparado and not em_combo_espada_longa() then
				qual = "m2"; -- preparacao: abre o Foresight / Special Sheathe
				alvo_p.preparado = true;
			end
			if qual == "m1" and #(op.toques.m1 or {}) == 0 then qual = nil; end
			if qual ~= nil then
				atq.nome, atq.quadro = qual, 0;
				atq.ultimo, atq.ultimo_em = qual, momento;
				atq.proximo_em = momento + op.ataque_intervalo_ms / 1000;
				combo.ultimo_ataque_em = os.clock(); -- um golpe seu: conta para o combo
			end
		end
	end
	if atq.nome ~= nil then
		atq.quadro = atq.quadro + 1;
		local gravado = op.toques[atq.nome] or {};
		if #gravado > 0 and atq.quadro <= math.min(#gravado, 6) then
			marcar("toque:" .. atq.nome .. ":" .. atq.quadro);
		elseif #gravado == 0 and atq.nome == "m2" and atq.quadro <= 4 then
			marcar("especial");
		else
			atq.nome = nil;
		end
	end

	-- esquiva: solta o resto (senao o jogo pode fazer outra coisa com o Espaco)
	if vai_esquivar then|, "ataque");

# =====================================================================================
# 5. MENU E PRINTS
# =====================================================================================
troca(q|	mudou_simples, op.tenho_guard_up = imgui.checkbox("Tenho Guard Up (guardar golpes \"impossiveis\")", op.tenho_guard_up);
	alterou_simples = alterou_simples or mudou_simples;|, q|	mudou_simples, op.tenho_guard_up = imgui.checkbox("Tenho Guard Up (guardar golpes \"impossiveis\")", op.tenho_guard_up);
	alterou_simples = alterou_simples or mudou_simples;

	mudou_simples, op.ataque_automatico = imgui.checkbox("Ataque automatico (Long Sword)", op.ataque_automatico);
	alterou_simples = alterou_simples or mudou_simples;
	if op.ataque_automatico and #(op.toques.m1 or {}) == 0 then
		imgui.text("   Falta gravar o toque do M1: Diagnostico > Testar botoes > Gravar toque do M1");
	end|, "menu_principal");

troca(q|		-- tempos que fazem parte de uma defesa (ex.: o Iai depois do Special Sheathe)|, q|		if perfil_menu.ataque then
			alterado, op.ataque_distancia = imgui.slider_float("Ataque automatico: monstro a ate quantos metros", op.ataque_distancia, 2.0, 15.0, "%.1f");
			mudou_arma = mudou_arma or alterado;
		end

		-- tempos que fazem parte de uma defesa (ex.: o Iai depois do Special Sheathe)|, "menu_distancia");

troca(q|	linha(string.format("Long Sword: ultimo golpe seu ha %.1fs (janela do combo %d ms)",|, q|	local atq_p = estado.ataque or {};
	linha(string.format("Ataque automatico: %s - ultimo: %s ha %.1fs - toques gravados: M1 %d, M2 %d, M5 %d quadros",
		op.ataque_automatico and "LIGADO" or "desligado", tostring(atq_p.ultimo or "-"),
		agora() - (atq_p.ultimo_em or -1000), #(op.toques.m1 or {}), #(op.toques.m2 or {}), #(op.toques.m5 or {})));
	linha(string.format("Long Sword: ultimo golpe seu ha %.1fs (janela do combo %d ms)",|, "prints");

print $s;
