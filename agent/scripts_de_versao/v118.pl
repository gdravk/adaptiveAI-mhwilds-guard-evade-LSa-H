local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 1.17 - |, q|	Versao 1.18 - (luta 1.17 contra a Lagiacrus) A medicao mostrou que o ISS NAO tem invencibilidade: so o
	contra de 0,3s. Os golpes seguintes chegavam no resto do ISS (8 danos de 352 a 728 ms) e por cima do ISS
	a esquiva nao sai e o FS saia sem protecao. Agora: 1. golpe com OUTRO acerto previsto ate 0,9s depois nao
	usa SS+ISS - usa o FS (750 ms de invencibilidade cobre os dois); 2. a barra de espirito e conferida de
	novo na hora de soltar o FS (sem barra: esquiva).
	1.17 - |, "cab");
$s =~ s/versao_mod = "1\.17"/versao_mod = "1.18"/g or die "vm";
$s =~ s/== Defesa Automatica v1\.17 ==/== Defesa Automatica v1.18 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v1\.17"\)/imgui.tree_node("Defesa Automatica v1.18")/ or die "tit";

troca(q|			if not golpe_bom_para_ss(chave) then return false; end|, q|			if not golpe_bom_para_ss(chave) then return false; end
			-- (1.18) outro acerto previsto ate 0,9s depois: o ISS (so 0,3s de contra) nao cobre -> FS
			for _, m_seq in pairs(monstros) do
				for _, o in ipairs(m_seq.previstos or {}) do
					if o ~= p and o.tempo > p.tempo + 0.05 and o.tempo <= p.tempo + 0.9 then
						estado.ss_trocado_por_fs = (estado.ss_trocado_por_fs or 0) + 1;
						return false;
					end
				end
			end|, "seq");
troca(q|			if desde >= 0.1 then return "indisponivel", "sem tempo"; end
			-- (0.89) forcado, o FS sai fora do combo tambem|, q|			if desde >= 0.1 then return "indisponivel", "sem tempo"; end
			-- (1.18) a barra pode ter acabado depois da decisao (ex.: no ISS): sem barra o FS nao protege
			local barra_agora = n78.barra_de_espirito(meu_cacador());
			if barra_agora ~= nil and barra_agora <= 0.1 then return "indisponivel", "sem barra"; end
			-- (0.89) forcado, o FS sai fora do combo tambem|, "barra");
troca(q|			r_iss.n, tostring(|, q|			r_iss.n, tostring(|, "nada");
troca(q|		linha("Todos os danos levados (novo primeiro): " .. #(estado.danos_log or {}));|,
q|		linha("SS+ISS trocado por FS (outro acerto ate 0,9s depois): " .. tostring(estado.ss_trocado_por_fs or 0) .. " vezes"); -- (1.18)
		linha("Todos os danos levados (novo primeiro): " .. #(estado.danos_log or {}));|, "linha");
print $s;
