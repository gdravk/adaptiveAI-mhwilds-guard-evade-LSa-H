local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

# antecedencias vindas do perfil
troca(q{	local antes = {
		contra_ataque = op.antecedencia_contra_ms / 1000,
		guarda = op.antecedencia_guarda_ms / 1000,
		power_guard = op.antecedencia_power_ms / 1000,
		esquiva = op.antecedencia_esquiva_ms / 1000
	};}, q{	-- perfil da arma atual (definido em pode_defender)
	local perfil, chave_perfil = estado.perfil, estado.chave_perfil;

	-- quantos segundos antes do impacto cada defesa do perfil comeca
	local antes = {};
	for acao, opcao in pairs(perfil.antecedencia) do antes[acao] = (op[opcao] or 0) / 1000; end}, "antes");

# sequencia so se o perfil tiver defesa de sequencia ligada
troca(q{				if op.usar_power_guard and #sequencia >= op.pg_multi_golpes then}, q{				local acao_seq = perfil.sequencia;
				local seq_ligada = acao_seq ~= nil and (perfil.desligavel[acao_seq] == nil or op[perfil.desligavel[acao_seq]]);

				if seq_ligada and #sequencia >= op.pg_multi_golpes then}, "seq1");

troca(q{					for _, outro in ipairs(sequencia) do
						outro.nivel = 3;
						outro.defesa = "power_guard";
						outro.estado_pg = compartilhado;
						outro.janela_ini = p.tempo - antes.power_guard;
						outro.janela_fim = ultimo + depois;
					end
					estado.ultima_decisao = string.format("Power Guard na SEQUENCIA de %d golpes (%.1fs) em %s",
						#sequencia, ultimo - p.tempo, tostring(p.origem));
				else
					p.nivel = escolher_defesa(p, m);
					p.defesa = p.nivel and NIVEIS[p.nivel] or nil;
					p.estado_pg = {};}, q{					for _, outro in ipairs(sequencia) do
						outro.nivel = posicao_no_perfil(perfil, acao_seq);
						outro.defesa = acao_seq;
						outro.perfil = chave_perfil;
						outro.chave = chave_do_golpe(chave_perfil, m, outro);
						outro.estado_pg = compartilhado;
						outro.janela_ini = p.tempo - (antes[acao_seq] or 0);
						outro.janela_fim = ultimo + depois;
					end
					estado.ultima_decisao = string.format("%s na SEQUENCIA de %d golpes (%.1fs) em %s",
						NOME_NIVEL[acao_seq], #sequencia, ultimo - p.tempo, tostring(p.origem));
				else
					p.nivel = escolher_defesa(p, m, chave_perfil, perfil);
					p.defesa = p.nivel and perfil.niveis[p.nivel] or nil;
					p.perfil = chave_perfil;
					p.chave = chave_do_golpe(chave_perfil, m, p);
					p.estado_pg = {};}, "seq2");

# execucao pelo perfil
troca(q{			local defesa = p.defesa;
			if p.janela_ini ~= nil then
				-- parte de uma sequencia: Power Guard continuo da primeira ate a ultima
				if momento >= p.janela_ini and momento <= p.janela_fim then
					marcar_power_guard(momento - p.janela_ini, p.estado_pg);
				end
			elseif defesa == "esquiva" then
				-- um toque no tempo certo
				if falta <= antes.esquiva and falta >= antes.esquiva - 0.1 then vai_esquivar = true; end
			elseif defesa ~= nil and falta <= antes[defesa] and falta >= -depois then
				local desde = antes[defesa] - falta;
				if defesa == "power_guard" then
					marcar_power_guard(desde, p.estado_pg);
				elseif defesa == "contra_ataque" then
					marcar_contra_ataque(desde);
				else
					marcar("guarda");
				end
			end}, q{			local defesa = p.defesa;
			local executar = defesa and perfil.executar and perfil.executar[defesa];

			if p.perfil ~= nil and p.perfil ~= chave_perfil then
				-- golpe decidido com outra arma (voce trocou de arma no meio): ignora
			elseif p.janela_ini ~= nil then
				-- parte de uma sequencia: a defesa fica continua da primeira ate a ultima
				if executar and momento >= p.janela_ini and momento <= p.janela_fim then
					executar(momento - p.janela_ini, p);
				end
			elseif defesa == "esquiva" then
				-- um toque no tempo certo
				if falta <= antes.esquiva and falta >= antes.esquiva - 0.1 then vai_esquivar = true; end
			elseif executar and falta <= (antes[defesa] or 0) and falta >= -depois then
				executar((antes[defesa] or 0) - falta, p);
			end}, "executar");

# conferencia usa o perfil gravado na verificacao
troca(q{			local proximo = math.min((v.nivel or 1) + 1, 4);
			if (defesas_aprendidas[v.chave] or 1) < proximo then
				defesas_aprendidas[v.chave] = proximo;
				mudou = true;
			end
			estado.ultimo_resultado = "FALHOU com " .. NOME_NIVEL[v.defesa] .. " (" .. v.chave .. ") -> proxima vez: " .. NOME_NIVEL[NIVEIS[proximo]];}, q{			local perfil_v = PERFIS[v.perfil] or PERFIS.lanca;
			local proximo = math.min((v.nivel or 1) + 1, #perfil_v.niveis);
			if (defesas_aprendidas[v.chave] or 1) < proximo then
				defesas_aprendidas[v.chave] = proximo;
				mudou = true;
			end
			estado.ultimo_resultado = "FALHOU com " .. NOME_NIVEL[v.defesa] .. " (" .. v.chave .. ") -> proxima vez: " .. NOME_NIVEL[perfil_v.niveis[proximo]];}, "conferir");

# impacto usa a chave gravada no golpe
troca(q{				chave = tostring(m.id) .. ":" .. tostring(casado.origem),
				nivel = casado.nivel, defesa = casado.defesa, em = os.clock()}, q{				chave = casado.chave or ("lanca:" .. tostring(m.id) .. ":" .. tostring(casado.origem)),
				perfil = casado.perfil, nivel = casado.nivel, defesa = casado.defesa, em = os.clock()}, "impacto");

# migracao das chaves antigas (sem arma) para a lanca
troca(q{	if type(salvo) == "table" and type(salvo.golpes) == "table" then defesas_aprendidas = salvo.golpes; end}, q{	if type(salvo) == "table" and type(salvo.golpes) == "table" then
		-- versao 0.24: as chaves passaram a ter a arma na frente ("lanca:27:50:210").
		-- Chaves antigas ("27:50:210") eram todas da lanca.
		for chave, nivel in pairs(salvo.golpes) do
			if string.match(chave, "^%d") then chave = "lanca:" .. chave; end
			defesas_aprendidas[chave] = nivel;
		end
	end}, "migracao");

# executores do perfil da lanca (depois das funcoes de marcar)
troca(q{local NOME_NIVEL = NOME_ACAO;}, q{-- Como a lanca executa cada defesa ("desde" = segundos desde o inicio da defesa; "p" = o golpe)
PERFIS.lanca.executar = {
	contra_ataque = function(desde, p) marcar_contra_ataque(desde); end,
	guarda = function(desde, p) marcar("guarda"); end,
	power_guard = function(desde, p) marcar_power_guard(desde, p.estado_pg); end
	-- a esquiva e tratada a parte (toque gravado, exclusivo)
};

local NOME_NIVEL = NOME_ACAO;}, "executores");
print $s;
