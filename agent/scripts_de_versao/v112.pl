local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 1.11 - |, q|	Versao 1.12 - LONG SWORD: o ISS so fica intocavel enquanto protege voce. A protecao = o contra do ISS
	(valor do jogo, ~0,3s) ou a invencibilidade que o jogo der junto (a maior), + 0,05s. Depois disso o FS e a
	esquiva podem ser forcados por cima do resto da animacao do ISS. A postura do SS continua intocavel.
	O relatorio mede cada ISS: contra, invencibilidade (tipo e duracao) e em que ms os danos chegaram.
	1.11 - |, "cab");
$s =~ s/versao_mod = "1\.11"/versao_mod = "1.12"/g or die "vm";
$s =~ s/== Defesa Automatica v1\.11 ==/== Defesa Automatica v1.12 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v1\.11"\)/imgui.tree_node("Defesa Automatica v1.12")/ or die "tit";

# funcoes: protecao do ISS
troca(q|n78.janelas_jogo = janelas_jogo;|, q|n78.janelas_jogo = janelas_jogo;
-- (1.12) PROTECAO DO ISS: fim = inicio + a maior entre o contra do ISS (jogo) e a invencibilidade que
-- comecou junto com ele, + 0,05s de margem
n78.iss_fim_protecao = function(ini)
	local contra = tonumber(janelas_jogo.contra[1]) or 0.3;
	local fim = ini + contra;
	local inv = invencibilidade;
	if inv.desde ~= nil and inv.ate ~= nil and inv.desde >= ini - 0.15 and inv.desde <= ini + 0.3 and inv.ate > fim then
		fim = inv.ate;
	end
	return fim + 0.05;
end;
-- o ISS esta na tela e a protecao dele ja acabou? (FS / esquiva liberados)
n78.iss_liberado = function()
	local a = estado.acao_nome_ultimo or "";
	if string.sub(a, 1, 4) ~= "cIai" or string.find(a, "Slash", 1, true) == nil then return false; end
	if estado.iss_inicio == nil then return false; end
	return agora() >= n78.iss_fim_protecao(estado.iss_inicio);
end;|, "funcoes");

# inicio do ISS + medicao
troca(q|				estado.acao_nome_ultimo = nome;|, q|				-- (1.12) comeco do ISS (para a protecao e a medicao)
				if wt_v == "3" and string.sub(nome, 1, 4) == "cIai" and string.find(nome, "Slash", 1, true) ~= nil
					and not (string.sub(tostring(estado.acao_nome_ultimo), 1, 4) == "cIai" and string.find(tostring(estado.acao_nome_ultimo), "Slash", 1, true)) then
					estado.iss_inicio = agora();
					estado.iss_medida = { ini = estado.iss_inicio, dano_antes = estado.levou_dano_em, dano_em = nil };
				end
				estado.acao_nome_ultimo = nome;|, "inicio");
troca(q|		-- (1.08) MEDICAO: cada FS (seu ou do mod)|, q|		-- (1.12) MEDICAO DO ISS: 1,5s depois do comeco anota contra, invencibilidade e danos
		local im = estado.iss_medida;
		if im ~= nil then
			if im.dano_em == nil and estado.levou_dano_em ~= im.dano_antes then im.dano_em = agora(); end
			if agora() - im.ini > 1.5 then
				estado.iss_medida = nil;
				local r = estado.iss_medidas or { n = 0, com_inv = 0, soma_inv = 0, tipos = {}, danos = {} };
				estado.iss_medidas = r;
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
		-- (1.08) MEDICAO: cada FS (seu ou do mod)|, "medida");

# liberar depois da protecao
troca(q|			if n78.ls_em_iai() then
				estado.ultima_decisao = "SS+ISS na tela: nada por cima ate acabar";
				return true; -- (1.03) prioridade 0: nem SS novo, nem FS, nem esquiva
			end|, q|			if n78.ls_em_iai() then
				-- (1.12) depois da protecao do ISS: FS / esquiva livres (o SS novo continua esperando)
				if n78.iss_liberado() then
					estado.ultima_decisao = "ISS sem protecao: FS / esquiva liberados";
					return false;
				end
				estado.ultima_decisao = "SS+ISS na tela: nada por cima ate acabar";
				return true; -- (1.03) nem SS novo, nem FS, nem esquiva
			end|, "controle");
troca(q|		if os.clock() - ssiss.iss_em < 0.6 then return true; end|,
	q|		if os.clock() - ssiss.iss_em < 0.6 then return not n78.iss_liberado(); end -- (1.12)|, "fase_iss");
troca(q|		if ANIM_ISS[combo.animacao or "?"] or n78.ls_em_iai() then|,
	q|		if (ANIM_ISS[combo.animacao or "?"] or n78.ls_em_iai()) and not n78.iss_liberado() then -- (1.12)|, "chamador");
troca(q|local forcavel = n78.acao_de("fs") ~= nil and motivo ~= "sem barra de espirito" and motivo ~= "postura / ISS";|,
	q|local forcavel = n78.acao_de("fs") ~= nil and motivo ~= "sem barra de espirito" and (motivo ~= "postura / ISS" or n78.iss_liberado());|, "fs");

# relatorio
troca(q|		linha("Todos os danos levados (novo primeiro): " .. #(estado.danos_log or {}));|,
q|		-- (1.12) protecao do ISS medida
		local r_iss = estado.iss_medidas;
		if r_iss ~= nil then
			local tipos_iss = {};
			for t in pairs(r_iss.tipos) do tipos_iss[#tipos_iss + 1] = t; end
			linha(string.format("ISS medidos: %d - contra do jogo %s s - com invencibilidade: %d (media %d ms, tipos %s) - danos durante o ISS (ms depois do comeco): %s",
				r_iss.n, tostring((n78.janelas_jogo or {}).contra and n78.janelas_jogo.contra[1] or "-"), r_iss.com_inv,
				r_iss.com_inv > 0 and math.floor(r_iss.soma_inv / r_iss.com_inv + 0.5) or 0,
				#tipos_iss > 0 and table.concat(tipos_iss, "/") or "-", #r_iss.danos > 0 and table.concat(r_iss.danos, ", ") or "nenhum"));
		else
			linha("ISS medidos: nenhum ainda");
		end
		linha("Todos os danos levados (novo primeiro): " .. #(estado.danos_log or {}));|, "relatorio");
print $s;
