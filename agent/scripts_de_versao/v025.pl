local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

# 1. multiplayer: "so sozinho" desligado por padrao + distancia
troca(q{	somente_solo = true,          -- so age quando voce esta sozinho na cacada}, q{	somente_solo = false,         -- (0.25: o mod tambem e usado no multiplayer)

	-- so defende golpes que ja chegaram em voce desta distancia (+ margem). Evita defender
	-- golpes contra outros jogadores no multiplayer (e golpes que nao alcancam no solo)
	checar_distancia = true,
	margem_distancia = 3.0,}, "op");

troca(q{	versao_campos = 4,}, q{	versao_campos = 5,}, "versao");

troca(q{	if (salvo.versao_campos or 1) < 4 then}, q{	-- 0.25: o mod passa a ser usado tambem no multiplayer
	if (salvo.versao_campos or 1) < 5 then
		op.somente_solo = false;
	end

	if (salvo.versao_campos or 1) < 4 then}, "migracao");

# 2. distancia maxima de cada impacto previsto (das medicoes)
troca(q{				novos[#novos + 1] = { tempo = momento + g.tempo, guarda = g.guarda, vezes = g.vezes, origem = animacao };}, q{				-- maior distancia em que este golpe ja chegou em voce (para o multiplayer)
				local dist_max = 0;
				for _, medicao in ipairs(g.lista) do
					if (medicao[3] or 0) > dist_max then dist_max = medicao[3]; end
				end
				novos[#novos + 1] = { tempo = momento + g.tempo, guarda = g.guarda, vezes = g.vezes, origem = animacao,
					dist_max = dist_max };}, "dist");

# 3. menu simples + avancado
troca(q{	if not imgui.tree_node("Aviso de Guarda (Lanca) v0.25") then return; end

	pcall(desenhar_aba_prints);}, q{	if not imgui.tree_node("Defesa Automatica v0.25") then return; end

	--[[
		MENU SIMPLES (versao 0.25): so o essencial para jogar. Todo o resto (tempos, botoes,
		pesquisa, a aba Prints) fica em "Avancado", que voce so precisa abrir se eu pedir.
	]]
	local alterou_simples = false;
	local mudou_simples;

	mudou_simples, op.guarda_automatica = imgui.checkbox("Defesa automatica", op.guarda_automatica);
	alterou_simples = alterou_simples or mudou_simples;

	mudou_simples, op.ativado = imgui.checkbox("Mostrar aviso na tela", op.ativado);
	alterou_simples = alterou_simples or mudou_simples;

	if alterou_simples then salvar_opcoes(); end

	-- status em uma linha
	local perfil_status = estado.perfil;
	if not op.guarda_automatica then
		imgui.text("Status: desligada");
	elseif estado.motivo_parado == "" and perfil_status ~= nil then
		imgui.text("Status: defendendo (" .. perfil_status.nome .. ")");
	else
		imgui.text("Status: parado - " .. (estado.motivo_parado ~= "" and estado.motivo_parado or "aguardando"));
	end

	-- resumo da sessao
	imgui.text(string.format("Nesta sessao: %d guardas perfeitas, %d guardas normais, %d Power Guards",
		estado.defesas.perfeita, estado.defesas.normal, estado.defesas.power));

	if not imgui.tree_node("Avancado (ajustes, botoes e diagnostico)") then
		imgui.tree_pop();
		return;
	end

	pcall(desenhar_aba_prints);}, "menu1");

troca(q{	if estado.mensagem ~= "" then imgui.text(estado.mensagem); end

	imgui.tree_pop();
end);}, q{	if estado.mensagem ~= "" then imgui.text(estado.mensagem); end

	imgui.tree_pop(); -- Avancado
	imgui.tree_pop();
end);}, "menu2");
print $s;
