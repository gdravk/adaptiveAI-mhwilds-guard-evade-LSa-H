local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.47 - |, q|	Versao 0.48 - Long Sword: o Foresight tem prioridade sobre TODOS os seus botoes de acao (M1, M2, M5
	e Espaco), nao so o M1
	0.47 - |, "cab");
$s =~ s/versao_mod = "0\.47"/versao_mod = "0.48"/ or die "vm";
$s =~ s/== Defesa Automatica v0\.47 ==/== Defesa Automatica v0.48 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.47"\)/imgui.tree_node("Defesa Automatica v0.48")/ or die "tit";

$s =~ s/\telseif acao == "bloquear_m1" then\n.*?\n\t\treturn lista;\n/\telseif string.sub(acao, 1, 9) == "bloquear:" then
		-- (0.48) BOTAO SOLTO: escreve "nao apertado" nos comandos de um grupo de botoes, por cima
		-- do que voce estiver apertando (usado na prioridade do Foresight)
		local lista = {};
		for _, n in ipairs(GRUPOS_DE_BOTOES[string.sub(acao, 10)] or {}) do
			lista[#lista + 1] = { t = n, l = false, c = "_On", v = false };
			lista[#lista + 1] = { t = n, l = false, c = "_RawOn", v = false };
			lista[#lista + 1] = { t = n, l = false, c = "_OnTrigger", v = false };
			lista[#lista + 1] = { t = n, l = false, c = "_Repeat", v = false };
			lista[#lista + 1] = { t = n, l = false, c = "_Success", v = false };
			lista[#lista + 1] = { t = n, l = false, c = "_AnalogValue", v = 0.0 };
		end
		return lista;
/s or die "campos";

troca(q|local function campos_da_acao(acao)|, q|--[[
	(0.48) GRUPOS DE BOTOES (comandos tirados das suas gravacoes):
	  M1 = 12, 21, 46, 50, 55   M2 = 13, 36, 43   M5 = 15, 22   Espaco = 24, 25, 32, 42, 51
	(o 42 aparece no M1 e no Espaco; fica so no grupo do Espaco)
]]
local GRUPOS_DE_BOTOES = {
	m1 = { 12, 21, 46, 50, 55 },
	m2_m5 = { 13, 36, 43, 15, 22 },
	espaco = { 24, 25, 32, 42, 51 }
};

local function campos_da_acao(acao)|, "grupos");

troca(q|	-- (0.47) Foresight com prioridade: o seu M1 fica solto ate o golpe passar (tambem durante
	-- o toque da esquiva, que limpa os outros botoes)
	if estado.bloquear_m1_ate ~= nil and agora() < estado.bloquear_m1_ate and estado.perfil == PERFIS.espada_longa then
		marcar("bloquear_m1");
	end|, q|	--[[
		(0.48) FORESIGHT COM PRIORIDADE MAXIMA: perto do golpe, TODOS os seus botoes de acao
		ficam soltos (M1, M2, M5 e Espaco) - qualquer ataque ou esquiva sua faria o cacador
		comecar outra acao e o Foresight nao sairia. So ficam livres os botoes que o PROPRIO mod
		esta apertando neste quadro (M5 + M2 do Foresight, Espaco da esquiva).
	]]
	if estado.bloquear_m1_ate ~= nil and agora() < estado.bloquear_m1_ate and estado.perfil == PERFIS.espada_longa then
		local usa_m2_m5, usa_espaco = false, false;
		for acao in pairs(teclas_agora) do
			if acao == "guarda" or acao == "especial" or string.sub(acao, 1, 9) == "toque:m5:" or string.sub(acao, 1, 9) == "toque:m2:" then
				usa_m2_m5 = true;
			elseif acao == "esquiva" or acao == "espaco" or string.sub(acao, 1, 14) == "toque:esquiva:" or string.sub(acao, 1, 15) == "toque:esquivab:" then
				usa_espaco = true;
			end
		end
		marcar("bloquear:m1");
		if not usa_m2_m5 then marcar("bloquear:m2_m5"); end
		if not usa_espaco then marcar("bloquear:espaco"); end
	end|, "marca");

troca(q|				(0.47) FORESIGHT COM PRIORIDADE MAXIMA: se voce estiver apertando / segurando o
				M1, o cacador continua atacando e o golpe do monstro acerta. Perto do golpe
				("ls_bloqueio_ms" antes ate um pouco depois), o mod segura o seu M1 solto; o
				Foresight (ou a esquiva) sai assim que o ataque atual deixar.|, q|				(0.47/0.48) FORESIGHT COM PRIORIDADE MAXIMA: se voce estiver apertando / segurando
				qualquer botao de acao, o cacador continua fazendo outra coisa e o golpe do monstro
				acerta. Perto do golpe ("ls_bloqueio_ms" antes ate um pouco depois), o mod segura os
				seus botoes de acao soltos; o Foresight (ou a esquiva) sai assim que der.|, "coment");

troca(q|	ls_bloqueio_ms = 400,   -- (0.47) o seu M1 fica bloqueado este tanto antes do golpe (o Foresight tem prioridade)|,
q|	ls_bloqueio_ms = 400,   -- (0.47) os seus botoes de acao ficam soltos este tanto antes do golpe (o Foresight tem prioridade)|, "op");
troca(q|"Prioridade do Foresight: bloquear o seu M1 quantos ms antes do golpe"|, q|"Prioridade do Foresight: bloquear os seus botoes quantos ms antes do golpe"|, "menu");

print $s;
