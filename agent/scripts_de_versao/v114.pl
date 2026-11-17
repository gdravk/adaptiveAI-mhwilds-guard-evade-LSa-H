local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 1.13 - |, q|	Versao 1.14 - O teste do FS sem barra e SEMPRE automatico (2 min desligado / 2 min ligado), sem opcao
	no menu - so o aviso de como ele esta agora. (Sai do mod quando a medicao responder a pergunta.)
	1.13 - |, "cab");
$s =~ s/versao_mod = "1\.13"/versao_mod = "1.14"/g or die "vm";
$s =~ s/== Defesa Automatica v1\.13 ==/== Defesa Automatica v1.14 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v1\.13"\)/imgui.tree_node("Defesa Automatica v1.14")/ or die "tit";

troca(q|	ls_fs_sem_barra_teste = false, -- (1.08) teste: FS tambem sem barra (para medir a invencibilidade)
	ls_fs_sem_barra_auto = true, -- (1.13) o teste liga / desliga sozinho a cada 2 minutos
	ls_fs_sem_barra_auto_s = 120,
|, "", "opcoes");
troca(q|	if op.ls_fs_sem_barra_auto then
		return math.floor(os.clock() / math.max(op.ls_fs_sem_barra_auto_s or 120, 10)) % 2 == 1;
	end
	return op.ls_fs_sem_barra_teste == true;|, q|	-- (1.14) sempre automatico: 2 minutos desligado, 2 minutos ligado
	return math.floor(os.clock() / 120) % 2 == 1;|, "efetivo");
troca(q|			.. (op.ls_fs_sem_barra_auto and string.format(" - TESTE AUTOMATICO (liga / desliga a cada %d s), agora %s",
				op.ls_fs_sem_barra_auto_s or 120, n78.teste_fs_sem_barra() and "LIGADO" or "desligado")
				or (op.ls_fs_sem_barra_teste and " - TESTE LIGADO (FS sai sem barra)" or "")));|,
q|			.. " - teste automatico (troca a cada 2 min), agora " .. (n78.teste_fs_sem_barra() and "LIGADO" or "desligado"));|, "relatorio");
troca(q|			alterado, op.ls_fs_sem_barra_teste = imgui.checkbox("TESTE: deixar o FS sair sem barra de espirito (para medir a invencibilidade)", op.ls_fs_sem_barra_teste);
			mudou_arma = mudou_arma or alterado;
			alterado, op.ls_fs_sem_barra_auto = imgui.checkbox("TESTE AUTOMATICO: liga e desliga sozinho a cada 2 minutos (ignora a opcao acima)", op.ls_fs_sem_barra_auto);
			if op.ls_fs_sem_barra_auto then
				imgui.text("   Teste agora: " .. (n78.teste_fs_sem_barra() and "LIGADO (FS sai sem barra)" or "desligado"));
			end
			mudou_arma = mudou_arma or alterado;|, q|			mudou_arma = mudou_arma or alterado;
			imgui.text("Teste do FS sem barra (automatico, troca a cada 2 min): " .. (n78.teste_fs_sem_barra() and "LIGADO" or "desligado"));|, "menu");
print $s;
