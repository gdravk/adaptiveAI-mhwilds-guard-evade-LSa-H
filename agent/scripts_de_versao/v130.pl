local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }
sub troca_todas { my ($velho, $novo, $nome) = @_; my $n = ($s =~ s/\Q$velho\E/$novo/g); die "$nome nao achado" unless $n; return $n; }

troca(q|	Versao 1.29 - VERIFICACAO: 1. ALCANCE PELA AREA TAMBEM NOS GOLPES JA APRENDIDOS:|,
q|	Versao 1.30 - (lutas 1.29 contra o Gore Magala, com e sem Evade Window 5 / escudo do Gogmazios)
	1. INVENCIBILIDADE MEDIDA DE VERDADE: o relatorio mostrou 217 / 750 ms mesmo com Evade Window 5 - o valor que
	o jogo informa no comeco da esquiva pode nao ter a skill. Agora o mod tambem MEDE a invencibilidade: a cada
	esquiva / FS ele olha, quadro a quadro, o "invencivel agora" do proprio cacador (vale qualquer skill, manto
	ou efeito) e anota quanto durou. A conta da hora da defesa (1.27) usa a maior das ultimas 5 medidas de cada
	tipo; sem medida, o valor informado pelo jogo. O relatorio mostra as duas (informada e medida).
	2. "FS JA EM ANDAMENTO" SO QUANDO ELE COBRE O GOLPE: 2 danos (17:14:14 e 17:14:28) vieram de golpes que o
	mod deixou para o FS que ja estava saindo, mas que chegavam depois da invencibilidade dele. Agora o mod so
	espera se o golpe cai dentro da invencibilidade do FS atual; se nao, esquiva por cima.
	O escudo do Gogmazios funcionou como previsto (1.26): 7 golpes "sem perder vida" contaram como acerto.
	1.29 - VERIFICACAO: 1. ALCANCE PELA AREA TAMBEM NOS GOLPES JA APRENDIDOS:|, "cabecalho");
troca_todas(q|versao_mod = "1.29"|, q|versao_mod = "1.30"|, "versao");

# hook: zera a medida e anota o valor informado
troca(q|			invencibilidade.duracao = tonumber(duracao);
|, q|			invencibilidade.duracao = tonumber(duracao);
			-- (1.30) medida de verdade (quadro a quadro) e valores informados pelo jogo
			invencibilidade.viu_nohit, invencibilidade.medida_feita = false, false;
			estado.inv_informada = estado.inv_informada or {};
			local inf = estado.inv_informada[tipo] or {};
			local d_inf = tonumber(duracao);
			if d_inf ~= nil then
				inf.min = math.min(inf.min or d_inf, d_inf);
				inf.max = math.max(inf.max or d_inf, d_inf);
			end
			estado.inv_informada[tipo] = inf;
|, "hook");

# medida por quadro
troca(q|function n82.processar()
	if estado.trocando_cena or (estado.parar_monstros_ate or 0) > os.clock() then rastreadas = {}; return; end -- (0.88)
	local momento = agora();
|, q|--[[
	(1.30) INVENCIBILIDADE MEDIDA: depois de cada esquiva / FS, le o "invencivel agora" do cacador a cada quadro
	ate ele acabar. Guarda as ultimas 5 medidas de cada tipo.
]]
local function medir_invencibilidade(momento)
	local inv = n78.invencibilidade;
	if inv == nil or inv.desde == nil or inv.medida_feita then return; end
	if momento - inv.desde > 3 then inv.medida_feita = true; return; end
	local nohit = nil;
	pcall(function()
		nohit = meu_cacador():get_field("_HunterMotionSupporter"):get_field("_BaseBasicMotionSeq"):get_field("_NoHit");
	end);
	if type(nohit) ~= "boolean" then return; end
	estado.inv_leitura_ok = true;
	if nohit then inv.viu_nohit = true; return; end
	if not inv.viu_nohit then
		if momento - inv.desde > 0.2 then inv.medida_feita = true; end -- nunca ligou: nao mede
		return;
	end
	inv.medida_feita = true;
	local real = momento - inv.desde;
	if real < 0.05 then return; end
	inv.ate = inv.desde + real; -- o fim de verdade (usado pelo FS atual, pelo ISS e pelos contatos)
	estado.inv_medida = estado.inv_medida or {};
	local lista = estado.inv_medida[inv.tipo] or {};
	lista[#lista + 1] = real;
	while #lista > 5 do table.remove(lista, 1); end
	estado.inv_medida[inv.tipo] = lista;
end
n78.inv_medida_max = function(tipo)
	local lista = (estado.inv_medida or {})[tipo];
	if lista == nil or #lista == 0 then return nil; end
	local maior = 0;
	for _, v in ipairs(lista) do if v > maior then maior = v; end end
	return maior;
end;

function n82.processar()
	if estado.trocando_cena or (estado.parar_monstros_ate or 0) > os.clock() then rastreadas = {}; return; end -- (0.88)
	local momento = agora();
	pcall(medir_invencibilidade, momento); -- (1.30)
|, "medida");

# janela_inv usa a medida
troca(q|	return inv_cache.valores[tipo] or INV_BASE[tipo];
end;|, q|	-- (1.30) a invencibilidade MEDIDA (quadro a quadro) vale mais que a informada; o FS usa o tipo 6 ou 7
	local medida = n78.inv_medida_max and n78.inv_medida_max(tipo) or nil;
	if tipo == 6 and n78.inv_medida_max then
		local vermelho = n78.inv_medida_max(7);
		if vermelho ~= nil and (medida == nil or vermelho > medida) then medida = vermelho; end
	end
	if medida ~= nil then return medida; end
	return inv_cache.valores[tipo] or INV_BASE[tipo];
end;
-- (1.30) o FS que ja esta saindo cobre um golpe que chega em "t"? (dentro da invencibilidade dele)
n78.inv_cobre = function(t)
	local inv = n78.invencibilidade or {};
	return (inv.tipo == 6 or inv.tipo == 7) and inv.ate ~= nil and t ~= nil and inv.ate >= t + 0.03;
end;|, "janela");

# FS ja em andamento: so se cobre
troca(q|						if n78.fs_cobre() then -- (1.02) depois dos 0,4s sai outro FS por cima|,
q|						if n78.fs_cobre() and n78.inv_cobre(p.tempo) then -- (1.02) depois dos 0,4s sai outro FS por cima; (1.30) so se cobre o golpe|, "decisao");
troca(q|			if n78.fs_cobre() then -- (1.02) so enquanto o contra do FS atual ainda vale
				if p.diag ~= nil then p.diag.resultado = "FS ja em andamento"; end
				p.estado_pg.ignorar = true;
				p.sem_combo = true; -- nao conta como falha do FS
				return; -- (1.24) o FS atual cobre: nada de esquiva por cima dele
			end|,
q|			if n78.fs_cobre() then -- (1.02) so enquanto o contra do FS atual ainda vale
				-- (1.30) o golpe chega depois da invencibilidade do FS atual: outro FS nao sai ainda -> esquiva
				if not n78.inv_cobre(p.tempo) then
					estado.fs_nao_cobre = (estado.fs_nao_cobre or 0) + 1;
					return "indisponivel", "FS atual acaba antes do golpe";
				end
				if p.diag ~= nil then p.diag.resultado = "FS ja em andamento"; end
				p.estado_pg.ignorar = true;
				p.sem_combo = true; -- nao conta como falha do FS
				return; -- (1.24) o FS atual cobre: nada de esquiva por cima dele
			end|, "executor");

# relatorio
troca(q|		math.floor(n78.extra_inv(0, 0.4) * 1000 + 0.5), math.floor(n78.extra_inv(6, 0.15) * 1000 + 0.5)));|,
q|		math.floor(n78.extra_inv(0, 0.4) * 1000 + 0.5), math.floor(n78.extra_inv(6, 0.15) * 1000 + 0.5)));
	-- (1.30) informada pelo jogo x medida quadro a quadro
	local partes_inv = {};
	local nomes_inv = { [0] = "esquiva", [1] = "passo", [6] = "FS", [7] = "FS vermelho" };
	local tipos_inv = {};
	for t in pairs(estado.inv_informada or {}) do tipos_inv[t] = true; end
	for t in pairs(estado.inv_medida or {}) do tipos_inv[t] = true; end
	for t in pairs(tipos_inv) do
		local inf = (estado.inv_informada or {})[t] or {};
		local med = (estado.inv_medida or {})[t] or {};
		local med_txt = {};
		for _, v in ipairs(med) do med_txt[#med_txt + 1] = tostring(math.floor(v * 1000 + 0.5)); end
		partes_inv[#partes_inv + 1] = string.format("%s: informada %s a %s ms, medida %s", nomes_inv[t] or ("tipo " .. tostring(t)),
			inf.min and tostring(math.floor(inf.min * 1000 + 0.5)) or "-", inf.max and tostring(math.floor(inf.max * 1000 + 0.5)) or "-",
			#med_txt > 0 and (table.concat(med_txt, "/") .. " ms") or "-");
	end
	linha("Invencibilidade informada x medida (leitura " .. (estado.inv_leitura_ok and "ok" or "NAO") .. "): "
		.. (#partes_inv > 0 and table.concat(partes_inv, " - ") or "nenhuma esquiva ainda")
		.. " - FS atual nao cobria o golpe (esquivou): " .. tostring(estado.fs_nao_cobre or 0));|, "relatorio");
print $s;
