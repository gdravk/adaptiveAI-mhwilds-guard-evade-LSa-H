local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 1.04 - |, q|	Versao 1.05 - LONG SWORD (2a luta contra a Lagiacrus): o SS nao comeca nos primeiros 0,75s de um FS
	(cortava a invencibilidade do FS e o golpe acertava); o tempo do ISS aprende por golpe: ISS que levou
	dano logo depois de sair fica mais cedo naquele golpe (ate 240 ms).
	1.04 - |, "cab");
$s =~ s/versao_mod = "1\.04"/versao_mod = "1.05"/g or die "vm";
$s =~ s/== Defesa Automatica v1\.04 ==/== Defesa Automatica v1.05 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v1\.04"\)/imgui.tree_node("Defesa Automatica v1.05")/ or die "tit";
troca(q|"SS+ISS (prioridade 1, FS 2, esquiva 3): %s|, q|"SS+ISS (prioridade 0, FS 1, esquiva 2): %s|, "rotulo");

# SS nao corta o FS
troca(q|				or (string.sub(atual_ss, 1, 6) == "cDodge" and string.find(atual_ss, "To", 7, true) == nil) then|,
q|				or (string.sub(atual_ss, 1, 6) == "cDodge" and string.find(atual_ss, "To", 7, true) == nil)
				or (ANIM_FS[anim] and os.clock() - (combo.animacao_em or -100) < 0.75) then -- (1.05) nao corta o FS|, "fs");

# ISS por golpe
troca(q|			if p.tempo - momento <= op.ls_iss_ms / 1000 then -- (0.89) forcado: nao espera o jogo aceitar|,
q|			-- (1.05) ajuste do ISS aprendido para este golpe
			local chave_iss = chave_do_golpe(estado.chave_perfil, m, p);
			local ajuste_iss = (op.iss_ajuste_golpe or {})[chave_iss] or 0;
			if p.tempo - momento <= (op.ls_iss_ms + ajuste_iss) / 1000 then -- (0.89) forcado: nao espera o jogo aceitar
				ssiss.chave_iss = chave_iss;|, "iss_tempo");
troca(q|		if not ssiss.manual and resultado == "OK (contra-ataque do ISS)" then anotar_sem_golpe(ssiss.chave, true); end|,
q|		if not ssiss.manual and resultado == "OK (contra-ataque do ISS)" then anotar_sem_golpe(ssiss.chave, true); end
		-- (1.05) dano logo depois do ISS (antes do contra valer): neste golpe o ISS sai mais cedo
		if ssiss.chave_iss ~= nil then
			op.iss_ajuste_golpe = op.iss_ajuste_golpe or {};
			local atual_aj = op.iss_ajuste_golpe[ssiss.chave_iss] or 0;
			if resultado == "LEVOU DANO" and (estado.levou_dano_em or 0) - ssiss.iss_em < 0.2 then
				op.iss_ajuste_golpe[ssiss.chave_iss] = math.min(atual_aj + 60, 240);
				salvar_opcoes();
			elseif resultado == "ISS saiu, sem contra-ataque" and atual_aj > 0 then
				op.iss_ajuste_golpe[ssiss.chave_iss] = math.max(atual_aj - 30, 0);
				salvar_opcoes();
			end
		end|, "iss_aprende");
print $s;
