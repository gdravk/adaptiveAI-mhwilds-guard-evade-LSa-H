local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.69 - |, q|	Versao 0.70 - GOLPES MULTIPLOS (ex.: golpe triplo do Chatacabra, golpes a ~0,3s um do outro): a trava
	dos seus ataques agora se prepara para o SS+ISS tambem com a barra vermelha quando o golpe vem em
	sequencia (antes ela se preparava para o FS, voce continuava atacando e o SS nao cabia mais); o SS
	de uma sequencia pode comecar ate 0,5s mais cedo
	0.69 - |, "cab");
$s =~ s/versao_mod = "0\.69"/versao_mod = "0.70"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.69 ==/== Defesa Automatica v0.70 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.69"\)/imgui.tree_node("Defesa Automatica v0.70")/ or die "tit";

troca(q|-- decide se os seus ataques ficam soltos agora|, q|--[[
	(0.70) GOLPE EM SEQUENCIA: outro golpe do mesmo monstro ate 1,2s depois deste. No golpe triplo
	do Chatacabra (aprendido: 2,52s e 2,71s depois da animacao 50:150; 3,14s e 3,47s depois da
	50:22) os golpes vem a ~0,3s um do outro: o FS e a esquiva cobrem so o 1o, e o personagem
	ainda esta no FS / rolando quando o 2o chega. So o SS+ISS cobre a sequencia.
]]
local function golpe_em_sequencia(p, m)
	for _, outro in ipairs((m and m.previstos) or {}) do
		if outro ~= p and outro.tempo > p.tempo + 0.05 and outro.tempo <= p.tempo + 1.2 then return true; end
	end
	return false;
end

-- decide se os seus ataques ficam soltos agora|, "helper");

troca(q|	local ss_vale = op.usar_ss_iss and (somente or not barra_vermelha() or (fs_falhas[chave] or 0) >= FS_FALHAS_PARA_SS);|,
q|	local ss_vale = op.usar_ss_iss and (somente or not barra_vermelha() or (fs_falhas[chave] or 0) >= FS_FALHAS_PARA_SS
		or golpe_em_sequencia(p, m)); -- (0.70) sequencia: prepara para o SS+ISS mesmo no vermelho|, "trava");

troca(q|			-- (0.63) golpe um pouco alem da janela do SS: o SS vem logo; trava ja os seus ataques
			local antes_do_ss = falta > op.ls_ss_max_ms / 1000;
			if antes_do_ss and falta > op.ls_ss_max_ms / 1000 + 0.6 then return false; end|,
q|			-- (0.70) sequencia: o SS pode comecar ate 0,5s mais cedo (a postura dura ~3,8s)
			local em_sequencia = golpe_em_sequencia(p, m);
			local ss_max = op.ls_ss_max_ms / 1000 + (em_sequencia and 0.5 or 0);
			-- (0.63) golpe um pouco alem da janela do SS: o SS vem logo; trava ja os seus ataques
			local antes_do_ss = falta > ss_max;
			if antes_do_ss and falta > ss_max + 0.6 then return false; end|, "ssmax");

troca(q|			local em_sequencia = false;
			for _, outro in ipairs(m.previstos) do
				if outro ~= p and outro.tempo > p.tempo + 0.05 and outro.tempo <= p.tempo + 1.2 then em_sequencia = true; end
			end
			if not op.somente_ss_iss|, q|			if not op.somente_ss_iss|, "loop_velho");

print $s;
