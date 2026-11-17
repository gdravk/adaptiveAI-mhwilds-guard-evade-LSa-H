local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.80 - |, q|	Versao 0.81 - ARMA GUARDADA: o mod nao faz NADA (nenhum botao, nenhuma trava, nenhum toque em
	andamento continua). Quando um valor medido pelo mod diverge do que os mods ja testados usam, vale
	o dos mods testados: postura do SS = 3,5s quando o jogo nao informa (antes: o tempo medido)
	0.80 - |, "cab");
$s =~ s/versao_mod = "0\.80"/versao_mod = "0.81"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.80 ==/== Defesa Automatica v0.81 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.80"\)/imgui.tree_node("Defesa Automatica v0.81")/ or die "tit";

troca(q|
	decidir_botoes();

	-- toque gravado em andamento: um quadro da gravacao por quadro do jogo|, q|
	--[[
		(0.81) REGRA: com a arma guardada o mod nao faz NADA - nenhum botao apertado, nenhuma trava
		nos seus botoes e nenhum toque gravado continua (ele so continua lendo o jogo e aprendendo).
	]]
	local arma_guardada = false;
	pcall(function()
		local cacador_g = meu_cacador();
		arma_guardada = cacador_g ~= nil and cacador_g:call("get_IsWeaponOn") ~= true;
	end);
	if arma_guardada then
		toque.quadro = nil;
		ssiss = nil;
		estado.bloquear_acoes_ate = nil;
		estado.bloquear_ataques_ate = nil;
		estado.motivo_parado = "arma guardada: o mod nao faz nada";
		preparar_escrita();
		estado.escreveu = false;
		return;
	end

	decidir_botoes();

	-- toque gravado em andamento: um quadro da gravacao por quadro do jogo|, "guardada");

troca(q|	if do_jogo ~= nil then return do_jogo; end
	local medida = op.postura_medida_ms or 0;
	if medida > 0 then return math.min(medida, op.ls_postura_max_ms) / 1000; end
	return op.ls_postura_max_ms / 1000;|, q|	if do_jogo ~= nil then return do_jogo; end
	-- (0.81) sem o valor do jogo: 3,5s, o tempo da postura usado pelos mods ja testados (o medido
	-- pelo mod divergia; quando diverge, vale o dos mods testados)
	return 3.5;|, "postura");

print $s;
