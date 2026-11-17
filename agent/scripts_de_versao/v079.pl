local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.78 - |, q|	Versao 0.79 - aprendizado novo ajustado pelo 1o teste: o contato do golpe que "passou" (o
	jogo testa o contato como acerto e so depois decide que voce esquivou) agora tambem ensina
	quando nenhum outro caminho aprendeu; area de ataque conferida pela MAIORIA das medicoes (antes
	uma medicao fora derrubava a animacao inteira); relatorio mostra os contatos em voce; armas com
	defesa na hora do golpe aparecem certo no Prints
	0.78 - |, "cab");
$s =~ s/versao_mod = "0\.78"/versao_mod = "0.79"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.78 ==/== Defesa Automatica v0.79 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.78"\)/imgui.tree_node("Defesa Automatica v0.79")/ or die "tit";

# ---------------------------------------------------------------- contato: passou tambem ensina
troca(q|local function contato_falhou(info_ptr, acerto_ptr)
	if not op.aprender or not op.aprender_por_contato then return; end|,
q|--[[
	(0.79) 1o teste: em ~30 esquivas so 3 contatos "falharam". O jogo testa o contato como acerto
	("passou") e so DEPOIS decide que voce esquivou - e nesse caso o aviso de acerto que o mod ja
	usava (ao_impacto) nem sempre vem. Agora o contato que passou fica guardado 0,15s: se nenhum
	outro caminho aprendeu aquele golpe, ele ensina.
]]
local contatos_pendentes = {};
local function anotar_contato(chave_contagem)
	estado.contatos_em_voce = estado.contatos_em_voce or {};
	estado.contatos_em_voce[chave_contagem] = (estado.contatos_em_voce[chave_contagem] or 0) + 1;
end

local function contato_falhou(info_ptr, acerto_ptr, passou)
	if not op.aprender or not op.aprender_por_contato then return; end|, "assinatura");

troca(q|	local momento = agora();
	if m.ultimo_aprendizado ~= nil and momento - m.ultimo_aprendizado < 0.6 and momento >= m.ultimo_aprendizado then return; end

	local mais_perto, conhecido = nil, false;|,
q|	local momento = agora();
	-- os quadros seguintes do mesmo contato nao contam
	if m.ultimo_contato ~= nil and momento - m.ultimo_contato < 0.6 and momento >= m.ultimo_contato then return; end
	m.ultimo_contato = momento;
	anotar_contato(passou and "passou" or "falhou");
	if invencibilidade.desde ~= nil and momento >= invencibilidade.desde and momento <= (invencibilidade.ate or 0) + 0.05 then
		anotar_contato("na invencibilidade");
		anotar_invencibilidade(momento);
	end
	if m.ultimo_aprendizado ~= nil and math.abs(momento - m.ultimo_aprendizado) < 0.6 then return; end
	if passou then
		contatos_pendentes[#contatos_pendentes + 1] = { m = m, em = momento, guarda = guarda };
		return;
	end

	local mais_perto, conhecido = nil, false;|, "contato_meio");

troca(q|	anotar_invencibilidade(momento);
	aprender_golpe_em(m, momento, guarda, "aprendidos_contato");
end|, q|	aprender_golpe_em(m, momento, guarda, "aprendidos_contato");
end|, "contato_fim");

troca(q|		if not passou then pcall(contato_falhou, info_ptr, acerto_ptr); end|,
q|		pcall(contato_falhou, info_ptr, acerto_ptr, passou); -- (0.79) passou tambem|, "gancho");

# processa os contatos que passaram (dentro de processar_ativacoes)
troca(q|	golpes_pendentes = restantes;
|, q|	golpes_pendentes = restantes;

	-- (0.79) contatos que passaram: ensinam se nenhum outro caminho aprendeu o golpe
	local contatos_restantes = {};
	for _, c in ipairs(contatos_pendentes) do
		if momento < c.em + 0.15 then
			contatos_restantes[#contatos_restantes + 1] = c;
		elseif op.aprender and not c.m.invalido and not (c.m.ultimo_aprendizado ~= nil
			and math.abs(c.m.ultimo_aprendizado - c.em) < 0.35) then
			local mais_perto, conhecido = nil, false;
			for _, p in ipairs(c.m.previstos or {}) do
				local erro = math.abs(c.em - p.tempo);
				if mais_perto == nil or erro < mais_perto then mais_perto = erro; end
				if (p.vezes or 0) >= 5 then conhecido = true; end
			end
			if mais_perto ~= nil and mais_perto > 0.3 and conhecido then
				estado.contatos_descartados = (estado.contatos_descartados or 0) + 1;
			else
				aprender_golpe_em(c.m, c.em, c.guarda, "aprendidos_contato");
			end
		end
	end
	contatos_pendentes = contatos_restantes;
|, "pend_contato");

# ---------------------------------------------------------------- area confiavel pela maioria
troca(q|local function area_confiavel(reg)
	local d = reg and reg.d;
	if d == nil or #d < 4 then return nil; end
	local menor, maior = math.huge, -math.huge;
	local copia = {};
	for _, v in ipairs(d) do
		if v < menor then menor = v; end
		if v > maior then maior = v; end
		copia[#copia + 1] = v;
	end
	if maior - menor > 0.08 then return nil; end
	table.sort(copia);
	return copia[math.floor((#copia + 1) / 2)];
end|, q|--[[
	(0.79) 1o teste: 34 animacoes com area vista e so 1 confiavel. Nas animacoes com varios golpes
	uma medicao cai no golpe vizinho (ex.: 2:23 do Chatacabra: 0,03 0,03 0,03 0,115 0,025...). Agora
	vale a MAIORIA: 5 medicoes ou mais e pelo menos 2 de cada 3 a no maximo 0,04s da mediana; o
	tempo usado e a media dessas.
]]
local function area_confiavel(reg)
	local d = reg and reg.d;
	if d == nil or #d < 5 then return nil; end
	local copia = {};
	for _, v in ipairs(d) do copia[#copia + 1] = v; end
	table.sort(copia);
	local mediana = copia[math.floor((#copia + 1) / 2)];
	local perto, soma = 0, 0;
	for _, v in ipairs(d) do
		if math.abs(v - mediana) <= 0.04 then perto, soma = perto + 1, soma + v; end
	end
	if perto * 3 < #d * 2 then return nil; end
	return soma / perto;
end|, "confiavel");

# so ensina perto de um golpe ja conhecido desta animacao (precisao)
troca(q|					local d = area_confiavel(reg);
					if d ~= nil and not agendado then|,
q|					local d = area_confiavel(reg);
					local perto_de_golpe = false;
					if d ~= nil then
						for _, g in ipairs(grupos_de(m.variante, h.chave) or {}) do
							if g.vezes >= 3 and math.abs(g.tempo - (ofs + d)) <= 0.15 then perto_de_golpe = true; end
						end
					end
					if d ~= nil and not agendado and perto_de_golpe then|, "agenda");

# ---------------------------------------------------------------- relatorio
troca(q|	linha("Invencibilidade: " .. (#inv_txt > 0|,
q|	local ct = estado.contatos_em_voce or {};
	linha(string.format("Contatos de golpes em voce: %d passaram, %d falharam, %d na sua invencibilidade",
		ct.passou or 0, ct.falhou or 0, ct["na invencibilidade"] or 0));
	linha("Invencibilidade: " .. (#inv_txt > 0|, "prints");

# ---------------------------------------------------------------- arma so com defesa na hora
troca(q|	if perfil == nil then return false, "arma sem perfil ainda (" .. tostring(classe) .. ")"; end|,
q|	if perfil == nil then
		-- (0.79) armas so com a defesa na hora do golpe
		local ok_t, tipo = pcall(function() return cacador:call("get_WeaponType"); end);
		local def = ok_t and n78.ARMAS and n78.ARMAS[tonumber(tipo) or -1] or nil;
		if def ~= nil then return false, "so defesa na hora do golpe (" .. def.nome .. ")"; end
		return false, "arma sem perfil ainda (" .. tostring(classe) .. ")";
	end|, "perfil");

print $s;
