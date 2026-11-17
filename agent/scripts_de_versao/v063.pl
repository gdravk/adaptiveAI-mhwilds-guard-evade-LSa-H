local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.62 - |, q|	Versao 0.63 - SS+ISS: seus ataques (M1, M2, M5) ficam travados 0,6s ANTES do SS (um golpe seu
	apertado antes ficava guardado e cancelava a postura); a postura continua travada se o golpe
	previsto "sumir" de repente (ate a hora dele passar); o "CANCELAR SS" so aparece depois de 0,4s
	seguidos sem golpe vindo
	0.62 - |, "cab");
$s =~ s/versao_mod = "0\.62"/versao_mod = "0.63"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.62 ==/== Defesa Automatica v0.63 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.62"\)/imgui.tree_node("Defesa Automatica v0.63")/ or die "tit";

# 1. trava antecipada dos ataques
troca(q|			if falta < math.max(op.ls_ss_min_ms / 1000, 1.55 + atraso) or falta > op.ls_ss_max_ms / 1000 then return false; end|,
q|			if falta < math.max(op.ls_ss_min_ms / 1000, 1.55 + atraso) then return false; end
			-- (0.63) golpe um pouco alem da janela do SS: o SS vem logo; trava ja os seus ataques
			local antes_do_ss = falta > op.ls_ss_max_ms / 1000;
			if antes_do_ss and falta > op.ls_ss_max_ms / 1000 + 0.6 then return false; end|, "pre1");
troca(q|			reservar_golpe(p, m, chave_perfil);
			anotar_defesa(p, "ss_iss", falta);|, q|			if antes_do_ss then
				--[[
					(0.63) TRAVA ANTECIPADA: um M1 / M2 / M5 seu apertado logo antes do SS fica guardado
					no buffer do jogo e sai DEPOIS, na postura, cancelando o SS. Nos 0,6s antes do SS
					os seus botoes de ataque ja ficam soltos (o Espaco continua livre).
				]]
				estado.bloquear_ataques_ate = momento + 0.1;
				return false;
			end
			reservar_golpe(p, m, chave_perfil);
			anotar_defesa(p, "ss_iss", falta);|, "pre2");

troca(q|	if estado.bloquear_acoes_ate ~= nil and agora() < estado.bloquear_acoes_ate and estado.perfil == PERFIS.espada_longa then
		local usa_m2, usa_m5, usa_espaco = false, false, false;|, q|	local so_ataques = estado.bloquear_ataques_ate ~= nil and agora() < estado.bloquear_ataques_ate; -- (0.63)
	local tudo = estado.bloquear_acoes_ate ~= nil and agora() < estado.bloquear_acoes_ate;
	if (tudo or so_ataques) and estado.perfil == PERFIS.espada_longa then
		local usa_m2, usa_m5, usa_espaco = false, false, not tudo;|, "bloq");

# 2 e 3. postura: golpe que sumiu continua travando; quadrado so apos 0,4s sem golpe
troca(q|			if p == nil or p.tempo > limite then|, q|			-- (0.63) o golpe alvo saiu da previsao (o monstro mudou de golpe), mas a hora dele ainda nao
			-- passou: continua travado (sem ISS) ate ela passar
			local alvo_pendente = ssiss.alvo ~= nil and ssiss.alvo.tempo + 0.3 > momento
				and (p == nil or p.tempo > limite);
			if alvo_pendente then
				ssiss.cancelavel, ssiss.sem_golpe_desde = false, nil;
				estado.bloquear_acoes_ate = math.max(estado.bloquear_acoes_ate or 0, momento + 0.1);
				return true;
			end
			if p == nil or p.tempo > limite then
				ssiss.sem_golpe_desde = ssiss.sem_golpe_desde or momento;|, "pendente");
troca(q|				if momento - (ssiss.postura_em or ssiss.inicio) > 0.3 then
					ssiss.cancelavel = true;|, q|				if momento - (ssiss.postura_em or ssiss.inicio) > 0.3 and momento - ssiss.sem_golpe_desde >= 0.4 then
					ssiss.cancelavel = true;|, "quadrado");
troca(q|			ssiss.cancelavel = false;
			estado.bloquear_acoes_ate = math.max(estado.bloquear_acoes_ate or 0, momento + 0.1);|,
q|			ssiss.cancelavel, ssiss.sem_golpe_desde = false, nil;
			estado.bloquear_acoes_ate = math.max(estado.bloquear_acoes_ate or 0, momento + 0.1);|, "golpe_vindo");

# diagnostico: Iai Slash fora do momento de cancelar = golpe seu que estava guardado
troca(q|			terminar_ss_iss((levou and "LEVOU DANO na postura") or (iai_slash and "cancelado por voce (M1)")|,
q|			local por_buffer = iai_slash and not ssiss.cancelavel;
			terminar_ss_iss((levou and "LEVOU DANO na postura")
				or (por_buffer and "cancelado por um M1 seu apertado antes (buffer)")
				or (iai_slash and "cancelado por voce (M1)")|, "buffer");

print $s;
