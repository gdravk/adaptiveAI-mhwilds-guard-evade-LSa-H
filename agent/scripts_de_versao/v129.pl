local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }
sub troca_todas { my ($velho, $novo, $nome) = @_; my $n = ($s =~ s/\Q$velho\E/$novo/g); die "$nome nao achado" unless $n; return $n; }

troca(q|	Versao 1.28 - ACERTOS QUE SO DERAM CERTO COM INVENCIBILIDADE MAIOR:|,
q|	Versao 1.29 - VERIFICACAO: 1. ALCANCE PELA AREA TAMBEM NOS GOLPES JA APRENDIDOS: o alcance de um golpe
	aprendido por contato era so a maior distancia em que ele ja tinha acertado voce (+3 m de margem) e a area
	de ataque nunca corrigia isso. Na morte para o Gore Magala (1.20) o golpe 2:132 tinha acertado ate 10,1 m
	e chegou a 13,3 m: o mod achou que nao chegava e nao soltou o ISS. Agora toda area de ataque guarda o
	alcance da animacao (o ponto mais longe da area ate o monstro) e o golpe previsto usa o maior dos dois -
	para qualquer monstro, grande ou pequeno, e sem precisar apanhar de longe. 2. "o jogo avisa o golpe"
	(1.26) so vale depois de o aviso chegar de verdade nesta sessao (antes bastava o gancho existir: se o
	jogo nunca avisasse, golpes pequenos de verdade seriam ignorados).
	1.28 - ACERTOS QUE SO DERAM CERTO COM INVENCIBILIDADE MAIOR:|, "cabecalho");
troca_todas(q|versao_mod = "1.28"|, q|versao_mod = "1.29"|, "versao");

# 2. aviso do jogo so vale se chegou
troca(q|			local jogo_avisa = (estado.ganchos_078 or {}).golpe_jogo == true;|,
q|			local jogo_avisa = next(estado.golpes_jogo or {}) ~= nil; -- (1.29) o aviso ja chegou nesta sessao|, "jogo avisa");

# 1. exporta a tabela de areas
troca(q|n78.resumo_ativacoes = resumo_ativacoes;
|, q|n78.resumo_ativacoes = resumo_ativacoes;
n78.ativacoes_tab = function() return ativacoes; end; -- (1.29) alcance das animacoes
n78.marcar_ativacoes = function() ativacoes_mudou = true; end;
|, "exporta");

# alcance guardado em toda area (antes da regra do contato)
troca(q|	local ofs = em - h.inicio;
	if ofs < 0 or ofs > AJUSTES.idade_maxima_animacao then return; end
	local tempo = ofs + 0.10;|,
q|	local ofs = em - h.inicio;
	if ofs < 0 or ofs > AJUSTES.idade_maxima_animacao then return; end
	-- (1.29) o alcance da animacao vale tambem para os golpes ja aprendidos por contato
	pcall(function()
		local tab = n78.ativacoes_tab();
		tab[m.variante] = tab[m.variante] or {};
		local reg = tab[m.variante][h.chave] or { n = 0, d = {} };
		tab[m.variante][h.chave] = reg;
		local alc = arredondar(grupo.alcance, 1);
		if alc > (reg.alc or 0) then reg.alc = alc; n78.marcar_ativacoes(); end
	end);
	local tempo = ofs + 0.10;|, "guarda alcance");

troca(q|-- (1.20) de onde veio um dano (para o relatorio)|,
q|-- (1.29) maior alcance medido pela area de ataque nesta animacao (0 = nunca vista)
estado.alcance_anim = function(variante, chave)
	local tab = n78.ativacoes_tab();
	local por_v = tab[tostring(variante)];
	local reg = por_v and por_v[chave];
	return (reg and tonumber(reg.alc)) or 0;
end

-- (1.20) de onde veio um dano (para o relatorio)|, "funcao alcance");

troca(q|				local dist_max = 0;
				for _, medicao in ipairs(g.lista) do
					if (medicao[3] or 0) > dist_max then dist_max = medicao[3]; end
				end
|, q|				local dist_max = 0;
				for _, medicao in ipairs(g.lista) do
					if (medicao[3] or 0) > dist_max then dist_max = medicao[3]; end
				end
				-- (1.29) a area de ataque desta animacao pode ir mais longe do que os golpes que ja acertaram voce
				if estado.alcance_anim ~= nil then
					local ok_a, alc_a = pcall(estado.alcance_anim, m.variante, animacao);
					if ok_a and type(alc_a) == "number" and alc_a > dist_max then dist_max = alc_a; end
				end
|, "usa alcance");
print $s;
