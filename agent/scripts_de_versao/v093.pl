local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.92 - HEAVY BOWGUN:|, q|	Versao 0.93 - HAMMER: se voce ja esta carregando (M5 segurado, nivel 1, 2 ou 3), o Charged Step sai pelos
	botoes (M5 continua segurado + toque no M2) e a sua carga fica para o follow up. Sem carga, o
	Charged Step e forcado (quando o mod ja aprendeu o numero) ou o mod carrega e aperta o M2.
	0.92 - HEAVY BOWGUN:|, "cab");
$s =~ s/versao_mod = "0\.92"/versao_mod = "0.93"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.92 ==/== Defesa Automatica v0.93 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.92"\)/imgui.tree_node("Defesa Automatica v0.93")/ or die "tit";

troca(q|		local hora_step = (op.martelo_carga_ms - op.martelo_step_ms) / 1000;
		if n78.acao_de("passo") ~= nil then|, q|		local hora_step = (op.martelo_carga_ms - op.martelo_step_ms) / 1000;
		-- (0.93) ja carregando (qualquer nivel): botoes, para a carga continuar e valer no follow up
		if p.estado_pg.forcou then return; end
		if not p.estado_pg.carga_sua and n78.martelo_carregando(true) == true then p.estado_pg.carga_sua = true; end
		if p.estado_pg.carga_sua then
			if not p.teste and desde >= hora_step + 0.1 then return "indisponivel", "sem tempo"; end
			marcar("guarda"); -- M5 continua segurado (nao perde a carga)
			if desde >= hora_step and desde < hora_step + 0.1 then marcar("especial"); end -- M2: Charged Step
			return;
		end
		if n78.acao_de("passo") ~= nil then|, "exec");

troca(q|n78.martelo_carregando = function()|, q|n78.martelo_carregando = function(estrito) -- (0.93) estrito: nil se nao der para ler|, "f1");
troca(q|		return carga > 0 or inicio > 0 or nivel > 0;
	end);
	if not ok then return true; end
	return sim;
end;|, q|		return carga > 0 or inicio > 0 or nivel > 0;
	end);
	if not ok then
		if estrito then return nil; end
		return true;
	end
	return sim;
end;|, "f2");

print $s;
