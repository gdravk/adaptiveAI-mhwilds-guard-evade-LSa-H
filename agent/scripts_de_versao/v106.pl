local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 1.05 - |, q|	Versao 1.06 - RELATORIO: lista de TODOS os danos levados (hora, vida, sua animacao, se o mod estava
	parado e por que, ultima decisao) para achar onde voce morreu; stamina lida na hora de cada FS / esquiva
	forcados (conta quantos sairam com a stamina zerada). Numeracao: SS+ISS 1, FS 2, esquiva 3 (0 = M4).
	1.05 - |, "cab");
$s =~ s/versao_mod = "1\.05"/versao_mod = "1.06"/g or die "vm";
$s =~ s/== Defesa Automatica v1\.05 ==/== Defesa Automatica v1.06 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v1\.05"\)/imgui.tree_node("Defesa Automatica v1.06")/ or die "tit";
troca(q|"SS+ISS (prioridade 0, FS 1, esquiva 2): %s|, q|"SS+ISS (prioridade 1, FS 2, esquiva 3): %s|, "rotulo");

# stamina
troca(q|n78.forcar = function(tipo, nome)|, q|-- (1.06) stamina do cacador (nil se nao der para ler)
n78.stamina = function()
	local valor = nil;
	pcall(function() valor = meu_cacador():call("get_HunterStamina"):call("get_Stamina"); end);
	return tonumber(valor);
end;
n78.forcar = function(tipo, nome)|, "stamina");
troca(q|	if ok then estado.forcado_pendente = { tipo = tipo, em = os.clock(), wt = tipo_arma(), padrao = padrao }; end|,
q|	if ok then
		local st = n78.stamina();
		estado.forcado_pendente = { tipo = tipo, em = os.clock(), wt = tipo_arma(), padrao = padrao,
			sem_stamina = st ~= nil and st <= 1 }; -- (1.06)
	end|, "pendente");
troca(q|				if tipo == fp.tipo or confere_sa then
					r.ok = r.ok + 1;|, q|				-- (1.06) forcados com a stamina zerada
				if fp.sem_stamina then
					estado.sem_stamina = estado.sem_stamina or {};
					local z = estado.sem_stamina[fp.tipo] or { ok = 0, falha = 0 };
					estado.sem_stamina[fp.tipo] = z;
					if tipo == fp.tipo or confere_sa then z.ok = z.ok + 1;
					elseif os.clock() - fp.em > 0.3 then z.falha = z.falha + 1; end
				end
				if tipo == fp.tipo or confere_sa then
					r.ok = r.ok + 1;|, "conta_st");

# registro de todos os danos
troca(q|			if estado.vida_anterior ~= nil and vida < estado.vida_anterior - 0.5 then
				estado.levou_dano_em = os.clock();|, q|			if estado.vida_anterior ~= nil and vida < estado.vida_anterior - 0.5 then
				estado.levou_dano_em = os.clock();
				-- (1.06) todos os danos, para achar onde voce morreu
				estado.danos_log = estado.danos_log or {};
				table.insert(estado.danos_log, 1, string.format("%s - vida %.0f -> %.0f - sacada %s - sua animacao %s - mod: %s - ultima decisao: %s",
					os.date("%H:%M:%S"), estado.vida_anterior, vida, tostring(cacador:call("get_IsWeaponOn") == true),
					tostring(combo.animacao), (estado.motivo_parado ~= nil and estado.motivo_parado ~= "") and ("parado (" .. estado.motivo_parado .. ")") or "agindo",
					tostring(estado.ultima_decisao)));
				if #estado.danos_log > 60 then table.remove(estado.danos_log); end|, "danos");

troca(q|		linha("Forcados: " .. (#fz > 0 and table.concat(fz, ", ") or "nenhum") .. " - acoes aprendidas: " .. (#ap > 0 and table.concat(ap, ", ") or "nenhuma ainda"));|,
q|		linha("Forcados: " .. (#fz > 0 and table.concat(fz, ", ") or "nenhum") .. " - acoes aprendidas: " .. (#ap > 0 and table.concat(ap, ", ") or "nenhuma ainda"));
		-- (1.06) stamina zerada e todos os danos
		local zs = {};
		for t, z in pairs(estado.sem_stamina or {}) do zs[#zs + 1] = t .. " " .. z.ok .. " saiu / " .. z.falha .. " nao"; end
		linha("Forcados com a stamina zerada: " .. (#zs > 0 and table.concat(zs, ", ") or "nenhum"));
		linha("Todos os danos levados (novo primeiro): " .. #(estado.danos_log or {}));
		for _, d in ipairs(estado.danos_log or {}) do linha("   " .. d); end|, "linha");
print $s;
