local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.70 - |, q|	Versao 0.71 - trava dos seus ataques: o mod descobre sozinho botoes de ataque que escapavam da trava
	(ex.: M1 + M2 juntos podem ser outro "comando" do jogo) e passa a trava-los tambem; o SS de uma
	sequencia nao comeca mais 0,5s antes (os SS de 3,5s eram previsoes longas e erravam)
	0.70 - |, "cab");
$s =~ s/versao_mod = "0\.70"/versao_mod = "0.71"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.70 ==/== Defesa Automatica v0.71 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.70"\)/imgui.tree_node("Defesa Automatica v0.71")/ or die "tit";

troca(q|	somente_ss_iss = false,|, q|	somente_ss_iss = false,
	-- (0.71) comandos de ataque descobertos que escapavam da trava: [numero] = true
	comandos_ataque_extra = {},
	vazamentos = {},        -- (0.71) [numero] = { golpe = vezes que veio junto de um golpe seu, nada = vezes sem }|, "op");

# volta a janela normal do SS na sequencia
troca(q|			local ss_max = op.ls_ss_max_ms / 1000 + (em_sequencia and 0.5 or 0);|,
q|			-- (0.71) sem os 0,5s a mais da 0.70: os SS de ~3,5s vinham de previsoes longas e erravam
			local ss_max = op.ls_ss_max_ms / 1000;|, "ssmax");

# grupo "extra" na trava
troca(q|		for _, n in ipairs(GRUPOS_DE_BOTOES[string.sub(acao, 10)] or {}) do|, q|		local grupo_b = GRUPOS_DE_BOTOES[string.sub(acao, 10)];
		if string.sub(acao, 10) == "extra" then
			grupo_b = {};
			for numero in pairs(op.comandos_ataque_extra or {}) do grupo_b[#grupo_b + 1] = tonumber(numero); end
		end
		for _, n in ipairs(grupo_b or {}) do|, "grupo_extra");
troca(q|		if not usa_espaco then marcar("bloquear:espaco"); end|, q|		if not usa_espaco then marcar("bloquear:espaco"); end
		if next(op.comandos_ataque_extra or {}) ~= nil then marcar("bloquear:extra"); end -- (0.71)
		estado.trava_ativa_em = os.clock(); -- (0.71) para descobrir botoes que escapam da trava|, "marca_extra");

# descobre os comandos que escapam
troca(q|	pcall(medir_golpes, combo.animacao or "?"); -- (0.64)|, q|	pcall(vigiar_vazamentos, combo.animacao or "?"); -- (0.71)
	pcall(medir_golpes, combo.animacao or "?"); -- (0.64)|, "chamada");

troca(q|local sinais_ls = {};|, q|local sinais_ls = {};

--[[
	(0.71) BOTOES QUE ESCAPAM DA TRAVA. Voce notou: spamando M1 / M2 o personagem ainda ficava preso
	no golpe e a esquiva nao saia. A trava solta os comandos achados nas suas gravacoes de cada
	botao (M1, M2, M5), mas o jogo pode ter OUTROS comandos de ataque (ex.: M1 + M2 juntos, ou
	um comando diferente no combo). Enquanto a trava esta ativa, o mod olha TODOS os comandos:
	  - um comando desconhecido foi apertado e logo depois (0,4s) comecou um golpe seu = escapou;
	  - foi apertado e nenhum golpe comecou (ex.: andar) = inocente.
	Depois de escapar 3 vezes (e mais vezes do que foi inocente), ele entra na trava.
]]
local vazamento = { candidatos = {}, anim = nil };
local comandos_conhecidos = nil;

local function vigiar_vazamentos(anim)
	if comandos_conhecidos == nil then
		comandos_conhecidos = {};
		for _, grupo in pairs(GRUPOS_DE_BOTOES) do for _, n in ipairs(grupo) do comandos_conhecidos[n] = true; end end
		for _, n in ipairs(comandos_do_m4()) do comandos_conhecidos[n] = true; end
	end
	local agora_lua = os.clock();
	local trava_ativa = agora_lua - (estado.trava_ativa_em or -100) < 0.1;

	-- um golpe seu comecou: os comandos apertados logo antes escaparam da trava
	if anim ~= vazamento.anim then
		if vazamento.anim ~= nil and e_golpe_seu(anim) and trava_ativa then
			for numero, em in pairs(vazamento.candidatos) do
				if agora_lua - em < 0.4 and not (op.comandos_ataque_extra or {})[tostring(numero)] then
					local v = op.vazamentos[tostring(numero)] or { golpe = 0, nada = 0 };
					v.golpe = v.golpe + 1;
					v.contado = true;
					op.vazamentos[tostring(numero)] = v;
					if v.golpe >= 3 and v.golpe > v.nada then
						op.comandos_ataque_extra[tostring(numero)] = true;
						entrada.campos_mudaram = true; -- refaz a lista de escritas
						estado.mensagem = "Trava: comando " .. tostring(numero) .. " escapava e agora e travado tambem";
					end
					salvar_opcoes();
				end
			end
			vazamento.candidatos = {};
		end
		vazamento.anim = anim;
	end

	-- apertados ha mais de 0,4s sem golpe: inocentes
	for numero, em in pairs(vazamento.candidatos) do
		if agora_lua - em >= 0.4 then
			local v = op.vazamentos[tostring(numero)] or { golpe = 0, nada = 0 };
			v.nada = v.nada + 1;
			op.vazamentos[tostring(numero)] = v;
			vazamento.candidatos[numero] = nil;
		end
	end

	if not trava_ativa then return; end
	for _, entrada_jogador in ipairs(entradas_ativas()) do
		local teclas = entrada_jogador:get_field("_Keys");
		local ok_t, tamanho = pcall(function() return teclas:get_size(); end);
		if ok_t and type(tamanho) == "number" then
			for numero = 0, math.min(tamanho, 128) - 1 do
				if not comandos_conhecidos[numero] and not (op.comandos_ataque_extra or {})[tostring(numero)] then
					local tecla = teclas:get_element(numero);
					if tecla ~= nil and tecla:get_field("_OnTrigger") == true then vazamento.candidatos[numero] = agora_lua; end
				end
			end
		end
	end
end|, "vigia");

# Prints
troca(q|		linha(string.format("Seus golpes: %d medidos|, q|		local extras_txt = {};
		for numero in pairs(op.comandos_ataque_extra or {}) do extras_txt[#extras_txt + 1] = numero; end
		linha("Trava: comandos extras descobertos: " .. (#extras_txt > 0 and table.concat(extras_txt, ", ") or "nenhum"));
		linha(string.format("Seus golpes: %d medidos|, "prints");

print $s;
