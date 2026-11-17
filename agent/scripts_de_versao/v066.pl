local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.65 - |, q|	Versao 0.66 - botoes travados agora APAGAM tambem o aperto guardado no buffer do jogo: spamando,
	o seu ultimo M1 / M2 / M5 ficava guardado (~0,6s) e saia no lugar do SS / FS / esquiva
	0.65 - |, "cab");
$s =~ s/versao_mod = "0\.65"/versao_mod = "0.66"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.65 ==/== Defesa Automatica v0.66 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.65"\)/imgui.tree_node("Defesa Automatica v0.66")/ or die "tit";

troca(q|			lista[#lista + 1] = { t = n, l = false, c = "_AnalogValue", v = 0.0 };
		end
		return lista;|, q|			lista[#lista + 1] = { t = n, l = false, c = "_AnalogValue", v = 0.0 };
			--[[
				(0.66) BUFFER: um aperto seu fica guardado no buffer do jogo (~0,6s) e sai quando o
				golpe atual deixa - mesmo com o botao ja solto. Spamando, o seu ultimo ataque saia no
				lugar do SS. As suas capturas mostram o buffer PARADO (sem aperto guardado) como
				_LagFrameCounter = 0 e _LagTimer = 0.0 (com aperto: -1 e um tempo negativo); o mod
				escreve o parado. O _LastRawTriggerIndex continua de fora (suspeito do travamento da 0.17).
			]]
			lista[#lista + 1] = { t = n, l = true, c = "_LagFrameCounter", v = 0 };
			lista[#lista + 1] = { t = n, l = true, c = "_LagTimer", v = 0.0 };
		end
		return lista;|, "buffer");

print $s;
