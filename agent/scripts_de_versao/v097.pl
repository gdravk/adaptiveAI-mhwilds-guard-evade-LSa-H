local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.96 - |, q|	Versao 0.97 - CHARGE BLADE: forma espada = block > esquiva; forma machado = so esquiva (a forma e lida
	pelo nome das suas acoes: cAxe... / ...ToAxe = machado; cSword... / ...ToSword / sacar a arma = espada).
	0.96 - |, "cab");
$s =~ s/versao_mod = "0\.96"/versao_mod = "0.97"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.96 ==/== Defesa Automatica v0.97 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.96"\)/imgui.tree_node("Defesa Automatica v0.97")/ or die "tit";

troca(q|			local chave_v = nome .. "(" .. tostring(cat) .. "," .. tostring(idx) .. ")";|,
q|			local chave_v = nome .. "(" .. tostring(cat) .. "," .. tostring(idx) .. ")";
			-- (0.97) forma da Charge Blade pelo nome da acao
			if wt_v == "9" then
				if string.find(nome, "ToAxe", 1, true) or string.sub(nome, 1, 4) == "cAxe" then estado.cb_machado = true;
				elseif string.find(nome, "ToSword", 1, true) or string.sub(nome, 1, 6) == "cSword"
					or string.sub(nome, 1, 5) == "cWpOn" or string.sub(nome, 1, 9) == "cWpMoveOn" or string.sub(nome, 1, 7) == "cWpSpOn" then
					estado.cb_machado = false;
				end
			end|, "forma");

troca(q|PERFIS.lamina.executar = { guarda = function(desde, p) marcar("guarda"); end };|,
q|-- (0.97) Charge Blade: na forma machado nao tem block -> esquiva
PERFIS.lamina.executar = { guarda = function(desde, p)
	if estado.cb_machado then return "indisponivel", "forma machado"; end
	marcar("guarda");
end };|, "exec");

troca(q|		if estado.perfil == nil or posicao_no_perfil(estado.perfil, "guarda") ~= nil then|,
q|		if estado.perfil == nil or (posicao_no_perfil(estado.perfil, "guarda") ~= nil
			and not (estado.perfil == PERFIS.lamina and estado.cb_machado)) then|, "aviso");

print $s;
