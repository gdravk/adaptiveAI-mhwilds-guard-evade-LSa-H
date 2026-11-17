local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }
sub troca_todas { my ($velho, $novo, $nome) = @_; my $n = ($s =~ s/\Q$velho\E/$novo/g); die "$nome nao achado" unless $n; return $n; }

troca(q|	Versao 1.32 - MAIS SS+ISS COM A BARRA VERMELHA,|,
q|	Versao 1.33 - (2 lutas 1.32 contra a Lagiacrus, com e sem Evade Window 5) 1. O SS+ISS NO VERMELHO (1.32) SAIU:
	pedido do usuario - na luta o ISS saiu 10 vezes sem contra-ataque e 3 vezes com dano; volta a regra da 1.29
	(no vermelho o FS tem a vez; SS+ISS so onde o FS falha). 2. A MEDIDA QUADRO A QUADRO (1.30) SAIU: a luta
	mostrou que o valor que o jogo informa JA TEM o Evade Window (esquiva 217 -> 417 ms, FS 750 -> 917 ms) e a
	medida nunca funcionou (o "invencivel agora" lido nunca ligou). A hora da defesa (1.27) segue pelo valor
	informado. O relatorio continua mostrando o menor e o maior valor informado de cada tipo.
	1.32 - MAIS SS+ISS COM A BARRA VERMELHA,|, "cabecalho");
troca_todas(q|versao_mod = "1.32"|, q|versao_mod = "1.33"|, "versao");

# 1. SS+ISS no vermelho volta ao da 1.29
troca(q|-- (1.32) golpe em que o ISS ja provou que funciona: 2+ contra-ataques e nenhum dano no SS+ISS
n78.ss_provado = function(chave)
	local s = chave and ss_sem_golpe[chave];
	return s ~= nil and (s.ok or 0) >= 2 and (s.dano or 0) == 0 and golpe_bom_para_ss(chave);
end;
|, "", "funcao ss");
troca(q| or (n78.ss_provado and n78.ss_provado(chave))); -- (1.32) no vermelho, golpe provado|, q|);|, "trava");
troca(q| and not n78.ss_provado(chave_m2) then|, q| then|, "m2");
troca(q| and not n78.ss_provado(chave) then|, q| then|, "ss");
troca(q|"VERMELHA: FS > esquiva (SS+ISS onde o FS falha e nos golpes em que o ISS ja provou que funciona)"|, q|"VERMELHA: FS > esquiva (SS+ISS so onde o FS falha)"|, "relatorio ss");

# 2. medida quadro a quadro sai
troca(q|			invencibilidade.viu_nohit, invencibilidade.medida_feita = false, false;
|, "", "hook");
troca(q|-- ---------- por quadro
--[[
	(1.30) INVENCIBILIDADE MEDIDA:|, q|-- ---------- por quadro
--[[
	(1.30, saiu na 1.33) INVENCIBILIDADE MEDIDA:|, "marca") if 0;
my $ini = index($s, "--[[\n\t(1.30) INVENCIBILIDADE MEDIDA:"); die "ini" if $ini < 0;
my $fim_txt = "\treturn copia[math.floor((#copia + 1) / 2)], lista.em;\nend;\n";
my $fim = index($s, $fim_txt, $ini); die "fim" if $fim < 0;
substr($s, $ini, $fim + length($fim_txt) - $ini) = "";
troca(q|	pcall(medir_invencibilidade, momento); -- (1.30)
|, "", "chamada");
troca(q|	-- (1.30) a invencibilidade MEDIDA (quadro a quadro) vale mais que a informada; o FS usa o tipo 6 ou 7
	local medida, medida_em, tipo_usado = nil, nil, tipo;
	if n78.inv_medida_max then
		medida, medida_em = n78.inv_medida_max(tipo);
		-- (1.31) FS: tipo 6 ou 7 (vermelho); esquiva: rolar (0) ou passo (1) - vale o usado por ultimo
		local outro = (tipo == 6 and 7) or (tipo == 0 and 1) or nil;
		if outro ~= nil then
			local m2, em2 = n78.inv_medida_max(outro);
			if m2 ~= nil and (medida == nil or (em2 or 0) > (medida_em or 0)) then medida, tipo_usado = m2, outro; end
		end
	end
	if medida ~= nil then return medida, tipo_usado; end
	return inv_cache.valores[tipo] or INV_BASE[tipo], tipo;|,
q|	-- (1.33) o valor informado pelo jogo ja tem o Evade Window (medido: esquiva 217 -> 417 ms, FS 750 -> 917 ms)
	return inv_cache.valores[tipo] or INV_BASE[tipo], tipo;|, "janela");
troca(q|	-- (1.31) FS ainda em andamento: o fim esperado usa a invencibilidade medida (com as skills)
	if not inv.medida_feita then fim = math.max(fim, inv.desde + n78.janela_inv(6)); end|,
q|	-- (1.31) FS ainda em andamento: o fim esperado usa a invencibilidade de agora (com as skills)
	fim = math.max(fim, inv.desde + n78.janela_inv(6));|, "cobre");
troca(q|	-- (1.30) informada pelo jogo x medida quadro a quadro
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
		.. (#partes_inv > 0 and table.concat(partes_inv, " - ") or "nenhuma esquiva ainda")|,
q|	-- (1.30 / 1.33) menor e maior invencibilidade informada pelo jogo nesta sessao, por tipo
	local partes_inv = {};
	local nomes_inv = { [0] = "esquiva", [1] = "passo", [6] = "FS", [7] = "FS vermelho" };
	for t, inf in pairs(estado.inv_informada or {}) do
		partes_inv[#partes_inv + 1] = string.format("%s %s a %s ms", nomes_inv[t] or ("tipo " .. tostring(t)),
			inf.min and tostring(math.floor(inf.min * 1000 + 0.5)) or "-", inf.max and tostring(math.floor(inf.max * 1000 + 0.5)) or "-");
	end
	linha("Invencibilidade informada pelo jogo nesta sessao: "
		.. (#partes_inv > 0 and table.concat(partes_inv, " - ") or "nenhuma esquiva ainda")|, "relatorio inv");
print $s;
