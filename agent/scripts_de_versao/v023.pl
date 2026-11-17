local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q{local function contar_conhecimento()
	local animacoes, medicoes = 0, 0;
	for _, lista in pairs(conhecimento["27"] or {}) do
		animacoes = animacoes + 1;
		medicoes = medicoes + #lista;
	end
	return animacoes, medicoes;
end}, q{-- conhecimento de um monstro (ou de todos, se "id" for nil): monstros, animacoes, medicoes
local function contar_conhecimento(id)
	local quantos_monstros, animacoes, medicoes = 0, 0, 0;
	for chave_monstro, golpes in pairs(conhecimento) do
		if id == nil or chave_monstro == tostring(id) then
			quantos_monstros = quantos_monstros + 1;
			for _, lista in pairs(golpes) do
				animacoes = animacoes + 1;
				medicoes = medicoes + #lista;
			end
		end
	end
	return animacoes, medicoes, quantos_monstros;
end}, "contar");

troca(q{	local animacoes, medicoes = 0, 0;
	for _, l in pairs(conhecimento["27"] or {}) do animacoes = animacoes + 1; medicoes = medicoes + #l; end
	linha(string.format("Conhecimento: %d animacoes, %d medicoes | golpes previstos: %d de %d | ultimo erro: %s",
		animacoes, medicoes, estado.avisos_certos, estado.impactos_vistos,
		estado.ultimo_erro_ms and (estado.ultimo_erro_ms .. " ms") or "-"));}, q{	local animacoes, medicoes, quantos = contar_conhecimento(nil);
	linha(string.format("Conhecimento (todos): %d monstros, %d animacoes, %d medicoes | golpes previstos: %d de %d | ultimo erro: %s",
		quantos, animacoes, medicoes, estado.avisos_certos, estado.impactos_vistos,
		estado.ultimo_erro_ms and (estado.ultimo_erro_ms .. " ms") or "-"));
	if m ~= nil then
		local a_m, med_m = contar_conhecimento(m.id);
		linha(string.format("Conhecimento deste monstro (ID %d): %d animacoes, %d medicoes", m.id, a_m, med_m));
	end}, "prints");

troca(q{	local animacoes, medicoes = contar_conhecimento();
	imgui.text(string.format("Conhecimento do Arkveld: %d animacoes, %d medicoes", animacoes, medicoes));}, q{	local animacoes, medicoes, quantos = contar_conhecimento(nil);
	imgui.text(string.format("Conhecimento: %d monstros, %d animacoes, %d medicoes", quantos, animacoes, medicoes));}, "menu");
print $s;
