local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; die "$nome repetido" if index($s, $velho, $i + length($novo)) >= 0 && $velho ne ""; }
sub troca_todas { my ($velho, $novo, $nome) = @_; my $n = ($s =~ s/\Q$velho\E/$novo/g); die "$nome nao achado" unless $n; return $n; }
sub corta { my ($ini_txt, $fim_txt, $nome) = @_; my $i = index($s, $ini_txt); die "$nome ini" if $i < 0; my $f = index($s, $fim_txt, $i); die "$nome fim" if $f < 0; substr($s, $i, $f + length($fim_txt) - $i) = ""; }

troca(q|	Versao 1.33 - (2 lutas 1.32 contra a Lagiacrus, com e sem Evade Window 5) 1. O SS+ISS NO VERMELHO (1.32) SAIU:|,
q|	Versao 1.34 - VERIFICACAO 1.28 A 1.33 E LIMPEZA: 1. GEOMETRIA NO SOS: o golpe previsto pela geometria (area de
	ataque chegando a menos de 2,5 m do SEU corpo) era jogado fora no SOS pela regra "golpe que nunca te acertou"
	(ele nao tem alcance aprendido). Como a conta ja e feita contra o seu corpo, agora ele vale no SOS tambem
	(no relatorio da 1.32: 36 golpes previstos assim, todos ignorados). 2. LIMPEZA: saiu a limpeza de uma vez so
	da 1.21 / 1.22 (ja feita no seu jogo), a pesquisa ao vivo do Diagnostico, a opcao "janela" (sem uso), restos
	da medida quadro a quadro (1.31) e uma variavel sem uso no FS. O salvamento das defesas virou uma funcao so.
	3. MENU: titulo com a versao certa (mostrava 1.19); "Somente SS+ISS" foi para "Ajustes da arma"; a aba Prints
	virou "Relatorio" (so o nome do arquivo e o botao - o texto todo ja vai no relatorio automatico).
	1.33 - (2 lutas 1.32 contra a Lagiacrus, com e sem Evade Window 5) 1. O SS+ISS NO VERMELHO (1.32) SAIU:|, "cabecalho");
troca_todas(q|versao_mod = "1.33"|, q|versao_mod = "1.34"|, "versao");

# 1. geometria vale no SOS (a conta ja e contra o seu corpo)
troca(q|				if (estado.jogadores or 1) > 1 and (p.dist_max or 0) <= 0 then fora = true; end|,
q|				if (estado.jogadores or 1) > 1 and (p.dist_max or 0) <= 0 and not p.geometria then fora = true; end -- (1.34) geometria: ja e contra o seu corpo|, "sos geometria");
troca(q|				or ((estado.jogadores or 1) > 1 and (o.dist_max or 0) <= 0);|,
q|				or ((estado.jogadores or 1) > 1 and (o.dist_max or 0) <= 0 and not o.geometria); -- (1.34)|, "sos geometria seq");

# 2a. limpeza de uma vez so (1.21 / 1.22) - ja feita
troca(q|	-- (1.21) uma vez so: os danos desses 2 golpes eram tiques de 1 de vida, nao golpes
	if type(salvo) == "table" and salvo.limpeza_121 == nil then
		estado.limpeza_121_pendente = true; -- (1.22) o ajuste do ISS (opcoes) e limpo depois de carregar as opcoes
		for _, chave_l in ipairs({ "espada_longa:10:t:50:124", "espada_longa:10:t:50:295" }) do
			local s_l = ss_sem_golpe[chave_l];
			if type(s_l) == "table" and (s_l.ok or 0) == 0 then s_l.dano = 0; end
		end
	end
|, "", "limpeza 121 carga");
troca(q|-- (1.22) uma vez so: o ajuste do ISS desses 2 golpes veio dos tiques de 1 de vida (1.21)
if estado.limpeza_121_pendente then
	pcall(function()
		local ajustes_l = op.iss_ajuste_golpe or {};
		ajustes_l["espada_longa:10:t:50:124"] = nil;
		ajustes_l["espada_longa:10:t:50:295"] = nil;
		salvar_opcoes();
	end);
end
|, "", "limpeza 122");

# 2b. salvamento das defesas: uma funcao so
my $dump = q|json.dump_file("aviso_lanca_defesas.json", { golpes = defesas_aprendidas, bloqueios = bloqueios_ls, fs_falhas = fs_falhas, ss_animacoes = ss_animacoes, ss_sem_golpe = ss_sem_golpe, janela_combo = janela_combo_dados, anim_fs = ANIM_FS, anim_iss = ANIM_ISS, duracao_golpes = duracao_golpes, limpeza_121 = true, fs_descontos = n78.fs_descontos });|;
my $n = troca_todas($dump, q|n78.salvar_defesas();|, "dump defesas"); die "dump $n" unless $n == 2;
troca(q|local function conferir_defesas()
|, q|-- (1.34) tudo o que foi aprendido das defesas (um lugar so para salvar)
n78.salvar_defesas = function()
	json.dump_file("aviso_lanca_defesas.json", { golpes = defesas_aprendidas, bloqueios = bloqueios_ls, fs_falhas = fs_falhas,
		ss_animacoes = ss_animacoes, ss_sem_golpe = ss_sem_golpe, janela_combo = janela_combo_dados, anim_fs = ANIM_FS,
		anim_iss = ANIM_ISS, duracao_golpes = duracao_golpes, fs_descontos = n78.fs_descontos });
end;

local function conferir_defesas()
|, "funcao salvar");

# 2c. pesquisa ao vivo sai
corta("-- ---------- 16. PESQUISA (Diagnostico): tudo ao vivo, nada e escrito no jogo\n", "\t\tif n == 0 then imgui.text(\"   (nada mudou ainda)\"); end\n\tend\n\timgui.tree_pop();\nend\n", "pesquisa");
troca(q|		if estado.n82 ~= nil then pcall(estado.n82.desenhar_pesquisa); end -- (0.82)
|, "", "chamada pesquisa");

# 2d. opcao sem uso
troca(q|	janela = 1.2,           -- o marcador aparece este tanto de segundos antes do impacto
|, "", "op janela");

# 2e. restos da medida (1.31): janela_inv devolve so o valor; a base e a do proprio tipo
troca(q|	return inv_cache.valores[tipo] or INV_BASE[tipo], tipo;|, q|	return inv_cache.valores[tipo] or INV_BASE[tipo];|, "janela retorno");
troca(q|	-- (1.31) a base e a do tipo medido (o passo da Lance tem outra invencibilidade que o rolar)
	local valor, tipo_usado = n78.janela_inv(tipo);
	local base = INV_BASE[tipo_usado] or (((estado.inv_informada or {})[tipo_usado] or {}).min) or valor;
	local extra = (valor - base) / 2;|,
q|	local extra = (n78.janela_inv(tipo) - INV_BASE[tipo]) / 2;|, "extra");
troca(q|				local inv_l = n78.invencibilidade or {};
				if n78.inv_cobre(p.tempo + 0.02)|, q|				if n78.inv_cobre(p.tempo + 0.02)|, "inv_l");
troca(q|			-- (1.30) medida de verdade (quadro a quadro) e valores informados pelo jogo
|, q|			-- (1.30) menor e maior valor informado pelo jogo (para o relatorio)
|, "comentario hook");

# 3. menu
troca(q|	if not imgui.tree_node("Defesa Automatica v1.19") then return; end|, q|	if not imgui.tree_node("Defesa Automatica v1.34") then return; end|, "titulo");
troca(q|	alterou_simples = alterou_simples or mudou_simples;


	if alterou_simples|, q|	alterou_simples = alterou_simples or mudou_simples;
	if alterou_simples|, "linha vazia");
troca(q|	if estado.perfil == PERFIS.espada_longa then
		local mudou_somente;
		mudou_somente, op.somente_ss_iss = imgui.checkbox("Somente SS+ISS (sem FS e sem esquiva)", op.somente_ss_iss);
		if mudou_somente then
			if op.somente_ss_iss then op.usar_ss_iss = true; end
			salvar_opcoes();
		end
	end

|, "", "somente fora");
troca(q|			alterado, op.usar_ss_iss = imgui.checkbox("Usar SS+ISS (barra abaixo do vermelho: prioridade 1)", op.usar_ss_iss);
			mudou_arma = mudou_arma or alterado;
|, q|			alterado, op.usar_ss_iss = imgui.checkbox("Usar SS+ISS (barra abaixo do vermelho: prioridade 1)", op.usar_ss_iss);
			mudou_arma = mudou_arma or alterado;
			alterado, op.somente_ss_iss = imgui.checkbox("Somente SS+ISS (sem FS e sem esquiva)", op.somente_ss_iss);
			if alterado and op.somente_ss_iss then op.usar_ss_iss = true; end
			mudou_arma = mudou_arma or alterado;
|, "somente dentro");
troca(q|	if not imgui.tree_node("Prints (abra esta aba e tire um print)") then return; end
	montar_prints(function(texto) imgui.text(texto); end);

	local r = estado.relatorio or {};|, q|	if not imgui.tree_node("Relatorio") then return; end
	local r = estado.relatorio or {};|, "prints");
troca(q|	if imgui.tree_node("Diagnostico (so se eu pedir)") then|, q|	if imgui.tree_node("Avancado (so se eu pedir)") then|, "diagnostico");
# comentarios com os nomes novos do menu
troca(q|toque gravado do R+F (Diagnostico > Testar /|, q|toque gravado do R+F (Avancado > Testar /|, "coment hbg");
troca(q|"Ajustes da arma" mostra so as opcoes da arma que esta na sua mao; "Diagnostico"
		(Prints e teste de botoes) so precisa ser aberto se eu pedir.|, q|"Ajustes da arma" mostra so as opcoes da arma que esta na sua mao; "Avancado"
		(relatorio, tempos e teste de botoes) so precisa ser aberto se eu pedir.|, "coment menu");
troca(q|-- (0.44) monta as linhas da aba Prints; "linha" recebe cada linha (na tela ou no relatorio)|,
q|-- (0.44) monta as linhas do relatorio; "linha" recebe cada linha|, "coment prints");
troca(q|			if (estado.jogadores or 1) > 1 and (p.dist_max or 0) <= 0 then longe = true; end|,
q|			if (estado.jogadores or 1) > 1 and (p.dist_max or 0) <= 0 and not p.geometria then longe = true; end -- (1.34)|, "sos geometria decisao");
print $s;
