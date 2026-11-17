local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.53 - |, q|	Versao 0.54 - fora os golpes em voce, aprende SO com golpes no Palico (nunca com bots / cacadores
	de suporte, outros jogadores ou objetos); limpeza unica das medicoes de origem incerta
	0.53 - |, "cab");
$s =~ s/versao_mod = "0\.53"/versao_mod = "0.54"/ or die "vm";
$s =~ s/== Defesa Automatica v0\.53 ==/== Defesa Automatica v0.54 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.53"\)/imgui.tree_node("Defesa Automatica v0.54")/ or die "tit";

troca(q|	limpeza_sos_053 = false,|, q|	limpeza_bots_054 = false, -- (0.54) limpeza unica de medicoes que podem ter vindo de bots
	limpeza_sos_053 = false,|, "op");

troca(q|local function ao_impacto(argumentos)|, q|-- (0.54) o alvo e um Palico? (bots / cacadores de suporte sao cacadores, nao Palicos)
local tipo_palico = sdk.typeof("app.OtomoCharacter");

local function e_palico(objeto)
	if tipo_palico == nil or objeto == nil then return false; end
	local ok, componente = pcall(function() return objeto:call("getComponent(System.Type)", tipo_palico); end);
	return ok and componente ~= nil;
end

local function ao_impacto(argumentos)|, "palico");

troca(q|		if (estado.jogadores or 1) > 1 then return; end|, q|		if (estado.jogadores or 1) > 1 then return; end
		-- (0.54) e so com o PALICO: golpes em bots (cacadores de suporte), em objetos ou em
		-- qualquer outro alvo nao ensinam nada
		if not e_palico(alvo) then return; end|, "so_palico");

troca(q|	op.limpeza_sos_053 = true;
	salvar_opcoes();
end);|, q|	op.limpeza_sos_053 = true;
	salvar_opcoes();
end);

--[[
	(0.54) LIMPEZA UNICA: no Tempered Rathalos e no Doshaguma havia medicoes de golpes em outros
	alvos que podem ter sido bots. Como nao da para saber se foram no Palico ou num bot, saem
	(as medicoes dos golpes em VOCE ficam).
]]
pcall(function()
	if op.limpeza_bots_054 == true then return; end
	for _, chave_monstro in ipairs({ "1:t", "16" }) do
		local golpes = conhecimento[chave_monstro];
		if golpes ~= nil then
			for animacao, lista in pairs(golpes) do
				local nova = {};
				for _, medicao in ipairs(lista) do
					if (medicao[3] or 0) > 0 then nova[#nova + 1] = medicao; end
				end
				if #nova > 0 then golpes[animacao] = nova; else golpes[animacao] = nil; end
			end
			if next(golpes) == nil then conhecimento[chave_monstro] = nil; end
		end
	end
	grupos_cache = {};
	salvar_conhecimento();
	op.limpeza_bots_054 = true;
	salvar_opcoes();
end);|, "limpeza");

troca(q|aprendidos no Palico ou outros: %d",|, q|aprendidos no seu Palico: %d",|, "prints");

print $s;
