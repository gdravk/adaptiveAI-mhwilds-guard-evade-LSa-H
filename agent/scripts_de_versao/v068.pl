local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.67 - |, q|	Versao 0.68 - TRAVAMENTO NO FIM DA LUTA: o log mostrou o mod chamando a posicao e a animacao de um
	monstro ja destruido (18:04:21) e o jogo parou logo depois. Agora o mod le a VIDA do monstro e,
	quando ele morre, nao chama mais nada nele; se a posicao falhar, nao chama mais nada no mesmo
	quadro. Long Sword: abaixo da barra vermelha o FS vira esquiva (o FS zerava o carregamento da
	barra); durante o ISS e o FS o mod nao aperta mais nada (golpes multiplos)
	0.67 - |, "cab");
$s =~ s/versao_mod = "0\.67"/versao_mod = "0.68"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.67 ==/== Defesa Automatica v0.68 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.67"\)/imgui.tree_node("Defesa Automatica v0.68")/ or die "tit";

troca(q|	somente_ss_iss = false,|, q|	somente_ss_iss = false,
	-- (0.68) abaixo da barra vermelha o FS zera o carregamento do proximo nivel: usa a esquiva no lugar
	ls_sem_fs_abaixo_vermelho = true,|, "op");

# 1. vida do monstro
troca(q|		local legendary = contexto:call("get_LegendaryID");

		m = {|, q|		local legendary = contexto:call("get_LegendaryID");

		-- (0.68) onde ler a vida (mesmo caminho do seu mod de barras de vida)
		local gerenciador_vida = nil;
		pcall(function()
			local navegador = contexto:call("get_Browser");
			local portador = navegador and navegador:get_field("_Context");
			local personagem = portador and portador:call("get_Chara");
			gerenciador_vida = personagem and personagem:call("get_HealthManager");
		end);

		m = {
			gerenciador_vida = gerenciador_vida,|, "vida_reg");

troca(q|		else
			local mx, my, mz = posicao(m.objeto);
			if mx == nil then m.invalido = true; end -- objeto ja destruido: para na hora
			m.distancia = distancia(mx, my, mz, cx, cy, cz);|, q|		else
			--[[
				(0.68) MONSTRO MORTO: le a vida (objeto de dados, nao o corpo do monstro). Vida 0 =
				morto: o mod nao chama mais NADA no corpo dele (posicao, animacao). No fim da luta o
				jogo destroi o corpo, e chamar funcoes nele trava o jogo (log de 18:04:21: posicao e
				animacao chamadas num monstro destruido, e o jogo parou).
			]]
			if m.gerenciador_vida ~= nil then
				local ok_v, vida_m = pcall(function() return m.gerenciador_vida:call("get_Health"); end);
				if ok_v and type(vida_m) == "number" and vida_m <= 0 then m.invalido, m.morto = true, true; end
			end
			local mx, my, mz = nil, nil, nil;
			if not m.invalido then
				mx, my, mz = posicao(m.objeto);
				if mx == nil then m.invalido = true; end -- objeto ja destruido: para na hora
			end
			if m.invalido then
				m.previstos = {}; -- (0.68) e NAO chama a animacao (antes chamava no mesmo quadro)
			else
			m.distancia = distancia(mx, my, mz, cx, cy, cz);|, "monstro");
troca(q|			m.previstos = restantes;
		end
	end
|, q|			m.previstos = restantes;
			end -- (0.68) fim do "monstro vivo"
		end
	end
|, "monstro_fim");

# LS: FS vira esquiva abaixo do vermelho; nada de FS repetido no meio do FS
troca(q|					p.defesa = p.nivel and perfil.niveis[p.nivel] or nil;|, q|					p.defesa = p.nivel and perfil.niveis[p.nivel] or nil;
					if perfil == PERFIS.espada_longa and p.defesa == "foresight" then
						if ANIM_FS[combo.animacao or "?"] then
							-- (0.68) GOLPES MULTIPLOS: o FS ja esta saindo (outro golpe da sequencia);
							-- apertar outro FS nao faz nada - o mod espera
							p.defesa = nil;
							estado.ultima_decisao = "golpe seguido: FS ja em andamento";
						elseif op.ls_sem_fs_abaixo_vermelho and not barra_vermelha() then
							--[[
								(0.68) Voce notou: o FS mantem o nivel do Spirit Gauge mas ZERA o
								carregamento para o proximo, e voce ficou no amarelo a luta toda. Abaixo
								do vermelho: SS+ISS (sobe a barra) e, sem tempo para ele, ESQUIVA.
								No vermelho o FS volta a ser o 1.
							]]
							p.defesa, p.sem_combo = "esquiva", true;
							estado.ultima_decisao = "abaixo do vermelho: esquiva no lugar do FS";
						end
					end|, "fs_vermelho");

# durante o ISS o mod nao aperta nada
troca(q|		-- (0.60) agora segue: fora da janela do SS sai a esquiva normal; dentro dela, nada de FS|,
q|		-- (0.60) agora segue: fora da janela do SS sai a esquiva normal; dentro dela, nada de FS
		-- (0.68) GOLPES MULTIPLOS: durante o ISS (muita invencibilidade, corre para frente) o mod nao
		-- aperta mais nada - antes ele tentava FS / esquiva nos golpes seguintes e atrapalhava
		if ANIM_ISS[combo.animacao or "?"] then
			estado.ultima_decisao = "ISS em andamento: espera";
			return;
		end|, "iss_espera");

# menu
troca(q|			alterado, op.usar_ss_iss = imgui.checkbox("Usar SS+ISS (barra abaixo do vermelho: prioridade 1)", op.usar_ss_iss);
			mudou_arma = mudou_arma or alterado;|, q|			alterado, op.usar_ss_iss = imgui.checkbox("Usar SS+ISS (barra abaixo do vermelho: prioridade 1)", op.usar_ss_iss);
			mudou_arma = mudou_arma or alterado;
			alterado, op.ls_sem_fs_abaixo_vermelho = imgui.checkbox("Abaixo do vermelho: esquiva no lugar do FS (o FS zera o carregamento da barra)", op.ls_sem_fs_abaixo_vermelho);
			mudou_arma = mudou_arma or alterado;|, "menu");

print $s;
