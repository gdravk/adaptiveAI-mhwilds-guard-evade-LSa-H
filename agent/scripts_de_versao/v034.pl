local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }
sub todas { my ($velho, $novo, $nome) = @_; my $n = 0; while ((my $i = index($s, $velho)) >= 0) { substr($s, $i, length($velho)) = $novo; $n++; } die "$nome nao achado" if $n == 0; }

# --- versao
$s =~ s/Versao 0\.33 - Long Sword/Versao 0.34 - toque gravado do M5 (Iai) e dano pela vida; 0.33 - Long Sword/ or die "cab";
$s =~ s/versao_mod = "0\.33"/versao_mod = "0.34"/ or die "vm";
$s =~ s/== Defesa Automatica v0\.33 ==/== Defesa Automatica v0.34 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.33"\)/imgui.tree_node("Defesa Automatica v0.34")/ or die "tit";

# =====================================================================================
# 1. TOQUE GRAVADO DO M5 (para o Iai)
# =====================================================================================
troca(q|	toques = {},|, q|	toques = {},
	ls_zerado_034 = false, -- (0.34) o aprendizado da espada longa da 0.33 foi zerado uma vez|, "op");

# captura: o "toque_m5" grava quadro a quadro, como a esquiva
troca(q|	if numero == 2 and entrada.alvo == "esquiva" then|, q|	if numero == 2 and (entrada.alvo == "esquiva" or entrada.alvo == "toque_m5") then|, "cap1");
troca(q|		if entrada.captura_numero == 2 and entrada.alvo == "esquiva" and entrada.base ~= nil then|,
q|		if entrada.captura_numero == 2 and (entrada.alvo == "esquiva" or entrada.alvo == "toque_m5") and entrada.base ~= nil then|, "cap2");
troca(q|			if entrada.captura_numero == 2 and entrada.alvo == "esquiva" then
				pcall(calcular_toque);|, q|			if entrada.captura_numero == 2 and (entrada.alvo == "esquiva" or entrada.alvo == "toque_m5") then
				pcall(calcular_toque);|, "cap3");

troca(q|	op.toques.esquiva = quadros;
	op.espaco_segurado = maior;
	json.dump_file("aviso_lanca_opcoes.json", op);|, q|	-- (0.34) toque do M5 (Iai Spirit Slash da espada longa)
	if entrada.alvo == "toque_m5" then
		op.toques.m5 = quadros;
		json.dump_file("aviso_lanca_opcoes.json", op);
		estado.mensagem = string.format("Toque do M5 gravado: %d quadros.", #quadros);
		return;
	end

	op.toques.esquiva = quadros;
	op.espaco_segurado = maior;
	json.dump_file("aviso_lanca_opcoes.json", op);|, "calcular_toque");
troca(q|		estado.mensagem = "Toque nao gravado: nenhuma mudanca. Aperte e solte o Espaco durante a captura.";|,
q|		estado.mensagem = "Toque nao gravado: nenhuma mudanca. Aperte e solte o botao durante a captura.";|, "msg_toque");

# reproducao: o toque tem nome ("esquiva" ou "m5")
troca(q|	elseif string.sub(acao, 1, 6) == "toque:" then
		-- um quadro do toque gravado da esquiva
		local quadro = tonumber(string.sub(acao, 7));
		return (op.toques.esquiva or {})[quadro] or {};|, q|	elseif string.sub(acao, 1, 6) == "toque:" then
		-- um quadro de um toque gravado ("toque:esquiva:12" ou "toque:m5:3")
		local nome, quadro = string.match(acao, "^toque:([%w_]+):(%d+)$");
		return (op.toques[nome or "esquiva"] or {})[tonumber(quadro or 0)] or {};|, "campos_toque");

troca(q|local toque = { quadro = nil, exclusivo = true };

local function comecar_toque(exclusivo)
	if toque.quadro == nil and #(op.toques.esquiva or {}) > 0 then
		toque.quadro = 1;
		toque.exclusivo = exclusivo;
		return true;
	end
	return false;
end|, q|local toque = { quadro = nil, exclusivo = true, nome = "esquiva" };

-- (0.34) "nome": qual gravacao tocar ("esquiva" = Espaco, padrao; "m5" = M5 do Iai)
local function comecar_toque(exclusivo, nome)
	nome = nome or "esquiva";
	if toque.quadro == nil and #(op.toques[nome] or {}) > 0 then
		toque.quadro = 1;
		toque.exclusivo = exclusivo;
		toque.nome = nome;
		return true;
	end
	return false;
end|, "comecar_toque");

troca(q|	if toque.quadro ~= nil then
		local quadros = op.toques.esquiva or {};
		if toque.quadro > #quadros then
			toque.quadro = nil;
		else
			if toque.exclusivo then teclas_agora = {}; end
			marcar("toque:" .. toque.quadro);|, q|	if toque.quadro ~= nil then
		local quadros = op.toques[toque.nome or "esquiva"] or {};
		if toque.quadro > #quadros then
			toque.quadro = nil;
		else
			if toque.exclusivo then teclas_agora = {}; end
			marcar("toque:" .. (toque.nome or "esquiva") .. ":" .. toque.quadro);|, "reproducao");

# Iai: usa o toque gravado do M5 (se existir)
troca(q|				if na_postura then
					e.m5_ate = desde + 0.1;
					e.proximo_m5 = desde + 0.25;
				else|, q|				if na_postura then
					-- (0.34) o M5 escrito como "guarda" nao solta o Iai (no teste so guardava a
					-- arma). Usa o toque do M5 gravado de verdade, como na esquiva.
					e.usou_toque = comecar_toque(false, "m5");
					e.m5_ate = desde + 0.1;
					e.proximo_m5 = desde + math.max(0.25, #(op.toques.m5 or {}) / 60 + 0.1);
				else|, "iai1");
troca(q|			if e.m5_ate ~= nil and desde < e.m5_ate then marcar("guarda"); end|,
q|			if e.m5_ate ~= nil and desde < e.m5_ate and not e.usou_toque then marcar("guarda"); end|, "iai2");

# teste e menu do toque do M5
troca(q|		elseif entrada.alvo == "contra_ataque" then
			if desde < 1.5 then marcar_contra_ataque(desde); end|, q|		elseif entrada.alvo == "toque_m5" then
			if not entrada.teste_estado.tocou then
				entrada.teste_estado.tocou = true;
				if not comecar_toque(true, "m5") then marcar("guarda"); end
			end
		elseif entrada.alvo == "contra_ataque" then
			if desde < 1.5 then marcar_contra_ataque(desde); end|, "teste_m5");

troca(q|local NOME_DO_ALVO = { |, q|local NOME_DO_ALVO = { toque_m5 = "TOQUE DO M5 (Iai da Long Sword)", |, "nome_alvo");

troca(q|		acao = (entrada.alvo == "esquiva") and "APERTE E SOLTE O ESPACO UMA VEZ" or ("SEGURE " .. NOME_DO_ALVO[entrada.alvo]);|,
q|		if entrada.alvo == "esquiva" then acao = "APERTE E SOLTE O ESPACO UMA VEZ";
		elseif entrada.alvo == "toque_m5" then acao = "APERTE E SOLTE O M5 UMA VEZ";
		else acao = "SEGURE " .. NOME_DO_ALVO[entrada.alvo]; end|, "status_cap");

troca(q|			local texto_passo2 = (entrada.alvo == "esquiva") and "Passo 2: captura APERTANDO E SOLTANDO O ESPACO UMA VEZ" or ("Passo 2: captura SEGURANDO " .. NOME_DO_ALVO[entrada.alvo]);|,
q|			local texto_passo2 = (entrada.alvo == "esquiva") and "Passo 2: captura APERTANDO E SOLTANDO O ESPACO UMA VEZ" or ("Passo 2: captura SEGURANDO " .. NOME_DO_ALVO[entrada.alvo]);
			if entrada.alvo == "toque_m5" then texto_passo2 = "Passo 2: captura APERTANDO E SOLTANDO O M5 UMA VEZ"; end|, "passo2");

troca(q|				"Foresight Slash (Long Sword)", "Special Sheathe + Iai (Long Sword)", "Charged Step (Hammer)" };|,
q|				"Foresight Slash (Long Sword)", "Special Sheathe + Iai (Long Sword)", "Charged Step (Hammer)",
				"Gravar toque do M5 (para o Iai da Long Sword)" };|, "menu_nomes");
troca(q|			local alvos = { "guarda", "contra_ataque", "power_guard", "esquiva", "foresight", "iai", "charged_step" };|,
q|			local alvos = { "guarda", "contra_ataque", "power_guard", "esquiva", "foresight", "iai", "charged_step", "toque_m5" };|, "menu_alvos");

# =====================================================================================
# 2. DANO PELA VIDA DO CACADOR (a animacao "banco 14" pode nao ser so de dano)
# =====================================================================================
troca(q|		if banco == 14 and estado.banco_cacador ~= 14 then estado.levou_dano_em = os.clock(); end|,
q|		-- (0.34) se a vida do cacador puder ser lida, ela decide (ver abaixo); o banco 14 so
		-- fica como reserva
		if banco == 14 and estado.banco_cacador ~= 14 and not estado.vida_lida then estado.levou_dano_em = os.clock(); end|, "banco14");

troca(q|	local objeto_cacador = cacador and objeto_de_jogo(cacador);
	local cx, cy, cz;|, q|	local objeto_cacador = cacador and objeto_de_jogo(cacador);
	local cx, cy, cz;

	--[[
		(0.34) DANO PELA VIDA: na 0.33 a espada longa marcou 14 golpes como "falhou" e o
		Foresight virou Iai neles. O mod achava que voce levou dano quando o cacador entrava
		numa animacao do "banco 14", que talvez nao seja so de dano. Agora, se a vida do
		cacador puder ser lida, "levou dano" = a vida caiu.
	]]
	if cacador ~= nil then
		local ok_vida, vida = pcall(function()
			return cacador:call("get_HunterHealth"):call("get_HealthMgr"):call("get_Health");
		end);
		vida = ok_vida and tonumber(vida) or nil;
		if vida ~= nil then
			estado.vida_lida = true;
			if estado.vida_anterior ~= nil and vida < estado.vida_anterior - 0.5 then
				estado.levou_dano_em = os.clock();
			end
			estado.vida_anterior = vida;
		end
	end|, "vida");

# Prints: vida e ultimo dano
troca(q|	linha(string.format("Long Sword: ultimo golpe seu ha %.1fs (janela do combo %d ms)",|,
q|	linha(string.format("Vida do cacador: %s - ultimo dano ha %.1fs - toque do M5: %d quadros",
		estado.vida_lida and string.format("%.0f", estado.vida_anterior or 0) or "NAO LIDA (usando o banco 14)",
		os.clock() - (estado.levou_dano_em or -1000), #(op.toques.m5 or {})));
	linha(string.format("Long Sword: ultimo golpe seu ha %.1fs (janela do combo %d ms)",|, "prints");

# =====================================================================================
# 3. ZERA UMA VEZ o aprendizado da espada longa da 0.33 (feito com o Iai sem funcionar)
# =====================================================================================
troca(q|		for chave, nivel in pairs(salvo.golpes) do
			if string.match(chave, "^%d") then chave = "lanca:" .. chave; end
			defesas_aprendidas[chave] = nivel;
		end|, q|		for chave, nivel in pairs(salvo.golpes) do
			if string.match(chave, "^%d") then chave = "lanca:" .. chave; end
			-- (0.34) os golpes da espada longa aprendidos ate a 0.33 voltam ao Foresight
			if not (op.ls_zerado_034 ~= true and string.sub(chave, 1, 13) == "espada_longa:") then
				defesas_aprendidas[chave] = nivel;
			end
		end
		if op.ls_zerado_034 ~= true then
			op.ls_zerado_034 = true;
			json.dump_file("aviso_lanca_opcoes.json", op);
			json.dump_file("aviso_lanca_defesas.json", { golpes = defesas_aprendidas });
		end|, "zerar_ls");

print $s;
