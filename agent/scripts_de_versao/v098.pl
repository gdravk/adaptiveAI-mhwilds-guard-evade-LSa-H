local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.97 - |, q|	Versao 0.98 - CHARGE BLADE (luta contra a Quematrice): na forma machado a esquiva forcada agora e a do
	machado (cAxeDodge 2,20) - a esquiva normal (1,19) e da espada e desfazia a forma machado. Guarda segurada
	entre golpes nunca na forma machado. "cAxe...ToSword..." (volta para a espada) agora conta como espada.
	0.97 - |, "cab");
$s =~ s/versao_mod = "0\.97"/versao_mod = "0.98"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.97 ==/== Defesa Automatica v0.98 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.97"\)/imgui.tree_node("Defesa Automatica v0.98")/ or die "tit";

# forma: "ToSword" primeiro (cAxeDischargeCancelToSwordAttack volta para a espada)
troca(q|				if string.find(nome, "ToAxe", 1, true) or string.sub(nome, 1, 4) == "cAxe" then estado.cb_machado = true;
				elseif string.find(nome, "ToSword", 1, true) or string.sub(nome, 1, 6) == "cSword"
					or string.sub(nome, 1, 5) == "cWpOn" or string.sub(nome, 1, 9) == "cWpMoveOn" or string.sub(nome, 1, 7) == "cWpSpOn" then
					estado.cb_machado = false;
				end|, q|				if string.find(nome, "ToSword", 1, true) or string.sub(nome, 1, 6) == "cSword"
					or string.sub(nome, 1, 5) == "cWpOn" or string.sub(nome, 1, 9) == "cWpMoveOn" or string.sub(nome, 1, 7) == "cWpSpOn" then
					estado.cb_machado = false;
				elseif string.find(nome, "ToAxe", 1, true) or string.sub(nome, 1, 4) == "cAxe" then estado.cb_machado = true; end|, "forma");

# esquiva forcada da forma machado
troca(q|	if tipo == "esquiva" and wt == 2 and n78.db_demonio() then return 2, 42, true; end|,
q|	if tipo == "esquiva" and wt == 2 and n78.db_demonio() then return 2, 42, true; end
	-- (0.98) Charge Blade na forma machado: a esquiva do machado (cAxeDodge); a normal desfaz a forma
	if tipo == "esquiva" and wt == 9 and estado.cb_machado then return 2, 20, true; end|, "acao_de");
troca(q|				or (fp.tipo == "esquiva" and nome == "cKijinDodge"));|,
	q|				or (fp.tipo == "esquiva" and (nome == "cKijinDodge" or nome == "cAxeDodge")));|, "confere");

# ponte de guarda: nunca na forma machado
troca(q|	if not vai_esquivar and posicao_no_perfil(perfil, "guarda") ~= nil
		and momento - (estado.ultima_guarda_em or -100) < 0.1 then|, q|	if not vai_esquivar and posicao_no_perfil(perfil, "guarda") ~= nil
		and not (perfil == PERFIS.lamina and estado.cb_machado) -- (0.98)
		and momento - (estado.ultima_guarda_em or -100) < 0.1 then|, "ponte");

print $s;
