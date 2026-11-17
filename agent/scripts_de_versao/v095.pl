local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.94 - |, q|	Versao 0.95 - SWITCH AXE: o Counter Rising Slash (espada, R+M1) e pedido direto ao jogo e conferido; se
	nao sair 3 vezes, o mod usa o toque gravado do R+M1 (Diagnostico > Testar / reaprender botoes).
	0.94 - |, "cab");
$s =~ s/versao_mod = "0\.94"/versao_mod = "0.95"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.94 ==/== Defesa Automatica v0.95 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.94"\)/imgui.tree_node("Defesa Automatica v0.95")/ or die "tit";

troca(q|		if n78.modo_machado() ~= 1 then return "indisponivel", "forma machado"; end
		p.estado_pg.forcou = true;
		n78.acao_direta(2, 54, "SA postura");
		n78.acao_direta(2, 31, "SA Counter");
	end|, q|		if n78.modo_machado() ~= 1 then return "indisponivel", "forma machado"; end
		p.estado_pg.forcou = true;
		-- (0.95) 1. pedido direto (2,54 + 2,31, como os mods testados)  2. R+M1 gravado  3. esquiva
		if n78.acao_de("contra_sa") ~= nil then
			n78.acao_direta(2, 54, "SA postura");
			if n78.forcar("contra_sa", "SA Counter") then return; end
		end
		if comecar_toque(true, "rm1") then return; end
		return "indisponivel", "R+M1 nao gravado";
	end|, "exec");

troca(q|	if tipo == "bloqueio" and wt == 12 and not por.bloqueio_padrao_ruim then return 1, 146, true; end|,
q|	if tipo == "bloqueio" and wt == 12 and not por.bloqueio_padrao_ruim then return 1, 146, true; end
	-- (0.95) Counter Rising Slash da Switch Axe (mods testados)
	if tipo == "contra_sa" and wt == 8 and not por.contra_sa_padrao_ruim then return 2, 31, true; end|, "acao_de");

troca(q|			if fp ~= nil and fp.tipo == "bloqueio" and cat == 1 and idx == 146 then tipo = "bloqueio"; end -- (0.92)|,
q|			if fp ~= nil and fp.tipo == "bloqueio" and cat == 1 and idx == 146 then tipo = "bloqueio"; end -- (0.92)
			-- (0.95) Counter da Switch Axe: so confere (2,54 / 2,31 / 2,32), nao guarda como acao aprendida
			local confere_sa = fp ~= nil and fp.tipo == "contra_sa" and cat == 2 and (idx == 54 or idx == 31 or idx == 32);|, "confere");
troca(q|				if tipo == fp.tipo then
					r.ok = r.ok + 1;|, q|				if tipo == fp.tipo or confere_sa then
					r.ok = r.ok + 1;|, "ok");
troca(q|(fp.tipo == "esquiva" or fp.tipo == "bloqueio")|, q|(fp.tipo == "esquiva" or fp.tipo == "bloqueio" or fp.tipo == "contra_sa")|, "ruim");

troca(q|toque_m4 = "m4", toque_rf = "rf" };|, q|toque_m4 = "m4", toque_rf = "rf", toque_rm1 = "rm1" };|, "alvo");
troca(q|local NOME_DO_ALVO = { toque_rf =|, q|local NOME_DO_ALVO = { toque_rm1 = "TOQUE DO R+M1 (Counter da Switch Axe, forma espada)", toque_rf =|, "nome_alvo");
troca(q|"toque_m4", "toque_rf" };|, q|"toque_m4", "toque_rf", "toque_rm1" };|, "lista");
troca(q|"Gravar toque do R+F (Perfect Block da Heavy Bowgun)" };|, q|"Gravar toque do R+F (Perfect Block da Heavy Bowgun)", "Gravar toque do R+M1 (Counter da Switch Axe)" };|, "lista2");

print $s;
