local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

# --- versao
$s =~ s/Versao 0\.28 - menu simples; 7 ARMAS/Versao 0.29 - Long Sword (Foresight Slash, Special Sheathe + Iai) e Hammer (Charged Step); menu simples; 7 ARMAS/ or die "cab";
$s =~ s/versao_mod = "0\.28"/versao_mod = "0.29"/ or die "vm";
$s =~ s/== Defesa Automatica v0\.28 ==/== Defesa Automatica v0.29 ==/ or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.28"\)/imgui.tree_node("Defesa Automatica v0.29")/ or die "tit";

# --- opcoes novas
troca(q|	esquiva_ms_espada_longa = 150,|, q|	esquiva_ms_espada_longa = 150,

	-- Espada Longa (0.29)
	ls_foresight_ms = 120,  -- Foresight Slash (M5 + M2) este tanto antes do golpe
	ls_sheathe_ms = 900,    -- Special Sheathe (M5 + Espaco) este tanto antes do golpe
	ls_iai_ms = 120,        -- Iai Spirit Slash (M5) este tanto antes do golpe
	animacoes_ataque_ls = {}, -- animacoes de ataque da espada longa (aprendidas sozinhas)

	-- Martelo (0.29)
	martelo_carga_ms = 900, -- comeca a carregar (M5 segurado) este tanto antes do golpe
	martelo_step_ms = 150,  -- Charged Step (M2 com a carga) este tanto antes do golpe|, "op");

# --- nomes das defesas
troca(q|	contra_ataque = "contra-ataque", guarda = "guarda", power_guard = "Power Guard", esquiva = "esquiva"
};|, q|	contra_ataque = "contra-ataque", guarda = "guarda", power_guard = "Power Guard", esquiva = "esquiva",
	foresight = "Foresight Slash", iai = "Special Sheathe + Iai", charged_step = "Charged Step"
};|, "nomes");

# --- perfil do martelo
$s =~ s/\t-- Martelo: por enquanto so a esquiva.*?\n\t\teventos = \{\}\n\t\},\n/\t--[[
		MARTELO (0.29): 1. Charged Step   2. esquiva (quando o Charged Step nao der).
		Charged Step = carregar (M5 segurado) e, carregando, um toque no M2.
	]]
	martelo = {
		nome = "Hammer",
		classe = "app.cHunterWp04Handling",
		niveis = { "charged_step", "esquiva" },
		so_de_frente = {},
		antecedencia = { charged_step = "martelo_carga_ms", esquiva = "esquiva_ms_martelo" },
		rotulo_tempo = { charged_step = "Charged Step: comeca a carregar (M5) quantos ms antes do golpe" },
		tempos_extras = { { opcao = "martelo_step_ms", nome = "Charged Step: M2 quantos ms antes do golpe", maximo = 500 } },
		confere_por_dano = true, -- sucesso = nao levou dano
		desligavel = {},
		eventos = {}
	},
/s or die "martelo";

# --- perfil da espada longa
$s =~ s/\t-- Espada Longa: por enquanto so a esquiva.*?\n\t\}\n\};/\t--[[
		ESPADA LONGA (0.29):
		  1. Foresight Slash (M5 + M2 juntos);
		  2. Special Sheathe (M5 + Espaco juntos) e depois Iai Spirit Slash (M5);
		  3. esquiva normal.
		Os dois primeiros so existem logo depois de um golpe da espada (no meio do combo).
		Se na hora voce nao estiver num combo, o mod esquiva no lugar.
	]]
	espada_longa = {
		nome = "Long Sword",
		classe = "app.cHunterWp03Handling",
		niveis = { "foresight", "iai", "esquiva" },
		so_de_frente = {},
		antecedencia = { foresight = "ls_foresight_ms", iai = "ls_sheathe_ms", esquiva = "esquiva_ms_espada_longa" },
		rotulo_tempo = {
			foresight = "Foresight Slash: M5 + M2 quantos ms antes do golpe",
			iai = "Special Sheathe: M5 + Espaco quantos ms antes do golpe"
		},
		tempos_extras = { { opcao = "ls_iai_ms", nome = "Iai Spirit Slash: M5 quantos ms antes do golpe", maximo = 500 } },
		confere_por_dano = true, -- sucesso = nao levou dano
		desligavel = {},
		eventos = {
			{ classe = "app.cHunterWp03Handling", funcao = "doSuccessMikiri", conta = "esquiva_perfeita" }
		}
	}
};/s or die "espada_longa";

# --- combo da espada longa e carga do martelo (antes dos ganchos de defesa)
troca(q|for _, d in ipairs(EVENTOS_DE_DEFESA) do|, q|--[[
	COMBO DA ESPADA LONGA (0.29): o Foresight Slash e o Special Sheathe so existem logo
	depois de um golpe da espada. O mod sabe que voce esta num combo quando:
	  - a sua espada acertou o monstro ha menos de 0,6s; ou
	  - voce esta numa animacao de ataque da espada. Estas animacoes sao aprendidas
	    sozinhas: toda vez que a espada acerta, a animacao daquele momento e anotada.
]]
local combo = { ultimo_acerto = -100, animacao = nil };

local tipo_espada_longa = sdk.find_type_definition("app.cHunterWp03Handling");
local acerto_espada_longa = tipo_espada_longa and tipo_espada_longa:get_method("doOnHit_AttackPre");
if acerto_espada_longa ~= nil then
	pcall(sdk.hook, acerto_espada_longa, function(args)
		pcall(function()
			local cacador = meu_cacador();
			local minha_arma = cacador and cacador:call("get_WeaponHandling");
			if minha_arma == nil then return; end
			if sdk.to_int64(args[2]) ~= minha_arma:get_address() then return; end -- espada de outro jogador
			combo.ultimo_acerto = os.clock();
			if combo.animacao ~= nil and not op.animacoes_ataque_ls[combo.animacao] then
				op.animacoes_ataque_ls[combo.animacao] = true;
				salvar_opcoes();
			end
		end);
	end, function(retorno) return retorno; end);
end

local function em_combo_espada_longa()
	if os.clock() - combo.ultimo_acerto < 0.6 then return true; end
	return combo.animacao ~= nil and op.animacoes_ataque_ls[combo.animacao] == true;
end

-- o martelo esta carregando? (se nao der para ler, tenta o Charged Step mesmo assim)
local function martelo_carregando()
	local ok, sim = pcall(function()
		local arma = meu_cacador():call("get_WeaponHandling");
		local carga = tonumber(arma:get_field("_ChargeTimer")) or 0;
		local inicio = tonumber(arma:get_field("_StartChargeFrameTimer")) or 0;
		local nivel = tonumber(arma:call("get_ChargeLv")) or 0;
		return carga > 0 or inicio > 0 or nivel > 0;
	end);
	if not ok then return true; end
	return sim;
end

for _, d in ipairs(EVENTOS_DE_DEFESA) do|, "combo");

# --- executores
troca(q|PERFIS.martelo.executar = {};
PERFIS.espada_longa.executar = {};|, q|--[[
	MARTELO - Charged Step: M5 segurado desde "martelo_carga_ms" antes do golpe (carrega) e,
	"martelo_step_ms" antes do golpe, um toque no M2. Se na hora do M2 o martelo nao estiver
	carregando (voce estava no meio de outro golpe), devolve "indisponivel": o mod esquiva.
]]
PERFIS.martelo.executar = {
	charged_step = function(desde, p)
		marcar("guarda");
		local hora_step = (op.martelo_carga_ms - op.martelo_step_ms) / 1000;
		if desde >= hora_step and desde < hora_step + 0.1 then
			if not p.teste and not p.estado_pg.conferiu then
				p.estado_pg.conferiu = true;
				if not martelo_carregando() then return "indisponivel"; end
			end
			marcar("especial");
		end
	end
};

--[[
	ESPADA LONGA
	  Foresight Slash: M5 + M2 juntos, um toque.
	  Special Sheathe + Iai: M5 + Espaco juntos (toque gravado do Espaco por cima do M5) e,
	  "ls_iai_ms" antes do golpe, um toque no M5 (Iai Spirit Slash).
	Fora de um combo os dois devolvem "indisponivel" e o mod esquiva no lugar.
]]
PERFIS.espada_longa.executar = {
	foresight = function(desde, p)
		if not p.teste and not p.estado_pg.conferiu then
			p.estado_pg.conferiu = true;
			if not em_combo_espada_longa() then return "indisponivel"; end
		end
		if desde < 0.1 then marcar("guarda"); marcar("especial"); end
	end,
	iai = function(desde, p)
		if not p.teste and not p.estado_pg.conferiu then
			p.estado_pg.conferiu = true;
			if not em_combo_espada_longa() then return "indisponivel"; end
		end
		if desde < 0.1 then
			marcar("guarda");
			if not p.estado_pg.tocou then p.estado_pg.tocou = true; comecar_toque(false); end
		end
		local hora_iai = (op.ls_sheathe_ms - op.ls_iai_ms) / 1000;
		if desde >= hora_iai and desde < hora_iai + 0.1 then marcar("guarda"); end
	end
};|, "executores");

# --- execucao com reserva (esquiva) quando a defesa nao da para usar
troca(q|			elseif defesa == "esquiva" then
				-- um toque no tempo certo
				if falta <= antes.esquiva and falta >= antes.esquiva - 0.1 then vai_esquivar = true; end
			elseif executar and falta <= (antes[defesa] or 0) and falta >= -depois then
				executar((antes[defesa] or 0) - falta, p);
			end|, q|			elseif defesa == "esquiva" then
				-- um toque no tempo certo
				if not p.esquiva_feita and falta <= antes.esquiva and falta >= antes.esquiva - 0.1 then vai_esquivar = true; end
			elseif executar and falta <= (antes[defesa] or 0) and falta >= -depois then
				if executar((antes[defesa] or 0) - falta, p) == "indisponivel" then
					-- (0.29) esta defesa nao existe agora (ex.: espada longa fora do combo, martelo
					-- sem carga): esquiva no lugar, so neste golpe (nao muda o aprendizado)
					p.defesa, p.sem_combo = "esquiva", true;
					estado.ultima_decisao = NOME_NIVEL[defesa] .. " indisponivel agora -> esquiva";
					if falta < (antes.esquiva or 0.15) - 0.1 then vai_esquivar = true; p.esquiva_feita = true; end
				end
			end|, "execucao");

# --- conferencia: esquiva de reserva nao muda o aprendizado
troca(q|				perfil = casado.perfil, nivel = casado.nivel, defesa = casado.defesa, em = os.clock()|,
q|				perfil = casado.perfil, nivel = casado.nivel, defesa = casado.defesa, em = os.clock(),
				sem_combo = casado.sem_combo|, "registro");

troca(q|		else
			local perfil_v = PERFIS[v.perfil] or PERFIS.lanca;
			local proximo = math.min|, q|		elseif v.sem_combo then
			estado.ultimo_resultado = "FALHOU com a esquiva de reserva (" .. v.chave .. ") - aprendizado nao muda";
		else
			local perfil_v = PERFIS[v.perfil] or PERFIS.lanca;
			local proximo = math.min|, "conferir");

# --- animacao do cacador para o combo
troca(q|		local _, banco = animacao_de(objeto_cacador);
		if banco == 14|, q|		local id_cacador, banco = animacao_de(objeto_cacador);
		combo.animacao = tostring(banco) .. ":" .. tostring(id_cacador);
		if banco == 14|, "animacao");

# --- testes
troca(q|local NOME_DO_ALVO = { guarda = "GUARDA (M5)",|, q|local NOME_DO_ALVO = { foresight = "FORESIGHT SLASH (M5 + M2)", iai = "SPECIAL SHEATHE + IAI (M5 + Espaco, depois M5)", charged_step = "CHARGED STEP (M5 segurado, depois M2)", guarda = "GUARDA (M5)",|, "nome_alvo");

troca(q|		elseif entrada.alvo == "power_guard" then
			marcar_power_guard(desde, entrada.teste_estado);
		else|, q|		elseif entrada.alvo == "power_guard" then
			marcar_power_guard(desde, entrada.teste_estado);
		elseif entrada.alvo == "foresight" or entrada.alvo == "iai" or entrada.alvo == "charged_step" then
			-- (0.29) combos: roda a sequencia uma vez, como se o golpe viesse logo depois
			local perfil_teste = (entrada.alvo == "charged_step") and PERFIS.martelo or PERFIS.espada_longa;
			local duracao = (op[perfil_teste.antecedencia[entrada.alvo]] or 0) / 1000 + 0.3;
			if desde < duracao then
				perfil_teste.executar[entrada.alvo](desde, { teste = true, estado_pg = entrada.teste_estado });
			end
		else|, "teste");

troca(q|	forcar_de = 0,          -- o teste comeca aqui (4 segundos depois do clique)|, q|	forcar_de = 0,          -- o teste comeca aqui (8 segundos depois do clique)|, "coment_teste");

# --- menu: testar botoes
troca(q|			local alvos = { "guarda", "contra_ataque", "power_guard", "esquiva" };
			local nomes = { "Guarda (M5)", "Contra-ataque (M5 e depois M2)", "Power Guard (M5, M2 e Espaco)", "Esquiva (Espaco)" };|,
q|			local alvos = { "guarda", "contra_ataque", "power_guard", "esquiva", "foresight", "iai", "charged_step" };
			local nomes = { "Guarda (M5)", "Contra-ataque (M5 e depois M2)", "Power Guard (M5, M2 e Espaco)", "Esquiva (Espaco)",
				"Foresight Slash (Long Sword)", "Special Sheathe + Iai (Long Sword)", "Charged Step (Hammer)" };
			local e_combo = entrada.alvo == "foresight" or entrada.alvo == "iai" or entrada.alvo == "charged_step";|, "menu_alvos");

troca(q|			if imgui.button("Testar: o mod aperta " .. NOME_DO_ALVO[entrada.alvo] .. " por 5 segundos (feche o menu)") then
				entrada.forcar_de = agora() + 4;|, q|			if e_combo then
				imgui.text("O teste comeca 8 segundos depois do clique: feche o menu e, na espada longa, de um golpe antes.");
			end
			if imgui.button("Testar: o mod aperta " .. NOME_DO_ALVO[entrada.alvo] .. " (comeca em 8 segundos)") then
				entrada.forcar_de = agora() + 8;|, "menu_teste");

troca(q|			imgui.text("Se o teste nao funcionar, com a arma SACADA e sem monstro perto:");|, q|			if not e_combo then
			imgui.text("Se o teste nao funcionar, com a arma SACADA e sem monstro perto:");|, "menu_cap1");
troca(q|				imgui.text("Nao achei diferenca entre as capturas. Repita o passo 2 segurando o botao o tempo todo.");
			end
|, q|				imgui.text("Nao achei diferenca entre as capturas. Repita o passo 2 segurando o botao o tempo todo.");
			end
			end -- not e_combo
|, "menu_cap2");

# --- menu: rotulos e tempos extras
troca(q|				local maximo = (acao == "power_guard") and 1000 or ((acao == "contra_ataque") and 800 or 500);
				alterado, op[opcao] = imgui.slider_int("Tempo: " .. NOME_ACAO[acao] .. " (ms antes do golpe)", op[opcao] or 150, 0, maximo);
				mudou_arma = mudou_arma or alterado;
			end
		end
|, q|				local maximo = (acao == "power_guard") and 1000 or ((acao == "contra_ataque") and 800 or 500);
				if acao == "iai" or acao == "charged_step" then maximo = 1500; end
				local rotulo = (perfil_menu.rotulo_tempo and perfil_menu.rotulo_tempo[acao]) or ("Tempo: " .. NOME_ACAO[acao] .. " (ms antes do golpe)");
				alterado, op[opcao] = imgui.slider_int(rotulo, op[opcao] or 150, 0, maximo);
				mudou_arma = mudou_arma or alterado;
			end
		end

		-- tempos que fazem parte de uma defesa (ex.: o Iai depois do Special Sheathe)
		for _, extra in ipairs(perfil_menu.tempos_extras or {}) do
			alterado, op[extra.opcao] = imgui.slider_int(extra.nome, op[extra.opcao] or 150, 0, extra.maximo or 500);
			mudou_arma = mudou_arma or alterado;
		end
|, "menu_tempos");

# --- prints: combo e carga
troca(q|	linha("== Defesa Automatica v0.29 ==");
|, q|	linha("== Defesa Automatica v0.29 ==");

	-- espada longa e martelo (0.29)
	local qtd_ataques = 0;
	for _ in pairs(op.animacoes_ataque_ls) do qtd_ataques = qtd_ataques + 1; end
	linha(string.format("Long Sword: em combo = %s - animacao %s - animacoes de ataque aprendidas: %d",
		tostring(em_combo_espada_longa()), tostring(combo.animacao), qtd_ataques));
	pcall(function()
		local arma = meu_cacador():call("get_WeaponHandling");
		if string.find(arma:get_type_definition():get_full_name(), "Wp04", 1, true) then
			linha(string.format("Hammer: carregando = %s - _ChargeTimer %s - _StartChargeFrameTimer %s - ChargeLv %s",
				tostring(martelo_carregando()), tostring(arma:get_field("_ChargeTimer")),
				tostring(arma:get_field("_StartChargeFrameTimer")), tostring(arma:call("get_ChargeLv"))));
		end
	end);
|, "prints");

print $s;
