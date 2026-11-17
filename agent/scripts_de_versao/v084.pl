local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.83 - |, q|	Versao 0.84 - diagnostico das falhas: cada defesa anota com quanto tempo de aviso o golpe foi
	previsto e se voce estava preso num golpe seu; o relatorio separa as falhas por causa
	0.83 - |, "cab");
$s =~ s/versao_mod = "0\.83"/versao_mod = "0.84"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.83 ==/== Defesa Automatica v0.84 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.83"\)/imgui.tree_node("Defesa Automatica v0.84")/ or die "tit";

troca(q|					dist_max = dist_max, correcao = correcao };|, q|					dist_max = dist_max, correcao = correcao, criado_em = momento };|, "criado");
troca(q|origem = "geometria", dist_max = 0, geometria = true };|, q|origem = "geometria", dist_max = 0, geometria = true, criado_em = momento };|, "criado_geo");

troca(q|	-- (0.44) relatorio automatico: guarda tambem a arma, o golpe e a hora
	d.arma, d.golpe = estado.chave_perfil, p.chave;|, q|	-- (0.84) com quanto tempo de aviso o golpe foi previsto e se voce estava preso num golpe seu
	if p.criado_em ~= nil then d.aviso_ms = math.floor((p.tempo - p.criado_em) * 1000 + 0.5); end
	d.preso_em_golpe = (op.animacoes_ataque_ls or {})[d.antes] == true;
	d.trava_recente = estado.trava_ativa_em ~= nil and os.clock() - estado.trava_ativa_em < 1.0;

	-- (0.44) relatorio automatico: guarda tambem a arma, o golpe e a hora
	d.arma, d.golpe = estado.chave_perfil, p.chave;|, "diag");

troca(q|	local ct = estado.contatos_em_voce or {};|, q|	-- (0.84) por que as defesas falharam
	do
		local falhas, curto, preso, preso_sem_trava, sem_aviso = 0, 0, 0, 0, 0;
		for _, d in ipairs(estado.defesas_sessao or {}) do
			if d.resultado == "LEVOU DANO" then
				falhas = falhas + 1;
				if d.aviso_ms == nil then sem_aviso = sem_aviso + 1;
				elseif d.aviso_ms < 800 then curto = curto + 1; end
				if d.preso_em_golpe then
					preso = preso + 1;
					if not d.trava_recente then preso_sem_trava = preso_sem_trava + 1; end
				end
			end
		end
		linha(string.format("Falhas (levou dano): %d - previstas com menos de 0,8s de aviso: %d - voce preso num golpe seu: %d (sem trava antes: %d) - sem dado de aviso: %d",
			falhas, curto, preso, preso_sem_trava, sem_aviso));
	end
	local ct = estado.contatos_em_voce or {};|, "prints");

print $s;
