local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.68 - |, q|	Versao 0.69 - Long Sword: GOLPES MULTIPLOS - com a barra vermelha, golpe que vem em sequencia
	(outro golpe do mesmo monstro ate 1,2s depois) usa SS+ISS quando da tempo (o FS cobre so um
	golpe); FS nao e apertado de novo se o personagem ja esta no meio de um FS
	0.68 - |, "cab");
$s =~ s/versao_mod = "0\.68"/versao_mod = "0.69"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.68 ==/== Defesa Automatica v0.69 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.68"\)/imgui.tree_node("Defesa Automatica v0.69")/ or die "tit";

troca(q|		if not p.teste and not p.estado_pg.conferiu then
			p.estado_pg.conferiu = true;|, q|		if not p.teste and not p.estado_pg.conferiu then
			p.estado_pg.conferiu = true;
			-- (0.69) ja no meio de um FS (golpe anterior da sequencia): outro FS nao sai
			if ANIM_FS[combo.animacao or "?"] then
				if p.diag ~= nil then p.diag.resultado = "FS ja em andamento"; end
				p.estado_pg.ignorar = true;
			end|, "fs_andamento");
troca(q|		local e = p.estado_pg;
		local m5, m2 = op.toques.m5 or {}, op.toques.m2 or {};|, q|		local e = p.estado_pg;
		if e.ignorar then return; end
		local m5, m2 = op.toques.m5 or {}, op.toques.m2 or {};|, "fs_ignorar");

troca(q|			if not op.somente_ss_iss and barra_vermelha() and (fs_falhas[chave] or 0) < FS_FALHAS_PARA_SS then|,
q|			--[[
				(0.69) GOLPES MULTIPLOS: o FS cobre um golpe so (no golpe triplo do Chatacabra o FS
				saiu no 1o e os outros acertaram). Se vier outro golpe do mesmo monstro ate 1,2s
				depois deste, mesmo com a barra vermelha o mod usa SS+ISS (o ISS tem muito mais
				invencibilidade e corre para frente).
			]]
			local em_sequencia = false;
			for _, outro in ipairs(m.previstos) do
				if outro ~= p and outro.tempo > p.tempo + 0.05 and outro.tempo <= p.tempo + 1.2 then em_sequencia = true; end
			end
			if not op.somente_ss_iss and barra_vermelha() and not em_sequencia and (fs_falhas[chave] or 0) < FS_FALHAS_PARA_SS then|, "sequencia");

print $s;
