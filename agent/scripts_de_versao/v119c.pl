local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }
troca(q|	for _, m_seq in pairs(monstros) do
		for _, o in ipairs(m_seq.previstos or {}) do
			if o ~= p and o.tempo > p.tempo + 0.05 and o.tempo <= p.tempo + 0.9 then|,
q|	for _, m_seq in pairs(monstros) do
		-- acertos que nao chegam em voce (longe, ou no SOS golpe que nunca te acertou) nao contam
		local longe_seq = op.checar_distancia and m_seq.distancia ~= nil;
		for _, o in ipairs(m_seq.previstos or {}) do
			local fora_seq = (longe_seq and (o.dist_max or 0) > 0 and m_seq.distancia > o.dist_max + op.margem_distancia)
				or ((estado.jogadores or 1) > 1 and (o.dist_max or 0) <= 0);
			if o ~= p and not m_seq.invalido and not fora_seq and o.tempo > p.tempo + 0.05 and o.tempo <= p.tempo + 0.9 then|, "filtro");
troca(q|	normais); 3. "SS+ISS trocado por FS" conta uma vez por golpe (antes contava a cada quadro).|,
q|	normais); 3. "SS+ISS trocado por FS" conta uma vez por golpe (antes contava a cada quadro) e ignora acertos
	que nao chegam em voce (outro monstro longe, golpe que nunca te acertou no SOS).|, "cab");
print $s;
