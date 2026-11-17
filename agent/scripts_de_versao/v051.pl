local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.50 - |, q|	Versao 0.51 - Long Sword: bloqueio dos seus botoes APRENDIDO por animacao (prende menos, solta antes
	o Foresight); sem bloqueio fora do combo (primeiro golpe e esquiva livres); a esquiva fora do combo
	sai no tempo certo; nao mexe mais em monstros que ja sairam do jogo (erro no fim da missao)
	0.50 - |, "cab");
$s =~ s/versao_mod = "0\.50"/versao_mod = "0.51"/ or die "vm";
$s =~ s/== Defesa Automatica v0\.50 ==/== Defesa Automatica v0.51 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.50"\)/imgui.tree_node("Defesa Automatica v0.51")/ or die "tit";

# =====================================================================================
# 1. MONSTROS QUE JA SAIRAM DO JOGO (provavel causa do jogo fechar no fim da missao)
# =====================================================================================
troca(q|		if momento - m.visto_em > 1 then
			monstros[chave] = nil;
		else
			local mx, my, mz = posicao(m.objeto);|, q|		if momento - m.visto_em > 1 then
			monstros[chave] = nil;
		elseif momento - m.visto_em > 0.25 or m.invalido then
			--[[
				(0.51) o jogo parou de atualizar este monstro (morreu, foi capturado ou a missao
				acabou). O mod continuava chamando funcoes no objeto dele por ate 1 segundo: no
				fim das missoes o registro do REFramework mostrou ~100 erros por segundo disso, e
				o jogo fechou 1 segundo depois. Agora nao chama mais nada nele.
			]]
		else
			local mx, my, mz = posicao(m.objeto);
			if mx == nil then m.invalido = true; end -- objeto ja destruido: para na hora|, "monstro_invalido");

# =====================================================================================
# 2. NOMES: o jogo ja escreve "Tempered" no nome (ficava "Tempered Tempered Congalala")
# =====================================================================================
troca(q|		m.nome_completo = prefixo .. tostring(m.nome);|, q|		-- (0.51) o nome do jogo ja vem com "Tempered" / "Arch-tempered": nao repete
		if string.find(string.lower(tostring(m.nome)), "tempered", 1, true) then prefixo = ""; end
		m.nome_completo = prefixo .. tostring(m.nome);|, "nome");
troca(q|	if type(salvo) == "table" and type(salvo.nomes) == "table" then nomes_monstros = salvo.nomes; end|,
q|	if type(salvo) == "table" and type(salvo.nomes) == "table" then nomes_monstros = salvo.nomes; end
	for chave_nome, nome in pairs(nomes_monstros) do -- (0.51) conserta "Tempered Tempered ..."
		nomes_monstros[chave_nome] = string.gsub(string.gsub(tostring(nome), "^Tempered Tempered ", "Tempered "),
			"^Arch%-tempered Arch%-tempered ", "Arch-tempered ");
	end|, "nomes_load");

# =====================================================================================
# 3. LONG SWORD: bloqueio aprendido por animacao
# =====================================================================================
troca(q|local verificacoes_defesa = {};|, q|local verificacoes_defesa = {};

--[[
	(0.51) BLOQUEIO APRENDIDO (Long Sword). No relatorio, os Foresights que falharam eram de
	quando voce estava preso numa animacao de ataque (ex.: 20:201, 20:212, 20:289): o Foresight
	foi apertado mas a sua animacao nao mudou e o golpe acertou. Para cada animacao SUA, o mod
	aprende com quanta antecedencia precisa segurar os seus botoes soltos para o Foresight
	conseguir sair:
	  - Foresight falhou e voce continuou preso na animacao (ou levou o golpe): +150 ms;
	  - Foresight deu certo: -20 ms (volta devagar ao padrao "ls_bloqueio_ms").
	Limite: 950 ms. Fica salvo em aviso_lanca_defesas.json.
]]
local bloqueios_ls = {};

local function aprender_bloqueio(d, deu_certo)
	if d == nil or d.antes == nil or d.antes == "?" then return; end
	local atual = bloqueios_ls[d.antes] or op.ls_bloqueio_ms;
	local preso = d.depois == d.antes or string.sub(tostring(d.depois), 1, 3) == "14:";
	if deu_certo then
		atual = math.max(atual - 20, op.ls_bloqueio_ms);
	elseif preso then
		atual = math.min(atual + 150, 950);
	else
		return;
	end
	bloqueios_ls[d.antes] = atual;
	estado.bloqueio_mudou = true;
end|, "bloqueio_tabela");

troca(q|	if type(salvo) == "table" and type(salvo.golpes) == "table" then
		-- versao 0.24|, q|	if type(salvo) == "table" and type(salvo.bloqueios) == "table" then bloqueios_ls = salvo.bloqueios; end
	if type(salvo) == "table" and type(salvo.golpes) == "table" then
		-- versao 0.24|, "bloqueio_load");

troca(q|	if mudou then json.dump_file("aviso_lanca_defesas.json", { golpes = defesas_aprendidas }); end|,
q|	if mudou or estado.bloqueio_mudou then
		estado.bloqueio_mudou = false;
		json.dump_file("aviso_lanca_defesas.json", { golpes = defesas_aprendidas, bloqueios = bloqueios_ls });
	end|, "bloqueio_save");

troca(q|			estado.ultimo_resultado = "defendeu com " .. NOME_NIVEL[v.defesa] .. " (" .. v.chave .. ")";
			if v.diag ~= nil then v.diag.resultado = "OK (sem dano)"; end|, q|			estado.ultimo_resultado = "defendeu com " .. NOME_NIVEL[v.defesa] .. " (" .. v.chave .. ")";
			if v.diag ~= nil then v.diag.resultado = "OK (sem dano)"; end
			if v.perfil == "espada_longa" and v.defesa == "foresight" then aprender_bloqueio(v.diag, true); end|, "aprende_ok");
troca(q|			if v.diag ~= nil then v.diag.resultado = "LEVOU DANO"; end
			local perfil_v = PERFIS[v.perfil] or PERFIS.lanca;|, q|			if v.diag ~= nil then v.diag.resultado = "LEVOU DANO"; end
			if v.perfil == "espada_longa" and v.defesa == "foresight" then aprender_bloqueio(v.diag, false); end
			local perfil_v = PERFIS[v.perfil] or PERFIS.lanca;|, "aprende_falha");

# decisao: combo conferido na hora da esquiva; bloqueio so dentro do combo, com o tempo aprendido
troca(q|			if perfil == PERFIS.espada_longa and not longe and (p.defesa == "foresight" or p.defesa == "esquiva")
				and falta <= op.ls_bloqueio_ms / 1000 and falta >= -depois then
				estado.bloquear_acoes_ate = math.max(estado.bloquear_acoes_ate or 0, p.tempo + depois);
			end|, q|			--[[
				(0.51) FORA DO COMBO a esquiva era decidida so na hora do Foresight (120 ms antes)
				e saia atrasada (~90 ms antes; no relatorio varias levaram dano). Agora o combo e
				conferido ja na hora da esquiva (150 ms): fora do combo, esquiva no tempo certo.
			]]
			if perfil == PERFIS.espada_longa and p.defesa == "foresight" and not p.combo_conferido and p.janela_ini == nil
				and falta <= math.max(antes.esquiva or 0, antes.foresight or 0) then
				p.combo_conferido = true;
				if not em_combo_espada_longa() then
					p.defesa, p.sem_combo, p.estado_pg = "esquiva", true, {};
					estado.ultima_decisao = "fora do combo -> esquiva";
				end
			end

			-- (0.51) so bloqueia DENTRO do combo (fora dele o seu primeiro golpe e a esquiva
			-- ficam livres) e com o tempo aprendido para a animacao em que voce esta agora
			if perfil == PERFIS.espada_longa and not longe and p.defesa == "foresight" and falta >= -depois then
				local antecedencia_bloqueio = (bloqueios_ls[combo.animacao or "?"] or op.ls_bloqueio_ms) / 1000;
				if falta <= antecedencia_bloqueio and em_combo_espada_longa() then
					estado.bloquear_acoes_ate = math.max(estado.bloquear_acoes_ate or 0, p.tempo + depois);
				end
			end|, "decisao");

# Prints: bloqueio aprendido
troca(q|			op.ls_janela_combo_ms, tostring(combo.animacao), qtd_ataques, #(op.toques.m5 or {}), #(op.toques.m2 or {})));
	end|, q|			op.ls_janela_combo_ms, tostring(combo.animacao), qtd_ataques, #(op.toques.m5 or {}), #(op.toques.m2 or {})));
		local qtd_bloqueios, maior = 0, 0;
		for _, ms in pairs(bloqueios_ls) do
			qtd_bloqueios = qtd_bloqueios + 1;
			if ms > maior then maior = ms; end
		end
		linha(string.format("Long Sword: bloqueio dos seus botoes na animacao atual %d ms - aprendido em %d animacoes (maior %d ms)",
			bloqueios_ls[combo.animacao or "?"] or op.ls_bloqueio_ms, qtd_bloqueios, maior));
	end|, "prints");

print $s;
