local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.87 - |, q|	Versao 0.88 - (1) TRAVAMENTO no "Saving..." depois de falhar a quest: na troca de cena / fim da quest o
	mod para tambem as leituras novas da 0.82 (sua animacao antes da tela e a geometria das areas).
	(2) TRAVA QUE VAZAVA: 40 de 147 golpes seus comecaram com a trava ligada. Agora, a cada golpe que
	escapa, o mod anota quais botoes foram apertados logo antes; botao que escapou 3 vezes entra na trava.
	(3) Animacoes que nao sao ataque (levantar do chao, andar, mirar, esquiva, dano...) nao contam mais
	como golpe seu (pelo nome que o proprio jogo da)
	0.87 - |, "cab");
$s =~ s/versao_mod = "0\.87"/versao_mod = "0.88"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.87 ==/== Defesa Automatica v0.88 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.87"\)/imgui.tree_node("Defesa Automatica v0.88")/ or die "tit";

# 1. nada de leituras novas na troca de cena / fim da quest
troca(q|re.on_pre_application_entry("BeginRendering", function()
	pcall(function()
		local cacador = meu_cacador();|, q|re.on_pre_application_entry("BeginRendering", function()
	-- (0.88) troca de cena / fim da quest: nao le nada (o jogo travou no "Saving..." na 0.87)
	if estado.trocando_cena or (estado.parar_monstros_ate or 0) > os.clock() then estado.foto_cacador = nil; return; end
	pcall(function()
		local cacador = meu_cacador();|, "begin");
troca(q|function n82.processar()
	local momento = agora();|, q|function n82.processar()
	if estado.trocando_cena or (estado.parar_monstros_ate or 0) > os.clock() then rastreadas = {}; return; end -- (0.88)
	local momento = agora();|, "proc");

# 3. nao e ataque pelo nome do jogo
troca(q|local function e_golpe_seu(anim)
	return anim ~= nil|, q|--[[
	(0.88) pelo nome que o jogo da a acao, estas animacoes NAO sao ataques seus (no teste, levantar do
	chao "cDownFaceDownStandUp" estava sendo contado como golpe)
]]
local NAO_E_ATAQUE = { "cMove", "cRun", "cDash", "cWalk", "cAim", "cDown", "cDamage", "cDodge", "cIdle",
	"cPorter", "cLand", "cStand", "cTalk", "cTemp", "cLobby", "cSmash", "cGetIn", "cFeint", "cSimple", "cJump", "cFall" };
local function nome_nao_e_ataque(anim)
	local nome = estado.nomes_golpes and estado.nomes_golpes[anim];
	if type(nome) ~= "string" then return false; end
	for _, prefixo in ipairs(NAO_E_ATAQUE) do
		if string.sub(nome, 1, #prefixo) == prefixo then return true; end
	end
	return false;
end

local function e_golpe_seu(anim)
	if nome_nao_e_ataque(anim) then return false; end
	return anim ~= nil|, "nao_ataque");

# 2. registra todos os botoes apertados enquanto a trava esta ligada
troca(q|			for numero = 0, math.min(tamanho, 128) - 1 do
				if not comandos_conhecidos[numero] and not (op.comandos_ataque_extra or {})[tostring(numero)] then
					local tecla = teclas:get_element(numero);
					if tecla ~= nil and tecla:get_field("_OnTrigger") == true then vazamento.candidatos[numero] = agora_lua; end
				end
			end|, q|			for numero = 0, math.min(tamanho, 128) - 1 do
				local tecla = teclas:get_element(numero);
				local apertou = tecla ~= nil and tecla:get_field("_OnTrigger") == true;
				if apertou then
					-- (0.88) todos os botoes apertados com a trava ligada (para achar o que escapa)
					estado.teclas_apertadas = estado.teclas_apertadas or {};
					estado.teclas_apertadas[numero] = agora_lua;
				end
				if apertou and not comandos_conhecidos[numero] and not (op.comandos_ataque_extra or {})[tostring(numero)] then
					vazamento.candidatos[numero] = agora_lua;
				end
			end|, "scan");

troca(q|			estado.golpes_com_trava = estado.golpes_com_trava or {};
			estado.golpes_com_trava[anim] = (estado.golpes_com_trava[anim] or 0) + 1;|, q|			estado.golpes_com_trava = estado.golpes_com_trava or {};
			estado.golpes_com_trava[anim] = (estado.golpes_com_trava[anim] or 0) + 1;
			--[[
				(0.88) QUAL BOTAO ESCAPOU: os apertados ate 0,4s antes. Os que ja sao travados (M1 / M2 /
				M5) aparecem no relatorio (a trava deles falhou); os outros, depois de 3 escapadas, entram
				na trava.
			]]
			local conhecidos = {};
			for _, grupo in pairs(GRUPOS_DE_BOTOES) do for _, n in ipairs(grupo) do conhecidos[n] = true; end end
			op.escapes_trava = op.escapes_trava or {};
			estado.teclas_no_vazamento = estado.teclas_no_vazamento or {};
			for numero, em in pairs(estado.teclas_apertadas or {}) do
				if os.clock() - em < 0.4 then
					estado.teclas_no_vazamento[numero] = (estado.teclas_no_vazamento[numero] or 0) + 1;
					if not conhecidos[numero] then
						local chave_n = tostring(numero);
						op.escapes_trava[chave_n] = (op.escapes_trava[chave_n] or 0) + 1;
						if op.escapes_trava[chave_n] >= 3 and not (op.comandos_ataque_extra or {})[chave_n] then
							op.comandos_ataque_extra = op.comandos_ataque_extra or {};
							op.comandos_ataque_extra[chave_n] = true;
							entrada.campos_mudaram = true;
							estado.mensagem = "Trava: botao " .. chave_n .. " escapava (golpe com a trava ligada) e agora e travado";
						end
						salvar_opcoes();
					end
				end
			end|, "escape");

troca(q|		linha(string.format("Golpes seus que comecaram com a trava ligada: %d de %d (%s)", n, estado.golpes_iniciados or 0,
			#gt > 0 and table.concat(gt, ", ") or "nenhum"));|, q|		linha(string.format("Golpes seus que comecaram com a trava ligada: %d de %d (%s)", n, estado.golpes_iniciados or 0,
			#gt > 0 and table.concat(gt, ", ") or "nenhum"));
		local tv = {};
		for numero, q in pairs(estado.teclas_no_vazamento or {}) do tv[#tv + 1] = tostring(numero) .. " " .. q; end
		linha("Botoes apertados nesses golpes (comando: vezes): " .. (#tv > 0 and table.concat(tv, ", ") or "nenhum"));|, "prints");

print $s;
