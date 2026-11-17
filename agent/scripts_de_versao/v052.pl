local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.51 - |, q|	Versao 0.52 - ONLINE: nao aprende mais com golpes em outros jogadores (chegam atrasados pela rede);
	limpeza unica do que foi aprendido assim no SOS; no multiplayer so defende golpes que ja
	acertaram VOCE alguma vez
	0.51 - |, "cab");
$s =~ s/versao_mod = "0\.51"/versao_mod = "0.52"/ or die "vm";
$s =~ s/== Defesa Automatica v0\.51 ==/== Defesa Automatica v0.52 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.51"\)/imgui.tree_node("Defesa Automatica v0.52")/ or die "tit";

# 1. aprender com outros so sozinho (voce + Palico)
troca(q|	aprender_com_outros = true,|, q|	aprender_com_outros = true,
	limpeza_online_052 = false, -- (0.52) limpeza unica do aprendido com outros jogadores no SOS|, "op");
troca(q|		if not op.aprender_com_outros then return; end|, q|		if not op.aprender_com_outros then return; end
		--[[
			(0.52) So quando voce esta sem outros jogadores (voce + Palico). No SOS, o golpe
			num outro jogador chega ao seu jogo ATRASADO pela rede: o relatorio mostrou a Lala
			Barina com 91% de conhecimento (461 de 473 medicoes vindas de outros) e 0 de 4
			golpes em voce previstos. Golpes no Palico com voce sozinho continuam ensinando.
		]]
		if (estado.jogadores or 1) > 1 then return; end|, "outros");
troca(q|local function acompanhar()
	local momento = agora();|, q|local function acompanhar()
	local momento = agora();
	estado.jogadores = jogadores_na_cacada(); -- (0.52) usado no aprendizado (contado a cada 2s)|, "jogadores");

# 2. no multiplayer, so defende golpe que ja acertou voce
troca(q|			local longe = op.checar_distancia and m.distancia ~= nil and (p.dist_max or 0) > 0
				and m.distancia > p.dist_max + op.margem_distancia;|, q|			local longe = op.checar_distancia and m.distancia ~= nil and (p.dist_max or 0) > 0
				and m.distancia > p.dist_max + op.margem_distancia;
			-- (0.52) com outros jogadores, golpe que NUNCA acertou voce (so o Palico / outros) nao e
			-- defendido: no SOS o mod soltava Foresight em golpes mirados nos outros
			if (estado.jogadores or 1) > 1 and (p.dist_max or 0) <= 0 then longe = true; end|, "longe");

# 3. limpeza unica: medicoes de outros alvos (distancia 0) nos monstros enfrentados no SOS
troca(q|pcall(carregar_conhecimento);|, q|pcall(carregar_conhecimento);

--[[
	(0.52) LIMPEZA UNICA do aprendido online: tira as medicoes vindas de golpes em outros alvos
	(distancia 0) dos monstros enfrentados no SOS em 13/11. A Quematrice e o Tempered Congalala
	ficam como estao (essas medicoes vieram do seu Palico, com voce sozinho).
]]
pcall(function()
	if op.limpeza_online_052 == true then return; end
	local alvos = { "0", "1", "6", "7:t", "13:t", "21", "23", "25:t", "27", "31", "31:t" };
	for _, chave_monstro in ipairs(alvos) do
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
	op.limpeza_online_052 = true;
	salvar_opcoes();
end);|, "limpeza");

print $s;
