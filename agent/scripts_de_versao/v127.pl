local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }
sub troca_todas { my ($velho, $novo, $nome) = @_; my $n = ($s =~ s/\Q$velho\E/$novo/g); die "$nome nao achado" unless $n; return $n; }

troca(q|	Versao 1.26 - "LEVOU O GOLPE" PELO JOGO, NAO PELA VIDA:|,
q|	Versao 1.27 - INVENCIBILIDADE LIDA DO JOGO A CADA MOMENTO (Evade Window, Bubbly Dance, Evasion Mantle e
	qualquer outra skill / manto / efeito): o mod pergunta ao jogo quanto dura AGORA a invencibilidade da
	esquiva e do FS (a mesma conta que o jogo usa, ja com tudo que voce tem). Sem nada, a esquiva tem 217 ms e
	o FS 750 ms (medido). Com invencibilidade maior, a defesa sai mais cedo pela METADE do que aumentou: o
	golpe continua caindo no meio da invencibilidade, com mais folga para golpe que chega antes da hora. O FS
	sai no maximo 150 ms mais cedo (o contra-ataque do FS so vale nos primeiros 0,4s). O ISS ja usava a
	invencibilidade que o jogo der junto com ele (1.12): se alguma skill der invencibilidade ao ISS, o mod usa.
	O relatorio mostra a invencibilidade de agora e quantos ms antes cada defesa sai.
	1.26 - "LEVOU O GOLPE" PELO JOGO, NAO PELA VIDA:|, "cabecalho");
troca_todas(q|versao_mod = "1.26"|, q|versao_mod = "1.27"|, "versao");

troca(q|-- (1.23) ja sairam 3 FS seguidos? (o 4o vira esquiva)
|, q|--[[
	(1.27) INVENCIBILIDADE DE AGORA, PELO JOGO: quanto dura a invencibilidade da esquiva (tipo 0) e do FS (tipo 6)
	com as skills, mantos e efeitos que voce tem agora. Lido no maximo a cada 0,5s. Sem leitura: os valores
	sem skill (217 / 750 ms, medidos no jogo).
]]
local INV_BASE = { [0] = 0.217, [6] = 0.75 };
local inv_cache = { em = -100, valores = {} };
n78.janela_inv = function(tipo)
	if os.clock() - inv_cache.em > 0.5 then
		inv_cache.em = os.clock();
		local cacador = meu_cacador();
		for t in pairs(INV_BASE) do
			local v = nil;
			pcall(function() v = tonumber(cacador:call("get_HunterSkill"):call("getDodgeNoHitTime", t)); end);
			inv_cache.valores[t] = (v ~= nil and v > 0.05 and v < 3) and v or nil;
		end
	end
	return inv_cache.valores[tipo] or INV_BASE[tipo];
end;
-- quanto a defesa sai mais cedo: metade do que a invencibilidade cresceu (golpe no meio dela)
n78.extra_inv = function(tipo, maximo)
	local extra = (n78.janela_inv(tipo) - INV_BASE[tipo]) / 2;
	return math.max(0, math.min(maximo or 1, extra));
end;

-- (1.23) ja sairam 3 FS seguidos? (o 4o vira esquiva)
|, "funcoes");

troca(q|	for acao, opcao in pairs(perfil.antecedencia) do antes[acao] = (op[opcao] or 0) / 1000; end
|, q|	for acao, opcao in pairs(perfil.antecedencia) do antes[acao] = (op[opcao] or 0) / 1000; end
	-- (1.27) invencibilidade maior (Evade Window, manto, bolhas...): a defesa sai mais cedo
	if antes.esquiva ~= nil then antes.esquiva = antes.esquiva + n78.extra_inv(0, 0.4); end
	if antes.foresight ~= nil then antes.foresight = antes.foresight + n78.extra_inv(6, 0.15); end
|, "antes");

troca(q|	linha("Invencibilidade: " .. (#inv_txt > 0 and table.concat(inv_txt, " - ") or "nenhum golpe pego na invencibilidade ainda"));|,
q|	linha("Invencibilidade: " .. (#inv_txt > 0 and table.concat(inv_txt, " - ") or "nenhum golpe pego na invencibilidade ainda"));
	linha(string.format("Invencibilidade agora (skills / mantos / efeitos, lida do jogo): esquiva %d ms (sem nada 217), FS %d ms (sem nada 750) - esquiva sai %d ms mais cedo, FS %d ms mais cedo", -- (1.27)
		math.floor(n78.janela_inv(0) * 1000 + 0.5), math.floor(n78.janela_inv(6) * 1000 + 0.5),
		math.floor(n78.extra_inv(0, 0.4) * 1000 + 0.5), math.floor(n78.extra_inv(6, 0.15) * 1000 + 0.5)));|, "relatorio");
print $s;
