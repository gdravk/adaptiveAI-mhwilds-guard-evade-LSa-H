local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.66 - |, q|	Versao 0.67 - SEGURANCA: o buffer de entrada e achado de novo a cada escrita (antes o mod guardava
	o objeto e podia escrever num buffer que o jogo ja tinha trocado - suspeita do travamento no fim
	da luta); sem monstro grande vivo o SS+ISS para na hora; golpes seus novos sao aprendidos pelo
	seu aperto (antes so quando a espada acertava o monstro)
	0.66 - |, "cab");
$s =~ s/versao_mod = "0\.66"/versao_mod = "0.67"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.66 ==/== Defesa Automatica v0.67 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.66"\)/imgui.tree_node("Defesa Automatica v0.67")/ or die "tit";

# 1. buffer achado de novo a cada escrita
troca(q|				local alvo = teclas:get_element(item.t);
				if alvo ~= nil and item.l then
					local buffer = alvo:get_field("<LagWorker>k__BackingField");
					alvo = buffer and buffer:get_element(0);
				end
				if alvo ~= nil then
					local campo = campo_do_objeto(alvo, item.c);
					if campo ~= nil then escritas[#escritas + 1] = { alvo, campo, item.c, item.v }; end
				end|, q|				local alvo = teclas:get_element(item.t);
				if alvo ~= nil and item.l then
					--[[
						(0.67) BUFFER: guarda a TECLA (fixa) e acha o buffer dela na hora de escrever.
						Antes o objeto do buffer ficava guardado; se o jogo o trocasse (fim da luta,
						corte de camera), o mod escrevia num objeto que nao existia mais.
					]]
					local buffer = alvo:get_field("<LagWorker>k__BackingField");
					local amostra = buffer and buffer:get_element(0);
					local campo = amostra and campo_do_objeto(amostra, item.c);
					if campo ~= nil then escritas[#escritas + 1] = { alvo, campo, item.c, item.v, true }; end
				elseif alvo ~= nil then
					local campo = campo_do_objeto(alvo, item.c);
					if campo ~= nil then escritas[#escritas + 1] = { alvo, campo, item.c, item.v }; end
				end|, "montar");

troca(q|	for i = 1, #escrita do
		local e = escrita[i];
		local ok = pcall(e[2].set_data, e[2], e[1], e[4]);
		if not ok then pcall(e[1].set_field, e[1], e[3], e[4]); end
	end|, q|	for i = 1, #escrita do
		local e = escrita[i];
		if e[5] then
			-- (0.67) buffer: achado agora (o objeto pode ter sido trocado pelo jogo)
			pcall(function()
				local buffer = e[1]:get_field("<LagWorker>k__BackingField");
				local alvo = buffer and buffer:get_element(0);
				if alvo ~= nil then
					local ok = pcall(e[2].set_data, e[2], alvo, e[4]);
					if not ok then alvo:set_field(e[3], e[4]); end
				end
			end);
		else
			local ok = pcall(e[2].set_data, e[2], e[1], e[4]);
			if not ok then pcall(e[1].set_field, e[1], e[3], e[4]); end
		end
	end|, "apertar");

# 2. sem monstro vivo: o SS+ISS para
troca(q|local function controlar_ss_iss(momento, chave_perfil)
	local anim = combo.animacao or "?";|, q|local function controlar_ss_iss(momento, chave_perfil)
	local anim = combo.animacao or "?";

	-- (0.67) nenhum monstro grande vivo por perto (morreu, captura, fim da missao): para tudo
	local vivo = false;
	for _, m in pairs(monstros) do
		if not m.invalido and momento - (m.visto_em or -100) <= 0.25 then vivo = true; break; end
	end
	if not vivo then
		if ssiss ~= nil then terminar_ss_iss(nil); estado.bloquear_acoes_ate = nil; end
		return false;
	end|, "vivo");

# 3. golpes novos aprendidos pelo aperto
troca(q|							combo.ultimo_ataque_em = os.clock();|, q|							combo.ultimo_ataque_em = os.clock();
							estado.apertou_ataque_em = os.clock(); -- (0.67) aperto SEU de ataque|, "aperto");
troca(q|local function medir_golpes(anim)
	if anim == golpe_atual.anim then return; end|, q|local function medir_golpes(anim)
	if anim == golpe_atual.anim then return; end
	--[[
		(0.67) GOLPES NOVOS: a Long Sword tem muitos golpes e combos. Antes um golpe so virava
		"ataque" quando a espada acertava o monstro (os que erravam nunca eram medidos). Agora,
		se voce apertou M1 / M2 / M5 e logo em seguida (0,4s) comecou uma animacao nova da espada
		que nao e FS, SS, ISS, esquiva nem o neutro, ela vira golpe seu e passa a ser medida.
	]]
	if os.clock() - (estado.apertou_ataque_em or -100) < 0.4 and string.sub(anim, 1, 3) == "20:"
		and anim ~= "20:0" and not ANIM_FS[anim] and not ANIM_SS[anim] and not ANIM_ISS[anim]
		and anim ~= "20:61" and anim ~= "20:62" and anim ~= "20:63" and not op.animacoes_ataque_ls[anim] then
		op.animacoes_ataque_ls[anim] = true;
		salvar_opcoes();
	end|, "golpe_novo");

print $s;
