local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }
sub todas { my ($velho, $novo, $nome) = @_; my $n = 0; while ((my $i = index($s, $velho)) >= 0) { substr($s, $i, length($velho)) = $novo; $n++; } die "$nome nao achado" if $n == 0; }

troca(q|	Versao 0.42 - |, q|	Versao 0.43 - LIMPEZA: sem mudar o que funciona, saiu o codigo que nao era mais usado (ferramentas
	de pesquisa, gravador, exportacoes, painel, Special Sheathe + Iai). Voltou ao menu a gravacao dos
	toques do M5 e do M2 (o Foresight da Long Sword usa essas gravacoes).
	0.42 - |, "cab");
$s =~ s/versao_mod = "0\.42"/versao_mod = "0.43"/ or die "vm";
$s =~ s/== Defesa Automatica v0\.42 ==/== Defesa Automatica v0.43 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.42"\)/imgui.tree_node("Defesa Automatica v0.43")/ or die "tit";

# =====================================================================================
# 1. PESQUISA: gravador, exportacoes e painel
# =====================================================================================
$s =~ s/\n\tregistrar\("impacto_em_voce", \{.*?\n\t\}\);\n//s or die "reg_impacto";
troca(q|local registrar; -- gravador (parte 6)
|, "", "decl_registrar");

$s =~ s/-- =+\n-- 6\. PESQUISA \(gravador, exportacao, arma\)\n.*?\tjson\.dump_file\("aviso_lanca_controles\.json", resultado\);\n.*?\nend\n/-- =====================================================================================
-- 6. ARMA ATUAL (para a aba Prints)
-- =====================================================================================

local pesquisa = {
	arma_tipo = nil,         -- classe real da sua arma (ex.: lanca)
	arma_ganchos = {}        -- funcoes da arma com gancho ligado
};
/s or die "pesquisa";

$s =~ s/\n\n\t\t\tif pesquisa\.gravando then\n\t\t\t\tlocal m = monstro_mais_perto\(\);\n\t\t\t\tregistrar\("defesa".*?\n\t\t\tend\n/\n/s or die "reg_defesa";
$s =~ s/\n\n\t\t\t\t\tregistrar\("animacao_monstro".*?\}\);\n/\n/s or die "reg_animacao";
$s =~ s/\t-- suas animacoes \(so para a gravacao de pesquisa\)\n\tif pesquisa\.gravando and objeto_cacador ~= nil then\n.*?\n\tend\n\n//s or die "reg_minha";
troca(qq|local minha_animacao = nil;\n|, "", "minha_animacao");
$s =~ s/-- painel de pesquisa \(opcional\)\nlocal function desenhar_painel\(\)\n.*?\nend\n\n//s or die "painel";
troca(qq|\tif op.mostrar_painel then pcall(desenhar_painel); end\n|, "", "painel_call");
troca(qq|\tmostrar_painel = false, -- painel de pesquisa (animacao atual, distancia...)\n|, "", "op_painel");
troca(qq|\t\top.mostrar_painel = false;\n|, "", "mig_painel");

# =====================================================================================
# 2. SPECIAL SHEATHE + IAI (desativado na 0.41)
# =====================================================================================
$s =~ s/\tend,\n\tiai = function\(desde, p\)\n.*?\n\tend\n\};/\tend\n};/s or die "exec_iai";
troca(q|--[[
	ESPADA LONGA (revisado na 0.30)
	  Foresight Slash: M5 + M2 juntos, um toque.
	  Special Sheathe + Iai: M5 + Espaco juntos (toque gravado do Espaco por cima do M5) e,
	  "ls_iai_ms" antes do golpe, um toque no M5 (Iai Spirit Slash).
	Devolvem "indisponivel" quando:
	  - voce nao esta num combo (os dois so aparecem depois de um golpe da espada);
	  - o golpe foi previsto tarde demais para comecar a tempo.
]]|, q|--[[
	ESPADA LONGA - Foresight Slash: M5 + M2 juntos (toques gravados, com o buffer).
	Devolve "indisponivel" (e o mod esquiva) quando:
	  - voce nao esta num combo (o Foresight so aparece depois de um golpe da espada);
	  - o golpe foi previsto tarde demais para comecar a tempo.
]]|, "doc_ls");

troca(q|	if cacador:call("get_IsWeaponOn") ~= true then
		-- (0.35) na postura do Special Sheathe a espada fica na bainha, mas o mod ainda
		-- precisa apertar o M5 do Iai: continua ate a postura acabar
		local na_postura = estado.postura_ls_ate ~= nil and os.clock() < estado.postura_ls_ate;
		if not na_postura then return false, string.lower(perfil.nome) .. " guardada"; end
	end|, q|	if cacador:call("get_IsWeaponOn") ~= true then return false, string.lower(perfil.nome) .. " guardada"; end|, "pode_defender");

troca(q|-- (0.39) a espada esta na bainha? (na postura do Special Sheathe ela fica; o Iai a tira)
local function espada_na_bainha()
	local ok, sacada = pcall(function() return meu_cacador():call("get_IsWeaponOn"); end);
	return ok and sacada == false;
end

|, "", "bainha");

troca(qq|\tls_sheathe_ms = 1200,   -- Special Sheathe (M5 + Espaco) este tanto antes do golpe\n|, "", "op_sheathe");
troca(qq|\tls_iai_ms = 120,        -- Iai Spirit Slash (M5) este tanto antes do golpe\n|, "", "op_iai");
troca(q|	ls_janela_combo_ms = 2300, -- (0.33) Foresight e Iai ficam disponiveis ate este tanto depois de um golpe|,
q|	ls_janela_combo_ms = 2300, -- (0.33) o Foresight fica disponivel ate este tanto depois de um golpe|, "op_janela");
troca(q|	-- 0.33: na 0.32 o Iai (M5) vinha cedo demais, antes da postura do Special Sheathe ficar
	-- pronta. O Special Sheathe passa a comecar 1200 ms antes (era 900).
	if (salvo.versao_campos or 1) < 7 and op.ls_sheathe_ms == 900 then
		op.ls_sheathe_ms = 1200;
	end
|, "", "mig_sheathe");
troca(q|	-- volta para 120 ms. O Iai (ls_iai_ms) ja era 120 ms; o Special Sheathe continua antes.|,
q|	-- volta para 120 ms.|, "mig_coment");

troca(q|	foresight = "Foresight Slash", iai = "Special Sheathe + Iai"|, q|	foresight = "Foresight Slash"|, "nome_acao");

troca(q|		elseif entrada.alvo == "foresight" or entrada.alvo == "iai" then|, q|		elseif entrada.alvo == "foresight" then|, "teste1");
troca(q|			local duracao = (op[perfil_teste.antecedencia[entrada.alvo]] or 0) / 1000 + ((entrada.alvo == "iai") and 1.5 or 0.3);|,
q|			local duracao = (op[perfil_teste.antecedencia[entrada.alvo]] or 0) / 1000 + 0.3;|, "teste2");
troca(qq|\t\t\t\tif acao == "iai" then maximo = 1500; end\n|, "", "menu_max");
troca(q|			local e_combo = entrada.alvo == "foresight" or entrada.alvo == "iai";|, q|			local e_combo = entrada.alvo == "foresight";|, "menu_combo");

# =====================================================================================
# 3. GRAVACAO DOS TOQUES DO M5 E DO M2 DE VOLTA NO MENU (o Foresight usa as duas)
# =====================================================================================
troca(q|local NOME_DO_ALVO = { toque_m5 = "TOQUE DO M5 (Iai da Long Sword)", foresight = "FORESIGHT SLASH (M5 + M2)", iai = "SPECIAL SHEATHE + IAI (M5 + Espaco, depois M5)",|,
q|-- botoes gravados como TOQUE (quadro a quadro): alvo -> nome da gravacao
local ALVO_TOQUE = { toque_m5 = "m5", toque_m2 = "m2" };

local function alvo_de_toque(alvo)
	return alvo == "esquiva" or ALVO_TOQUE[alvo] ~= nil;
end

local NOME_DO_ALVO = { toque_m5 = "TOQUE DO M5 (Foresight da Long Sword)", toque_m2 = "TOQUE DO M2 (Foresight da Long Sword)", foresight = "FORESIGHT SLASH (M5 + M2)",|, "nome_alvo");
todas(q|(entrada.alvo == "esquiva" or entrada.alvo == "toque_m5")|, q|alvo_de_toque(entrada.alvo)|, "capturas");
troca(q|	-- (0.34) toque do M5 (Iai Spirit Slash da espada longa)
	if entrada.alvo == "toque_m5" then
		op.toques.m5 = quadros;
		json.dump_file("aviso_lanca_opcoes.json", op);
		estado.mensagem = string.format("Toque do M5 gravado: %d quadros.", #quadros);
		return;
	end|, q|	-- toques do M5 e do M2 (Foresight Slash da espada longa)
	local nome_toque = ALVO_TOQUE[entrada.alvo];
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
			end|, "teste_toque");
troca(q|			if entrada.alvo == "toque_m5" then texto_passo2 = "Passo 2: captura APERTANDO E SOLTANDO O M5 UMA VEZ"; end|,
q|			if ALVO_TOQUE[entrada.alvo] then texto_passo2 = "Passo 2: captura APERTANDO E SOLTANDO O " .. string.upper(ALVO_TOQUE[entrada.alvo]) .. " UMA VEZ"; end|, "passo2");
troca(q|			-- (0.41) Special Sheathe + Iai e o toque do M5 sairam do menu (desativados)
			local alvos = { "guarda", "contra_ataque", "power_guard", "esquiva", "foresight" };
			local nomes = { "Guarda (M5)", "Contra-ataque (M5 e depois M2)", "Power Guard (M5, M2 e Espaco)", "Esquiva (Espaco)",
				"Foresight Slash (Long Sword)" };|, q|			local alvos = { "guarda", "contra_ataque", "power_guard", "esquiva", "foresight", "toque_m5", "toque_m2" };
			local nomes = { "Guarda (M5)", "Contra-ataque (M5 e depois M2)", "Power Guard (M5, M2 e Espaco)", "Esquiva (Espaco)",
				"Foresight Slash (Long Sword)", "Gravar toque do M5 (Foresight)", "Gravar toque do M2 (Foresight)" };|, "menu_alvos");
troca(q|	linha(string.format("Vida do cacador: %s - ultimo dano ha %.1fs - toque do M5: %d quadros",
		estado.vida_lida and string.format("%.0f", estado.vida_anterior or 0) or "NAO LIDA (usando o banco 14)",
		os.clock() - (estado.levou_dano_em or -1000), #(op.toques.m5 or {})));|,
q|	linha(string.format("Vida do cacador: %s - ultimo dano ha %.1fs - toques gravados: M5 %d, M2 %d quadros",
		estado.vida_lida and string.format("%.0f", estado.vida_anterior or 0) or "NAO LIDA (usando o banco 14)",
		os.clock() - (estado.levou_dano_em or -1000), #(op.toques.m5 or {}), #(op.toques.m2 or {})));|, "prints");

print $s;
