local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.46 - |, q|	Versao 0.47 - Long Sword: o Foresight tem prioridade maxima (o seu M1 fica bloqueado perto do golpe);
	nome de cada monstro salvo no aprendizado (para a lista de monstros com a porcentagem)
	0.46 - |, "cab");
$s =~ s/versao_mod = "0\.46"/versao_mod = "0.47"/ or die "vm";
$s =~ s/== Defesa Automatica v0\.46 ==/== Defesa Automatica v0.47 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.46"\)/imgui.tree_node("Defesa Automatica v0.47")/ or die "tit";

# =====================================================================================
# 1. NOMES DOS MONSTROS NO APRENDIZADO
# =====================================================================================
troca(q|local conhecimento = {};|, q|local conhecimento = {};
local nomes_monstros = {}; -- (0.47) id -> nome do monstro no jogo (salvo junto com o aprendizado)|, "decl_nomes");
troca(q|	if type(salvo) == "table" and type(salvo.monstros) == "table" then
		conhecimento = salvo.monstros;
	end|, q|	if type(salvo) == "table" and type(salvo.monstros) == "table" then
		conhecimento = salvo.monstros;
	end
	if type(salvo) == "table" and type(salvo.nomes) == "table" then nomes_monstros = salvo.nomes; end|, "carregar");
troca(q|	json.dump_file("aviso_lanca_aprendizado.json", { versao = 1, monstros = conhecimento });|,
q|	json.dump_file("aviso_lanca_aprendizado.json", { versao = 1, monstros = conhecimento, nomes = nomes_monstros });|, "salvar");
troca(q|		monstros[chave] = m;
	end|, q|		monstros[chave] = m;

		-- (0.47) guarda o nome do monstro (para a lista de monstros com a porcentagem)
		if m.nome ~= nil and nomes_monstros[tostring(id)] ~= m.nome then
			nomes_monstros[tostring(id)] = m.nome;
			precisa_salvar = true;
		end
	end|, "registrar_nome");

# relatorio: nome salvo e arquivo de cobertura separado
troca(q|			id = id, nome = stat.nome, animacoes = a_m,|, q|			id = id, nome = nomes_monstros[chave_monstro] or stat.nome, animacoes = a_m,|, "relatorio_nome");
troca(q|		monstros = por_monstro, prints = linhas, defesas = defesas
	});|, q|		monstros = por_monstro, prints = linhas, defesas = defesas
	});
	-- (0.47) so a cobertura de cada monstro (para atualizar a "Lista de monstros.txt")
	json.dump_file("aviso_lanca_prints/cobertura.json", { salvo_as = ok_hora and hora or nil, monstros = por_monstro });|, "cobertura_json");

# =====================================================================================
# 2. FORESIGHT COM PRIORIDADE MAXIMA: bloqueia o seu M1 perto do golpe
# =====================================================================================
troca(q|	ls_janela_combo_ms = 2300,|, q|	ls_bloqueio_ms = 400,   -- (0.47) o seu M1 fica bloqueado este tanto antes do golpe (o Foresight tem prioridade)
	ls_janela_combo_ms = 2300,|, "op");

troca(q|			{ opcao = "ls_janela_combo_ms", nome = "Combo: Foresight ate quantos ms depois de um golpe seu", maximo = 4000 }|,
q|			{ opcao = "ls_janela_combo_ms", nome = "Combo: Foresight ate quantos ms depois de um golpe seu", maximo = 4000 },
			{ opcao = "ls_bloqueio_ms", nome = "Prioridade do Foresight: bloquear o seu M1 quantos ms antes do golpe", maximo = 1500 }|, "menu");

troca(q|	elseif acao == "espaco" and #(op.espaco_segurado or {}) > 0 then|, q|	elseif acao == "bloquear_m1" then
		-- (0.47) M1 SOLTO: escreve "nao apertado" nos comandos do M1 (12, 21, 46, 50, 55), por
		-- cima do que voce estiver apertando
		local lista = {};
		for _, n in ipairs({ 12, 21, 46, 50, 55 }) do
			lista[#lista + 1] = { t = n, l = false, c = "_On", v = false };
			lista[#lista + 1] = { t = n, l = false, c = "_RawOn", v = false };
			lista[#lista + 1] = { t = n, l = false, c = "_OnTrigger", v = false };
			lista[#lista + 1] = { t = n, l = false, c = "_Repeat", v = false };
			lista[#lista + 1] = { t = n, l = false, c = "_Success", v = false };
			lista[#lista + 1] = { t = n, l = false, c = "_AnalogValue", v = 0.0 };
		end
		return lista;

	elseif acao == "espaco" and #(op.espaco_segurado or {}) > 0 then|, "campos");

troca(q|			local defesa = p.defesa;
			local executar = defesa and perfil.executar and perfil.executar[defesa];|, q|			--[[
				(0.47) FORESIGHT COM PRIORIDADE MAXIMA: se voce estiver apertando / segurando o
				M1, o cacador continua atacando e o golpe do monstro acerta. Perto do golpe
				("ls_bloqueio_ms" antes ate um pouco depois), o mod segura o seu M1 solto; o
				Foresight (ou a esquiva) sai assim que o ataque atual deixar.
			]]
			if perfil == PERFIS.espada_longa and not longe and (p.defesa == "foresight" or p.defesa == "esquiva")
				and falta <= op.ls_bloqueio_ms / 1000 and falta >= -depois then
				estado.bloquear_m1_ate = math.max(estado.bloquear_m1_ate or 0, p.tempo + depois);
			end

			local defesa = p.defesa;
			local executar = defesa and perfil.executar and perfil.executar[defesa];|, "bloqueio_decide");

troca(q|	preparar_escrita();
	estado.escreveu = next(teclas_agora) ~= nil;|, q|	-- (0.47) Foresight com prioridade: o seu M1 fica solto ate o golpe passar (tambem durante
	-- o toque da esquiva, que limpa os outros botoes)
	if estado.bloquear_m1_ate ~= nil and agora() < estado.bloquear_m1_ate and estado.perfil == PERFIS.espada_longa then
		marcar("bloquear_m1");
	end

	preparar_escrita();
	estado.escreveu = next(teclas_agora) ~= nil;|, "bloqueio_marca");

print $s;
