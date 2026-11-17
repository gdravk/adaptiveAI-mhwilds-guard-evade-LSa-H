local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 1.12 - |, q|	Versao 1.13 - TESTE AUTOMATICO do FS sem barra: ligado, o teste liga e desliga sozinho a cada 2 minutos
	(sem precisar marcar no menu). O relatorio mostra se o teste estava ligado. O ajuste do ISS
	por golpe (1.05) nao voltava do arquivo ao abrir o jogo; agora volta.
	1.12 - |, "cab");
$s =~ s/versao_mod = "1\.12"/versao_mod = "1.13"/g or die "vm";
$s =~ s/== Defesa Automatica v1\.12 ==/== Defesa Automatica v1.13 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v1\.12"\)/imgui.tree_node("Defesa Automatica v1.13")/ or die "tit";

troca(q|	ls_fs_sem_barra_teste = false,|, q|	ls_fs_sem_barra_teste = false,
	ls_fs_sem_barra_auto = true, -- (1.13) o teste liga / desliga sozinho a cada 2 minutos
	ls_fs_sem_barra_auto_s = 120,
	iss_ajuste_golpe = {}, -- (1.13) ajuste do ISS por golpe (1.05): agora volta do arquivo ao abrir o jogo|, "opcao");
# teste efetivo
troca(q|n78.barra_de_espirito = barra_de_espirito;|, q|n78.barra_de_espirito = barra_de_espirito;
-- (1.13) o teste do FS sem barra esta ligado agora? (manual ou automatico, alternando a cada X segundos)
n78.teste_fs_sem_barra = function()
	if op.ls_fs_sem_barra_auto then
		return math.floor(os.clock() / math.max(op.ls_fs_sem_barra_auto_s or 120, 10)) % 2 == 1;
	end
	return op.ls_fs_sem_barra_teste == true;
end;|, "efetivo");
troca(q|	if barra ~= nil and barra <= 0.1 and not op.ls_fs_sem_barra_teste then|,
	q|	if barra ~= nil and barra <= 0.1 and not n78.teste_fs_sem_barra() then|, "regra");
troca(q|			.. (op.ls_fs_sem_barra_teste and " - TESTE LIGADO (FS sai sem barra)" or ""));|,
q|			.. (op.ls_fs_sem_barra_auto and string.format(" - TESTE AUTOMATICO (liga / desliga a cada %d s), agora %s",
				op.ls_fs_sem_barra_auto_s or 120, n78.teste_fs_sem_barra() and "LIGADO" or "desligado")
				or (op.ls_fs_sem_barra_teste and " - TESTE LIGADO (FS sai sem barra)" or "")));|, "relatorio");
troca(q|			alterado, op.ls_fs_sem_barra_teste = imgui.checkbox("TESTE: deixar o FS sair sem barra de espirito (para medir a invencibilidade)", op.ls_fs_sem_barra_teste);|,
q|			alterado, op.ls_fs_sem_barra_teste = imgui.checkbox("TESTE: deixar o FS sair sem barra de espirito (para medir a invencibilidade)", op.ls_fs_sem_barra_teste);
			mudou_arma = mudou_arma or alterado;
			alterado, op.ls_fs_sem_barra_auto = imgui.checkbox("TESTE AUTOMATICO: liga e desliga sozinho a cada 2 minutos (ignora a opcao acima)", op.ls_fs_sem_barra_auto);
			if op.ls_fs_sem_barra_auto then
				imgui.text("   Teste agora: " .. (n78.teste_fs_sem_barra() and "LIGADO (FS sai sem barra)" or "desligado"));
			end|, "menu");
print $s;
