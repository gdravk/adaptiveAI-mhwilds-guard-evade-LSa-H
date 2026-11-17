local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.85 - |, q|	Versao 0.86 - TRAVA FIXA (Long Sword): quando o golpe que vem vai ser defendido com SS+ISS, os seus
	ataques ficam travados nos ultimos 2s antes dele (ajustavel) - o SS sai do seu golpe atual ou do M2
	automatico. No teste da 0.85, 9 de 10 danos foram com voce preso num golpe, com 1,5s a 3,9s de aviso e a
	trava ligada. O relatorio agora mostra os seus golpes que COMECARAM com a trava ligada (botao que escapou)
	0.85 - |, "cab");
$s =~ s/versao_mod = "0\.85"/versao_mod = "0.86"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.85 ==/== Defesa Automatica v0.86 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.85"\)/imgui.tree_node("Defesa Automatica v0.86")/ or die "tit";

troca(q|	ls_bloqueio_ms = 400,|, q|	ls_trava_fixa_ms = 2000, -- (0.86) golpe do SS+ISS: seus ataques travados nos ultimos X ms antes dele
	ls_bloqueio_ms = 400,|, "op");

troca(q|			{ opcao = "ls_bloqueio_ms", nome = "Prioridade do Foresight: bloquear os seus botoes quantos ms antes do golpe", maximo = 1500 }|,
q|			{ opcao = "ls_bloqueio_ms", nome = "Prioridade do Foresight: bloquear os seus botoes quantos ms antes do golpe", maximo = 1500 },
			{ opcao = "ls_trava_fixa_ms", nome = "Trava fixa: golpe do SS+ISS trava os seus ataques quantos ms antes (0 = desliga)", maximo = 3000 }|, "menu");

troca(q|	local ss_minimo = math.max(op.ls_ss_min_ms / 1000, 1.55);
|, q|	local ss_minimo = math.max(op.ls_ss_min_ms / 1000, 1.55);

	--[[
		(0.86) TRAVA FIXA: o golpe vai ser defendido com SS+ISS -> nos ultimos "ls_trava_fixa_ms" antes
		dele nenhum ataque seu comeca (o SS sai do golpe que ja esta acontecendo ou do M2 automatico).
		A conta abaixo (quanto o seu golpe prende) continua valendo para o resto.
	]]
	if ss_vale and (op.ls_trava_fixa_ms or 0) > 0 and falta <= op.ls_trava_fixa_ms / 1000 then
		estado.bloquear_ataques_ate = math.max(estado.bloquear_ataques_ate or 0, momento + 0.1);
		estado.trava_golpe = string.format("golpe daqui a %d ms: trava fixa do SS+ISS", math.floor(falta * 1000 + 0.5));
		return;
	end
|, "trava_fixa");

troca(q|	local antes, durou = golpe_atual.anim, os.clock() - golpe_atual.inicio;
	golpe_atual.anim, golpe_atual.inicio = anim, os.clock();|, q|	local antes, durou = golpe_atual.anim, os.clock() - golpe_atual.inicio;
	golpe_atual.anim, golpe_atual.inicio = anim, os.clock();
	-- (0.86) golpe seu que COMECOU com a trava ligada (o botao escapou da trava)
	if e_golpe_seu(anim) and estado.m2_auto == nil and ssiss == nil then
		local agora_t = agora();
		estado.golpes_iniciados = (estado.golpes_iniciados or 0) + 1;
		if (estado.bloquear_ataques_ate ~= nil and agora_t < estado.bloquear_ataques_ate)
			or (estado.bloquear_acoes_ate ~= nil and agora_t < estado.bloquear_acoes_ate) then
			estado.golpes_com_trava = estado.golpes_com_trava or {};
			estado.golpes_com_trava[anim] = (estado.golpes_com_trava[anim] or 0) + 1;
		end
	end|, "vazou");

troca(q|	local ct = estado.contatos_em_voce or {};|, q|	do
		local gt, n = {}, 0;
		for anim, q in pairs(estado.golpes_com_trava or {}) do gt[#gt + 1] = anim .. " " .. q; n = n + q; end
		linha(string.format("Golpes seus que comecaram com a trava ligada: %d de %d (%s)", n, estado.golpes_iniciados or 0,
			#gt > 0 and table.concat(gt, ", ") or "nenhum"));
	end
	local ct = estado.contatos_em_voce or {};|, "prints");

print $s;
