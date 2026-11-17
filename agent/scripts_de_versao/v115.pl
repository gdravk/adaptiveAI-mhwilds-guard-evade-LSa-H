local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }
sub troca_todos { my ($velho, $novo, $nome) = @_; my $n = 0; while ((my $i = index($s, $velho)) >= 0) { substr($s, $i, length($velho)) = $novo; $n++; } die "$nome nao achado" if $n == 0; return $n; }

troca(q|	Versao 1.14 - |, q|	Versao 1.15 - (luta 1.14 contra a Lagiacrus) A medicao do ISS (1.12) usava um nome que o mod ja usava
	para outra coisa (estado.iss_medidas): o relatorio parava no meio e perdia as ultimas linhas. Agora e
	estado.iss_protecao. SS+ISS POR GOLPE: dano na postura ou no ISS conta contra o golpe; golpe com 2+
	danos e menos de 2 acertos do ISS para cada dano sai do SS+ISS (vai para FS / esquiva).
	1.14 - |, "cab");
$s =~ s/versao_mod = "1\.14"/versao_mod = "1.15"/g or die "vm";
$s =~ s/== Defesa Automatica v1\.14 ==/== Defesa Automatica v1.15 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v1\.14"\)/imgui.tree_node("Defesa Automatica v1.15")/ or die "tit";

# nome sem colisao (so os usos da 1.12)
troca(q|				local r = estado.iss_medidas or { n = 0, com_inv = 0, soma_inv = 0, tipos = {}, danos = {} };
				estado.iss_medidas = r;|, q|				local r = estado.iss_protecao or { n = 0, com_inv = 0, soma_inv = 0, tipos = {}, danos = {} };
				estado.iss_protecao = r;|, "colisao1");
troca(q|		local r_iss = estado.iss_medidas;|, q|		local r_iss = estado.iss_protecao; -- (1.15) nome proprio|, "colisao2");

# dano conta contra o golpe no SS+ISS
troca(q|local function golpe_bom_para_ss(chave)
	local s = ss_sem_golpe[chave];
	return s == nil or s.sem < 2 or s.sem <= s.ok * 2;
end|, q|local function golpe_bom_para_ss(chave)
	local s = ss_sem_golpe[chave];
	if s == nil then return true; end
	-- (1.15) golpe que acerta voce na postura / no ISS (chega fora da hora prevista): FS / esquiva
	if (s.dano or 0) >= 2 and (s.dano or 0) * 2 > (s.ok or 0) then return false; end
	return s.sem < 2 or s.sem <= s.ok * 2;
end
-- (1.15) dano na postura ou no ISS deste golpe
n78.anotar_dano_ss = function(chave)
	if chave == nil then return; end
	local s = ss_sem_golpe[chave] or { sem = 0, ok = 0 };
	s.dano = (s.dano or 0) + 1;
	ss_sem_golpe[chave] = s;
	estado.bloqueio_mudou = true;
end|, "bom");
troca(q|			terminar_ss_iss((levou and "LEVOU DANO na postura")|, q|			if levou and not ssiss.manual then n78.anotar_dano_ss(ssiss.chave); end -- (1.15)
			terminar_ss_iss((levou and "LEVOU DANO na postura")|, "postura");
troca(q|		elseif estado.levou_dano_em ~= ssiss.dano_antes then resultado = "LEVOU DANO";|,
	q|		elseif estado.levou_dano_em ~= ssiss.dano_antes then resultado = "LEVOU DANO";
			if not ssiss.manual then n78.anotar_dano_ss(ssiss.chave); end -- (1.15)|, "iss");
print $s;
