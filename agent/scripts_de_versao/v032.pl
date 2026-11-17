local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

# --- versao
$s =~ s/Versao 0\.31 - Guard Up/Versao 0.32 - guarda segurada em golpes seguidos; 0.31 - Guard Up/ or die "cab";
$s =~ s/versao_mod = "0\.31"/versao_mod = "0.32"/ or die "vm";
$s =~ s/== Defesa Automatica v0\.31 ==/== Defesa Automatica v0.32 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.31"\)/imgui.tree_node("Defesa Automatica v0.32")/ or die "tit";

# --- opcoes
troca(q|	tenho_guard_up = true,|, q|	tenho_guard_up = true,

	--[[
		GOLPES SEGUIDOS (0.32): antes a guarda era solta entre um golpe e outro (250 ms depois
		de cada impacto) e o contra-ataque era usado no meio das sequencias. Em combos rapidos
		(ex.: dois golpes rapidos e a correntada dupla do Arkveld) a guarda caia e o golpe
		seguinte acertava. Agora, depois que a guarda sobe:
		  - continua segurada enquanto houver outro golpe previsto em ate "ponte_guarda_ms";
		  - continua segurada por "manter_apos_golpe_ms" depois de cada golpe que chega em
		    voce (o golpe seguinte do combo pode ainda nao ter sido previsto);
		  - no meio de uma sequencia o contra-ataque vira guarda (o contra-ataque e um ataque
		    e deixa voce aberto para o golpe seguinte).
	]]
	ponte_guarda_ms = 900,
	manter_apos_golpe_ms = 600,|, "op");

# --- momento do ultimo golpe que chegou em voce
troca(q|	local momento = agora();

	local guarda, forca = 0, nil;|, q|	local momento = agora();
	estado.ultimo_impacto_em = momento; -- (0.32) usado para manter a guarda em golpes seguidos

	local guarda, forca = 0, nil;|, "impacto");

# --- defesas que seguram a guarda
troca(q|local NOME_NIVEL = NOME_ACAO;|, q|local NOME_NIVEL = NOME_ACAO;

-- (0.32) defesas que seguram o botao de guarda (M5)
local DEFESAS_DE_GUARDA = { guarda = true, contra_ataque = true, power_guard = true };|, "def_guarda");

# --- contra-ataque vira guarda no meio de sequencias
troca(q|					p.estado_pg = {};
					if p.defesa ~= nil then|, q|					p.estado_pg = {};

					-- (0.32) contra-ataque no meio de golpes seguidos vira guarda
					if p.defesa == "contra_ataque" then
						local ponte = op.ponte_guarda_ms / 1000;
						local seguido = momento - (estado.ultimo_impacto_em or -100) < ponte;
						for _, outro in ipairs(m.previstos) do
							if outro ~= p and math.abs(outro.tempo - p.tempo) < ponte then seguido = true; end
						end
						local pos_guarda = posicao_no_perfil(perfil, "guarda");
						if seguido and pos_guarda ~= nil then
							p.nivel, p.defesa = pos_guarda, "guarda";
						end
					end

					if p.defesa ~= nil then|, "contra_vira_guarda");

# --- anota quando a guarda esta sendo segurada
troca(q|					executar(momento - p.janela_ini, p);|, q|					executar(momento - p.janela_ini, p);
					if DEFESAS_DE_GUARDA[defesa] then estado.ultima_guarda_em = momento; end|, "seq_marca");

troca(q|				if executar((antes[defesa] or 0) - falta, p) == "indisponivel" then|, q|				local resultado = executar((antes[defesa] or 0) - falta, p);
				if resultado ~= "indisponivel" and DEFESAS_DE_GUARDA[defesa] then estado.ultima_guarda_em = momento; end
				if resultado == "indisponivel" then|, "exec_marca");

# --- ponte de guarda
troca(q|	-- esquiva: solta o resto (senao o jogo pode fazer outra coisa com o Espaco)
	if vai_esquivar then|, q|	--[[
		(0.32) PONTE DE GUARDA: a guarda estava segurada ate o quadro anterior? Continua
		segurada se vem outro golpe logo (previsto) ou se um golpe acabou de chegar em voce
		(o proximo do combo pode ainda nao ter sido previsto).
	]]
	if not vai_esquivar and posicao_no_perfil(perfil, "guarda") ~= nil
		and momento - (estado.ultima_guarda_em or -100) < 0.1 then
		local ponte = op.ponte_guarda_ms / 1000;
		local continuar = momento - (estado.ultimo_impacto_em or -100) < op.manter_apos_golpe_ms / 1000;
		if not continuar then
			for _, m in pairs(monstros) do
				local longe = op.checar_distancia and m.distancia ~= nil;
				for _, p in ipairs(m.previstos) do
					local falta = p.tempo - momento;
					local alcanca = not longe or (p.dist_max or 0) <= 0 or m.distancia <= p.dist_max + op.margem_distancia;
					if falta > 0 and falta <= ponte and alcanca and p.defesa ~= "esquiva" then continuar = true; end
				end
			end
		end
		if continuar then
			marcar("guarda");
			estado.ultima_guarda_em = momento;
		end
	end

	-- esquiva: solta o resto (senao o jogo pode fazer outra coisa com o Espaco)
	if vai_esquivar then|, "ponte");

# --- ajustes no menu da lanca e da espada e escudo
troca(q|		so_de_frente = { contra_ataque = true, guarda = true },
|, q|		so_de_frente = { contra_ataque = true, guarda = true },
		tempos_extras = {
			{ opcao = "ponte_guarda_ms", nome = "Golpes seguidos: manter a guarda se o proximo vier em ate (ms)", maximo = 2000 },
			{ opcao = "manter_apos_golpe_ms", nome = "Golpes seguidos: manter a guarda depois de cada golpe (ms)", maximo = 2000 }
		},
|, "lanca_menu");
troca(q|		so_de_frente = { guarda = true },
		forte = "esquiva",|, q|		so_de_frente = { guarda = true },
		forte = "esquiva",
		tempos_extras = {
			{ opcao = "ponte_guarda_ms", nome = "Golpes seguidos: manter a guarda se o proximo vier em ate (ms)", maximo = 2000 },
			{ opcao = "manter_apos_golpe_ms", nome = "Golpes seguidos: manter a guarda depois de cada golpe (ms)", maximo = 2000 }
		},|, "sns_menu");

print $s;
