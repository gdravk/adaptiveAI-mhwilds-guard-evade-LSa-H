local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.84 - |, q|	Versao 0.85 - TRAVA DOS SEUS GOLPES mais segura (a prioridade e nao levar dano). No teste da 0.84,
	as 13 falhas foram com voce preso num golpe seu, e em 12 a trava estava ligada: o mod achava que o
	golpe soltava antes do que solta (ex.: 20:200 / 20:201 medidos em ~0,8s, mas pelos mods ja testados o
	FS so e aceito no quadro 70 = ~1,17s). Agora o tempo que cada golpe prende e o MAIOR entre o medido e
	o dos mods testados, e o resto do golpe atual vem do quadro real da sua animacao. M2 automatico tambem
	quando voce esta andando / parado depois de um golpe (antes so fora do combo); o ISS so espera na
	entrada do SS (antes do quadro 75), nunca mais na postura
	0.84 - |, "cab");
$s =~ s/versao_mod = "0\.84"/versao_mod = "0.85"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.84 ==/== Defesa Automatica v0.85 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.84"\)/imgui.tree_node("Defesa Automatica v0.85")/ or die "tit";

# exporta a janela do FS (quadros dos mods testados)
troca(q|n78.fs_vai_sair = fs_vai_sair;|, q|n78.fs_vai_sair = fs_vai_sair;
-- (0.85) quanto tempo (s) o golpe "banco:id" prende pelos mods testados (quadro em que o FS e aceito)
n78.prende_pelos_mods = function(anim)
	local banco, id = string.match(tostring(anim), "^(%d+):(%d+)$");
	if tonumber(banco) ~= 20 then return nil; end
	local limite = JANELA_FS[tonumber(id)];
	return limite and (limite / QUADROS_POR_SEGUNDO) or nil;
end;
n78.janela_fs_quadro = function(anim)
	local banco, id = string.match(tostring(anim), "^(%d+):(%d+)$");
	if tonumber(banco) ~= 20 then return nil; end
	return JANELA_FS[tonumber(id)];
end;|, "exp");

# ISS: so espera na entrada do SS
troca(q|	if id == 247 or id == 248 or id == 250 then return true; end
	if id == 249 then return (quadro or 0) >= 75; end
	return nil;|, q|	if id == 247 or id == 248 or id == 250 then return true; end
	if id == 249 then return (quadro or 0) >= 75 and true or false; end
	-- (0.85) qualquer outra animacao: nao sabe (nao segura o ISS - na 0.84 ele esperou 9 vezes)
	return nil;|, "iss");

# 1. trava do golpe = maior entre medido e mods testados
troca(q|local function trava_do_golpe(anim)
	local g = duracao_golpes[anim];
	return g and g.ms and (g.ms / 1000) or nil;
end|, q|local function trava_do_golpe(anim)
	local g = duracao_golpes[anim];
	local medido = g and g.ms and (g.ms / 1000) or nil;
	-- (0.85) o maior entre o medido e o dos mods testados (quadro em que o FS e aceito)
	local dos_mods = n78.prende_pelos_mods and n78.prende_pelos_mods(anim) or nil;
	if medido == nil then return dos_mods; end
	if dos_mods == nil then return medido; end
	return math.max(medido, dos_mods);
end|, "trava");

# 2. resto do golpe atual pelo quadro real
troca(q|	local t = trava_do_golpe(anim) or 0.7;
	return math.max(0, t - (os.clock() - golpe_atual.inicio));
end|, q|	local t = trava_do_golpe(anim) or 0.7;
	local resto = math.max(0, t - (os.clock() - golpe_atual.inicio));
	-- (0.85) com o quadro real da sua animacao: o que falta ate o quadro em que o FS e aceito
	local f = estado.foto_cacador;
	local limite = n78.janela_fs_quadro and n78.janela_fs_quadro(anim) or nil;
	if f ~= nil and limite ~= nil and f.quadro ~= nil and os.clock() - f.em < 0.1
		and (tostring(f.banco) .. ":" .. tostring(f.id)) == anim then
		resto = math.max(resto, (limite - f.quadro) / 60);
	end
	return resto;
end|, "resto");

# 3. M2 automatico tambem quando a animacao atual nao e golpe (andando, parado depois do golpe)
troca(q|			if not em_combo_espada_longa("ss") then
				-- (0.83) parado: o SS nao sai -> M2 automatico (se o golpe precisa do SS+ISS e da tempo)|,
q|			-- (0.85) "parado" tambem e andar / ficar parado logo depois de um golpe (o combo ainda conta,
			-- mas o SS nao sai dessas animacoes: no teste, "20:34 -> SS nao saiu (saiu esquiva)")
			local sem_golpe_agora = not e_golpe_seu(anim) and not ANIM_FS[anim] and not ANIM_ISS[anim]
				and anim ~= "20:251" and anim ~= "20:252";
			if not em_combo_espada_longa("ss") or sem_golpe_agora then
				-- (0.83) parado: o SS nao sai -> M2 automatico (se o golpe precisa do SS+ISS e da tempo)|, "m2_parado");
troca(q|				if falta < precisa or falta > precisa + 0.5 then return false; end|,
q|				if falta < precisa or falta > precisa + 0.8 then return false; end|, "m2_janela");

print $s;
