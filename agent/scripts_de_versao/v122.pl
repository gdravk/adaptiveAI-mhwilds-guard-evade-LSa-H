local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }
sub troca_todas { my ($velho, $novo, $nome) = @_; my $n = ($s =~ s/\Q$velho\E/$novo/g); die "$nome nao achado" unless $n; return $n; }

troca(q|	Versao 1.21 - (lutas 1.20 contra o Gore Magala e a Congalala) DANO PEQUENO NAO E GOLPE:|,
q|	Versao 1.22 - VERIFICACAO: os tiques de 1 de vida tambem tinham mudado o tempo do ISS desses 2 golpes do
	Gore Magala (+60 ms cada, "dano logo depois do ISS"). Voltam a 0, uma vez so, junto com a limpeza da 1.21.
	1.21 - (lutas 1.20 contra o Gore Magala e a Congalala) DANO PEQUENO NAO E GOLPE:|, "cabecalho");
troca_todas(q|versao_mod = "1.21"|, q|versao_mod = "1.22"|, "versao");

troca(q|	if type(salvo) == "table" and salvo.limpeza_121 == nil then
|, q|	if type(salvo) == "table" and salvo.limpeza_121 == nil then
		estado.limpeza_121_pendente = true; -- (1.22) o ajuste do ISS (opcoes) e limpo depois de carregar as opcoes
|, "marca pendente");

troca(q|pcall(carregar_opcoes);
|, q|pcall(carregar_opcoes);
-- (1.22) uma vez so: o ajuste do ISS desses 2 golpes veio dos tiques de 1 de vida (1.21)
if estado.limpeza_121_pendente then
	pcall(function()
		local ajustes_l = op.iss_ajuste_golpe or {};
		ajustes_l["espada_longa:10:t:50:124"] = nil;
		ajustes_l["espada_longa:10:t:50:295"] = nil;
		salvar_opcoes();
	end);
end
|, "limpa ajuste");
print $s;
