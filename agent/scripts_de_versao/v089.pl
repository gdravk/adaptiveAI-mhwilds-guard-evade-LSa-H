local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.88 - |, q|	Versao 0.89 - FORCAR (pedido seu): o FS, o SS, o ISS e a esquiva sao pedidos direto ao jogo na hora
	da defesa, mesmo no meio de um golpe seu, em qualquer modo (normal / foco) e tambem no multiplayer.
	Nada e anulado nem ganha invencibilidade. Os numeros das acoes que faltavam (SS, esquiva de cada arma)
	o mod aprende sozinho vendo as SUAS acoes (pelo nome que o jogo da: cIaiWpOff, cDodge...) e confere
	se cada acao forcada saiu. Com o FS e o SS forcados, a trava longa dos seus ataques e o M2 automatico
	nao sao mais necessarios (so a trava curta na hora da defesa continua)
	0.88 - |, "cab");
$s =~ s/versao_mod = "0\.88"/versao_mod = "0.89"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.88 ==/== Defesa Automatica v0.89 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.88"\)/imgui.tree_node("Defesa Automatica v0.89")/ or die "tit";

troca(q|	ls_acao_direta = true,|, q|	acoes_aprendidas = {}, -- (0.89) [tipo de arma][acao] = { cat, idx } aprendidos das suas acoes
	ls_acao_direta = true,|, "op");

troca(q|n78.nivel_aura = function()|, q|-- (0.89) FORCAR: numero da acao (aprendido das suas acoes; FS da LS e esquiva padrao conhecidos)
local function tipo_arma()
	local t = nil;
	pcall(function() t = meu_cacador():call("get_WeaponType"); end);
	return tonumber(t);
end
n78.tipo_arma = tipo_arma;
n78.acao_de = function(tipo)
	local wt = tipo_arma();
	if wt == nil then return nil; end
	local por = (op.acoes_aprendidas or {})[tostring(wt)] or {};
	local a = por[tipo];
	if a ~= nil and a.cat ~= nil and not a.ruim then return a.cat, a.idx, false; end
	if tipo == "fs" and wt == 3 then return 2, 16, true; end
	if tipo == "esquiva" and not por.esquiva_padrao_ruim then return 1, 19, true; end
	return nil;
end;
n78.forcar = function(tipo, nome)
	local cat, idx, padrao = n78.acao_de(tipo);
	if cat == nil then return false; end
	local ok = n78.acao_direta(cat, idx, nome or tipo);
	if ok then estado.forcado_pendente = { tipo = tipo, em = os.clock(), wt = tipo_arma(), padrao = padrao }; end
	return ok;
end;
n78.nivel_aura = function()|, "forcar");

troca(q|		if banco ~= nil and id ~= nil and nome ~= nil and cacador:call("get_WeaponType") == 3 then
			estado.nomes_golpes[tostring(banco) .. ":" .. tostring(id)] = nome;
			if not tabela_ls_salva then pcall(salvar_tabela_ls); end
		end|, q|		if banco ~= nil and id ~= nil and nome ~= nil and cacador:call("get_WeaponType") == 3 then
			estado.nomes_golpes[tostring(banco) .. ":" .. tostring(id)] = nome;
			if not tabela_ls_salva then pcall(salvar_tabela_ls); end
		end
		-- (0.89) numero de cada acao pelo nome do jogo + conferencia das acoes forcadas
		if cat ~= nil and idx ~= nil and type(nome) == "string" then
			local tipo = nil;
			if string.sub(nome, 1, 6) == "cDodge" then tipo = "esquiva";
			elseif nome == "cIaiWpOff" then tipo = "ss";
			elseif nome == "cMikiriSlash" then tipo = "fs"; end
			local fp = estado.forcado_pendente;
			if fp ~= nil then
				estado.forcados = estado.forcados or {};
				local r = estado.forcados[fp.tipo] or { ok = 0, falha = 0 };
				estado.forcados[fp.tipo] = r;
				if tipo == fp.tipo then
					r.ok = r.ok + 1;
					estado.forcado_pendente = nil;
				elseif os.clock() - fp.em > 0.3 then
					r.falha = r.falha + 1;
					estado.forcado_pendente = nil;
					-- a esquiva padrao (1, 19) nao serviu 3 vezes nesta arma: volta para os botoes
					if fp.padrao and fp.tipo == "esquiva" and r.ok == 0 and r.falha >= 3 and fp.wt ~= nil then
						op.acoes_aprendidas[tostring(fp.wt)] = op.acoes_aprendidas[tostring(fp.wt)] or {};
						op.acoes_aprendidas[tostring(fp.wt)].esquiva_padrao_ruim = true;
						salvar_opcoes();
					end
				end
			end
			if tipo ~= nil then
				local wt = tostring(cacador:call("get_WeaponType"));
				op.acoes_aprendidas = op.acoes_aprendidas or {};
				op.acoes_aprendidas[wt] = op.acoes_aprendidas[wt] or {};
				local atual = op.acoes_aprendidas[wt][tipo];
				local melhor = atual == nil or (tipo == "esquiva" and string.find(nome, "Front", 1, true) ~= nil
					and not string.find(tostring(atual.nome), "Front", 1, true));
				if melhor and not (atual ~= nil and atual.cat == cat and atual.idx == idx) then
					op.acoes_aprendidas[wt][tipo] = { cat = cat, idx = idx, nome = nome };
					salvar_opcoes();
				end
			end
		end|, "aprende");

troca(q|	if vai_esquivar then
		teclas_agora = {};
		if not comecar_toque(true, perfil.toque_esquiva) and toque.quadro == nil then marcar("esquiva"); end
	end|, q|	if vai_esquivar then
		teclas_agora = {};
		-- (0.89) FORCAR a esquiva (uma vez a cada 0,5s); sem o numero da acao, botoes como antes
		if os.clock() - (estado.esquiva_forcada_em or -100) > 0.5 and n78.forcar("esquiva", "esquiva") then
			estado.esquiva_forcada_em = os.clock();
		end
		if os.clock() - (estado.esquiva_forcada_em or -100) > 0.5 then
			if not comecar_toque(true, perfil.toque_esquiva) and toque.quadro == nil then marcar("esquiva"); end
		end
	end|, "esquiva");

troca(q|			if desde >= 0.1 then return "indisponivel", "sem tempo"; end
			if not em_combo_espada_longa() then return "indisponivel", "fora do combo"; end|,
q|			if desde >= 0.1 then return "indisponivel", "sem tempo"; end
			-- (0.89) forcado, o FS sai fora do combo tambem
			if n78.acao_de("fs") == nil and not em_combo_espada_longa() then return "indisponivel", "fora do combo"; end|, "fs_combo");
troca(q|			if op.ls_acao_direta and n78.fs_vai_sair ~= nil and n78.fs_vai_sair(0) == true
				and n78.acao_direta(2, 16, "FS") then|, q|			if n78.forcar("fs", "FS") then -- (0.89) forcado|, "fs_direto");
troca(q|							if vai == false then
								p.defesa, p.sem_combo = "esquiva", true;|, q|							-- (0.89) forcado: so a falta de barra (ou estar na postura / ISS) troca o FS
							local forcavel = n78.acao_de("fs") ~= nil and motivo ~= "sem barra de espirito" and motivo ~= "postura / ISS";
							if vai == false and not forcavel then
								p.defesa, p.sem_combo = "esquiva", true;|, "fs_decisao");
troca(q|				elseif not em_combo_espada_longa(somente and "ss" or "fs") then
					p.defesa, p.sem_combo, p.estado_pg = "esquiva", true, {};|, q|				elseif not em_combo_espada_longa(somente and "ss" or "fs") and n78.acao_de("fs") == nil then
					p.defesa, p.sem_combo, p.estado_pg = "esquiva", true, {};|, "fs_fora");

troca(q|			if p.tempo - momento <= op.ls_iss_ms / 1000 and pronto ~= false then|,
q|			if p.tempo - momento <= op.ls_iss_ms / 1000 then -- (0.89) forcado: nao espera o jogo aceitar|, "iss_espera");
troca(q|				if op.ls_acao_direta and pronto == true and aura ~= nil and n78.acao_direta(2, 25 + aura, "ISS") then|,
q|				if aura ~= nil and n78.acao_direta(2, 25 + aura, "ISS") then -- (0.89) forcado|, "iss");

troca(q|			local falta = p.tempo - momento;
			-- (0.59) o golpe precisa vir depois do seu ataque acabar (atraso aprendido) + bainha + ISS
			local pode, info = ss_permitido(anim);
			-- (0.65) o SS sai quando o seu golpe atual soltar: o que falta dele (medido) + bainha + ISS
			local atraso = resto_do_golpe_atual();|, q|			local falta = p.tempo - momento;
			-- (0.89) SS forcado: sai de qualquer animacao (nao precisa do combo, do M2 nem do fim do seu golpe)
			local ss_forca = n78.acao_de("ss") ~= nil;
			-- (0.59) o golpe precisa vir depois do seu ataque acabar (atraso aprendido) + bainha + ISS
			local pode, info = ss_permitido(anim);
			-- (0.65) o SS sai quando o seu golpe atual soltar: o que falta dele (medido) + bainha + ISS
			local atraso = ss_forca and 0 or resto_do_golpe_atual();|, "ss_falta");
troca(q|			if not em_combo_espada_longa("ss") or sem_golpe_agora then|, q|			if not ss_forca and (not em_combo_espada_longa("ss") or sem_golpe_agora) then|, "ss_m2");
troca(q|			if not pode then return false; end|, q|			if not pode and not ss_forca then return false; end|, "ss_pode");
troca(q|			ssiss.quadro = ssiss.quadro + 1;
			-- (0.59) o aperto (com buffer) dura ~0,6s; se o seu golpe ainda segura o personagem,|, q|			-- (0.89) SS forcado: um pedido so, depois espera a bainha
			if not ssiss.forcado and n78.forcar("ss", "SS") then ssiss.forcado = true; end
			if ssiss.forcado then return true; end
			ssiss.quadro = ssiss.quadro + 1;
			-- (0.59) o aperto (com buffer) dura ~0,6s; se o seu golpe ainda segura o personagem,|, "ss_fase");

troca(q|local function travar_por_golpe(momento, chave_perfil)
	estado.trava_golpe = nil;|, q|local function travar_por_golpe(momento, chave_perfil)
	estado.trava_golpe = nil;
	-- (0.89) FS e SS forcados: os seus ataques nao precisam mais ser travados antes do golpe
	if n78.acao_de("fs") ~= nil and n78.acao_de("ss") ~= nil then return; end|, "trava");

troca(q|	do
		local ad = {};|, q|	do
		local fz, ap = {}, {};
		for tipo, r in pairs(estado.forcados or {}) do fz[#fz + 1] = string.format("%s %d saiu / %d nao", tipo, r.ok, r.falha); end
		for wt, por in pairs(op.acoes_aprendidas or {}) do
			for tipo, a in pairs(por) do
				if type(a) == "table" then ap[#ap + 1] = string.format("arma %s %s=(%s,%s)", wt, tipo, tostring(a.cat), tostring(a.idx)); end
			end
		end
		linha("Forcados: " .. (#fz > 0 and table.concat(fz, ", ") or "nenhum") .. " - acoes aprendidas: " .. (#ap > 0 and table.concat(ap, ", ") or "nenhuma ainda"));
	end
	do
		local ad = {};|, "prints");

print $s;
