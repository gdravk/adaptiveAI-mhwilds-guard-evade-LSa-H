local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }
sub troca_todas { my ($velho, $novo, $nome) = @_; my $n = ($s =~ s/\Q$velho\E/$novo/g); die "$nome nao achado" unless $n; return $n; }

troca(q|	Versao 1.31 - VERIFICACAO DA MEDIDA DA INVENCIBILIDADE (1.30):|,
q|	Versao 1.32 - MAIS SS+ISS COM A BARRA VERMELHA, SO ONDE ELE JA PROVOU QUE FUNCIONA: com a barra vermelha o FS
	tinha a vez e o SS+ISS so saia onde o FS falhava - quase nunca. Agora, no vermelho, o SS+ISS tambem sai nos
	golpes em que o ISS ja deu contra-ataque pelo menos 2 vezes e nunca deixou voce levar dano (na postura ou
	no ISS). Continuam valendo todas as protecoes: golpe com outro acerto ate 0,9s depois usa o FS; no SOS o
	monstro precisa estar virado para voce; precisa de tempo para a postura; golpe que deu dano no SS+ISS sai
	da lista. Abaixo do vermelho nada muda (SS+ISS ja tem a vez).
	1.31 - VERIFICACAO DA MEDIDA DA INVENCIBILIDADE (1.30):|, "cabecalho");
troca_todas(q|versao_mod = "1.31"|, q|versao_mod = "1.32"|, "versao");

troca(q|n78.barra_vermelha = barra_vermelha; -- (0.80) usada pelo FS (definida acima)
|, q|n78.barra_vermelha = barra_vermelha; -- (0.80) usada pelo FS (definida acima)
-- (1.32) golpe em que o ISS ja provou que funciona: 2+ contra-ataques e nenhum dano no SS+ISS
n78.ss_provado = function(chave)
	local s = chave and ss_sem_golpe[chave];
	return s ~= nil and (s.ok or 0) >= 2 and (s.dano or 0) == 0 and golpe_bom_para_ss(chave);
end;
|, "funcao");

troca(q|	local ss_vale = op.usar_ss_iss and (somente or not barra_vermelha() or n78.fs_falhas_de(chave) >= FS_FALHAS_PARA_SS
		or golpe_em_sequencia(p, m));|,
q|	local ss_vale = op.usar_ss_iss and (somente or not barra_vermelha() or n78.fs_falhas_de(chave) >= FS_FALHAS_PARA_SS
		or golpe_em_sequencia(p, m) or (n78.ss_provado and n78.ss_provado(chave))); -- (1.32) no vermelho, golpe provado|, "trava");
troca(q|barra_vermelha() and not em_sequencia and n78.fs_falhas_de(chave_m2) < FS_FALHAS_PARA_SS then|,
q|barra_vermelha() and not em_sequencia and n78.fs_falhas_de(chave_m2) < FS_FALHAS_PARA_SS and not n78.ss_provado(chave_m2) then|, "m2");
troca(q|barra_vermelha() and not em_sequencia and n78.fs_falhas_de(chave) < FS_FALHAS_PARA_SS then|,
q|barra_vermelha() and not em_sequencia and n78.fs_falhas_de(chave) < FS_FALHAS_PARA_SS and not n78.ss_provado(chave) then|, "ss");
troca(q|"VERMELHA: FS > esquiva (SS+ISS so onde o FS falha)"|, q|"VERMELHA: FS > esquiva (SS+ISS onde o FS falha e nos golpes em que o ISS ja provou que funciona)"|, "relatorio");
print $s;
