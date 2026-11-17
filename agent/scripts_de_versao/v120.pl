local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; die "$nome repetido" if index($s, $velho, $i + length($novo)) >= 0 && $velho ne $novo && 0; }
sub troca_todas { my ($velho, $novo, $nome) = @_; my $n = ($s =~ s/\Q$velho\E/$novo/g); die "$nome nao achado" unless $n; }

# cabecalho
troca(q|	Versao 1.19 - PREPARACAO PARA O SOS:|,
q|	Versao 1.20 - (lutas no SOS com Lance, Hunting Horn e Long Sword) APRENDER PELA AREA SOZINHA: o golpe do
	monstro liga uma area de ataque no tempo certo da animacao, acerte alguem ou nao. Antes essa area so
	ajustava golpes que ja tinham acertado voce; agora, numa animacao sem golpe conhecido, a area sozinha
	ensina o tempo (area + 0,10s) e o alcance (o ponto mais longe da area ate o monstro). Vale no SOS (a area
	e do seu jogo, sem atraso de rede) e com golpes em outros jogadores, no Palico ou no vazio - nao precisa
	apanhar. Projeteis ficam de fora (o tempo depende da distancia). DANOS NO RELATORIO: cada dano mostra o
	monstro, a animacao dele, se o golpe estava previsto e se a sua invencibilidade tinha comecado.
	A MEDICAO DO ISS (1.12) SAIU: respondida (o ISS nao tem invencibilidade; 0 danos nele nas duas ultimas lutas).
	1.19 - PREPARACAO PARA O SOS:|, "cabecalho");
troca_todas(q|versao_mod = "1.19"|, q|versao_mod = "1.20"|, "versao");

# aprender: 5o campo opcional (marca da origem: 1 = area sozinha)
troca(q|local function aprender(id, animacao, segundos, guarda, dist)|, q|local function aprender(id, animacao, segundos, guarda, dist, marca)|, "aprender assinatura");
troca(q|	lista[#lista + 1] = { arredondar(segundos, 3), guarda or 0, arredondar(dist or 0, 1) };|,
q|	lista[#lista + 1] = { arredondar(segundos, 3), guarda or 0, arredondar(dist or 0, 1), marca };|, "aprender lista");

# posicao do monstro para o alcance da area
troca(q|			m.distancia = distancia(mx, my, mz, cx, cy, cz);
|, q|			m.distancia = distancia(mx, my, mz, cx, cy, cz);
			m.pos = { mx, my, mz }; -- (1.20) alcance da area de ataque
|, "pos");

# rastrear: todas as partes de uma ativacao dividem um grupo
troca(q|	for _, col in ipairs(cols) do
		if col ~= nil and #rastreadas < 48 then
			rastreadas[#rastreadas + 1] = { m = a.m, col = col, em = a.em, guarda = guarda or 0, projetil = a.projetil };
		end
	end
end|, q|	-- (1.20) as partes de uma mesma area ensinam uma vez so (projetil fica de fora)
	local grupo = (not a.projetil) and { restantes = 0, alcance = 0, guarda = guarda or 0 } or nil;
	for _, col in ipairs(cols) do
		if col ~= nil and #rastreadas < 48 then
			rastreadas[#rastreadas + 1] = { m = a.m, col = col, em = a.em, guarda = guarda or 0, projetil = a.projetil, grupo = grupo };
			if grupo ~= nil then grupo.restantes = grupo.restantes + 1; end
		end
	end
end

-- (1.20) APRENDER PELA AREA SOZINHA: a animacao que estava na tela quando a area ligou ganha um golpe
-- em (area + 0,10s) com o alcance da area - so se nenhum golpe de CONTATO ja explica essa area
function n82.aprender_area(m, em, grupo)
	if not op.aprender or not op.aprender_por_ativacao or m == nil or m.invalido then return; end
	if (grupo.alcance or 0) <= 0 then return; end
	local h = nil;
	for i = #m.historico, 1, -1 do
		if m.historico[i].inicio <= em then h = m.historico[i]; break; end
	end
	if h == nil then return; end
	local ofs = em - h.inicio;
	if ofs < 0 or ofs > AJUSTES.idade_maxima_animacao then return; end
	local tempo = ofs + 0.10;
	for _, g in ipairs(grupos_de(m.variante, h.chave) or {}) do
		local de_contato = false;
		for _, md in ipairs(g.lista) do
			if md[4] == nil then de_contato = true; break; end
		end
		if de_contato and math.abs(g.tempo - tempo) <= 0.25 then return; end
	end
	aprender(m.variante, h.chave, tempo, grupo.guarda, grupo.alcance, 1);
	estado.aprendidos_area_sozinha = (estado.aprendidos_area_sozinha or 0) + 1;
end

-- (1.20) de onde veio um dano (para o relatorio): monstro mais perto, animacao, previsao e invencibilidade
n78.info_dano = function()
	local partes = {};
	local momento = agora();
	local m = monstro_mais_perto();
	if m ~= nil then
		local h = m.historico[#m.historico];
		local perto = nil;
		for _, p in ipairs(m.previstos or {}) do
			local e = momento - p.tempo;
			if perto == nil or math.abs(e) < math.abs(perto) then perto = e; end
		end
		partes[#partes + 1] = string.format("golpe: %s anim %s (%.2fs) a %.1f m - previsto: %s", tostring(m.variante),
			h and tostring(h.chave) or "-", h and (momento - h.inicio) or 0, m.distancia or -1,
			perto ~= nil and string.format("%+d ms", math.floor(perto * 1000 + 0.5)) or "nao");
	end
	local inv = n78.invencibilidade or {};
	if inv.desde ~= nil and momento - inv.desde < 1.5 then
		partes[#partes + 1] = string.format("invencibilidade comecou ha %d ms (dura %d ms)",
			math.floor((momento - inv.desde) * 1000 + 0.5), math.floor((inv.duracao or 0) * 1000 + 0.5));
	end
	return table.concat(partes, " - ");
end;|, "rastrear");

# geometria: alcance da area e fim do grupo
troca(q|				if ok and forma ~= nil then
					local gap = distancia_segmentos(forma, corpo);|,
q|				if ok and forma ~= nil then
					-- (1.20) alcance: ponto mais longe da area ate o monstro (+ raio da area e do corpo)
					local pm = r.m.pos;
					if r.grupo ~= nil and pm ~= nil then
						for _, ponto in ipairs({ forma.a, forma.b }) do
							local dx, dy, dz = ponto[1] - pm[1], ponto[2] - pm[2], ponto[3] - pm[3];
							local alc = math.sqrt(dx * dx + dy * dy + dz * dz) + (forma.r or 0) + 0.45;
							if alc > r.grupo.alcance then r.grupo.alcance = alc; end
						end
					end
					local gap = distancia_segmentos(forma, corpo);|, "alcance");
troca(q|		if manter then
			restantes[#restantes + 1] = r;
		elseif r.vista then|,
q|		if not manter and r.grupo ~= nil then
			r.grupo.restantes = r.grupo.restantes - 1;
			if r.grupo.restantes <= 0 and r.grupo.alcance > 0 then pcall(n82.aprender_area, r.m, r.em, r.grupo); end
		end
		if manter then
			restantes[#restantes + 1] = r;
		elseif r.vista then|, "fim do grupo");

# relatorio
troca(q|pela area de ataque %d (areas vistas %d, relogios acertados %d) - golpes repetidos vistos %d",
		estado.aprendidos_contato or 0, estado.contatos_descartados or 0, estado.aprendidos_ativacao or 0,|,
q|pela area de ataque %d, pela area sozinha %d (areas vistas %d, relogios acertados %d) - golpes repetidos vistos %d",
		estado.aprendidos_contato or 0, estado.contatos_descartados or 0, estado.aprendidos_ativacao or 0, estado.aprendidos_area_sozinha or 0,|, "relatorio area");

# danos com a origem
troca(q|					tostring(estado.ultima_decisao)));
				if #estado.danos_log > 60|,
q|					tostring(estado.ultima_decisao)) .. (function()
						local ok_i, info_i = pcall(n78.info_dano);
						return (ok_i and info_i ~= nil and info_i ~= "") and (" - " .. info_i) or "";
					end)());
				if #estado.danos_log > 60|, "danos");

# medicao do ISS sai
troca(q|		-- (1.12) MEDICAO DO ISS: 1,5s depois do comeco anota contra, invencibilidade e danos
		local im = estado.iss_medida;
		if im ~= nil then
			if im.dano_em == nil and estado.levou_dano_em ~= im.dano_antes then im.dano_em = agora(); end
			if agora() - im.ini > 1.5 then
				estado.iss_medida = nil;
				local r = estado.iss_protecao or { n = 0, com_inv = 0, soma_inv = 0, tipos = {}, danos = {} };
				estado.iss_protecao = r;
				r.n = r.n + 1;
				local inv = n78.invencibilidade or {};
				if inv.desde ~= nil and inv.desde >= im.ini - 0.15 and inv.desde <= im.ini + 0.3 then
					r.com_inv = r.com_inv + 1;
					r.soma_inv = r.soma_inv + ((inv.ate or inv.desde) - inv.desde) * 1000;
					r.tipos[tostring(inv.tipo)] = true;
				end
				local fim = n78.iss_fim_protecao(im.ini);
				if im.dano_em ~= nil then
					r.danos[#r.danos + 1] = string.format("%d ms (protecao ate %d)", math.floor((im.dano_em - im.ini) * 1000 + 0.5),
						math.floor((fim - im.ini) * 1000 + 0.5));
					if #r.danos > 20 then table.remove(r.danos, 1); end
				end
			end
		end
|, "", "medicao iss");
troca(q|				-- (1.12) comeco do ISS (para a protecao e a medicao)|, q|				-- (1.12) comeco do ISS (para a protecao)|, "iss comentario");
troca(q|					estado.iss_inicio = agora();
					estado.iss_medida = { ini = estado.iss_inicio, dano_antes = estado.levou_dano_em, dano_em = nil };
|, q|					estado.iss_inicio = agora();
|, "iss inicio");
troca(q|		-- (1.12) protecao do ISS medida
		local r_iss = estado.iss_protecao; -- (1.15) nome proprio
		if r_iss ~= nil then
			local tipos_iss = {};
			for t in pairs(r_iss.tipos) do tipos_iss[#tipos_iss + 1] = t; end
			linha(string.format("ISS medidos: %d - contra do jogo %s s - com invencibilidade: %d (media %d ms, tipos %s) - danos durante o ISS (ms depois do comeco): %s",
				r_iss.n, tostring((n78.janelas_jogo or {}).contra and n78.janelas_jogo.contra[1] and arredondar(n78.janelas_jogo.contra[1], 2) or "-"), r_iss.com_inv,
				r_iss.com_inv > 0 and math.floor(r_iss.soma_inv / r_iss.com_inv + 0.5) or 0,
				#tipos_iss > 0 and table.concat(tipos_iss, "/") or "-", #r_iss.danos > 0 and table.concat(r_iss.danos, ", ") or "nenhum"));
		else
			linha("ISS medidos: nenhum ainda");
		end
|, "", "relatorio iss");
print $s;
