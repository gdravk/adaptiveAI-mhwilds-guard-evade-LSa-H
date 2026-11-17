local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.52 - |, q|	Versao 0.53 - limpeza unica COMPLETA do Arkveld e de todos os monstros enfrentados no SOS
	(golpes aprendidos e defesas aprendidas desses monstros comecam do zero)
	0.52 - |, "cab");
$s =~ s/versao_mod = "0\.52"/versao_mod = "0.53"/ or die "vm";
$s =~ s/== Defesa Automatica v0\.52 ==/== Defesa Automatica v0.53 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.52"\)/imgui.tree_node("Defesa Automatica v0.53")/ or die "tit";

troca(q|	limpeza_online_052 = false, -- (0.52) limpeza unica do aprendido com outros jogadores no SOS|,
q|	limpeza_sos_053 = false, -- (0.53) limpeza unica e completa dos monstros enfrentados no SOS|, "op");

$s =~ s/--\[\[\n\t\(0\.52\) LIMPEZA UNICA do aprendido online.*?\nend\);\n/--[[
	(0.53) LIMPEZA UNICA E COMPLETA (como voce pediu): apaga TUDO que foi aprendido do Arkveld e
	dos monstros enfrentados no SOS em 13\/11 - os tempos dos golpes e as defesas aprendidas de
	cada golpe. Eles comecam do zero:
	  Arkveld (27), Lala Barina (21), Tempered Mizutsune (13:t), Tempered Nu Udra (25:t),
	  Rey Dau (23), Xu Wu (31), Tempered Xu Wu (31:t), Tempered Blangonga (7:t),
	  Congalala (6), Rathian (0), Rathalos (1).
	Ficam: Chatacabra, Ajarakan, Quematrice, Tempered Congalala e Doshaguma.
]]
pcall(function()
	if op.limpeza_sos_053 == true then return; end
	local apagar = {};
	for _, chave_monstro in ipairs({ "27", "21", "13:t", "25:t", "23", "31", "31:t", "7:t", "6", "0", "1" }) do
		apagar[chave_monstro] = true;
		conhecimento[chave_monstro] = nil;
	end
	grupos_cache = {};
	salvar_conhecimento();

	-- defesas aprendidas: chave "arma:monstro:banco:animacao" (o monstro pode ter ":t" ou ":at")
	for chave in pairs(defesas_aprendidas) do
		local resto = string.match(chave, "^[^:]+:(.+)\$");
		local monstro = resto and string.match(resto, "^(.+):%d+:%d+\$");
		if monstro ~= nil and apagar[monstro] then defesas_aprendidas[chave] = nil; end
	end
	json.dump_file("aviso_lanca_defesas.json", { golpes = defesas_aprendidas, bloqueios = bloqueios_ls });

	op.limpeza_sos_053 = true;
	salvar_opcoes();
end);
/s or die "limpeza";

print $s;
