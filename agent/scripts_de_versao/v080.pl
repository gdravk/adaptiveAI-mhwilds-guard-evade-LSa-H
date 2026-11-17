local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.79 - |, q|	Versao 0.80 - MOD LEGIT: o mod so LE o jogo e aperta botoes reais, nada do jogo e modificado.
	Saiu a "defesa na hora do golpe" da 0.78/0.79 (ela anulava o golpe e dava invencibilidade).
	Long Sword: o FS so e escolhido se ele vai sair de verdade (o golpe seu chegou no quadro em que
	o FS e aceito e tem barra de espirito); o ISS so e apertado quando o jogo ja aceita (postura, ou
	a partir do quadro 75 da entrada do SS); o tempo maximo da postura e as janelas de contra-ataque
	do FS / ISS sao lidos do proprio jogo; contato de golpe sem dano (rugido etc.) nao ensina
	0.79 - |, "cab");
$s =~ s/versao_mod = "0\.79"/versao_mod = "0.80"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.79 ==/== Defesa Automatica v0.80 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.79"\)/imgui.tree_node("Defesa Automatica v0.80")/ or die "tit";

# ------------------------------------------------ 1. tira a defesa na hora do golpe (modificava o jogo)
troca(q|	defesa_na_hora_ligada = true,
	na_hora_so_sacada = true,
	na_hora = { gs = true, sns = true, db = true, sa = true, cb = true, arco = true, hbg = true, lbg = true },
|, q||, "op");
$s =~ s/\n--\[\[\n\tE\. OUTRAS ARMAS: DEFESA NA HORA DO GOLPE.*?\n(n78\.processar_ativacoes = processar_ativacoes;)/\n$1/s or die "bloco_E";
troca(q|n78.ARMAS = ARMAS_NA_HORA;
n78.ORDEM = ORDEM_ARMAS_NA_HORA;
|, q||, "exporta");
troca(q|	if perfil == nil then
		-- (0.79) armas so com a defesa na hora do golpe
		local ok_t, tipo = pcall(function() return cacador:call("get_WeaponType"); end);
		local def = ok_t and n78.ARMAS and n78.ARMAS[tonumber(tipo) or -1] or nil;
		if def ~= nil then return false, "so defesa na hora do golpe (" .. def.nome .. ")"; end
		return false, "arma sem perfil ainda (" .. tostring(classe) .. ")";
	end|, q|	if perfil == nil then return false, "arma sem perfil ainda (" .. tostring(classe) .. ")"; end|, "perfil");
$s =~ s/\tlocal nh_txt = \{\};\n.*?\n\tlinha\("Defesa na hora do golpe \(outras armas\): "[^\n]*\n//s or die "prints_nh";
$s =~ s/ - ganchos: contato %s, area %s, invencibilidade %s, fim da quest %s, defesa na hora %s"/ - ganchos: contato %s, area %s, invencibilidade %s, fim da quest %s"/ or die "ganchos_txt";
$s =~ s/g78\.fim_quest and "ok" or "NAO", g78\.na_hora and "ok" or "NAO"\)\);/g78.fim_quest and "ok" or "NAO"));/ or die "ganchos_val";
troca(q|	if imgui.tree_node("Aprendizado e outras armas") then|, q|	if imgui.tree_node("Aprendizado") then|, "menu_nome");
$s =~ s/\t\tm78, op\.defesa_na_hora_ligada = imgui\.checkbox.*?\n\t\timgui\.text\("Sem dados ainda: Hammer[^\n]*\n/\t\timgui.text("O mod so le o jogo e aperta botoes reais: nada do jogo e modificado.");\n/s or die "menu_corpo";

# ------------------------------------------------ 5. contato sem dano nao ensina
troca(q|		pcall(function()
			local dados = acerto:call("get_AttackData");
			if dados ~= nil then guarda = dados:get_field("_GuardType") or 0; end
		end);|, q|		local forca = nil;
		pcall(function()
			local dados = acerto:call("get_AttackData");
			if dados ~= nil then
				guarda = dados:get_field("_GuardType") or 0;
				forca = dados:get_field("_Attack");
			end
		end);
		-- (0.80) rugido, vento, dano continuo de area: sem dano, nao e golpe
		if type(forca) == "number" and forca <= 0 then return; end|, "forca");

# ------------------------------------------------ 2/3/4. Long Sword: janelas reais do jogo (so leitura)
troca(q|n78.processar_ativacoes = processar_ativacoes;|, q|--[[
	(0.80) LONG SWORD: QUANDO O JOGO ACEITA O FS E O ISS (so leitura).
	  - FS: em cada golpe seu da Long Sword o FS so e aceito a partir de um quadro da animacao
	    (tabela abaixo, animacoes do banco 20) e so com barra de espirito (acima de 0,1) ou com a
	    aura vermelha. Nao existe FS na postura do SS (247-250), no Iai Slash (252) e no ISS (263-265).
	  - ISS: na postura (247, 248, 250) ou a partir do quadro 75 da entrada do SS (249).
	  - O jogo guarda o tempo maximo da postura e a duracao da deteccao do contra-ataque do FS / ISS:
	    o mod so LE esses valores.
]]
local JANELA_FS = {
	[195] = 51, [197] = 42, [198] = 38, [199] = 38, [200] = 70, [201] = 70, [202] = 76, [205] = 72,
	[206] = 72, [207] = 80, [208] = 56, [209] = 38, [210] = 44, [211] = 42, [212] = 50, [214] = 58,
	[216] = 62, [220] = 72, [221] = 70, [222] = 56, [223] = 56, [224] = 56, [225] = 72, [227] = 80,
	[251] = 45, [279] = 20, [285] = 38, [286] = 38, [287] = 38, [288] = 32, [289] = 30, [292] = 50,
	[293] = 69, [294] = 64, [322] = 70, [340] = 0, [342] = 0, [344] = 10, [347] = 14, [350] = 70,
	[351] = 70, [393] = 10, [467] = 50
};
local SEM_FS = { [247] = true, [248] = true, [249] = true, [250] = true, [252] = true, [263] = true, [264] = true, [265] = true };
local QUADROS_POR_SEGUNDO = 60;

-- animacao, quadro e velocidade do cacador (camada 0)
local function animacao_cacador()
	local cacador = meu_cacador();
	local objeto = cacador and objeto_de_jogo(cacador);
	if objeto == nil then return nil; end
	local id, banco, quadro = animacao_de(objeto);
	return id, banco, quadro, cacador;
end

local function barra_de_espirito(cacador)
	local valor = nil;
	pcall(function() valor = cacador:call("get_WeaponHandling"):call("get_RenkiGauge"):call("get_Value"); end);
	return tonumber(valor);
end

--[[
	o FS vai sair se for apertado daqui a "segundos"? Devolve true / false (com o motivo) ou nil
	quando nao da para saber (a regra antiga decide)
]]
local function fs_vai_sair(segundos)
	local id, banco, quadro, cacador = animacao_cacador();
	if id == nil or banco ~= 20 then return nil; end
	if SEM_FS[id] then return false, "postura / ISS"; end
	local barra = barra_de_espirito(cacador);
	if barra ~= nil and barra <= 0.1 and not (n78.barra_vermelha and n78.barra_vermelha()) then
		estado.fs_sem_barra = (estado.fs_sem_barra or 0) + 1;
		return false, "sem barra de espirito";
	end
	local limite = JANELA_FS[id];
	if limite == nil or quadro == nil then return nil; end
	local falta = (limite - quadro) / QUADROS_POR_SEGUNDO;
	if falta <= (segundos or 0) then return true; end
	estado.fs_fora_da_janela = (estado.fs_fora_da_janela or 0) + 1;
	return false, string.format("janela do FS abre em %.2fs", falta);
end

-- o jogo ja aceita o ISS agora? (nil = nao da para saber)
local function iss_pronto()
	local id, banco, quadro = animacao_cacador();
	if id == nil or banco ~= 20 then return nil; end
	if id == 247 or id == 248 or id == 250 then return true; end
	if id == 249 then return (quadro or 0) >= 75; end
	return nil;
end

-- valores do proprio jogo (so leitura)
local janelas_jogo = { contra = {}, postura = nil };
pcall(function()
	local tipo = sdk.find_type_definition("app.mcShellPlMikiri");
	local metodo = tipo and tipo:get_method("update");
	if metodo == nil then return; end
	sdk.hook(metodo, function(args)
		pcall(function()
			local obj = sdk.to_managed_object(args[2]);
			local param = obj and obj:call("get_ParamMikiri");
			local shell = obj and obj:call("get_Shell");
			if param == nil or shell == nil then return; end
			local tipo_m = param:get_field("_MikiriType");
			local limite = shell:get_field("_LifeTimer"):get_field("_Limit");
			if type(limite) == "number" then janelas_jogo.contra[tonumber(tipo_m) or -1] = limite; end
		end);
	end, function(retorno) return retorno; end);
	estado.ganchos_078.janela_contra = true;
end);
pcall(function()
	local tipo = sdk.find_type_definition("app.Wp03Action.cIaiWpOff");
	local metodo = tipo and tipo:get_method("doUpdate");
	if metodo == nil then return; end
	sdk.hook(metodo, function(args)
		pcall(function()
			local obj = sdk.to_managed_object(args[2]);
			local espera = obj and obj:get_field("_IaiWpOffWaitTime");
			if type(espera) == "number" and espera > 0.5 and espera < 30 then janelas_jogo.postura = espera; end
		end);
	end, function(retorno) return retorno; end);
	estado.ganchos_078.postura = true;
end);

n78.fs_vai_sair = fs_vai_sair;
n78.iss_pronto = iss_pronto;
n78.janelas_jogo = janelas_jogo;
n78.processar_ativacoes = processar_ativacoes;|, "ls_bloco");

# FS: so se vai sair
troca(q|							p.defesa, p.sem_combo = "esquiva", true;
							estado.ultima_decisao = "abaixo do vermelho: esquiva no lugar do FS";
						end
					end|, q|							p.defesa, p.sem_combo = "esquiva", true;
							estado.ultima_decisao = "abaixo do vermelho: esquiva no lugar do FS";
						end
						-- (0.80) o FS so sai na janela do golpe seu e com barra de espirito
						if p.defesa == "foresight" and n78.fs_vai_sair ~= nil then
							local vai, motivo = n78.fs_vai_sair(p.tempo - momento - op.ls_foresight_ms / 1000);
							if vai == false then
								p.defesa, p.sem_combo = "esquiva", true;
								estado.ultima_decisao = "FS nao sairia (" .. tostring(motivo) .. "): esquiva";
							end
						end
					end|, "fs_decisao");

# ISS: so quando o jogo aceita
troca(q|			if p.tempo - momento <= op.ls_iss_ms / 1000 then
				if not p.ss_iss then reservar_golpe(p, m, estado.chave_perfil); end|,
q|			-- (0.80) o ISS so e apertado quando o jogo ja aceita (postura, ou quadro 75 da entrada do SS)
			local pronto = n78.iss_pronto and n78.iss_pronto();
			if pronto == false and p.tempo - momento <= op.ls_iss_ms / 1000 then
				estado.iss_esperou = (estado.iss_esperou or 0) + 1;
			end
			if p.tempo - momento <= op.ls_iss_ms / 1000 and pronto ~= false then
				if not p.ss_iss then reservar_golpe(p, m, estado.chave_perfil); end|, "iss");

# barra_vermelha vem depois do bloco: exporta
troca(q|-- (0.59) quanto tempo a postura dura sozinha|, q|n78.barra_vermelha = barra_vermelha; -- (0.80) usada pelo FS (definida acima)

-- (0.59) quanto tempo a postura dura sozinha|, "exp_barra");

# postura maxima: valor do jogo
troca(q|local function postura_maxima()
	local medida = op.postura_medida_ms or 0;|, q|local function postura_maxima()
	-- (0.80) o proprio jogo guarda quanto a postura dura: usa esse valor quando lido
	local do_jogo = n78.janelas_jogo and n78.janelas_jogo.postura;
	if do_jogo ~= nil then return do_jogo; end
	local medida = op.postura_medida_ms or 0;|, "postura");

# relatorio
troca(q|	local ct = estado.contatos_em_voce or {};|, q|	-- (0.80) Long Sword: janelas do jogo e decisoes novas
	local jj = n78.janelas_jogo or { contra = {} };
	linha(string.format("Long Sword (jogo): contra do FS ativo %s s, contra do ISS ativo %s s, postura maxima %s s - FS trocado por esquiva: %d fora da janela, %d sem barra - ISS esperou o jogo aceitar: %d",
		tostring(jj.contra[0] and arredondar(jj.contra[0], 3) or "-"), tostring(jj.contra[1] and arredondar(jj.contra[1], 3) or "-"),
		tostring(jj.postura and arredondar(jj.postura, 2) or "-"),
		estado.fs_fora_da_janela or 0, estado.fs_sem_barra or 0, estado.iss_esperou or 0));
	local ct = estado.contatos_em_voce or {};|, "prints");

print $s;
