local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.99 - |, q|	Versao 1.00 - LONG SWORD: sem a regra "sem FS abaixo do vermelho" (o SS+ISS certo sempre sobe um nivel);
	abaixo do vermelho o SS+ISS continua prioridade (e nos golpes seguidos, que pedem mais invencibilidade),
	mas o FS sai sempre que o SS+ISS nao couber. SWORD AND SHIELD / CHARGE BLADE: a guarda nao e mais
	forcada por cima de um ataque seu (so o M5, que o jogo aceita quando o seu golpe deixar).
	0.99 - |, "cab");
$s =~ s/versao_mod = "0\.99"/versao_mod = "1.00"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.99 ==/== Defesa Automatica v1.00 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.99"\)/imgui.tree_node("Defesa Automatica v1.00")/ or die "tit";

# --- LS: FS liberado abaixo do vermelho ---
troca(q|						elseif op.ls_sem_fs_abaixo_vermelho and not barra_vermelha() and not (op.somente_ss_iss and op.usar_ss_iss) then
							--[[
								(0.68) Voce notou: o FS mantem o nivel do Spirit Gauge mas ZERA o
								carregamento para o proximo, e voce ficou no amarelo a luta toda. Abaixo
								do vermelho: SS+ISS (sobe a barra) e, sem tempo para ele, ESQUIVA.
								No vermelho o FS volta a ser o 1.
							]]
							p.defesa, p.sem_combo = "esquiva", true;
							estado.ultima_decisao = "abaixo do vermelho: esquiva no lugar do FS";
						end|, q|						end
						-- (1.00) sem a regra "sem FS abaixo do vermelho": o SS+ISS certo sempre sobe um nivel, entao
						-- o FS (rapido) sai sempre que o SS+ISS nao couber|, "fs_vermelho");
troca(q|			alterado, op.ls_sem_fs_abaixo_vermelho = imgui.checkbox("Abaixo do vermelho: esquiva no lugar do FS (o FS zera o carregamento da barra)", op.ls_sem_fs_abaixo_vermelho);
			mudou_arma = mudou_arma or alterado;
|, "", "menu_fs");
troca(q|	-- (0.68) abaixo da barra vermelha o FS zera o carregamento do proximo nivel: usa a esquiva no lugar
	ls_sem_fs_abaixo_vermelho = true,
|, "", "opcao_fs");

# --- categoria da acao atual ---
troca(q|				estado.acao_nome_ultimo = nome;|, q|				estado.acao_nome_ultimo = nome;
				estado.acao_cat_ultimo = cat; -- (1.00)|, "cat");

# --- SnS / CB: nao forca a guarda por cima de um ataque seu ---
troca(q|n78.guarda_forcada = function(desde, p)
	n78.forcar_uma_vez(p, "guarda", "guarda");
	marcar("guarda");
end;|, q|n78.guarda_forcada = function(desde, p)
	-- (1.00) Sword and Shield / Charge Blade: por cima de um ataque seu so o M5 (o jogo guarda quando o
	-- golpe deixar); forcar a guarda no meio dos seus ataques travava o seu combo
	local atual = estado.acao_nome_ultimo or "";
	local atacando = estado.acao_cat_ultimo == 2 and string.find(atual, "Guard", 1, true) == nil
		and string.find(atual, "Dodge", 1, true) == nil;
	if atacando and (estado.perfil == PERFIS.espada_escudo or estado.perfil == PERFIS.lamina) then
		p.estado_pg = p.estado_pg or {};
		if not p.estado_pg.anotou_sem_forcar then
			p.estado_pg.anotou_sem_forcar = true;
			estado.acoes_diretas = estado.acoes_diretas or {};
			local chave = "guarda so M5 (ataque seu)";
			estado.acoes_diretas[chave] = (estado.acoes_diretas[chave] or 0) + 1;
		end
	else
		n78.forcar_uma_vez(p, "guarda", "guarda");
	end
	marcar("guarda");
end;|, "sns");

print $s;
