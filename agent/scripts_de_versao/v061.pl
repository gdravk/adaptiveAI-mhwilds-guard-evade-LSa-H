local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.60 - |, q|	Versao 0.61 - postura do SS: com golpe vindo, M1, M2, M5 e Espaco ficam TRAVADOS (tambem no SS
	feito por voce) - o M1 soltava um golpe sem invencibilidade e cancelava o ISS; sem golpe vindo,
	aparece o quadrado vermelho "CANCELAR SS" e so entao o M1 e o M5 ficam livres para voce cancelar.
	O mod nao cancela mais a postura sozinho
	0.60 - |, "cab");
$s =~ s/versao_mod = "0\.60"/versao_mod = "0.61"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.60 ==/== Defesa Automatica v0.61 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.60"\)/imgui.tree_node("Defesa Automatica v0.61")/ or die "tit";

# sai o cancelamento automatico
troca(q|	cancelar_postura_m1 = true, -- (0.60) golpe nao veio: o mod cancela a postura do SS com o M1 (Iai Slash)
|, q||, "op");
troca(q|
			alterado, op.cancelar_postura_m1 = imgui.checkbox("Golpe nao veio: cancelar a postura com M1 (Iai Slash)", op.cancelar_postura_m1);|, q||, "menu");

# postura: saida por ISS / M1
troca(q|		if ANIM_ISS[anim] then
			-- o ISS saiu (por voce): so acompanha o resultado
			ssiss.fase, ssiss.iss_em, ssiss.quadro, ssiss.viu_iss = "iss", os.clock(), math.huge, true;|,
q|		if ANIM_ISS[anim] and ssiss.cancelavel then
			-- (0.61) voce cancelou com o M5 (ISS) num momento sem golpe vindo
			terminar_ss_iss("cancelado por voce (M5)");
			estado.bloquear_acoes_ate = nil;
			return false;
		elseif ANIM_ISS[anim] then
			-- o ISS saiu (por voce): so acompanha o resultado
			ssiss.fase, ssiss.iss_em, ssiss.quadro, ssiss.viu_iss = "iss", os.clock(), math.huge, true;|, "saida_iss");

# postura: travar com golpe vindo / quadrado vermelho sem golpe
troca(q|			-- (0.60) na postura o seu M1 fica livre: voce cancela com o Iai Slash quando ve que o golpe nao vem
			estado.liberar_m1_ate = momento + 0.1;
			local p, m = golpe_mais_proximo(momento);
			local limite = (ssiss.postura_em or ssiss.inicio) + postura_maxima() - 0.25;
			if p == nil or p.tempo > limite then
				if momento - (ssiss.postura_em or ssiss.inicio) > 1.3 and (p == nil or momento > limite - 0.3) then
					if not ssiss.manual then anotar_sem_golpe(ssiss.chave, false); end
					-- (0.60) o golpe nao vem: cancela a postura com o M1 (Iai Slash), mais rapido que esperar
					if not ssiss.manual and op.cancelar_postura_m1 and #(op.toques.m1 or {}) > 0 then
						ssiss.fase, ssiss.quadro, ssiss.cancelar_em = "cancelar", 0, momento;
						return true;
					end
					terminar_ss_iss((not ssiss.manual) and "sem golpe: postura liberada" or nil);
					estado.bloquear_acoes_ate = nil;
					return false;
				end
				return true;
			end|, q|			local p, m = golpe_mais_proximo(momento);
			local limite = (ssiss.postura_em or ssiss.inicio) + postura_maxima() - 0.25;
			if p == nil or p.tempo > limite then
				--[[
					(0.61) NENHUM GOLPE VINDO na postura: o quadrado vermelho "CANCELAR SS" aparece em
					cima da barra e so o M1 (Iai Slash) e o M5 (ISS) ficam livres - voce decide se cancela.
					O mod nao cancela sozinho. (A bainha, no comeco, nao conta: la nada sai ainda.)
				]]
				if momento - (ssiss.postura_em or ssiss.inicio) > 0.3 then
					ssiss.cancelavel = true;
					estado.aviso_cancelar_ss_ate = momento + 0.1;
					estado.liberar_m1_ate = momento + 0.1;
					estado.liberar_m5_ate = momento + 0.1;
					if not ssiss.manual and not ssiss.sem_golpe_anotado and momento - (ssiss.postura_em or ssiss.inicio) > 1.3 then
						ssiss.sem_golpe_anotado = true;
						anotar_sem_golpe(ssiss.chave, false);
					end
				end
				return true;
			end
			--[[
				(0.61) GOLPE VINDO: M1, M2, M5 e Espaco TRAVADOS ate o ISS (tambem no SS feito por voce).
				No teste, o M1 na postura soltava um golpe para frente sem invencibilidade, cancelava o
				ISS e o golpe do monstro acertava.
			]]
			ssiss.cancelavel = false;
			estado.bloquear_acoes_ate = math.max(estado.bloquear_acoes_ate or 0, momento + 0.1);|, "postura");

# a fase "cancelar" sai
$s =~ s/\tif ssiss\.fase == "cancelar" then\n.*?\n\tend\n\n(?=\tif ssiss\.fase == "iss" then)//s or die "fase_cancelar";

# M5 livre no bloqueio
troca(q|		local usa_m1 = estado.liberar_m1_ate ~= nil and agora() < estado.liberar_m1_ate; -- (0.60) postura do SS|,
q|		local usa_m1 = estado.liberar_m1_ate ~= nil and agora() < estado.liberar_m1_ate; -- (0.61) cancelar o SS
		local m5_livre = estado.liberar_m5_ate ~= nil and agora() < estado.liberar_m5_ate;|, "m5_livre");
troca(q|		if not usa_m5 then marcar("bloquear:m5"); end|, q|		if not usa_m5 and not m5_livre then marcar("bloquear:m5"); end|, "bloq_m5");

# quadrado vermelho em cima da barra (aparece mesmo sem golpe na barra)
troca(q|local function desenhar_aviso()
	if not op.ativado then return; end

	local momento = agora();|, q|local function desenhar_aviso()
	-- (0.61) "CANCELAR SS": postura do SS sem golpe vindo (o M1 / M5 estao livres)
	if estado.aviso_cancelar_ss_ate ~= nil and agora() < estado.aviso_cancelar_ss_ate then
		local largura_t, altura_t = tamanho_tela();
		local esc = altura_t / 1080;
		local larg_q, alt_q = 150 * esc, 30 * esc;
		local xq = largura_t / 2 - larg_q / 2;
		local yq = altura_t * op.altura_tela - 75 * esc;
		draw.filled_rect(xq, yq, larg_q, alt_q, COR.impossivel);
		texto_com_sombra("CANCELAR SS", xq + 30 * esc, yq + 8 * esc, COR.texto);
	end

	if not op.ativado then return; end

	local momento = agora();|, "desenho");

print $s;
