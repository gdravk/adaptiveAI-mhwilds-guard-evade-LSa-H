local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.93 - HAMMER:|, q|	Versao 0.94 - O relatorio (Prints) lista as acoes do jogo que voce fez com cada arma (nome e numero),
	para achar o nome do Charged Step do Hammer (nao tem "Step" no nome).
	0.93 - HAMMER:|, "cab");
$s =~ s/versao_mod = "0\.93"/versao_mod = "0.94"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.93 ==/== Defesa Automatica v0.94 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.93"\)/imgui.tree_node("Defesa Automatica v0.94")/ or die "tit";

troca(q|		-- (0.89) numero de cada acao pelo nome do jogo + conferencia das acoes forcadas
		if cat ~= nil and idx ~= nil and type(nome) == "string" then|, q|		-- (0.94) acoes vistas nesta sessao, por arma (nome, numero e quantas vezes comecou)
		if cat ~= nil and idx ~= nil and type(nome) == "string" then
			local wt_v = tostring(cacador:call("get_WeaponType"));
			estado.acoes_vistas = estado.acoes_vistas or {};
			local por_v = estado.acoes_vistas[wt_v] or { qtd = 0, lista = {} };
			estado.acoes_vistas[wt_v] = por_v;
			local chave_v = nome .. "(" .. tostring(cat) .. "," .. tostring(idx) .. ")";
			if estado.acao_vista_antes ~= chave_v then
				estado.acao_vista_antes = chave_v;
				if por_v.lista[chave_v] ~= nil then por_v.lista[chave_v] = por_v.lista[chave_v] + 1;
				elseif por_v.qtd < 80 then por_v.lista[chave_v], por_v.qtd = 1, por_v.qtd + 1; end
			end
		end
		-- (0.89) numero de cada acao pelo nome do jogo + conferencia das acoes forcadas
		if cat ~= nil and idx ~= nil and type(nome) == "string" then|, "vistas");

troca(q|		linha("Forcados: " .. (#fz > 0 and table.concat(fz, ", ") or "nenhum") .. " - acoes aprendidas: " .. (#ap > 0 and table.concat(ap, ", ") or "nenhuma ainda"));|,
q|		linha("Forcados: " .. (#fz > 0 and table.concat(fz, ", ") or "nenhum") .. " - acoes aprendidas: " .. (#ap > 0 and table.concat(ap, ", ") or "nenhuma ainda"));
		-- (0.94) acoes do jogo vistas nesta sessao (para achar o nome do Charged Step e de outras acoes)
		for wt_v, por_v in pairs(estado.acoes_vistas or {}) do
			local itens_v = {};
			for chave_v, vezes_v in pairs(por_v.lista) do itens_v[#itens_v + 1] = chave_v .. " x" .. vezes_v; end
			table.sort(itens_v);
			linha("Acoes vistas (arma " .. wt_v .. "): " .. table.concat(itens_v, ", "));
		end|, "linha");

print $s;
