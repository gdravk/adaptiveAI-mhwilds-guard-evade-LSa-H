local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 1.10 - |, q|	Versao 1.11 - MEDICAO DO FS corrigida: a invencibilidade do FS comeca no mesmo quadro (ou antes) da
	acao ser lida, entao a 1.10 contava 0 em todos. Agora vale a invencibilidade de FS que comecou de 0,15s
	antes ate 0,4s depois do FS.
	1.10 - |, "cab");
$s =~ s/versao_mod = "1\.10"/versao_mod = "1.11"/g or die "vm";
$s =~ s/== Defesa Automatica v1\.10 ==/== Defesa Automatica v1.11 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v1\.10"\)/imgui.tree_node("Defesa Automatica v1.11")/ or die "tit";

troca(q|			if inv.desde ~= nil and inv.desde ~= fm.inv_antes and (inv.tipo == 6 or inv.tipo == 7) then g.inv = g.inv + 1; end|,
q|			if inv.desde ~= nil and inv.desde >= fm.agora - 0.15 and inv.desde <= fm.agora + 0.4
				and (inv.tipo == 6 or inv.tipo == 7) then g.inv = g.inv + 1; end -- (1.11)|, "inv");
troca(q|			estado.fs_medida = { em = os.clock(), barra = barra_antes or barra_agora, inv_antes = (n78.invencibilidade or {}).desde,|,
q|			estado.fs_medida = { em = os.clock(), agora = agora(), barra = barra_antes or barra_agora, inv_antes = (n78.invencibilidade or {}).desde,|, "agora");
print $s;
