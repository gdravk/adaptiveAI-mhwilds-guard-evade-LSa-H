local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.39 - |, q|	Versao 0.41 - Long Sword so com Foresight Slash (1) e esquiva (2); Special Sheathe + Iai desativado;
	ataque automatico da 0.40 removido (feita a partir da 0.39)
	0.39 - |, "cab");
$s =~ s/versao_mod = "0\.39"/versao_mod = "0.41"/ or die "vm";
$s =~ s/== Defesa Automatica v0\.39 ==/== Defesa Automatica v0.41 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.39"\)/imgui.tree_node("Defesa Automatica v0.41")/ or die "tit";

troca(q|		niveis = { "foresight", "iai", "esquiva" },
		so_de_frente = {},
		antecedencia = { foresight = "ls_foresight_ms", iai = "ls_sheathe_ms", esquiva = "esquiva_ms_espada_longa" },
		rotulo_tempo = {
			foresight = "Foresight Slash: M5 + M2 quantos ms antes do golpe",
			iai = "Special Sheathe: M5 + Espaco quantos ms antes do golpe"
		},
		tempos_extras = {
			{ opcao = "ls_iai_ms", nome = "Iai Spirit Slash: M5 quantos ms antes do golpe", maximo = 500 },
			{ opcao = "ls_janela_combo_ms", nome = "Combo: Foresight e Iai ate quantos ms depois de um golpe seu", maximo = 4000 }
		},
		-- (0.30) prioridade fixa 1, 2, 3: se o Foresight falhar num golpe, da proxima vez vai o
		-- Special Sheathe + Iai. O aprendizado NUNCA desce para a esquiva normal: ela so entra
		-- quando voce nao esta num combo (nenhum golpe dado).
		nivel_maximo_aprendido = 2,
		-- sem tempo para o Special Sheathe (golpe previsto em cima da hora): tenta o Foresight
		reserva = { iai = "foresight" },|, q|		--[[
			(0.41) como voce pediu: 1. Foresight Slash   2. esquiva (quando o Foresight nao
			serve: fora do combo ou sem tempo). O Special Sheathe + Iai foi DESATIVADO (o codigo
			dele continua no arquivo, mas a espada longa nao usa mais).
		]]
		niveis = { "foresight", "esquiva" },
		so_de_frente = {},
		antecedencia = { foresight = "ls_foresight_ms", esquiva = "esquiva_ms_espada_longa" },
		rotulo_tempo = {
			foresight = "Foresight Slash: M5 + M2 quantos ms antes do golpe"
		},
		tempos_extras = {
			{ opcao = "ls_janela_combo_ms", nome = "Combo: Foresight ate quantos ms depois de um golpe seu", maximo = 4000 }
		},
		-- prioridade fixa: sempre o Foresight; o aprendizado nunca troca para a esquiva
		nivel_maximo_aprendido = 1,
		reserva = {},|, "perfil");

troca(q|			local alvos = { "guarda", "contra_ataque", "power_guard", "esquiva", "foresight", "iai", "toque_m5" };
			local nomes = { "Guarda (M5)", "Contra-ataque (M5 e depois M2)", "Power Guard (M5, M2 e Espaco)", "Esquiva (Espaco)",
				"Foresight Slash (Long Sword)", "Special Sheathe + Iai (Long Sword)",
				"Gravar toque do M5 (para o Iai da Long Sword)" };|, q|			-- (0.41) Special Sheathe + Iai e o toque do M5 sairam do menu (desativados)
			local alvos = { "guarda", "contra_ataque", "power_guard", "esquiva", "foresight" };
			local nomes = { "Guarda (M5)", "Contra-ataque (M5 e depois M2)", "Power Guard (M5, M2 e Espaco)", "Esquiva (Espaco)",
				"Foresight Slash (Long Sword)" };|, "menu");

print $s;
