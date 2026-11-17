local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.91 - AS 14 ARMAS:|, q|	Versao 0.92 - HEAVY BOWGUN: 1. Perfect Block (pedido direto ao jogo, acao 1,146 dos mods testados; sem
	ele, o toque gravado do R+F)  2. esquiva. O block normal (automatico, parado olhando o monstro) o
	mod deixa com o jogo.
	0.91 - AS 14 ARMAS:|, "cab");
$s =~ s/versao_mod = "0\.91"/versao_mod = "0.92"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.91 ==/== Defesa Automatica v0.92 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.91"\)/imgui.tree_node("Defesa Automatica v0.92")/ or die "tit";

troca(q|	sa_contra_ms = 150,     -- Switch Axe (espada): Counter este tanto antes do golpe
|, q|	sa_contra_ms = 150,     -- Switch Axe (espada): Counter este tanto antes do golpe
	hbg_bloqueio_ms = 120,  -- (0.92) Heavy Bowgun: Perfect Block este tanto antes do golpe
|, "op");
troca(q|charged_step = "Charged Step", contra_sa = "Counter (Switch Axe)"|,
	q|charged_step = "Charged Step", contra_sa = "Counter (Switch Axe)", bloqueio_perfeito = "Perfect Block"|, "nomes");

troca(q|		niveis = { "esquiva" },
		so_de_frente = {},
		antecedencia = { esquiva = "esquiva_ms_bowgun_pesada" },|, q|		-- (0.92) 1. Perfect Block (de frente)  2. esquiva. O block normal e automatico (parado,
		-- olhando o monstro): o mod nao mexe nele.
		niveis = { "bloqueio_perfeito", "esquiva" },
		so_de_frente = { bloqueio_perfeito = true },
		forte = "esquiva",
		antecedencia = { bloqueio_perfeito = "hbg_bloqueio_ms", esquiva = "esquiva_ms_bowgun_pesada" },
		rotulo_tempo = { bloqueio_perfeito = "Perfect Block: quantos ms antes do golpe" },|, "perfil");

troca(q|PERFIS.bowgun_pesada.executar = {};|, q|--[[
	(0.92) HEAVY BOWGUN - Perfect Block: um pedido so, "hbg_bloqueio_ms" antes do golpe.
	  1. pedido direto ao jogo (acao 1,146, a mesma dos mods testados);
	  2. se o jogo nao aceitar (3 vezes sem sair), o toque gravado do R+F (Diagnostico > Testar /
	     reaprender botoes > Gravar toque do R+F);
	  3. sem os dois ou sem tempo: esquiva.
]]
PERFIS.bowgun_pesada.executar = {
	bloqueio_perfeito = function(desde, p)
		p.estado_pg = p.estado_pg or {};
		if p.estado_pg.feito then return; end
		if not p.teste and desde >= 0.1 then return "indisponivel", "sem tempo"; end
		p.estado_pg.feito = true;
		if n78.forcar("bloqueio", "Perfect Block") then return; end
		if comecar_toque(true, "rf") then return; end
		return "indisponivel", "R+F nao gravado";
	end
};|, "exec");

troca(q|		if wt == 11 then return 2, 9, true; end -- (0.91) Bow (mods testados)
		return 1, 19, true;
	end|, q|		if wt == 11 then return 2, 9, true; end -- (0.91) Bow (mods testados)
		return 1, 19, true;
	end
	-- (0.92) Perfect Block da Heavy Bowgun (mods testados)
	if tipo == "bloqueio" and wt == 12 and not por.bloqueio_padrao_ruim then return 1, 146, true; end|, "acao_de");

# conferencia: o Perfect Block e reconhecido pelo numero da acao
troca(q|			elseif nome == "cMikiriSlash" then tipo = "fs"; end
			local fp = estado.forcado_pendente;|, q|			elseif nome == "cMikiriSlash" then tipo = "fs"; end
			local fp = estado.forcado_pendente;
			if fp ~= nil and fp.tipo == "bloqueio" and cat == 1 and idx == 146 then tipo = "bloqueio"; end -- (0.92)|, "confere");
troca(q|					if fp.padrao and fp.tipo == "esquiva" and r.ok == 0 and r.falha >= 3 and fp.wt ~= nil then
						op.acoes_aprendidas[tostring(fp.wt)] = op.acoes_aprendidas[tostring(fp.wt)] or {};
						op.acoes_aprendidas[tostring(fp.wt)].esquiva_padrao_ruim = true;|,
q|					if fp.padrao and (fp.tipo == "esquiva" or fp.tipo == "bloqueio") and r.ok == 0 and r.falha >= 3 and fp.wt ~= nil then
						op.acoes_aprendidas[tostring(fp.wt)] = op.acoes_aprendidas[tostring(fp.wt)] or {};
						op.acoes_aprendidas[tostring(fp.wt)][fp.tipo .. "_padrao_ruim"] = true;|, "ruim");

# gravacao do toque R+F
troca(q|local ALVO_TOQUE = { toque_m5 = "m5", toque_m2 = "m2", toque_m4 = "m4" };|,
	q|local ALVO_TOQUE = { toque_m5 = "m5", toque_m2 = "m2", toque_m4 = "m4", toque_rf = "rf" };|, "alvo");
troca(q|local NOME_DO_ALVO = { toque_m4 = "TOQUE DO M4 (guardar a arma e correr)",|,
	q|local NOME_DO_ALVO = { toque_rf = "TOQUE DO R+F (Perfect Block da Heavy Bowgun)", toque_m4 = "TOQUE DO M4 (guardar a arma e correr)",|, "nome_alvo");
troca(q|"foresight", "toque_m5", "toque_m2", "toque_m4" };|, q|"foresight", "toque_m5", "toque_m2", "toque_m4", "toque_rf" };|, "lista");
troca(q|"Gravar toque do M4 (guardar a arma e correr)" };|, q|"Gravar toque do M4 (guardar a arma e correr)", "Gravar toque do R+F (Perfect Block da Heavy Bowgun)" };|, "lista2");

print $s;
