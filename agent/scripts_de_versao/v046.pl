local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.45 - |, q|	Versao 0.46 - Long Sword: o combo conta tambem os seus botoes de ataque (M1, M2, M5), mesmo sem
	acertar; menu e aba Prints mais simples (so o que importa para a arma atual); limpeza de
	opcoes e codigo antigos que nao eram mais usados
	0.45 - |, "cab");
$s =~ s/versao_mod = "0\.45"/versao_mod = "0.46"/ or die "vm";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.45"\)/imgui.tree_node("Defesa Automatica v0.46")/ or die "tit";

# =====================================================================================
# 1. LONG SWORD: combo pelos seus botoes de ataque
# =====================================================================================
troca(q|		local id_cacador, banco = animacao_de(objeto_cacador);|, q|		local id_cacador, banco = animacao_de(objeto_cacador);

		--[[
			(0.46) COMBO PELOS SEUS BOTOES: antes o combo so contava quando a espada ACERTAVA
			ou numa animacao de ataque ja aprendida - um golpe que errou o monstro nao abria o
			Foresight. Agora, quando voce aperta M1, M2 ou M5 (lido no aperto de verdade, nos
			quadros em que o mod nao esta escrevendo nada), conta como golpe seu.
		]]
		if estado.perfil == PERFIS.espada_longa and not estado.escreveu then
			pcall(function()
				for _, entrada_jogador in ipairs(entradas_ativas()) do
					local teclas = entrada_jogador:get_field("_Keys");
					for _, n in ipairs(COMANDOS_DE_ATAQUE) do
						local tecla = teclas and teclas:get_element(n);
						if tecla ~= nil and tecla:get_field("_OnTrigger") == true then
							combo.ultimo_ataque_em = os.clock();
							return;
						end
					end
				end
			end);
		end|, "combo_botoes");

troca(q|local combo = { ultimo_acerto = -100, ultimo_ataque_em = -100, animacao = nil };|,
q|local combo = { ultimo_acerto = -100, ultimo_ataque_em = -100, animacao = nil };

-- (0.46) comandos que so os botoes de ataque usam (das suas gravacoes): M1 = 12, 21, 46, 50, 55;
-- M2 = 13, 36, 43; M5 = 15, 22. (O 42 tambem e do Espaco, por isso fica de fora.)
local COMANDOS_DE_ATAQUE = { 12, 21, 46, 50, 55, 13, 36, 43, 15, 22 };|, "comandos");

troca(q|	pcall(conferir_defesas);
	decidir_botoes();|, q|	pcall(conferir_defesas);
	decidir_botoes();|, "noop");
troca(q|	preparar_escrita();
end|, q|	preparar_escrita();
	estado.escreveu = next(teclas_agora) ~= nil; -- (0.46) para nao ler os proprios apertos como seus
end|, "escreveu");

# =====================================================================================
# 2. LIMPEZA DE OPCOES E CODIGO ANTIGOS
# =====================================================================================
troca(q|	somente_solo = false,         -- (0.25: o mod tambem e usado no multiplayer)
|, "", "solo1");
troca(qq|\tif op.somente_solo and jogadores_na_cacada() > 1 then return false, "tem outros jogadores na cacada"; end\n\n|, "", "solo2");
troca(q|	-- golpes impossiveis de guardar: "esquiva" ou "power_guard"
	acao_impossivel = "esquiva",
|, "", "impossivel1");
troca(qq|\tif op.acao_impossivel ~= "esquiva" and op.acao_impossivel ~= "power_guard" then op.acao_impossivel = "esquiva"; end\n|, "", "impossivel2");
$s =~ s/\t-- escrever tambem na entrada de controle .*?escrever_no_paralelo = false,\n\n//s or die "escrever_op";
troca(qq|\tls_zerado_034 = false, -- (0.34) o aprendizado da espada longa da 0.33 foi zerado uma vez\n|, "", "zerado_op");
$s =~ s/-- \(0\.34\) zera UMA vez os golpes da espada longa.*?\nend\);\n\n//s or die "zerado_bloco";

# migracoes antigas: o seu arquivo de opcoes ja esta na versao 9
$s =~ s/\t-- opcoes salvas pela 0\.8 a 0\.12.*?\top\.versao_campos = 9;\n/\t-- (0.46) as migracoes das versoes antigas (0.8 a 0.38) sairam: o seu arquivo ja esta atualizado\n\top.versao_campos = 9;\n/s or die "migracoes";

# escrita no controle e no processamento paralelo (desligados desde a 0.11/0.28)
troca(q|	local nomes = { "_MkbPlayerInput" };
	if op.escrever_controle then nomes[#nomes + 1] = "_PadPlayerInput"; end
|, q|	local nomes = { "_MkbPlayerInput" };
|, "controle1");
troca(q|-- objetos de entrada (mouse/teclado e, se ligado, controle)|, q|-- objeto de entrada do mouse/teclado|, "controle2");
troca(q|	local chave = tostring(op.escrever_controle);|, q|	local chave = "mkb";|, "controle3");
$s =~ s/\n\t-- dentro do processamento paralelo dos botoes \(desligado por padrao: pode travar\)\n\tif op\.escrever_no_paralelo then\n.*?\n\tend\n(end\n)/\n$1/s or die "paralelo";

# diagnostico do tempo de escrita (so aparecia na aba Prints)
$s =~ s/\nlocal diagnostico_escrita = \{\n.*?\n\};\n//s or die "diag1";
troca(q|	if #escrita == 0 then return; end
	local inicio = os.clock();
|, q|	if #escrita == 0 then return; end
|, "diag2");
troca(q|
	diagnostico_escrita.ms_acumulado = diagnostico_escrita.ms_acumulado + (os.clock() - inicio) * 1000;
	diagnostico_escrita.chamadas = diagnostico_escrita.chamadas + 1;
|, "", "diag3");
$s =~ s/-- fecha o diagnostico do quadro e confere se o jogo trocou entre controle e teclado\nlocal function fechar_diagnostico_do_quadro\(\)\n.*?\n\tend\);\nend\n\n//s or die "diag4";
troca(qq|\tfechar_diagnostico_do_quadro();\n|, "", "diag5");
troca(q|	  - mede o tempo gasto escrevendo e quantas vezes o jogo trocou de controle/teclado.
|, "", "diag6");

# =====================================================================================
# 3. ABA PRINTS: so o que importa para a arma atual
# =====================================================================================
$s =~ s/local function montar_prints\(linha\)\n.*?\n\tif estado\.mensagem ~= "" then linha\("Mensagem: " \.\. estado\.mensagem\); end\nend\n/local function montar_prints(linha)
	local momento = agora();
	linha("== Defesa Automatica v0.46 ==");

	-- arma e estado
	local cacador = meu_cacador();
	local sacada = cacador and cacador:call("get_IsWeaponOn");
	local _, perfil_atual = perfil_da_arma(cacador or {});
	linha(string.format("Arma: %s (%s) - sacada: %s - defesa: %s - jogadores: %d - Guard Up: %s",
		perfil_atual and perfil_atual.nome or tostring(pesquisa.arma_tipo),
		perfil_atual and table.concat(perfil_atual.niveis, " > ") or "sem perfil", tostring(sacada),
		not op.guarda_automatica and "desligada" or (estado.motivo_parado == "" and "agindo" or ("parada: " .. estado.motivo_parado)),
		jogadores_na_cacada(), op.tenho_guard_up and "sim" or "nao"));

	local tempos_txt = {};
	if perfil_atual ~= nil then
		for _, acao in ipairs(perfil_atual.niveis) do
			local opcao = perfil_atual.antecedencia[acao];
			if opcao ~= nil then tempos_txt[#tempos_txt + 1] = NOME_ACAO[acao] .. " " .. tostring(op[opcao]); end
		end
		for _, extra in ipairs(perfil_atual.tempos_extras or {}) do
			tempos_txt[#tempos_txt + 1] = extra.opcao .. " " .. tostring(op[extra.opcao]);
		end
	end
	linha("Tempos (ms antes do golpe): " .. (#tempos_txt > 0 and table.concat(tempos_txt, " - ") or "-"));

	-- espada longa
	if perfil_atual == PERFIS.espada_longa then
		local qtd_ataques = 0;
		for _ in pairs(op.animacoes_ataque_ls) do qtd_ataques = qtd_ataques + 1; end
		linha(string.format("Long Sword: em combo = %s - ultimo golpe seu ha %.1fs (janela %d ms) - sua animacao %s - ataques aprendidos %d - toques M5 %d, M2 %d",
			tostring(em_combo_espada_longa()), os.clock() - math.max(combo.ultimo_acerto, combo.ultimo_ataque_em),
			op.ls_janela_combo_ms, tostring(combo.animacao), qtd_ataques, #(op.toques.m5 or {}), #(op.toques.m2 or {})));
	end

	linha(string.format("Vida: %s - ultimo dano ha %.1fs",
		estado.vida_lida and string.format("%.0f", estado.vida_anterior or 0) or "NAO LIDA",
		os.clock() - (estado.levou_dano_em or -1000)));

	-- historico das defesas
	linha("Ultimas defesas (nova primeiro): defesa - ms antes do golpe - sua animacao antes -> 0,25s depois - resultado");
	if #(estado.historico or {}) == 0 then linha("   (nenhuma ainda)"); end
	for _, d in ipairs(estado.historico or {}) do
		linha(string.format("   %s - %d ms - %s -> %s - %s%s", NOME_ACAO[d.defesa] or tostring(d.defesa), d.ms,
			tostring(d.antes), tostring(d.depois or "..."), tostring(d.resultado),
			d.toques and (" - apertou " .. d.toques .. "x") or ""));
	end
	linha("Ultima decisao: " .. (estado.ultima_decisao or "-"));
	linha("Ultimo resultado: " .. (estado.ultimo_resultado or "-"));

	-- monstro mais perto e conhecimento
	local m = monstro_mais_perto();
	if m ~= nil then
		local proximo = nil;
		for _, p in ipairs(m.previstos) do
			local falta = p.tempo - momento;
			if falta >= 0 and (proximo == nil or falta < proximo.falta) then proximo = { falta = falta, guarda = p.guarda }; end
		end
		local a_m, med_m = contar_conhecimento(m.id);
		local stat = (estado.por_monstro or {})[m.id] or { vistos = 0, certos = 0 };
		linha(string.format("Monstro: %s (ID %d) - %.1f m - animacao %s%s",
			m.nome, m.id, m.distancia or -1, tostring(m.animacao),
			proximo and string.format(" - proximo golpe em %.2fs (tipo %d)", proximo.falta, proximo.guarda) or ""));
		linha(string.format("Conhecimento deste monstro: %d animacoes, %d medicoes - cobertura %d%% - previstos nesta sessao: %d de %d",
			a_m, med_m, cobertura(m.id), stat.certos, stat.vistos));
	else
		linha("Monstro: nenhum monstro grande por perto");
	end
	local animacoes, medicoes, quantos = contar_conhecimento(nil);
	linha(string.format("Conhecimento (todos): %d monstros, %d animacoes, %d medicoes - previstos nesta sessao: %d de %d - ultimo erro: %s - aprendidos no Palico ou outros: %d",
		quantos, animacoes, medicoes, estado.avisos_certos, estado.impactos_vistos,
		estado.ultimo_erro_ms and (estado.ultimo_erro_ms .. " ms") or "-", estado.aprendidos_outros or 0));

	if estado.mensagem ~= "" then linha("Mensagem: " .. estado.mensagem); end
end
/s or die "prints";

# =====================================================================================
# 4. MENU
# =====================================================================================
troca(q|	-- resumo da sessao
	imgui.text(string.format("Nesta sessao: %d guardas perfeitas, %d guardas normais, %d Power Guards, %d esquivas perfeitas",
		estado.defesas.perfeita, estado.defesas.normal, estado.defesas.power, estado.defesas.esquiva_perfeita or 0));|,
q|	-- resumo da sessao (0.46: vale para qualquer arma)
	local certas, total_def = 0, 0;
	for _, d in ipairs(estado.defesas_sessao or {}) do
		if d.resultado == "OK (sem dano)" then certas = certas + 1; total_def = total_def + 1;
		elseif d.resultado == "LEVOU DANO" then total_def = total_def + 1; end
	end
	local extras = {};
	if estado.defesas.perfeita > 0 then extras[#extras + 1] = estado.defesas.perfeita .. " guardas perfeitas"; end
	if estado.defesas.power > 0 then extras[#extras + 1] = estado.defesas.power .. " Power Guards"; end
	if (estado.defesas.esquiva_perfeita or 0) > 0 then extras[#extras + 1] = estado.defesas.esquiva_perfeita .. " esquivas perfeitas"; end
	imgui.text(string.format("Nesta sessao: %d de %d defesas sem dano%s", certas, total_def,
		#extras > 0 and (" - " .. table.concat(extras, ", ")) or ""));|, "resumo");

troca(q|	--[[
		MENU (versao 0.28): o minimo para jogar.
		  - "Ajustes da arma" mostra so as opcoes da arma que esta na sua mao;
		  - "Diagnostico" (Prints e teste de botoes) so precisa ser aberto se eu pedir.
		Todas as outras opcoes continuam funcionando com os valores ja ajustados.
	]]|, q|	--[[
		"Ajustes da arma" mostra so as opcoes da arma que esta na sua mao; "Diagnostico"
		(Prints e teste de botoes) so precisa ser aberto se eu pedir.
	]]|, "menu_coment");

troca(q|		pcall(desenhar_aba_prints);

		if imgui.button("Esquecer as animacoes de ataque da Long Sword") then
			op.animacoes_ataque_ls = {};
			salvar_opcoes();
		end
|, q|		pcall(desenhar_aba_prints);
|, "esquecer");

troca(q|		if imgui.tree_node("Testar botoes") then|, q|		if imgui.tree_node("Testar / reaprender botoes") then|, "testar_nome");
troca(q|		if estado.mensagem ~= "" then imgui.text(estado.mensagem); end
		imgui.tree_pop();
	end

	imgui.tree_pop();
end);|, q|		imgui.tree_pop();
	end

	imgui.tree_pop();
end);|, "menu_msg");

print $s;
