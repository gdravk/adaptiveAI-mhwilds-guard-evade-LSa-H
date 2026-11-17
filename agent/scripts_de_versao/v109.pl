local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 1.08 - |, q|	Versao 1.09 - CORRECAO URGENTE da 1.08: a medicao do FS usava duas funcoes fora do alcance e dava erro em
	todo quadro; isso parava a leitura das suas acoes (conferencia dos forcados, espera do SS+ISS pelo nome
	da acao, forma da Charge Blade, tiros do Bow / Light Bowgun). Agora usa as copias em n78.
	1.08 - |, "cab");
$s =~ s/versao_mod = "1\.08"/versao_mod = "1.09"/g or die "vm";
$s =~ s/== Defesa Automatica v1\.08 ==/== Defesa Automatica v1.09 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v1\.08"\)/imgui.tree_node("Defesa Automatica v1.09")/ or die "tit";

troca(q|n78.fs_vai_sair = fs_vai_sair;|, q|n78.fs_vai_sair = fs_vai_sair;
n78.barra_de_espirito = barra_de_espirito; -- (1.09) usada na medicao do FS (outro bloco)|, "export");
troca(q|		local barra_agora = barra_de_espirito(cacador);|, q|		local barra_agora = n78.barra_de_espirito(cacador);|, "uso1");
troca(q|			if invencibilidade.desde ~= nil and invencibilidade.desde ~= fm.inv_antes
				and (invencibilidade.tipo == 6 or invencibilidade.tipo == 7) then g.inv = g.inv + 1; end|,
q|			local inv = n78.invencibilidade or {};
			if inv.desde ~= nil and inv.desde ~= fm.inv_antes and (inv.tipo == 6 or inv.tipo == 7) then g.inv = g.inv + 1; end|, "uso2");
troca(q|			estado.fs_medida = { em = os.clock(), barra = barra_antes or barra_agora, inv_antes = invencibilidade.desde,|,
q|			estado.fs_medida = { em = os.clock(), barra = barra_antes or barra_agora, inv_antes = (n78.invencibilidade or {}).desde,|, "uso3");
print $s;
