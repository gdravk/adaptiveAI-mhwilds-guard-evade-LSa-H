local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 1.01 - |, q|	Versao 1.02 - LONG SWORD: so o SS+ISS espera a animacao acabar. FS e esquiva sao forcados por cima de
	qualquer animacao (ISS, outro FS, esquiva, golpe seu), quantas vezes for preciso: sem a espera durante o
	ISS, FS por cima de FS quando o contra do FS anterior (0,4s) ja passou, esquiva sem a pausa de 0,5s.
	1.01 - |, "cab");
$s =~ s/versao_mod = "1\.01"/versao_mod = "1.02"/g or die "vm";
$s =~ s/== Defesa Automatica v1\.01 ==/== Defesa Automatica v1.02 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v1\.01"\)/imgui.tree_node("Defesa Automatica v1.02")/ or die "tit";

# inicio da animacao atual
troca(q|		combo.animacao = tostring(banco) .. ":" .. tostring(id_cacador);|,
q|		local anim_nova = tostring(banco) .. ":" .. tostring(id_cacador);
		if anim_nova ~= combo.animacao then combo.animacao_em = os.clock(); end -- (1.02)
		combo.animacao = anim_nova;|, "anim_em");

# FS anterior ainda cobre?
troca(q|local function em_combo_espada_longa(tipo)|, q|-- (1.02) o FS atual ainda cobre o golpe? (contra do FS ativo nos primeiros 0,4s da animacao)
n78.fs_cobre = function()
	if not ANIM_FS[combo.animacao or "?"] then return false; end
	return os.clock() - (combo.animacao_em or -100) < 0.4;
end;

local function em_combo_espada_longa(tipo)|, "fs_cobre");

troca(q|			if ANIM_FS[combo.animacao or "?"] then
				if p.diag ~= nil then p.diag.resultado = "FS ja em andamento"; end|,
q|			if n78.fs_cobre() then -- (1.02) so enquanto o contra do FS atual ainda vale
				if p.diag ~= nil then p.diag.resultado = "FS ja em andamento"; end|, "exec_fs");
troca(q|						if ANIM_FS[combo.animacao or "?"] then
							-- (0.68) GOLPES MULTIPLOS:|, q|						if n78.fs_cobre() then -- (1.02) depois dos 0,4s sai outro FS por cima
							-- (0.68) GOLPES MULTIPLOS:|, "decide_fs");

# FS forcado tambem no ISS / fim da postura
troca(q|local forcavel = n78.acao_de("fs") ~= nil and motivo ~= "sem barra de espirito" and motivo ~= "postura / ISS";|,
	q|local forcavel = n78.acao_de("fs") ~= nil and motivo ~= "sem barra de espirito"; -- (1.02) ISS tambem|, "forcavel");

# sem a espera durante o ISS
troca(q|		if ANIM_ISS[combo.animacao or "?"] then
			estado.ultima_decisao = "ISS em andamento: espera";
			return;
		end|, q|		-- (1.02) durante o ISS o FS / esquiva tambem podem ser forcados (so o SS+ISS novo espera)|, "iss_espera");
troca(q|			if n78.ls_em_iai() then
				estado.ultima_decisao = "SS+ISS ainda na tela: esperando acabar";
				return true;
			end|, q|			if n78.ls_em_iai() then
				estado.ultima_decisao = "SS+ISS ainda na tela: SS novo espera (FS / esquiva livres)";
				return false; -- (1.02) so o SS espera; FS e esquiva seguem
			end|, "iai");

# esquiva: pausa de 0,5s -> 0,15s (so para nao pedir duas vezes o mesmo golpe)
troca(q|		if os.clock() - (estado.esquiva_forcada_em or -100) > 0.5 and n78.forcar("esquiva", "esquiva") then|,
	q|		if os.clock() - (estado.esquiva_forcada_em or -100) > 0.15 and n78.forcar("esquiva", "esquiva") then -- (1.02)|, "esq1");
troca(q|		if os.clock() - (estado.esquiva_forcada_em or -100) > 0.5 then
			if not comecar_toque|, q|		if os.clock() - (estado.esquiva_forcada_em or -100) > 0.15 then
			if not comecar_toque|, "esq2");
print $s;
