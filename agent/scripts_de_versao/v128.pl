local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }
sub troca_todas { my ($velho, $novo, $nome) = @_; my $n = ($s =~ s/\Q$velho\E/$novo/g); die "$nome nao achado" unless $n; return $n; }

troca(q|	Versao 1.27 - INVENCIBILIDADE LIDA DO JOGO A CADA MOMENTO|,
q|	Versao 1.28 - ACERTOS QUE SO DERAM CERTO COM INVENCIBILIDADE MAIOR: o FS que defende um golpe tira uma falha
	desse golpe (as falhas levam o golpe para o SS+ISS). Com Evade Window, manto ou outra skill, o FS defende
	golpes que sem ela falhariam - e esses acertos apagavam falhas de verdade. Agora cada acerto do FS feito
	com invencibilidade MAIOR que a normal fica guardado com o tamanho dela. Se depois a sua invencibilidade
	estiver menor (tirou a skill), esses acertos nao valem: as falhas voltam a contar e o golpe ja vai para a
	defesa mais segura sem precisar apanhar de novo. Com a mesma invencibilidade (ou maior), tudo segue igual.
	Vale para qualquer skill, manto ou efeito (o tamanho vem do jogo, 1.27). As falhas sempre contam.
	1.27 - INVENCIBILIDADE LIDA DO JOGO A CADA MOMENTO|, "cabecalho");
troca_todas(q|versao_mod = "1.27"|, q|versao_mod = "1.28"|, "versao");

troca(q|local n78 = {}; -- (0.78) o arquivo ja esta no limite de variaveis locais do Lua: tudo da 0.78 fica aqui dentro
|, q|local n78 = {}; -- (0.78) o arquivo ja esta no limite de variaveis locais do Lua: tudo da 0.78 fica aqui dentro
-- (1.28) acertos do FS feitos com invencibilidade maior que a normal: [golpe] = { n = acertos, inv = maior invencibilidade }
n78.fs_descontos = {};
pcall(function()
	local salvo = json.load_file("aviso_lanca_defesas.json");
	if type(salvo) == "table" and type(salvo.fs_descontos) == "table" then for k_d, v_d in pairs(salvo.fs_descontos) do n78.fs_descontos[k_d] = v_d; end end
end);
|, "carregar");

troca(q|-- (1.23) ja sairam 3 FS seguidos? (o 4o vira esquiva)
|, q|-- (1.28) falhas do FS neste golpe: os acertos feitos com invencibilidade maior que a de agora nao descontam
n78.fs_falhas_de = function(chave)
	local n = fs_falhas[chave] or 0;
	local d = n78.fs_descontos[chave];
	if type(d) == "table" and n78.janela_inv(6) < (d.inv or 0) - 0.02 then n = n + (d.n or 0); end
	return n;
end;

-- (1.23) ja sairam 3 FS seguidos? (o 4o vira esquiva)
|, "funcao");

troca(q|(somente or not barra_vermelha() or (fs_falhas[chave] or 0) >= FS_FALHAS_PARA_SS|,
q|(somente or not barra_vermelha() or n78.fs_falhas_de(chave) >= FS_FALHAS_PARA_SS|, "uso 1");
troca(q|and not em_sequencia and (fs_falhas[chave_m2] or 0) < FS_FALHAS_PARA_SS then|,
q|and not em_sequencia and n78.fs_falhas_de(chave_m2) < FS_FALHAS_PARA_SS then|, "uso 2");
troca(q|and not em_sequencia and (fs_falhas[chave] or 0) < FS_FALHAS_PARA_SS then|,
q|and not em_sequencia and n78.fs_falhas_de(chave) < FS_FALHAS_PARA_SS then|, "uso 3");

troca(q|				if (fs_falhas[v.chave] or 0) > 0 then
					fs_falhas[v.chave] = fs_falhas[v.chave] - 1;
|, q|				if (fs_falhas[v.chave] or 0) > 0 then
					fs_falhas[v.chave] = fs_falhas[v.chave] - 1;
					-- (1.28) acerto com invencibilidade maior que a normal: guarda o tamanho dela
					local jan_d = n78.janela_inv(6);
					if jan_d > 0.75 + 0.02 then
						local d = n78.fs_descontos[v.chave];
						if type(d) ~= "table" then d = { n = 0, inv = 0 }; end
						d.n, d.inv = (d.n or 0) + 1, math.max(d.inv or 0, jan_d);
						n78.fs_descontos[v.chave] = d;
					end
|, "desconto");

troca(q|				fs_falhas = {};
|, q|				fs_falhas = {};
				for k_d in pairs(n78.fs_descontos) do n78.fs_descontos[k_d] = nil; end -- (1.28)
|, "menu");
my $n = troca_todas(q|limpeza_121 = true });|, q|limpeza_121 = true, fs_descontos = n78.fs_descontos });|, "gravar");
die "esperava 2 gravacoes, achou $n" unless $n == 2;
print $s;
