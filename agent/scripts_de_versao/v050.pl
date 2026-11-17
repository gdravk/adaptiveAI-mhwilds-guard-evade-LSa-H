local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }
sub todas { my ($velho, $novo, $nome) = @_; my $n = 0; while ((my $i = index($s, $velho)) >= 0) { substr($s, $i, length($velho)) = $novo; $n++; } die "$nome nao achado" if $n == 0; }

troca(q|	Versao 0.49 - |, q|	Versao 0.50 - revisao das versoes 0.45 a 0.49: o bloqueio dos botoes nao sobra depois de desligar /
	guardar a arma; o teste do M4 nao para a si mesmo; aviso claro no Prints quando o M4 gravado nao
	tem comando proprio
	0.49 - |, "cab");
$s =~ s/versao_mod = "0\.49"/versao_mod = "0.50"/ or die "vm";
$s =~ s/== Defesa Automatica v0\.49 ==/== Defesa Automatica v0.50 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.49"\)/imgui.tree_node("Defesa Automatica v0.50")/ or die "tit";

# 1. nome coerente: o bloqueio vale para todos os botoes de acao desde a 0.48
todas(q|estado.bloquear_m1_ate|, q|estado.bloquear_acoes_ate|, "nome_bloqueio");

# 2. BUG: com a defesa desligada, a arma guardada ou outra arma, o bloqueio que ja estava
#    marcado continuava ate ~0,65s (os seus botoes ficavam soltos sem motivo)
troca(q|	if momento < entrada.forcar_ate then return; end -- ainda na espera do teste

	if not op.guarda_automatica then estado.motivo_parado = "desligada"; return; end

	local pode, motivo = pode_defender();
	estado.motivo_parado = motivo;
	if not pode then return; end|, q|	if momento < entrada.forcar_ate then estado.bloquear_acoes_ate = nil; return; end -- ainda na espera do teste

	-- (0.50) parado: nenhum botao seu fica bloqueado
	if not op.guarda_automatica then estado.motivo_parado = "desligada"; estado.bloquear_acoes_ate = nil; return; end

	local pode, motivo = pode_defender();
	estado.motivo_parado = motivo;
	if not pode then estado.bloquear_acoes_ate = nil; return; end|, "parado");

# 3. BUG: no teste do "Gravar toque do M4", o proprio M4 apertado pelo mod fazia o mod parar
#    (prioridade 0) e cancelar o teste no primeiro quadro
troca(q|	if m4_apertado() then estado.m4_ate = os.clock() + op.m4_pausa_ms / 1000; end|,
q|	-- (0.50) o M4 apertado pelo PROPRIO mod (teste do toque do M4) nao conta
	local mod_apertando_m4 = toque.quadro ~= nil and toque.nome == "m4";
	if not mod_apertando_m4 and m4_apertado() then estado.m4_ate = os.clock() + op.m4_pausa_ms / 1000; end|, "m4_teste");

# 4. Prints: M4 gravado mas sem comando proprio
troca(q|		#m4 > 0 and ("comandos " .. table.concat(m4, ",")) or "NAO GRAVADO"));|,
q|		#m4 > 0 and ("comandos " .. table.concat(m4, ","))
			or (#(op.toques.m4 or {}) > 0 and "gravado, mas sem comando proprio (grave de novo)" or "NAO GRAVADO")));|, "prints_m4");

print $s;
