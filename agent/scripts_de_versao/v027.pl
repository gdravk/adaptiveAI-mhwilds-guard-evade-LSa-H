local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

# 1. tempo da esquiva por arma (opcoes)
troca(q{	antecedencia_esquiva_ms = 150,}, q{	antecedencia_esquiva_ms = 150,   -- esquiva da lanca

	-- esquiva das outras armas (cada arma tem invencibilidade diferente; ajuste no Avancado)
	esquiva_ms_dual = 150,
	esquiva_ms_bowgun_leve = 150,
	esquiva_ms_berrante = 150,
	esquiva_ms_espada_escudo = 150,
	esquiva_ms_martelo = 150,
	esquiva_ms_espada_longa = 150,}, "op");

troca(q{	defesas = { perfeita = 0, normal = 0, power = 0 }, -- contadas pelos eventos da lanca}, q{	defesas = { perfeita = 0, normal = 0, power = 0, esquiva_perfeita = 0 }, -- contadas pelos eventos do jogo}, "defesas");

# 2. perfis das armas novas (logo depois do perfil da lanca)
troca(q{			{ classe = "app.cHunterWeaponHandlingBase", funcao = "onParrySuccess", conta = "contra" }
		}
	}
};}, q{			{ classe = "app.cHunterWeaponHandlingBase", funcao = "onParrySuccess", conta = "contra" }
		}
	},

	--[[
		ARMAS SO COM ESQUIVA (versao 0.27). A esquiva usa o toque gravado do Espaco, que e
		o mesmo para todas as armas. Muda so o tempo ideal (invencibilidade de cada arma).
		Armas sem evento proprio de sucesso: o mod considera que a defesa FALHOU quando o
		cacador entra numa animacao de levar dano (banco 14) logo depois do impacto.
	]]
	dual = {
		nome = "Dual Blades",
		classe = "app.cHunterWp02Handling",
		niveis = { "esquiva" },
		so_de_frente = {},
		antecedencia = { esquiva = "esquiva_ms_dual" },
		desligavel = {},
		-- esquiva perfeita das Dual Blades ("Mikiri")
		eventos = {
			{ classe = "app.cHunterWp02Handling", funcao = "doMikiriSuccess", conta = "esquiva_perfeita" }
		}
	},

	bowgun_leve = {
		nome = "Light Bowgun",
		classe = "app.cHunterWp13Handling",
		niveis = { "esquiva" },
		so_de_frente = {},
		antecedencia = { esquiva = "esquiva_ms_bowgun_leve" },
		desligavel = {},
		eventos = {}
	},

	berrante = {
		nome = "Hunting Horn",
		classe = "app.cHunterWp05Handling",
		niveis = { "esquiva" },
		so_de_frente = {},
		antecedencia = { esquiva = "esquiva_ms_berrante" },
		desligavel = {},
		eventos = {}
	},

	-- Espada e Escudo: guarda (so de frente) e esquiva. A guarda usa os mesmos comandos da
	-- guarda da lanca (M5); se nao funcionar, e so ensinar a guarda com a espada sacada.
	espada_escudo = {
		nome = "Sword and Shield",
		classe = "app.cHunterWp01Handling",
		niveis = { "guarda", "esquiva" },
		so_de_frente = { guarda = true },
		forte = "esquiva",
		antecedencia = { guarda = "antecedencia_guarda_ms", esquiva = "esquiva_ms_espada_escudo" },
		desligavel = { esquiva = "esquivar" },
		eventos = {}
	},

	-- Martelo: por enquanto so a esquiva (o Charged Step vem na proxima etapa)
	martelo = {
		nome = "Hammer",
		classe = "app.cHunterWp04Handling",
		niveis = { "esquiva" },
		so_de_frente = {},
		antecedencia = { esquiva = "esquiva_ms_martelo" },
		desligavel = {},
		eventos = {}
	},

	-- Espada Longa: por enquanto so a esquiva (Foresight Slash e Iai vem na proxima etapa).
	-- O evento do Foresight Slash ja e contado, para quando ele for usado.
	espada_longa = {
		nome = "Long Sword",
		classe = "app.cHunterWp03Handling",
		niveis = { "esquiva" },
		so_de_frente = {},
		antecedencia = { esquiva = "esquiva_ms_espada_longa" },
		desligavel = {},
		eventos = {
			{ classe = "app.cHunterWp03Handling", funcao = "doSuccessMikiri", conta = "esquiva_perfeita" }
		}
	}
};}, "perfis");

# 3. executores das armas novas (guarda da espada e escudo)
troca(q{PERFIS.lanca.executar = {}, q{PERFIS.espada_escudo.executar = {
	guarda = function(desde, p) marcar("guarda"); end
};
PERFIS.dual.executar = {};
PERFIS.bowgun_leve.executar = {};
PERFIS.berrante.executar = {};
PERFIS.martelo.executar = {};
PERFIS.espada_longa.executar = {};

PERFIS.lanca.executar = {}, "executores");

# 4. conferencia: armas sem evento usam a animacao de dano
troca(q{		elseif (estado.ultimo_sucesso_defesa or -100) >= v.em - 0.05 then}, q{		elseif (function()
			-- deu certo? Com evento: o jogo confirmou a defesa. Sem evento (armas so com esquiva
			-- e a espada e escudo): deu certo se o cacador NAO entrou em animacao de dano.
			local perfil_v = PERFIS[v.perfil or "lanca"];
			if perfil_v ~= nil and #perfil_v.eventos == 0 then
				return (estado.levou_dano_em or -100) < v.em - 0.05;
			end
			return (estado.ultimo_sucesso_defesa or -100) >= v.em - 0.05;
		end)() then}, "conferir");

# 5. animacao de dano do cacador (banco 14), lida a cada quadro
troca(q{	-- so anota qual arma voce esta usando (para o menu). Nenhum gancho e ligado aqui.}, q{	-- quando o cacador entra numa animacao de levar dano (banco 14), anota o momento
	-- (usado para saber se a defesa falhou nas armas sem evento de sucesso)
	if objeto_cacador ~= nil then
		local _, banco = animacao_de(objeto_cacador);
		if banco == 14 and estado.banco_cacador ~= 14 then estado.levou_dano_em = os.clock(); end
		estado.banco_cacador = banco;
	end

	-- so anota qual arma voce esta usando (para o menu). Nenhum gancho e ligado aqui.}, "dano");

# 6. tira os botoes de pesquisa que nao sao mais necessarios
troca(q{		-- pode demorar alguns segundos (percorre todas as classes do jogo)
		if imgui.button("Exportar controles do jogo (para o modo automatico)") then
			local ok, erro = pcall(exportar_controles);
			if not ok then estado.mensagem = "Erro: " .. tostring(erro); end
		end

		if not pesquisa.gravando then
			if imgui.button("Comecar gravacao") then comecar_gravacao(); end
		elseif imgui.button("Parar e salvar gravacao") then
			local ok, erro = pcall(parar_gravacao);
			if not ok then estado.mensagem = "Erro: " .. tostring(erro); end
		end
}, q{		-- (0.27: "Exportar controles" e "Comecar gravacao" sairam do menu - nao sao mais necessarios)
}, "pesquisa");

# 7. tempo da esquiva da arma atual no menu
troca(q{		alterado, op.antecedencia_esquiva_ms = imgui.slider_int("Esquivar quantos ms antes do impacto", op.antecedencia_esquiva_ms, 0, 500);}, q{		-- tempo da esquiva da arma que voce esta usando agora (cada arma tem o seu)
		local perfil_menu = estado.perfil;
		local opcao_esquiva = perfil_menu and perfil_menu.antecedencia.esquiva or "antecedencia_esquiva_ms";
		local nome_arma_menu = perfil_menu and perfil_menu.nome or "Lanca";
		alterado, op[opcao_esquiva] = imgui.slider_int("Esquiva (" .. nome_arma_menu .. "): quantos ms antes do impacto", op[opcao_esquiva] or 150, 0, 500);}, "menu_esquiva");

print $s;
