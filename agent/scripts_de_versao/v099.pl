local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.98 - |, q|	Versao 0.99 - LUTA COM AS 14 ARMAS (Chatacabra): Long Sword espera o SS+ISS acabar antes de qualquer
	outra defesa; guarda, contra-ataque e Power Guard (Lance, Gunlance, Sword and Shield, Great Sword,
	Charge Blade espada) sao forcados por cima de qualquer animacao; sem guarda segurada entre golpes na
	Sword and Shield, Charge Blade e Great Sword (travava os seus ataques); Lance faz mais contra-ataques;
	Light Bowgun e Bow: rolamento sem tiro, deslize depois de tiro (Light Bowgun ate 2 deslizes).
	0.98 - |, "cab");
$s =~ s/versao_mod = "0\.98"/versao_mod = "0.99"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.98 ==/== Defesa Automatica v0.99 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.98"\)/imgui.tree_node("Defesa Automatica v0.99")/ or die "tit";

# --- acao atual / anterior, tiros e deslizes ---
troca(q|			if estado.acao_vista_antes ~= chave_v then
				estado.acao_vista_antes = chave_v;|, q|			if estado.acao_vista_antes ~= chave_v then
				estado.acao_vista_antes = chave_v;
				-- (0.99) acao atual (nome), tiros do Bow e deslizes da Light Bowgun
				estado.acao_nome_ultimo = nome;
				if wt_v == "11" and (string.find(nome, "Shot", 1, true) or string.sub(nome, 1, 11) == "cChargeStep") then
					estado.tiro_em = os.clock();
				end
				if wt_v == "13" and (string.find(nome, "StepDodge", 1, true) or string.find(nome, "SlideDodge", 1, true)) then
					estado.deslizes = (estado.deslizes or 0) + 1;
				end|, "atual");

# --- confere / padrao ruim ---
troca(q|				or (fp.tipo == "esquiva" and (nome == "cKijinDodge" or nome == "cAxeDodge")));|,
q|				or (fp.tipo == "guarda" and cat == 1 and idx >= 141 and idx <= 148) -- (0.99)
				or (fp.tipo == "power_guard" and string.sub(nome, 1, 11) == "cSuperGuard")
				or (fp.tipo == "esquiva" and (nome == "cKijinDodge" or nome == "cAxeDodge"
					or string.find(nome, "StepDodge", 1, true) ~= nil or string.find(nome, "SlideDodge", 1, true) ~= nil
					or string.sub(nome, 1, 11) == "cChargeStep")));|, "confere");
troca(q|(fp.tipo == "esquiva" or fp.tipo == "bloqueio" or fp.tipo == "contra_sa" or fp.tipo == "passo")|,
	q|(fp.tipo == "esquiva" or fp.tipo == "bloqueio" or fp.tipo == "contra_sa" or fp.tipo == "passo" or fp.tipo == "guarda" or fp.tipo == "power_guard")|, "ruim");

# --- numeros padrao ---
troca(q|	if tipo == "esquiva" and wt == 9 and estado.cb_machado then return 2, 20, true; end|,
q|	if tipo == "esquiva" and wt == 9 and estado.cb_machado then return 2, 20, true; end
	-- (0.99) Bow e Light Bowgun: sem tiro = rolamento (cDodge); depois de tiro = deslize
	-- (Bow: cChargeStep, sem limite; Light Bowgun: cShootStepDodge, ate 2 seguidos)
	if tipo == "esquiva" and (wt == 11 or wt == 13) then
		local atual = estado.acao_nome_ultimo or "";
		local recente = os.clock() - (estado.tiro_em or -100) < 1.5;
		if wt == 11 and (recente or string.find(atual, "Shot", 1, true) or string.sub(atual, 1, 11) == "cChargeStep") then
			estado.lado_deslize = not estado.lado_deslize;
			return 2, estado.lado_deslize and 12 or 11, true;
		end
		if wt == 13 and recente and (estado.deslizes or 0) < 2 then
			estado.lado_deslize = not estado.lado_deslize;
			return 2, estado.lado_deslize and 23 or 24, true;
		end
		return 1, 19, true;
	end
	-- (0.99) guarda forcada (cGuard) e Power Guard da Lance (cSuperGuardStart), vistos nos seus testes
	if tipo == "guarda" and (wt == 0 or wt == 1 or wt == 6 or wt == 7 or (wt == 9 and not estado.cb_machado))
		and not por.guarda_padrao_ruim then return 1, 141, true; end
	if tipo == "power_guard" and wt == 6 and not por.power_guard_padrao_ruim then return 2, 77, true; end|, "acao_de");

# --- forcar uma vez por golpe + tiro da Light Bowgun ---
troca(q|n78.nivel_aura = function()|, q|-- (0.99) forca a defesa uma vez por golpe (ou sequencia), por cima de qualquer animacao
n78.forcar_uma_vez = function(p, tipo, nome)
	p.estado_pg = p.estado_pg or {};
	if p.estado_pg["forcou_" .. tipo] then return false; end
	p.estado_pg["forcou_" .. tipo] = true;
	if p.teste then return false; end
	local atual = estado.acao_nome_ultimo or "";
	if tipo == "guarda" and string.find(atual, "Guard", 1, true) ~= nil and atual ~= "cGuardEnd" then return false; end
	if tipo == "power_guard" and string.sub(atual, 1, 11) == "cSuperGuard" then return false; end
	return n78.forcar(tipo, nome);
end;
-- (0.99) Long Sword: o SS+ISS ainda esta na tela (ISS / fim da postura)
n78.ls_em_iai = function()
	local atual = estado.acao_nome_ultimo or "";
	return string.sub(atual, 1, 4) == "cIai" and atual ~= "cIaiWpOff";
end;
-- (0.99) Light Bowgun: hora do ultimo tiro seu (o deslize so existe depois de um tiro)
for _, nome_metodo in ipairs({ "shootShell", "subAmmo" }) do
	pcall(function()
		local metodo = sdk.find_type_definition("app.cHunterWp13Handling"):get_method(nome_metodo);
		if metodo == nil then return; end
		sdk.hook(metodo, function(args)
			pcall(function()
				local eu = meu_cacador():call("get_WeaponHandling");
				if eu ~= nil and sdk.to_int64(args[2]) == eu:get_address() then
					if os.clock() - (estado.tiro_em or -100) > 0.05 then estado.deslizes = 0; end
					estado.tiro_em = os.clock();
				end
			end);
		end, nil);
	end);
end
n78.nivel_aura = function()|, "uma_vez");

# --- executores ---
troca(q|PERFIS.espada_escudo.executar = {
	guarda = function(desde, p) marcar("guarda"); end
};|, q|-- (0.99) guarda: cGuard forcado por cima de qualquer animacao + M5 segurado ate o golpe passar
n78.guarda_forcada = function(desde, p)
	n78.forcar_uma_vez(p, "guarda", "guarda");
	marcar("guarda");
end;
PERFIS.espada_escudo.executar = { guarda = n78.guarda_forcada };|, "sns");
troca(q|PERFIS.grande.executar = { guarda = function(desde, p) marcar("guarda"); end };
PERFIS.lanca_pistola.executar = { guarda = function(desde, p) marcar("guarda"); end };|,
q|PERFIS.grande.executar = { guarda = n78.guarda_forcada };
PERFIS.lanca_pistola.executar = { guarda = n78.guarda_forcada };|, "gs_gl");
troca(q|	if estado.cb_machado then return "indisponivel", "forma machado"; end
	marcar("guarda");
end };|, q|	if estado.cb_machado then return "indisponivel", "forma machado"; end
	n78.guarda_forcada(desde, p);
end };|, "cb");
troca(q|PERFIS.lanca.executar = {
	contra_ataque = function(desde, p) marcar_contra_ataque(desde); end,
	guarda = function(desde, p) marcar("guarda"); end,
	power_guard = function(desde, p) marcar_power_guard(desde, p.estado_pg); end|,
q|-- (0.99) Lance: guarda / Power Guard forcados por cima de qualquer animacao; o contra-ataque sai da
-- guarda forcada com o toque do M2
PERFIS.lanca.executar = {
	contra_ataque = function(desde, p) n78.forcar_uma_vez(p, "guarda", "guarda (contra)"); marcar_contra_ataque(desde); end,
	guarda = n78.guarda_forcada,
	power_guard = function(desde, p)
		n78.forcar_uma_vez(p, "power_guard", "Power Guard");
		if string.sub(estado.acao_nome_ultimo or "", 1, 11) == "cSuperGuard" then
			marcar("guarda"); marcar("especial"); marcar("espaco"); -- ja no Power Guard: os tres segurados
			return;
		end
		marcar_power_guard(desde, p.estado_pg);
	end|, "lanca");

# --- ponte de guarda: nao na Sword and Shield, Charge Blade e Great Sword ---
troca(q|		and not (perfil == PERFIS.lamina and estado.cb_machado) -- (0.98)
		and momento|, q|		and not (perfil == PERFIS.lamina and estado.cb_machado) -- (0.98)
		and perfil ~= PERFIS.espada_escudo and perfil ~= PERFIS.lamina and perfil ~= PERFIS.grande -- (0.99) travava os ataques
		and momento|, "ponte");

# --- Lance: contra-ataque so vira guarda se o proximo golpe vier muito perto ---
troca(q|					if p.defesa == "contra_ataque" then
						local ponte = op.ponte_guarda_ms / 1000;|, q|					if p.defesa == "contra_ataque" then
						local ponte = math.min(op.ponte_guarda_ms / 1000, 0.4); -- (0.99) mais contra-ataques|, "contra");

# --- Long Sword: espera o SS+ISS acabar ---
troca(q|			if not op.usar_ss_iss or #m5 == 0 or #espaco == 0 then return false; end
			local p, m = golpe_mais_proximo(momento);|, q|			-- (0.99) o SS+ISS anterior ainda esta na tela: nada novo por cima (espera a animacao acabar)
			if n78.ls_em_iai() then
				estado.ultima_decisao = "SS+ISS ainda na tela: esperando acabar";
				return true;
			end
			if not op.usar_ss_iss or #m5 == 0 or #espaco == 0 then return false; end
			local p, m = golpe_mais_proximo(momento);|, "ls");

print $s;
