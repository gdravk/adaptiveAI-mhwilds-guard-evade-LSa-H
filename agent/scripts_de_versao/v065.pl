local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.64 - |, q|	Versao 0.65 - trava dos seus golpes corrigida: o FS (20:226), o SS (20:249) e o ISS (20:263/264/
	265) eram medidos como "golpes seus" (1,3 a 1,5s) e o mod achava que todo ataque seu prendia 2s;
	o SS so e tentado se o que FALTA do seu golpe atual (medido) + bainha cabem antes do golpe do
	monstro (antes usava uma media); limpeza unica das medidas erradas
	0.64 - |, "cab");
$s =~ s/versao_mod = "0\.64"/versao_mod = "0.65"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.64 ==/== Defesa Automatica v0.65 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.64"\)/imgui.tree_node("Defesa Automatica v0.65")/ or die "tit";

troca(q|	reset_postura_062 = false,|, q|	reset_postura_062 = false,
	limpeza_golpes_065 = false, -- (0.65) tira FS / SS / ISS / esquiva das medidas dos seus golpes|, "op");

troca(q|local golpe_atual = { anim = nil, inicio = 0 };|, q|local golpe_atual = { anim = nil, inicio = 0 };

-- (0.65) golpe SEU = animacao de ataque que NAO e FS, SS, ISS nem esquiva (o mod aprende como
-- "ataque" toda animacao em que a espada acerta, e o FS / ISS tambem acertam)
local function e_golpe_seu(anim)
	return anim ~= nil and op.animacoes_ataque_ls[anim] == true and not ANIM_FS[anim] and not ANIM_SS[anim]
		and not ANIM_ISS[anim] and anim ~= "20:61";
end|, "e_golpe");

troca(q|	-- sem combo conhecido: o mais longo de todos os seus golpes medidos (ou 700 ms)
	for _, outro in pairs(duracao_golpes) do
		if outro.ms ~= nil and (maior == nil or outro.ms / 1000 > maior) then maior = outro.ms / 1000; end
	end
	return maior or 0.7;|, q|	-- (0.65) sem combo conhecido: o tempo TIPICO (mediana) dos seus golpes medidos (ou 700 ms);
	-- o mais longo de todos travava demais
	local lista = {};
	for anim_g, outro in pairs(duracao_golpes) do
		if outro.ms ~= nil and e_golpe_seu(anim_g) then lista[#lista + 1] = outro.ms / 1000; end
	end
	if #lista == 0 then return 0.7; end
	table.sort(lista);
	return lista[math.floor((#lista + 1) / 2)];|, "mediana");

troca(q|	if anim == nil or not op.animacoes_ataque_ls[anim] then return 0; end|,
q|	if not e_golpe_seu(anim) then return 0; end|, "resto");
troca(q|	if antes == nil or not op.animacoes_ataque_ls[antes] or durou < 0.08 or durou > 3 then return; end|,
q|	if not e_golpe_seu(antes) or durou < 0.08 or durou > 3 then return; end|, "medir1");
troca(q|	if op.animacoes_ataque_ls[anim] then
		g.prox = g.prox or {};|, q|	if e_golpe_seu(anim) then
		g.prox = g.prox or {};|, "medir2");
troca(q|	for seguinte in pairs((g and g.prox) or {}) do
		local t = trava_do_golpe(seguinte);|, q|	for seguinte in pairs((g and g.prox) or {}) do
		local t = e_golpe_seu(seguinte) and trava_do_golpe(seguinte) or nil;|, "prox_filtro");

# SS: o que falta do golpe atual (medido), nao a media de atraso
troca(q|			local atraso = (info and info.atraso or 0) / 1000;
			if falta < math.max(op.ls_ss_min_ms / 1000, 1.55 + atraso) then return false; end|,
q|			-- (0.65) o SS sai quando o seu golpe atual soltar: o que falta dele (medido) + bainha + ISS
			local atraso = resto_do_golpe_atual();
			if falta < math.max(op.ls_ss_min_ms / 1000, 1.55 + atraso) then return false; end|, "ss_resto");

# limpeza unica
troca(q|pcall(function()
	if op.reset_postura_062 == true then return; end|, q|pcall(function()
	if op.limpeza_golpes_065 == true then return; end
	for anim_g in pairs(duracao_golpes) do
		if not e_golpe_seu(anim_g) then duracao_golpes[anim_g] = nil; end
	end
	for _, g in pairs(duracao_golpes) do
		for seguinte in pairs(g.prox or {}) do
			if not e_golpe_seu(seguinte) then g.prox[seguinte] = nil; end
		end
	end
	estado.bloqueio_mudou = true;
	op.limpeza_golpes_065 = true;
	salvar_opcoes();
end);

pcall(function()
	if op.reset_postura_062 == true then return; end|, "limpeza");

print $s;
