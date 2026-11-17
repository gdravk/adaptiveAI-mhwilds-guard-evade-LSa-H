local $/; my $s = <STDIN>;
open(my $f, '<', $ARGV[0]) or die "menu"; my $menu = <$f>; close $f;

# menu: troca tudo de "Avancado" ate o fim do re.on_draw_ui
my $ini = index($s, qq|\tif not imgui.tree_node("Avancado (ajustes, botoes e diagnostico)") then|);
my $fim_txt = qq|\timgui.tree_pop(); -- Avancado\n\timgui.tree_pop();\nend);\n|;
my $fim = index($s, $fim_txt);
die "menu nao achado" if $ini < 0 || $fim < 0;
substr($s, $ini, $fim + length($fim_txt) - $ini) = $menu;

sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	MENU SIMPLES (versao 0.25): so o essencial para jogar. Todo o resto (tempos, botoes,
		pesquisa, a aba Prints) fica em "Avancado", que voce so precisa abrir se eu pedir.|,
q|	MENU SIMPLES: liga/desliga, aviso na tela, status e resumo da sessao.|, "comentario");

troca(q|	versao_campos = 5,|, q|	versao_campos = 6,|, "versao");

troca(q|	garantir_campos();
end

local function salvar_opcoes()|, q|	-- 0.28: o menu ficou simples; as opcoes que sairam do menu voltam ao valor seguro
	-- (para nenhuma ficar ligada sem ter como desligar)
	if (salvo.versao_campos or 1) < 6 then
		op.mostrar_painel = false;
		op.escrever_no_paralelo = false;
		op.somente_solo = false;
		op.aprender = true;
		op.checar_distancia = true;
	end
	op.versao_campos = 6;

	garantir_campos();
end

local function salvar_opcoes()|, "migracao");

$s =~ s/Versao 0\.27 - 7 ARMAS/Versao 0.28 - menu simples; 7 ARMAS/ or die "cab";
$s =~ s/versao_mod = "0\.27"/versao_mod = "0.28"/ or die "vm";
$s =~ s/== Defesa Automatica v0\.27 ==/== Defesa Automatica v0.28 ==/ or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.27"\)/imgui.tree_node("Defesa Automatica v0.28")/ or die "tit";
print $s;
