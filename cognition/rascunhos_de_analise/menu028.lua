	--[[
		MENU (versao 0.28): o minimo para jogar.
		  - "Ajustes da arma" mostra so as opcoes da arma que esta na sua mao;
		  - "Diagnostico" (Prints e teste de botoes) so precisa ser aberto se eu pedir.
		Todas as outras opcoes continuam funcionando com os valores ja ajustados.
	]]
	local perfil_menu = estado.perfil;

	if perfil_menu ~= nil and imgui.tree_node("Ajustes da arma (" .. perfil_menu.nome .. ")") then
		local mudou_arma, alterado = false, false;

		-- lanca: o que fazer nos golpes guardaveis
		if posicao_no_perfil(perfil_menu, "contra_ataque") ~= nil then
			local acoes = { "contra_ataque", "guarda" };
			local nomes_acoes = { "Contra-ataque", "So a guarda" };
			local atual_acao = (op.acao_guardavel == "guarda") and 2 or 1;
			local alterou_acao, nova_acao = imgui.combo("Nos golpes de frente", atual_acao, nomes_acoes);
			if alterou_acao then op.acao_guardavel = acoes[nova_acao] or "contra_ataque"; mudou_arma = true; end
		end

		-- liga/desliga das defesas que podem ser desligadas (Power Guard, esquiva)
		for _, acao in ipairs(perfil_menu.niveis) do
			local opcao = perfil_menu.desligavel[acao];
			if opcao ~= nil then
				alterado, op[opcao] = imgui.checkbox("Usar " .. NOME_ACAO[acao], op[opcao]);
				mudou_arma = mudou_arma or alterado;
			end
		end

		-- tempo de cada defesa da arma (quanto antes do golpe ela comeca)
		for _, acao in ipairs(perfil_menu.niveis) do
			local opcao = perfil_menu.antecedencia[acao];
			if opcao ~= nil then
				local maximo = (acao == "power_guard") and 1000 or ((acao == "contra_ataque") and 800 or 500);
				alterado, op[opcao] = imgui.slider_int("Tempo: " .. NOME_ACAO[acao] .. " (ms antes do golpe)", op[opcao] or 150, 0, maximo);
				mudou_arma = mudou_arma or alterado;
			end
		end

		if mudou_arma then salvar_opcoes(); end
		imgui.tree_pop();
	end

	if imgui.tree_node("Diagnostico (so se eu pedir)") then
		pcall(desenhar_aba_prints);

		-- testar os botoes (ex.: guarda da Espada e Escudo)
		if imgui.tree_node("Testar botoes") then
			local alvos = { "guarda", "contra_ataque", "power_guard", "esquiva" };
			local nomes = { "Guarda (M5)", "Contra-ataque (M5 e depois M2)", "Power Guard (M5, M2 e Espaco)", "Esquiva (Espaco)" };
			local atual = 1;
			for i, a in ipairs(alvos) do if a == entrada.alvo then atual = i; end end

			local alterou_alvo, novo = imgui.combo("Botao", atual, nomes);
			if alterou_alvo then entrada.alvo = alvos[novo] or "guarda"; entrada.achados = {}; end

			if imgui.button("Testar: o mod aperta " .. NOME_DO_ALVO[entrada.alvo] .. " por 5 segundos (feche o menu)") then
				entrada.forcar_de = agora() + 4;
				entrada.teste_estado = {};
				entrada.forcar_ate = entrada.forcar_de + 5;
			end

			-- se o teste nao funcionar com alguma arma, da para reaprender o botao
			imgui.text("Se o teste nao funcionar, com a arma SACADA e sem monstro perto:");
			if imgui.button("Passo 1: captura PARADO (sem apertar nada)") then comecar_captura(1); end
			local texto_passo2 = (entrada.alvo == "esquiva") and "Passo 2: captura APERTANDO E SOLTANDO O ESPACO UMA VEZ" or ("Passo 2: captura SEGURANDO " .. NOME_DO_ALVO[entrada.alvo]);
			if imgui.button(texto_passo2) then comecar_captura(2); end

			if #entrada.achados > 0 then
				imgui.text(string.format("Aprendido: %d campos", #entrada.achados));
			elseif entrada.capturou_2 and entrada.fase == "parado" then
				imgui.text("Nao achei diferenca entre as capturas. Repita o passo 2 segurando o botao o tempo todo.");
			end

			imgui.tree_pop();
		end

		if estado.mensagem ~= "" then imgui.text(estado.mensagem); end
		imgui.tree_pop();
	end

	imgui.tree_pop();
end);
