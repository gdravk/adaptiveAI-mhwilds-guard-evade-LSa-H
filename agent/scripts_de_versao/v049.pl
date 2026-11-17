local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }
sub todas { my ($velho, $novo, $nome) = @_; my $n = 0; while ((my $i = index($s, $velho)) >= 0) { substr($s, $i, length($velho)) = $novo; $n++; } die "$nome nao achado" if $n == 0; }

troca(q|	Versao 0.48 - |, q|	Versao 0.49 - cada VARIANTE de monstro (normal, Tempered, Arch-tempered) tem o seu proprio
	aprendizado; M4 (guardar a arma e correr) e a prioridade 0: o mod nunca interrompe
	0.48 - |, "cab");
$s =~ s/versao_mod = "0\.48"/versao_mod = "0.49"/ or die "vm";
$s =~ s/== Defesa Automatica v0\.48 ==/== Defesa Automatica v0.49 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.48"\)/imgui.tree_node("Defesa Automatica v0.49")/ or die "tit";

# =====================================================================================
# 1. VARIANTES SEPARADAS
# =====================================================================================
troca(q|		monstros[chave] = m;

		-- (0.47) guarda o nome do monstro (para a lista de monstros com a porcentagem)
		if m.nome ~= nil and nomes_monstros[tostring(id)] ~= m.nome then
			nomes_monstros[tostring(id)] = m.nome;
			precisa_salvar = true;
		end|, q|		monstros[chave] = m;

		--[[
			(0.49) VARIANTES SEPARADAS: normal, Tempered e Arch-tempered tem golpes, sequencias e
			velocidades diferentes (ex.: o Arch-tempered Arkveld e mais rapido e faz ate 4 golpes
			seguidos). Cada variante tem o seu proprio aprendizado:
			  normal = "27" (o mesmo de antes: tudo que ja foi aprendido era da versao normal),
			  Tempered = "27:t", Arch-tempered = "27:at".
			(Os Guardian ja sao monstros separados no jogo, com outro numero.)
		]]
		local sufixo, prefixo = "", "";
		if legendary == 1 then sufixo, prefixo = ":t", "Tempered ";
		elseif legendary == 2 then sufixo, prefixo = ":at", "Arch-tempered "; end
		m.variante = tostring(id) .. sufixo;
		m.nome_completo = prefixo .. tostring(m.nome);

		-- (0.47) guarda o nome do monstro (para a lista de monstros com a porcentagem)
		if m.nome ~= nil and nomes_monstros[m.variante] ~= m.nome_completo then
			nomes_monstros[m.variante] = m.nome_completo;
			precisa_salvar = true;
		end|, "variante");

todas(q|grupos_de(m.id, animacao)|, q|grupos_de(m.variante, animacao)|, "grupos");
todas(q|aprender(m.id, h.chave,|, q|aprender(m.variante, h.chave,|, "aprender");
troca(q|	local stat = estado.por_monstro[m.id] or { nome = m.nome, vistos = 0, certos = 0 };
	estado.por_monstro[m.id] = stat;|, q|	local stat = estado.por_monstro[m.variante] or { nome = m.nome_completo, vistos = 0, certos = 0 };
	estado.por_monstro[m.variante] = stat;|, "stat");
troca(q|("lanca:" .. tostring(m.id) .. ":" .. tostring(casado.origem))|, q|("lanca:" .. m.variante .. ":" .. tostring(casado.origem))|, "chave_lanca");
troca(q|	return chave_perfil .. ":" .. tostring(m.id) .. ":" .. tostring(p.origem);|,
q|	return chave_perfil .. ":" .. m.variante .. ":" .. tostring(p.origem); -- (0.49) por variante|, "chave_golpe");
troca(q|		local a_m, med_m = contar_conhecimento(m.id);
		local stat = (estado.por_monstro or {})[m.id] or { vistos = 0, certos = 0 };
		linha(string.format("Monstro: %s (ID %d) - %.1f m - animacao %s%s",
			m.nome, m.id, m.distancia or -1, tostring(m.animacao),|, q|		local a_m, med_m = contar_conhecimento(m.variante);
		local stat = (estado.por_monstro or {})[m.variante] or { vistos = 0, certos = 0 };
		linha(string.format("Monstro: %s (%s) - %.1f m - animacao %s%s",
			m.nome_completo, m.variante, m.distancia or -1, tostring(m.animacao),|, "prints1");
troca(q|			a_m, med_m, cobertura(m.id), stat.certos, stat.vistos));|, q|			a_m, med_m, cobertura(m.variante), stat.certos, stat.vistos));|, "prints2");
troca(q|		local id = tonumber(chave_monstro);
		local stat = (estado.por_monstro or {})[id] or {};|, q|		local id = chave_monstro;
		local stat = (estado.por_monstro or {})[chave_monstro] or {};|, "relatorio");

# =====================================================================================
# 2. M4 = PRIORIDADE 0 (guardar a arma e correr)
# =====================================================================================
troca(q|local ALVO_TOQUE = { toque_m5 = "m5", toque_m2 = "m2" };|, q|local ALVO_TOQUE = { toque_m5 = "m5", toque_m2 = "m2", toque_m4 = "m4" };|, "alvo");
troca(q|local NOME_DO_ALVO = { |, q|local NOME_DO_ALVO = { toque_m4 = "TOQUE DO M4 (guardar a arma e correr)", |, "nome_alvo");
troca(q|"foresight", "toque_m5", "toque_m2" };|, q|"foresight", "toque_m5", "toque_m2", "toque_m4" };|, "menu1");
troca(q|"Gravar toque do M2 (Foresight)" };|, q|"Gravar toque do M2 (Foresight)", "Gravar toque do M4 (guardar a arma e correr)" };|, "menu2");

troca(q|	ls_bloqueio_ms = 400,|, q|	-- (0.49) depois de voce apertar o M4 (guardar a arma e correr), o mod fica parado este tanto
	m4_pausa_ms = 1500,
	ls_bloqueio_ms = 400,|, "op");

troca(q|local function planejar_defesa()
	teclas_agora = {};
	pcall(conferir_defesas);|, q|--[[
	(0.49) M4 = PRIORIDADE 0, em qualquer arma: guardar a arma e correr (para o Leap of Faith e
	fugir de golpes que matam). Quando voce aperta o M4, o mod para TUDO na hora (defesa,
	toque em andamento, botoes bloqueados) e fica parado ate "m4_pausa_ms" depois de voce
	soltar. Os comandos do M4 saem da gravacao "Gravar toque do M4" (Testar / reaprender botoes).
]]
local m4_cache = { quadros = -1, comandos = {} };

local function comandos_do_m4()
	local gravado = op.toques.m4 or {};
	if #gravado == m4_cache.quadros then return m4_cache.comandos; end
	local nossos = {};
	for _, grupo in pairs(GRUPOS_DE_BOTOES) do for _, n in ipairs(grupo) do nossos[n] = true; end end
	local lista, vistos = {}, {};
	for _, item in ipairs(gravado[1] or {}) do
		if item.c == "_OnTrigger" and not nossos[item.t] and not vistos[item.t] then
			vistos[item.t] = true;
			lista[#lista + 1] = item.t;
		end
	end
	m4_cache.quadros, m4_cache.comandos = #gravado, lista;
	return lista;
end

local function m4_apertado()
	local comandos = comandos_do_m4();
	if #comandos == 0 then return false; end
	local apertado = false;
	pcall(function()
		for _, entrada_jogador in ipairs(entradas_ativas()) do
			local teclas = entrada_jogador:get_field("_Keys");
			for _, n in ipairs(comandos) do
				local tecla = teclas and teclas:get_element(n);
				if tecla ~= nil and (tecla:get_field("_On") == true or tecla:get_field("_OnTrigger") == true) then
					apertado = true;
					return;
				end
			end
		end
	end);
	return apertado;
end

local function planejar_defesa()
	teclas_agora = {};
	pcall(conferir_defesas);

	if m4_apertado() then estado.m4_ate = os.clock() + op.m4_pausa_ms / 1000; end
	if estado.m4_ate ~= nil and os.clock() < estado.m4_ate then
		toque.quadro = nil;
		estado.bloquear_m1_ate = nil;
		estado.motivo_parado = "M4 (guardar a arma e correr)";
		preparar_escrita();
		estado.escreveu = false;
		return;
	end
|, "planejar");

troca(q|	linha(string.format("Arma: %s (%s) - sacada: %s - defesa: %s - jogadores: %d - Guard Up: %s",
		perfil_atual and perfil_atual.nome or tostring(pesquisa.arma_tipo),
		perfil_atual and table.concat(perfil_atual.niveis, " > ") or "sem perfil", tostring(sacada),
		not op.guarda_automatica and "desligada" or (estado.motivo_parado == "" and "agindo" or ("parada: " .. estado.motivo_parado)),
		jogadores_na_cacada(), op.tenho_guard_up and "sim" or "nao"));|, q|	local m4 = comandos_do_m4();
	linha(string.format("Arma: %s (%s) - sacada: %s - defesa: %s - jogadores: %d - Guard Up: %s - M4: %s",
		perfil_atual and perfil_atual.nome or tostring(pesquisa.arma_tipo),
		perfil_atual and table.concat(perfil_atual.niveis, " > ") or "sem perfil", tostring(sacada),
		not op.guarda_automatica and "desligada" or (estado.motivo_parado == "" and "agindo" or ("parada: " .. estado.motivo_parado)),
		jogadores_na_cacada(), op.tenho_guard_up and "sim" or "nao",
		#m4 > 0 and ("comandos " .. table.concat(m4, ",")) or "NAO GRAVADO"));|, "prints_m4");

print $s;
