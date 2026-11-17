local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 1.15 - |, q|	Versao 1.16 - (luta 1.15 contra a Lagiacrus) 1. TESTE DO FS SEM BARRA ENCERRADO: com barra 96 de 96 FS
	tiveram invencibilidade, sem barra 1 de 7 (provavel resto de barra) - a pesquisa estava certa; o teste e
	a medicao sairam, a regra "sem barra, sem FS" fica. 2. O SS comeca mais perto do golpe: no maximo 2,2s
	antes (era 3,0s - na ult da Lagiacrus a postura esperava demais). 3. Depois da protecao do ISS a esquiva
	forcada nao saia (3 falhas): agora sai o FS (o ISS conta como golpe seu); sem barra, a esquiva.
	1.15 - |, "cab");
$s =~ s/versao_mod = "1\.15"/versao_mod = "1.16"/g or die "vm";
$s =~ s/== Defesa Automatica v1\.15 ==/== Defesa Automatica v1.16 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v1\.15"\)/imgui.tree_node("Defesa Automatica v1.16")/ or die "tit";

# 1. teste e medicao do FS sem barra saem
troca(q|	if barra ~= nil and barra <= 0.1 and not n78.teste_fs_sem_barra() then -- (1.07) sem barra o FS nao tem invencibilidade, tambem no vermelho|,
	q|	if barra ~= nil and barra <= 0.1 then -- (1.07) sem barra o FS nao tem invencibilidade (medido na 1.15: 1 de 7)|, "regra");
troca(q|n78.barra_de_espirito = barra_de_espirito;
-- (1.13) o teste do FS sem barra esta ligado agora? (manual ou automatico, alternando a cada X segundos)
n78.teste_fs_sem_barra = function()
	-- (1.14) sempre automatico: 2 minutos desligado, 2 minutos ligado
	return math.floor(os.clock() / 120) % 2 == 1;
end; -- (1.09) usada na medicao do FS (outro bloco)|, q|n78.barra_de_espirito = barra_de_espirito;|, "funcao_teste");
$s =~ s/\t\t-- \(1\.08\) MEDICAO: cada FS \(seu ou do mod\).*?\n(\t\t-- \(0\.94\) acoes vistas nesta sessao)/$1/s or die "medicao";
$s =~ s/\t\t-- \(1\.08\) FS x barra de espirito x invencibilidade\n.*?agora " \.\. \(n78\.teste_fs_sem_barra\(\) and "LIGADO" or "desligado"\)\);\n//s or die "linha_rel";
troca(q|			mudou_arma = mudou_arma or alterado;
			imgui.text("Teste do FS sem barra (automatico, troca a cada 2 min): " .. (n78.teste_fs_sem_barra() and "LIGADO" or "desligado"));
|, "", "menu");

# 2. SS mais perto do golpe (opcao nova: o valor salvo antigo, 3000, nao vale mais)
$s =~ s/ls_ss_max_ms/ls_ss_inicio_ms/g;
troca(q|	ls_ss_inicio_ms = 3000,    -- ... e no maximo este tanto depois|,
	q|	ls_ss_inicio_ms = 2200,    -- ... e no maximo este tanto depois (1.16: era 3000 - a postura esperava demais)|, "padrao");

# 3. depois da protecao do ISS: FS (o ISS e golpe seu); a esquiva forcada nao sai por cima do ISS
troca(q|local function em_combo_espada_longa(tipo)
	return idade_combo() < janela_combo(tipo or "fs");
end|, q|local function em_combo_espada_longa(tipo)
	if n78.iss_liberado and n78.iss_liberado() then return true; end -- (1.16) o ISS e golpe seu: o FS pode sair
	return idade_combo() < janela_combo(tipo or "fs");
end|, "combo");
troca(q|		if os.clock() - (estado.esquiva_forcada_em or -100) > 0.15 and n78.forcar("esquiva", "esquiva") then -- (1.02)|,
q|		-- (1.16) por cima do resto do ISS a esquiva forcada nao sai (3 falhas na 1.15): FS, se tiver barra
		local fs_no_iss = perfil == PERFIS.espada_longa and n78.iss_liberado() and (n78.barra_de_espirito(meu_cacador()) or 1) > 0.1;
		if fs_no_iss and os.clock() - (estado.esquiva_forcada_em or -100) > 0.15 and n78.forcar("fs", "FS (no fim do ISS)") then
			estado.esquiva_forcada_em = os.clock();
		end
		if os.clock() - (estado.esquiva_forcada_em or -100) > 0.15 and n78.forcar("esquiva", "esquiva") then -- (1.02)|, "esquiva");
print $s;
