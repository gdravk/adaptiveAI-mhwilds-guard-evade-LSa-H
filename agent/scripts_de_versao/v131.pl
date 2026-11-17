local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }
sub troca_todas { my ($velho, $novo, $nome) = @_; my $n = ($s =~ s/\Q$velho\E/$novo/g); die "$nome nao achado" unless $n; return $n; }

troca(q|	Versao 1.30 - (lutas 1.29 contra o Gore Magala, com e sem Evade Window 5 / escudo do Gogmazios)|,
q|	Versao 1.31 - VERIFICACAO DA MEDIDA DA INVENCIBILIDADE (1.30): 1. usava a MAIOR das ultimas 5 medidas: uma
	medida esticada por outra coisa (ex.: o contra do FS ou uma acao com invencibilidade logo depois) fazia a
	esquiva sair cedo demais. Agora usa a do MEIO (mediana) e so depois de 3 medidas; antes disso, o valor que
	o jogo informa. 2. a esquiva sai no maximo 200 ms mais cedo (era 400). 3. a esquiva de cada arma tem o
	seu tipo (rolar = 0, passo da Lance / Gunlance = 1): vale a medida do tipo usado por ultimo. 4. FS em
	andamento: o fim esperado dele usa a invencibilidade medida (antes so a informada, menor com Evade
	Window - o mod esquivava por cima de um FS que ainda cobria o golpe). 5. a regra do 4o FS usa a mesma conta.
	1.30 - (lutas 1.29 contra o Gore Magala, com e sem Evade Window 5 / escudo do Gogmazios)|, "cabecalho");
troca_todas(q|versao_mod = "1.30"|, q|versao_mod = "1.31"|, "versao");

# medidas com hora
troca(q|	lista[#lista + 1] = real;
	while #lista > 5 do table.remove(lista, 1); end
	estado.inv_medida[inv.tipo] = lista;|,
q|	lista[#lista + 1] = real;
	while #lista > 5 do table.remove(lista, 1); end
	lista.em = momento; -- (1.31) quando foi a ultima medida deste tipo
	estado.inv_medida[inv.tipo] = lista;|, "hora");

troca(q|n78.inv_medida_max = function(tipo)
	local lista = (estado.inv_medida or {})[tipo];
	if lista == nil or #lista == 0 then return nil; end
	local maior = 0;
	for _, v in ipairs(lista) do if v > maior then maior = v; end end
	return maior;
end;|,
q|-- (1.31) a medida do meio (mediana) das ultimas 5, so com 3 medidas ou mais; e a hora da ultima
n78.inv_medida_max = function(tipo)
	local lista = (estado.inv_medida or {})[tipo];
	if lista == nil or #lista < 3 then return nil, nil; end
	local copia = {};
	for _, v in ipairs(lista) do copia[#copia + 1] = v; end
	table.sort(copia);
	return copia[math.floor((#copia + 1) / 2)], lista.em;
end;|, "mediana");

troca(q|	local medida = n78.inv_medida_max and n78.inv_medida_max(tipo) or nil;
	if tipo == 6 and n78.inv_medida_max then
		local vermelho = n78.inv_medida_max(7);
		if vermelho ~= nil and (medida == nil or vermelho > medida) then medida = vermelho; end
	end|,
q|	local medida, medida_em = nil, nil;
	if n78.inv_medida_max then
		medida, medida_em = n78.inv_medida_max(tipo);
		-- (1.31) FS: tipo 6 ou 7 (vermelho); esquiva: rolar (0) ou passo (1) - vale o usado por ultimo
		local outro = (tipo == 6 and 7) or (tipo == 0 and 1) or nil;
		if outro ~= nil then
			local m2, em2 = n78.inv_medida_max(outro);
			if m2 ~= nil and (medida == nil or (em2 or 0) > (medida_em or 0)) then medida = m2; end
		end
	end|, "tipo usado");

troca(q|n78.inv_cobre = function(t)
	local inv = n78.invencibilidade or {};
	return (inv.tipo == 6 or inv.tipo == 7) and inv.ate ~= nil and t ~= nil and inv.ate >= t + 0.03;
end;|,
q|n78.inv_cobre = function(t)
	local inv = n78.invencibilidade or {};
	if not (inv.tipo == 6 or inv.tipo == 7) or inv.desde == nil or t == nil then return false; end
	local fim = inv.ate or inv.desde;
	-- (1.31) FS ainda em andamento: o fim esperado usa a invencibilidade medida (com as skills)
	if not inv.medida_feita then fim = math.max(fim, inv.desde + n78.janela_inv(6)); end
	return fim >= t + 0.03;
end;|, "cobre");

troca(q|				if (inv_l.tipo == 6 or inv_l.tipo == 7) and inv_l.ate ~= nil and inv_l.ate >= p.tempo + 0.05 then|,
q|				if n78.inv_cobre(p.tempo + 0.02) then -- (1.31) mesma conta do FS em andamento|, "4o fs");
troca(q|	local inv_l = n78.invencibilidade or {};
				if n78.inv_cobre|, q|	if n78.inv_cobre|, "tira inv_l") if 0;

troca_todas(q|n78.extra_inv(0, 0.4)|, q|n78.extra_inv(0, 0.2)|, "teto esquiva");
# tipo usado volta junto, e a base e a do mesmo tipo
troca(q|			if m2 ~= nil and (medida == nil or (em2 or 0) > (medida_em or 0)) then medida = m2; end
		end
	end
	if medida ~= nil then return medida; end
	return inv_cache.valores[tipo] or INV_BASE[tipo];
end;|, q|			if m2 ~= nil and (medida == nil or (em2 or 0) > (medida_em or 0)) then medida, tipo_usado = m2, outro; end
		end
	end
	if medida ~= nil then return medida, tipo_usado; end
	return inv_cache.valores[tipo] or INV_BASE[tipo], tipo;
end;|, "volta tipo");
troca(q|	local medida, medida_em = nil, nil;
	if n78.inv_medida_max then|, q|	local medida, medida_em, tipo_usado = nil, nil, tipo;
	if n78.inv_medida_max then|, "tipo_usado");
troca(q|	local extra = (n78.janela_inv(tipo) - INV_BASE[tipo]) / 2;|,
q|	-- (1.31) a base e a do tipo medido (o passo da Lance tem outra invencibilidade que o rolar)
	local valor, tipo_usado = n78.janela_inv(tipo);
	local base = INV_BASE[tipo_usado] or (((estado.inv_informada or {})[tipo_usado] or {}).min) or valor;
	local extra = (valor - base) / 2;|, "base do tipo");
print $s;
