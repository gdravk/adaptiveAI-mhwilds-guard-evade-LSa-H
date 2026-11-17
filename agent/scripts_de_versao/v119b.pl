local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }
# junta as duas checagens num lugar so (usado tambem pelo M2 automatico)
troca(q|			-- (1.19) SOS: monstro de costas para voce -> o golpe e em outro jogador; sem SS+ISS
			if (estado.jogadores or 1) > 1 and m ~= nil and m.virado ~= nil and m.virado > 100 then
				if not p.ss_sos_contado then p.ss_sos_contado = true; estado.ss_sos_costas = (estado.ss_sos_costas or 0) + 1; end
				return false;
			end
			-- (1.18) outro acerto previsto ate 0,9s depois: o ISS (so 0,3s de contra) nao cobre -> FS
			for _, m_seq in pairs(monstros) do
				for _, o in ipairs(m_seq.previstos or {}) do
					if o ~= p and o.tempo > p.tempo + 0.05 and o.tempo <= p.tempo + 0.9 then
						if not p.ss_trocado then p.ss_trocado = true; estado.ss_trocado_por_fs = (estado.ss_trocado_por_fs or 0) + 1; end -- (1.19)
						return false;
					end
				end
			end|, q|			if n78.ss_vetado(p, m) then return false; end -- (1.18 / 1.19)|, "inline");
troca(q|				if not golpe_bom_para_ss(chave_m2) then return false; end|,
	q|				if not golpe_bom_para_ss(chave_m2) then return false; end
				if n78.ss_vetado(p, m) then return false; end -- (1.19) o SS nao viria: nao aperta o M2 a toa|, "m2");
troca(q|-- devolve true enquanto o SS+ISS esta no comando (o FS / esquiva nao agem neste quadro)|,
q|-- (1.18 / 1.19) golpes em que o SS+ISS nao serve:
--   - SOS: monstro de costas para voce (mais de 100 graus) -> o golpe e em outro jogador;
--   - outro acerto previsto ate 0,9s depois: o ISS (so 0,3s de contra) nao cobre -> FS.
n78.ss_vetado = function(p, m)
	if (estado.jogadores or 1) > 1 and m ~= nil and m.virado ~= nil and m.virado > 100 then
		if not p.ss_sos_contado then p.ss_sos_contado = true; estado.ss_sos_costas = (estado.ss_sos_costas or 0) + 1; end
		return true;
	end
	for _, m_seq in pairs(monstros) do
		for _, o in ipairs(m_seq.previstos or {}) do
			if o ~= p and o.tempo > p.tempo + 0.05 and o.tempo <= p.tempo + 0.9 then
				if not p.ss_trocado then p.ss_trocado = true; estado.ss_trocado_por_fs = (estado.ss_trocado_por_fs or 0) + 1; end
				return true;
			end
		end
	end
	return false;
end;

-- devolve true enquanto o SS+ISS esta no comando (o FS / esquiva nao agem neste quadro)|, "funcao");
print $s;
