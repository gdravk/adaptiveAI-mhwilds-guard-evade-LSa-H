local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; die "$nome repetido" if index($s, $velho, $i + length($novo)) >= 0; }
sub troca_todas { my ($velho, $novo, $nome) = @_; my $n = ($s =~ s/\Q$velho\E/$novo/g); die "$nome nao achado" unless $n; return $n; }
sub corta { my ($ini_txt, $fim_txt, $nome) = @_; my $i = index($s, $ini_txt); die "$nome ini" if $i < 0; my $f = index($s, $fim_txt, $i); die "$nome fim" if $f < 0; substr($s, $i, $f + length($fim_txt) - $i) = ""; }

troca(q|	Versao 1.38 - LANCA: NOVA PRIORIDADE|,
q|	Versao 1.39 - (luta 1.38 contra o Omega Planetes com a Lanca) O APRENDIZADO DA LANCA SUBIA RAPIDO DEMAIS:
	1. DANO VALE MAIS QUE GUARDA: com os dois avisos (o jogo disse "guardou" e voce levou o golpe), a defesa era
	"OK". No contra-ataque isso e comum: ele pega o 1o golpe e voce cai no seguinte (10:55:21, 94 -> 33 de vida,
	marcado OK). Agora levou golpe = falhou (todas as armas que conferem pelo dano). 2. GEOMETRIA NAO MUDA O
	APRENDIZADO: todos os golpes previstos pela geometria de um monstro tem a MESMA chave; as falhas de golpes
	diferentes somavam e a chave do Omega chegou na esquiva (nivel 4) - duas mortes com o passo da Lanca (167 ms
	de invencibilidade). Golpe da geometria usa sempre a defesa inicial (pelas regras de direcao / tipo).
	3. LANCA SOBE SO COM 2 FALHAS SEGUIDAS no mesmo golpe (um acerto zera a conta); antes 1 falha ja subia - em
	uma luta 9 de 12 golpes do Omega subiram, 4 ate o contra-ataque ou a esquiva. 4. As defesas aprendidas da
	Lanca voltam ao inicio (uma vez so), porque subiram com as regras erradas. 5. Sairam as limpezas de uma vez
	so da 1.37 e da 1.38 (ja rodaram no seu jogo).
	1.38 - LANCA: NOVA PRIORIDADE|, "cabecalho");
troca_todas(q|versao_mod = "1.38"|, q|versao_mod = "1.39"|, "versao");
troca(q|Defesa Automatica v1.38") then|, q|Defesa Automatica v1.39") then|, "menu");
troca(q|linha("== Defesa Automatica v1.38 ==");|, q|linha("== Defesa Automatica v1.39 ==");|, "relatorio");

# 1. dano vale mais que guarda
troca(q|				-- (0.82) o jogo disse que guardou (perfeita, normal, guard point...)
				if (estado.guarda_jogo_em or -100) >= v.em - 0.05 then return true; end
				return (estado.levou_dano_em or -100) < v.em - 0.05;|,
q|				-- (1.39) levou o golpe = falhou, mesmo se o jogo tambem disse que guardou (o contra-ataque pega
				-- o 1o golpe e voce cai no seguinte); sem golpe em voce = defendeu
				return (estado.levou_dano_em or -100) < v.em - 0.05;|, "dano primeiro");

# 2. geometria nao muda o aprendizado
troca(q|				sem_combo = casado.sem_combo, diag = casado.diag|,
q|				sem_combo = casado.sem_combo, diag = casado.diag, geometria = casado.geometria -- (1.39)|, "verificacao geometria");
troca(q|		elseif n78.defesa_tarde(v) then|,
q|		elseif v.geometria then
			-- (1.39) golpes diferentes previstos pela geometria tem a mesma chave: a falha nao muda o aprendizado
			if v.diag ~= nil then v.diag.resultado = "LEVOU DANO (geometria)"; end
			estado.ultimo_resultado = "FALHOU com " .. NOME_NIVEL[v.defesa] .. " na geometria (" .. v.chave .. ") - aprendizado nao muda";
		elseif n78.defesa_tarde(v) then|, "conferir geometria");
troca(q|	local aprendido = defesas_aprendidas[chave_do_golpe(chave_perfil, m, p)] or 1;|,
q|	local aprendido = defesas_aprendidas[chave_do_golpe(chave_perfil, m, p)] or 1;
	if p.geometria then aprendido = 1; end -- (1.39) geometria: sempre a defesa inicial|, "escolher geometria");

# 3. Lanca: 2 falhas seguidas para subir
troca(q|		-- (0.31) com Guard Up o aprendizado para no nivel 3 (1.38: o contra-ataque; nunca vira esquiva)
		teto_com_guard_up = 3,|, q|		-- (0.31) com Guard Up o aprendizado para no nivel 3 (1.38: o contra-ataque; nunca vira esquiva)
		teto_com_guard_up = 3,
		-- (1.39) a defesa de um golpe so sobe depois de 2 falhas seguidas nele (um acerto zera a conta)
		falhas_para_subir = 2,|, "perfil falhas");
troca(q|n78.fs_descontos = {};
|, q|n78.fs_descontos = {};
n78.falhas_seguidas = {}; -- (1.39) [golpe] = falhas seguidas no nivel atual (perfis com "falhas_para_subir")
|, "tabela falhas");
troca(q|	if type(salvo) == "table" and type(salvo.fs_descontos) == "table" then for k_d, v_d in pairs(salvo.fs_descontos) do n78.fs_descontos[k_d] = v_d; end end|,
q|	if type(salvo) == "table" and type(salvo.fs_descontos) == "table" then for k_d, v_d in pairs(salvo.fs_descontos) do n78.fs_descontos[k_d] = v_d; end end
	if type(salvo) == "table" and type(salvo.falhas_seguidas) == "table" then for k_d, v_d in pairs(salvo.falhas_seguidas) do n78.falhas_seguidas[k_d] = v_d; end end|, "carrega falhas");
troca(q|		anim_iss = ANIM_ISS, duracao_golpes = duracao_golpes, fs_descontos = n78.fs_descontos });|,
q|		anim_iss = ANIM_ISS, duracao_golpes = duracao_golpes, fs_descontos = n78.fs_descontos, falhas_seguidas = n78.falhas_seguidas });|, "salva falhas");
troca(q|			local perfil_v = PERFIS[v.perfil] or PERFIS.lanca;
			local proximo = math.min((v.nivel or 1) + 1, teto_do_aprendizado(perfil_v, v.monstro));
			if (defesas_aprendidas[v.chave] or 1) < proximo then
				defesas_aprendidas[v.chave] = proximo;
				mudou = true;
			end
			estado.ultimo_resultado = "FALHOU com " .. NOME_NIVEL[v.defesa] .. " (" .. v.chave .. ") -> proxima vez: " .. NOME_NIVEL[perfil_v.niveis[proximo]];|,
q|			local perfil_v = PERFIS[v.perfil] or PERFIS.lanca;
			local proximo = math.min((v.nivel or 1) + 1, teto_do_aprendizado(perfil_v, v.monstro));
			-- (1.39) perfil com "falhas_para_subir": conta as falhas seguidas antes de subir
			local seguidas = (n78.falhas_seguidas[v.chave] or 0) + 1;
			if seguidas < (perfil_v.falhas_para_subir or 1) then
				n78.falhas_seguidas[v.chave] = seguidas;
				mudou = true;
				estado.ultimo_resultado = string.format("FALHOU com %s (%s) - falha %d de %d para subir", NOME_NIVEL[v.defesa], v.chave,
					seguidas, perfil_v.falhas_para_subir);
			else
				n78.falhas_seguidas[v.chave] = nil;
				if (defesas_aprendidas[v.chave] or 1) < proximo then
					defesas_aprendidas[v.chave] = proximo;
					mudou = true;
				end
				estado.ultimo_resultado = "FALHOU com " .. NOME_NIVEL[v.defesa] .. " (" .. v.chave .. ") -> proxima vez: " .. NOME_NIVEL[perfil_v.niveis[proximo]];
			end|, "subir com 2");
troca(q|			estado.ultimo_resultado = "defendeu com " .. NOME_NIVEL[v.defesa] .. " (" .. v.chave .. ")";
|, q|			estado.ultimo_resultado = "defendeu com " .. NOME_NIVEL[v.defesa] .. " (" .. v.chave .. ")";
			if n78.falhas_seguidas[v.chave] ~= nil then n78.falhas_seguidas[v.chave] = nil; mudou = true; end -- (1.39) acerto zera a conta
|, "acerto zera");

# 4/5. limpezas de uma vez so: sai 1.37/1.38, entra a da 1.39
corta("-- (1.38) uma vez so: a ordem da Lanca mudou", "\top.zerou_omega_137 = true;\n\tsalvar_opcoes();\nend\n", "limpezas antigas");
troca(q|pcall(ligar_pontos_de_escrita);
pcall(carregar_conhecimento);
|, q|pcall(ligar_pontos_de_escrita);
pcall(carregar_conhecimento);
-- (1.39) uma vez so: as defesas aprendidas da Lanca subiram com 1 falha e com a chave da geometria; voltam ao inicio
if not op.lanca_reset_139 then
	pcall(function()
		for k in pairs(defesas_aprendidas) do
			if type(k) == "string" and string.sub(k, 1, 6) == "lanca:" then defesas_aprendidas[k] = nil; end
		end
		n78.salvar_defesas();
	end);
	op.lanca_reset_139 = true;
	salvar_opcoes();
end
|, "reset lanca");
troca(q|	zerou_omega_137 = false, -- (1.37) o Omega Planetes e o Savage ja foram zerados (uma vez so)
	lanca_ordem_138 = false, -- (1.38) as defesas aprendidas da Lanca ja mudaram para a ordem nova (uma vez so)
|, q|	lanca_reset_139 = false, -- (1.39) as defesas aprendidas da Lanca ja voltaram ao inicio (uma vez so)
|, "op flags");
print $s;
