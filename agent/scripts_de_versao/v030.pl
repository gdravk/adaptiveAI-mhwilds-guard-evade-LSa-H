local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

# --- versao
$s =~ s/Versao 0\.29 - Long Sword/Versao 0.30 - revisao da Long Sword e do Hammer; 0.29 - Long Sword/ or die "cab";
$s =~ s/versao_mod = "0\.29"/versao_mod = "0.30"/ or die "vm";
$s =~ s/== Defesa Automatica v0\.29 ==/== Defesa Automatica v0.30 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.29"\)/imgui.tree_node("Defesa Automatica v0.30")/ or die "tit";

# --- perfis: prioridade fixa (o aprendizado nao desce ate a esquiva) e reserva sem tempo
troca(q|		tempos_extras = { { opcao = "martelo_step_ms", nome = "Charged Step: M2 quantos ms antes do golpe", maximo = 500 } },|,
q|		tempos_extras = { { opcao = "martelo_step_ms", nome = "Charged Step: M2 quantos ms antes do golpe", maximo = 500 } },
		-- (0.30) prioridade fixa: sempre o Charged Step. A esquiva so entra quando o Charged
		-- Step nao da para usar naquele golpe (martelo sem carga ou sem tempo)
		nivel_maximo_aprendido = 1,|, "martelo");

troca(q|		tempos_extras = { { opcao = "ls_iai_ms", nome = "Iai Spirit Slash: M5 quantos ms antes do golpe", maximo = 500 } },|,
q|		tempos_extras = { { opcao = "ls_iai_ms", nome = "Iai Spirit Slash: M5 quantos ms antes do golpe", maximo = 500 } },
		-- (0.30) prioridade fixa 1, 2, 3: se o Foresight falhar num golpe, da proxima vez vai o
		-- Special Sheathe + Iai. O aprendizado NUNCA desce para a esquiva normal: ela so entra
		-- quando voce nao esta num combo (nenhum golpe dado).
		nivel_maximo_aprendido = 2,
		-- sem tempo para o Special Sheathe (golpe previsto em cima da hora): tenta o Foresight
		reserva = { iai = "foresight" },|, "espada_longa");

# --- executores (revisados)
$s =~ s/PERFIS\.martelo\.executar = \{.*?hora_iai \+ 0\.1 then marcar\("guarda"\); end\n\tend\n\};/PERFIS.martelo.executar = {
	charged_step = function(desde, p)
		local hora_step = (op.martelo_carga_ms - op.martelo_step_ms) \/ 1000;
		-- (0.30) golpe previsto tarde demais: ja passou a hora do M2
		if not p.teste and desde >= hora_step + 0.1 then return "indisponivel"; end
		marcar("guarda"); -- M5 segurado: carrega
		if desde >= hora_step and desde < hora_step + 0.1 then
			if not p.teste and not p.estado_pg.conferiu then
				p.estado_pg.conferiu = true;
				if not martelo_carregando() then return "indisponivel"; end
			end
			marcar("especial"); -- M2 com a carga: Charged Step
		end
	end
};

--[[
	ESPADA LONGA (revisado na 0.30)
	  Foresight Slash: M5 + M2 juntos, um toque.
	  Special Sheathe + Iai: M5 + Espaco juntos (toque gravado do Espaco por cima do M5) e,
	  "ls_iai_ms" antes do golpe, um toque no M5 (Iai Spirit Slash).
	Devolvem "indisponivel" quando:
	  - voce nao esta num combo (os dois so aparecem depois de um golpe da espada);
	  - o golpe foi previsto tarde demais para comecar a tempo.
]]
PERFIS.espada_longa.executar = {
	foresight = function(desde, p)
		if not p.teste and not p.estado_pg.conferiu then
			p.estado_pg.conferiu = true;
			if desde >= 0.1 then return "indisponivel"; end
			if not em_combo_espada_longa() then return "indisponivel"; end
		end
		if desde < 0.1 then marcar("guarda"); marcar("especial"); end
	end,
	iai = function(desde, p)
		if not p.teste and not p.estado_pg.conferiu then
			p.estado_pg.conferiu = true;
			if desde >= 0.1 then return "indisponivel"; end
			if not em_combo_espada_longa() then return "indisponivel"; end
		end
		-- 1. Special Sheathe: M5 + Espaco juntos
		if desde < 0.1 then
			marcar("guarda");
			if not p.estado_pg.tocou then
				p.estado_pg.tocou = true;
				if not comecar_toque(false) then p.estado_pg.sem_toque = true; end
			end
			if p.estado_pg.sem_toque then marcar("esquiva"); end -- sem toque gravado: Espaco direto
		end
		-- 2. Iai Spirit Slash: um toque no M5
		local hora_iai = (op.ls_sheathe_ms - op.ls_iai_ms) \/ 1000;
		if desde >= hora_iai and desde < hora_iai + 0.1 then marcar("guarda"); end
	end
};/s or die "executores";

# --- reserva generica
troca(q|					p.defesa, p.sem_combo = "esquiva", true;
					estado.ultima_decisao = NOME_NIVEL[defesa] .. " indisponivel agora -> esquiva";
					if falta < (antes.esquiva or 0.15) - 0.1 then vai_esquivar = true; p.esquiva_feita = true; end|,
q|					local reserva = (perfil.reserva and perfil.reserva[defesa]) or "esquiva";
					p.defesa, p.sem_combo, p.estado_pg = reserva, true, {};
					estado.ultima_decisao = NOME_NIVEL[defesa] .. " indisponivel agora -> " .. NOME_NIVEL[reserva];
					if reserva == "esquiva" and falta < (antes.esquiva or 0.15) - 0.1 then vai_esquivar = true; p.esquiva_feita = true; end|, "reserva");

# --- janela de decisao cobre a defesa que comeca mais cedo (ex.: Special Sheathe 900 ms)
troca(q|	local depois = op.segurar_depois_ms / 1000;|, q|	local depois = op.segurar_depois_ms / 1000;

	-- (0.30) a defesa e escolhida antes da que comeca mais cedo (antes era fixo em 1 segundo:
	-- um Special Sheathe ajustado acima de 1000 ms nunca seria apertado)
	local janela_decisao = 1.0;
	for _, t in pairs(antes) do
		if t + 0.15 > janela_decisao then janela_decisao = t + 0.15; end
	end|, "janela1");
troca(q|			if p.nivel == nil and falta <= 1.0 and not longe then|, q|			if p.nivel == nil and falta <= janela_decisao and not longe then|, "janela2");

# --- aprendizado com teto por arma
troca(q|	local aprendido = defesas_aprendidas[chave_do_golpe(chave_perfil, m, p)] or 1;|,
q|	local aprendido = defesas_aprendidas[chave_do_golpe(chave_perfil, m, p)] or 1;
	if perfil.nivel_maximo_aprendido and aprendido > perfil.nivel_maximo_aprendido then
		aprendido = perfil.nivel_maximo_aprendido;
	end|, "teto1");
troca(q|			local proximo = math.min((v.nivel or 1) + 1, #perfil_v.niveis);|,
q|			local proximo = math.min((v.nivel or 1) + 1, perfil_v.nivel_maximo_aprendido or #perfil_v.niveis);|, "teto2");

# --- diagnostico: esquecer animacoes de ataque
troca(q|		pcall(desenhar_aba_prints);
|, q|		pcall(desenhar_aba_prints);

		if imgui.button("Esquecer as animacoes de ataque da Long Sword") then
			op.animacoes_ataque_ls = {};
			salvar_opcoes();
		end
|, "esquecer");

print $s;
