local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 1.09 - |, q|	Versao 1.10 - VERIFICACAO: no contato de golpe, o tipo do dano e o "e rugido?" chamavam duas funcoes
	definidas mais abaixo (fora do alcance): golpes sem dano (rugido, vento) davam erro e eram descartados.
	Agora usam as copias em n78 - o rugido volta a ser aprendido como golpe, como a 0.82/0.83 pretendiam.
	1.09 - |, "cab");
$s =~ s/versao_mod = "1\.09"/versao_mod = "1.10"/g or die "vm";
$s =~ s/== Defesa Automatica v1\.09 ==/== Defesa Automatica v1.10 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v1\.09"\)/imgui.tree_node("Defesa Automatica v1.10")/ or die "tit";

troca(q|				tipo_dano = nome_tipo_dano(dados:get_field("_DamageType"));|,
	q|				tipo_dano = n78.nome_tipo_dano and n78.nome_tipo_dano(dados:get_field("_DamageType")); -- (1.10)|, "tipo");
troca(q|		if type(forca) == "number" and forca <= 0 and not e_rugido(tipo_dano) then return; end|,
	q|		if type(forca) == "number" and forca <= 0 and not (n78.e_rugido and n78.e_rugido(tipo_dano)) then return; end -- (1.10)|, "rugido");
troca(q|n78.nome_tipo_dano = nome_tipo_dano;|, q|n78.nome_tipo_dano = nome_tipo_dano;
n78.e_rugido = e_rugido; -- (1.10) usada no contato (definida depois dele)|, "export");
print $s;
