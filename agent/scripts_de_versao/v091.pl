local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.90 - LIMPEZA:|, q|	Versao 0.91 - AS 14 ARMAS: Great Sword, Gunlance e Charge Blade (guarda > esquiva), Hammer (Charged
	Step > esquiva), Switch Axe (espada: Counter > esquiva; machado: so esquiva), Insect Glaive, Bow e
	Heavy Bowgun (esquiva). Guard Up agora e sempre considerado (a opcao saiu do menu e do codigo).
	0.90 - LIMPEZA:|, "cab");
$s =~ s/versao_mod = "0\.90"/versao_mod = "0.91"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.90 ==/== Defesa Automatica v0.91 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.90"\)/imgui.tree_node("Defesa Automatica v0.91")/ or die "tit";

# --- Guard Up sempre ---
my $i = index($s, "\t--[[\n\t\tGUARD UP (0.31):"); die "gu1" if $i < 0;
my $fim = "\ttenho_guard_up = true,\n"; my $j = index($s, $fim, $i); die "gu2" if $j < 0;
substr($s, $i, $j + length($fim) - $i) = "\t-- (0.91) Guard Up e SEMPRE considerado (voce sempre usa): golpes \"impossiveis\" de frente = guarda\n";
troca(q|	if op.tenho_guard_up and perfil.teto_com_guard_up and not monstro_imbloqueavel(nome_monstro) then|,
	q|	if perfil.teto_com_guard_up and not monstro_imbloqueavel(nome_monstro) then|, "gu_teto");
troca(q|		if op.tenho_guard_up and guarda ~= nil and not de_lado and not monstro_imbloqueavel(m.nome) then|,
	q|		if guarda ~= nil and not de_lado and not monstro_imbloqueavel(m.nome) then|, "gu_nivel");
troca(q|		if op.tenho_guard_up then return "SEGURE A GUARDA (Guard Up)", COR.power_guard; end
		if guarda == 2 then return "IMPOSSIVEL DE GUARDAR - ESQUIVE", COR.impossivel; end
		return "POWER GUARD", COR.power_guard;|, q|		-- (0.91) Guard Up sempre: arma de guarda segura a guarda; as outras esquivam
		if estado.perfil == nil or posicao_no_perfil(estado.perfil, "guarda") ~= nil then
			return "SEGURE A GUARDA (Guard Up)", COR.power_guard;
		end
		return "IMPOSSIVEL DE GUARDAR - ESQUIVE", COR.impossivel;|, "gu_aviso");
troca(q|jogadores_na_cacada(), op.tenho_guard_up and "sim" or "nao",|, q|jogadores_na_cacada(), "sempre",|, "gu_rel");
troca(q|	-- (0.90) Guard Up so aparece nas armas que guardam
	local p_menu = estado.perfil;
	if p_menu ~= nil and (p_menu.teto_com_guard_up or posicao_no_perfil(p_menu, "guarda") ~= nil) then
		mudou_simples, op.tenho_guard_up = imgui.checkbox("Tenho Guard Up (guardar golpes \"impossiveis\")", op.tenho_guard_up);
		alterou_simples = alterou_simples or mudou_simples;
	end
|, q||, "gu_menu");

# --- opcoes novas ---
troca(q|	esquiva_ms_espada_longa = 150,
|, q|	esquiva_ms_espada_longa = 150,
	-- (0.91) as outras armas
	esquiva_ms_grande = 150, esquiva_ms_martelo = 150, esquiva_ms_lanca_pistola = 150, esquiva_ms_machado = 150,
	esquiva_ms_lamina = 150, esquiva_ms_glaive = 150, esquiva_ms_arco = 150, esquiva_ms_bowgun_pesada = 150,
	martelo_carga_ms = 900, -- Hammer: comeca a carregar (M5 segurado) este tanto antes do golpe (sem o numero da acao)
	martelo_step_ms = 150,  -- Hammer: Charged Step este tanto antes do golpe
	sa_contra_ms = 150,     -- Switch Axe (espada): Counter este tanto antes do golpe
|, "op");

troca(q|	foresight = "Foresight Slash", ss_iss = "SS+ISS"
};|, q|	foresight = "Foresight Slash", ss_iss = "SS+ISS", charged_step = "Charged Step", contra_sa = "Counter (Switch Axe)"
};|, "nomes");

# --- perfis novos ---
troca(q|	espada_escudo = {
		nome = "Sword and Shield",|, q|	--[[
		(0.91) AS OUTRAS ARMAS. Guarda = M5 segurado (o mesmo botao da lanca e da Sword and Shield).
		Com Guard Up (sempre): de frente e guarda, ate nos golpes "impossiveis"; de lado / atras e nos
		ataques de arena inteira (Zoh Shia, Jin Dahaad, Omega): esquiva.
	]]
	grande = {
		nome = "Great Sword",
		classe = "app.cHunterWp00Handling",
		niveis = { "guarda", "esquiva" },
		so_de_frente = { guarda = true },
		forte = "esquiva",
		tempos_extras = {
			{ opcao = "ponte_guarda_ms", nome = "Golpes seguidos: manter a guarda se o proximo vier em ate (ms)", maximo = 2000 },
			{ opcao = "manter_apos_golpe_ms", nome = "Golpes seguidos: manter a guarda depois de cada golpe (ms)", maximo = 2000 }
		},
		teto_com_guard_up = 1,
		antecedencia = { guarda = "antecedencia_guarda_ms", esquiva = "esquiva_ms_grande" },
		confere_por_dano = true,
		desligavel = { esquiva = "esquivar" },
		eventos = {}
	},
	lanca_pistola = {
		nome = "Gunlance",
		classe = "app.cHunterWp07Handling",
		niveis = { "guarda", "esquiva" },
		so_de_frente = { guarda = true },
		forte = "esquiva",
		tempos_extras = {
			{ opcao = "ponte_guarda_ms", nome = "Golpes seguidos: manter a guarda se o proximo vier em ate (ms)", maximo = 2000 },
			{ opcao = "manter_apos_golpe_ms", nome = "Golpes seguidos: manter a guarda depois de cada golpe (ms)", maximo = 2000 }
		},
		teto_com_guard_up = 1,
		antecedencia = { guarda = "antecedencia_guarda_ms", esquiva = "esquiva_ms_lanca_pistola" },
		confere_por_dano = true,
		desligavel = { esquiva = "esquivar" },
		eventos = {}
	},
	lamina = {
		nome = "Charge Blade",
		classe = "app.cHunterWp09Handling",
		niveis = { "guarda", "esquiva" },
		so_de_frente = { guarda = true },
		forte = "esquiva",
		tempos_extras = {
			{ opcao = "ponte_guarda_ms", nome = "Golpes seguidos: manter a guarda se o proximo vier em ate (ms)", maximo = 2000 },
			{ opcao = "manter_apos_golpe_ms", nome = "Golpes seguidos: manter a guarda depois de cada golpe (ms)", maximo = 2000 }
		},
		teto_com_guard_up = 1,
		antecedencia = { guarda = "antecedencia_guarda_ms", esquiva = "esquiva_ms_lamina" },
		confere_por_dano = true,
		desligavel = { esquiva = "esquivar" },
		eventos = {}
	},
	-- Hammer: 1. Charged Step  2. esquiva (prioridade fixa)
	martelo = {
		nome = "Hammer",
		classe = "app.cHunterWp04Handling",
		niveis = { "charged_step", "esquiva" },
		so_de_frente = {},
		antecedencia = { charged_step = "martelo_carga_ms", esquiva = "esquiva_ms_martelo" },
		rotulo_tempo = { charged_step = "Charged Step: comeca a carregar (M5) quantos ms antes do golpe" },
		tempos_extras = { { opcao = "martelo_step_ms", nome = "Charged Step: quantos ms antes do golpe", maximo = 500 } },
		nivel_maximo_aprendido = 1,
		confere_por_dano = true,
		desligavel = {},
		eventos = {}
	},
	-- Switch Axe: espada = 1. Counter  2. esquiva; machado = so esquiva (prioridade fixa)
	machado = {
		nome = "Switch Axe",
		classe = "app.cHunterWp08Handling",
		niveis = { "contra_sa", "esquiva" },
		so_de_frente = { contra_sa = true },
		antecedencia = { contra_sa = "sa_contra_ms", esquiva = "esquiva_ms_machado" },
		rotulo_tempo = { contra_sa = "Counter (espada): quantos ms antes do golpe" },
		nivel_maximo_aprendido = 1,
		confere_por_dano = true,
		desligavel = {},
		eventos = {}
	},
	glaive = {
		nome = "Insect Glaive",
		classe = "app.cHunterWp10Handling",
		niveis = { "esquiva" },
		so_de_frente = {},
		antecedencia = { esquiva = "esquiva_ms_glaive" },
		confere_por_dano = true,
		desligavel = {},
		eventos = {}
	},
	arco = {
		nome = "Bow",
		classe = "app.cHunterWp11Handling",
		niveis = { "esquiva" },
		so_de_frente = {},
		antecedencia = { esquiva = "esquiva_ms_arco" },
		confere_por_dano = true,
		desligavel = {},
		eventos = {}
	},
	bowgun_pesada = {
		nome = "Heavy Bowgun",
		classe = "app.cHunterWp12Handling",
		niveis = { "esquiva" },
		so_de_frente = {},
		antecedencia = { esquiva = "esquiva_ms_bowgun_pesada" },
		confere_por_dano = true,
		desligavel = {},
		eventos = {}
	},

	espada_escudo = {
		nome = "Sword and Shield",|, "perfis");

# --- como cada arma nova executa ---
troca(q|PERFIS.berrante.executar = {};
|, q|PERFIS.berrante.executar = {};
-- (0.91) armas novas
PERFIS.grande.executar = { guarda = function(desde, p) marcar("guarda"); end };
PERFIS.lanca_pistola.executar = { guarda = function(desde, p) marcar("guarda"); end };
PERFIS.lamina.executar = { guarda = function(desde, p) marcar("guarda"); end };
PERFIS.glaive.executar = {};
PERFIS.arco.executar = {};
PERFIS.bowgun_pesada.executar = {};
--[[
	HAMMER - Charged Step. Com o numero da acao (aprendido do SEU Charged Step) ele e forcado
	"martelo_step_ms" antes do golpe. Sem o numero: M5 segurado (carrega) desde "martelo_carga_ms"
	e um toque no M2 na hora do step; sem carga na hora -> esquiva.
]]
PERFIS.martelo.executar = {
	charged_step = function(desde, p)
		p.estado_pg = p.estado_pg or {};
		local hora_step = (op.martelo_carga_ms - op.martelo_step_ms) / 1000;
		if n78.acao_de("passo") ~= nil then
			if p.estado_pg.forcou then return; end
			if not p.teste and desde >= hora_step + 0.1 then return "indisponivel", "sem tempo"; end
			if desde >= hora_step then
				p.estado_pg.forcou = true;
				n78.forcar("passo", "Charged Step");
			end
			return;
		end
		if not p.teste and desde >= hora_step + 0.1 then return "indisponivel", "sem tempo"; end
		marcar("guarda"); -- M5 segurado: carrega
		if desde >= hora_step and desde < hora_step + 0.1 then
			if not p.teste and not p.estado_pg.conferiu then
				p.estado_pg.conferiu = true;
				if not n78.martelo_carregando() then return "indisponivel", "sem carga"; end
			end
			marcar("especial"); -- M2 com a carga: Charged Step
		end
	end
};
--[[
	SWITCH AXE - Counter na forma espada (acoes do jogo 2,54 e 2,31, as mesmas dos mods testados).
	Na forma machado ou sem tempo: esquiva.
]]
PERFIS.machado.executar = {
	contra_sa = function(desde, p)
		p.estado_pg = p.estado_pg or {};
		if p.estado_pg.forcou then return; end
		if not p.teste and desde >= 0.1 then return "indisponivel", "sem tempo"; end
		if n78.modo_machado() ~= 1 then return "indisponivel", "forma machado"; end
		p.estado_pg.forcou = true;
		n78.acao_direta(2, 54, "SA postura");
		n78.acao_direta(2, 31, "SA Counter");
	end
};
|, "exec");

# --- n78: esquiva do Bow, carga do Hammer, forma da Switch Axe ---
troca(q|	if tipo == "esquiva" and not por.esquiva_padrao_ruim then return 1, 19, true; end
	return nil;
end;|, q|	if tipo == "esquiva" and not por.esquiva_padrao_ruim then
		if wt == 11 then return 2, 9, true; end -- (0.91) Bow (mods testados)
		return 1, 19, true;
	end
	return nil;
end;
-- (0.91) o Hammer esta carregando? (se nao der para ler, tenta mesmo assim)
n78.martelo_carregando = function()
	local ok, sim = pcall(function()
		local arma = meu_cacador():call("get_WeaponHandling");
		local carga = tonumber(arma:get_field("_ChargeTimer")) or 0;
		local inicio = tonumber(arma:get_field("_StartChargeFrameTimer")) or 0;
		local nivel = tonumber(arma:call("get_ChargeLv")) or 0;
		return carga > 0 or inicio > 0 or nivel > 0;
	end);
	if not ok then return true; end
	return sim;
end;
-- (0.91) forma da Switch Axe: 0 machado, 1 espada
n78.modo_machado = function()
	local modo = nil;
	pcall(function() modo = meu_cacador():call("get_WeaponHandling"):get_field("_Mode"); end);
	return tonumber(modo);
end;|, "n78");

# --- aprender o Charged Step pelo nome da acao ---
troca(q|			if string.sub(nome, 1, 6) == "cDodge" then tipo = "esquiva";|,
q|			if cacador:call("get_WeaponType") == 4 and string.find(nome, "Step", 1, true) ~= nil then tipo = "passo"; -- (0.91) Charged Step
			elseif string.sub(nome, 1, 6) == "cDodge" then tipo = "esquiva";|, "aprende");
troca(q|						op.acoes_aprendidas[tostring(fp.wt)].esquiva_padrao_ruim = true;
						salvar_opcoes();
					end|, q|						op.acoes_aprendidas[tostring(fp.wt)].esquiva_padrao_ruim = true;
						salvar_opcoes();
					-- (0.91) acao aprendida que nunca sai: volta para os botoes
					elseif fp.tipo == "passo" and r.ok == 0 and r.falha >= 3 and fp.wt ~= nil then
						local a = ((op.acoes_aprendidas or {})[tostring(fp.wt)] or {})[fp.tipo];
						if a ~= nil then a.ruim = true; salvar_opcoes(); end
					end|, "ruim");

print $s;
