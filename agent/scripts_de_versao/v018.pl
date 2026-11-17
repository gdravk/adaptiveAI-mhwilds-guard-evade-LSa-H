local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q{	acao_impossivel = "esquiva",}, q{	acao_impossivel = "esquiva",

	-- Power Guard na defesa automatica (desligado: o teste da 0.17 fechou o jogo; os golpes
	-- tipo 3 usam o contra-ataque ate o Power Guard ser confirmado em modo seguro)
	usar_power_guard = false,}, "opcao");

troca(q{			if p.guarda == 2 then
				defesa = (op.acao_impossivel == "power_guard") and "power_guard" or "esquiva";
			elseif p.guarda == 3 then
				defesa = "power_guard";
			else}, q{			if p.guarda == 2 then
				defesa = (op.usar_power_guard and op.acao_impossivel == "power_guard") and "power_guard" or "esquiva";
			elseif p.guarda == 3 then
				defesa = op.usar_power_guard and "power_guard" or "contra_ataque";
			else}, "defesa");

troca(q{			for _, item in ipairs(campos_da_acao(acao)) do
				local alvo = teclas:get_element(item.t);}, q{			-- MODO SEGURO do Espaco (versao 0.18): o teste do Power Guard da 0.17 fechou o jogo
			-- dentro da interface (GUIBase.update). Suspeita: "_LastRawTriggerIndex" e um
			-- INDICE para uma lista ligada a tecla fisica; fingindo o aperto, ele aponta para
			-- uma lista vazia e a interface le fora dela. Nas acoes do Espaco (esquiva, Espaco
			-- do Power Guard e o toque gravado) o mod nao escreve esse indice nem o buffer.
			local modo_seguro = (acao == "esquiva" or acao == "espaco" or string.sub(acao, 1, 6) == "toque:");

			for _, item in ipairs(campos_da_acao(acao)) do
				if modo_seguro and (item.l or item.c == "_LastRawTriggerIndex") then goto proximo; end

				local alvo = teclas:get_element(item.t);}, "seguro1");

troca(q{				if alvo ~= nil then
					local campo = campo_do_objeto(alvo, item.c);
					if campo ~= nil then escritas[#escritas + 1] = { alvo, campo, item.c, item.v }; end
				end
			end}, q{				if alvo ~= nil then
					local campo = campo_do_objeto(alvo, item.c);
					if campo ~= nil then escritas[#escritas + 1] = { alvo, campo, item.c, item.v }; end
				end

				::proximo::
			end}, "seguro2");
print $s;
