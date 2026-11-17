local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }
sub troca_todas { my ($velho, $novo, $nome) = @_; my $n = ($s =~ s/\Q$velho\E/$novo/g); die "$nome nao achado" unless $n; return $n; }

troca(q|	Versao 1.25 - VERIFICACAO PARA TODOS OS MONSTROS:|,
q|	Versao 1.26 - "LEVOU O GOLPE" PELO JOGO, NAO PELA VIDA: skills e itens mudam quanto de vida o golpe tira
	(Divine Blessing, escudo / barreira do Gogmazios, defesa, Rocksteady Mantle...) e efeitos tiram vida sem
	golpe (veneno, fogo, sangramento, bolhas, terreno). Agora "o golpe acertou voce" vem do proprio jogo
	(app.HunterCharacter.evHit_Damage): acertou = o jogo processou o golpe em voce sem esquiva e sem guarda,
	tire ele 0 ou 100 de vida. A vida virou so reserva (se esse aviso do jogo nao vier). Assim, para qualquer
	skill, escudo ou monstro: golpe absorvido pelo escudo = a defesa falhou (antes contava como certa); perda
	de vida sem golpe = efeito, nao conta. Tambem: 1. dano no ISS so conta se veio DEPOIS do ISS comecar (com
	Rocksteady voce leva o golpe e continua na postura - o golpe antigo marcava o ISS como falha); 2. esquivas
	diferentes (bolhas do Mizutsune, mantos, Evade Extender) contam como esquiva: o mod aceita qualquer acao de
	esquiva do jogo e qualquer invencibilidade que nao seja do FS (antes uma esquiva com outro nome contava
	como "nao saiu" e, 3 vezes seguidas, o mod trocava a esquiva pelos botoes); 3. qualquer esquiva que nao
	seja FS zera a contagem dos 3 FS seguidos. O relatorio mostra os golpes do jogo em voce (acertou / guardou /
	evitou) e os golpes que acertaram sem tirar vida (escudo / skill).
	1.25 - VERIFICACAO PARA TODOS OS MONSTROS:|, "cabecalho");
troca_todas(q|versao_mod = "1.25"|, q|versao_mod = "1.26"|, "versao");

# gancho do jogo: golpe processado em voce
troca(q|	sdk.hook(metodo, function(args)
		local guardado = thread.get_hook_storage();
		if guardado ~= nil then guardado.cac_082 = args[2]; end
	end, function(retorno)
		pcall(function()
			local guardado = thread.get_hook_storage();
			local ptr = guardado and guardado.cac_082;
			if ptr == nil then return; end
			guardado.cac_082 = nil;
			local cacador = meu_cacador();
			if cacador == nil or sdk.to_managed_object(ptr) ~= cacador then return; end
			local info = cacador:call("get_DamageInfo");
			local reacao = info and tonumber(info:get_field("_GuardReaction")) or 0;
			if reacao ~= 0 then
				local nome = nome_reacao(reacao);
				estado.guarda_jogo_em = os.clock();
				estado.reacoes_jogo = estado.reacoes_jogo or {};
				estado.reacoes_jogo[nome] = (estado.reacoes_jogo[nome] or 0) + 1;
			end
		end);
		return retorno;
	end);|,
q|	sdk.hook(metodo, function(args)
		local guardado = thread.get_hook_storage();
		if guardado ~= nil then guardado.cac_082, guardado.hit_126 = args[2], args[3]; end
	end, function(retorno)
		pcall(function()
			local guardado = thread.get_hook_storage();
			local ptr = guardado and guardado.cac_082;
			if ptr == nil then return; end
			local hit_ptr = guardado.hit_126;
			guardado.cac_082, guardado.hit_126 = nil, nil;
			local cacador = meu_cacador();
			if cacador == nil or sdk.to_managed_object(ptr) ~= cacador then return; end
			local info = cacador:call("get_DamageInfo");
			local reacao = info and tonumber(info:get_field("_GuardReaction")) or 0;
			if reacao ~= 0 then
				local nome = nome_reacao(reacao);
				estado.guarda_jogo_em = os.clock();
				estado.reacoes_jogo = estado.reacoes_jogo or {};
				estado.reacoes_jogo[nome] = (estado.reacoes_jogo[nome] or 0) + 1;
			end
			--[[
				(1.26) O GOLPE ACERTOU VOCE? Resposta do jogo: 0 = o golpe foi processado em voce (nao
				esquivou); outro valor = evitou (invencibilidade). Guarda (reacao) e contra-ataque (guarda de
				skill) nao sao acerto. Vale qualquer skill: escudo, Divine Blessing, Rocksteady, defesa -
				o golpe acertou mesmo se tirou 0 de vida. Golpe sem forca (rugido, vento) nao conta.
			]]
			local codigo = 0;
			pcall(function() codigo = sdk.to_int64(retorno) & 0xFFFFFFFF; end);
			local forca, guarda_skill, amigo = nil, false, false;
			pcall(function()
				local hit = hit_ptr and sdk.to_managed_object(hit_ptr);
				local dados = hit and hit:call("get_AttackData");
				if dados ~= nil then forca = tonumber(dados:get_field("_Attack")); end
				-- golpe de outro jogador ou de um Palico (fogo amigo) nao e golpe de monstro
				local dono = hit and hit:call("getActualAttackOwner");
				if dono ~= nil then
					for _, nome_t in ipairs({ "app.HunterCharacter", "app.OtomoCharacter" }) do
						local t = sdk.typeof(nome_t);
						if t ~= nil and dono:call("getComponent(System.Type)", t) ~= nil then amigo = true; end
					end
				end
			end);
			pcall(function() guarda_skill = info ~= nil and info:get_field("_IsSkillGuard") == true; end);
			if amigo or (forca ~= nil and forca <= 0) then return; end
			local tipo_r = (reacao ~= 0 or guarda_skill) and "guardou" or ((codigo == 0) and "acertou" or "evitou");
			estado.golpes_jogo = estado.golpes_jogo or {};
			estado.golpes_jogo[tipo_r] = (estado.golpes_jogo[tipo_r] or 0) + 1;
			if tipo_r == "acertou" then
				estado.golpe_jogo_em = agora();
				estado.levou_dano_em = os.clock();
				estado.golpe_jogo_pendente = { em = os.clock(), vida = estado.vida_anterior };
			end
		end);
		return retorno;
	end);
	estado.ganchos_078.golpe_jogo = true; -- (1.26)|, "gancho");

# vida: reserva
troca(q|			local golpe_recente = agora() - math.max(estado.contato_em_mim_em or -100, estado.ultimo_impacto_em or -100) <= 0.5;|,
q|			-- (1.26) com o aviso do jogo (evHit_Damage) so ele diz se houve golpe; sem ele, o contato e o impacto
			local jogo_avisa = (estado.ganchos_078 or {}).golpe_jogo == true;
			local golpe_recente = agora() - (estado.golpe_jogo_em or -100) <= 0.5
				or (not jogo_avisa and agora() - math.max(estado.contato_em_mim_em or -100, estado.ultimo_impacto_em or -100) <= 0.5);
			-- (1.26) golpe que acertou sem tirar vida (escudo, skill): anota e mostra na lista de danos
			local gp = estado.golpe_jogo_pendente;
			if gp ~= nil and os.clock() - gp.em > 0.3 then
				estado.golpe_jogo_pendente = nil;
				if gp.vida ~= nil and vida >= gp.vida - 0.5 then
					estado.golpes_sem_vida = (estado.golpes_sem_vida or 0) + 1;
					estado.danos_log = estado.danos_log or {};
					table.insert(estado.danos_log, 1, string.format("%s - GOLPE SEM PERDER VIDA (escudo / skill) - vida %.0f - sua animacao %s - ultima decisao: %s",
						os.date("%H:%M:%S"), vida, tostring(combo.animacao), tostring(estado.ultima_decisao)));
					if #estado.danos_log > 60 then table.remove(estado.danos_log); end
				end
			end|, "vida reserva");
troca(q|			elseif estado.vida_anterior ~= nil and vida < estado.vida_anterior - 0.5 then
				estado.levou_dano_em = os.clock();|,
q|			elseif estado.vida_anterior ~= nil and vida < estado.vida_anterior - 0.5 then
				-- (1.26) o jogo ja marcou o golpe: mantem a hora do golpe (a vida cai um quadro depois)
				if agora() - (estado.golpe_jogo_em or -100) > 0.5 then estado.levou_dano_em = os.clock(); end|, "nao sobrescreve");

# ISS: so dano depois do ISS
troca(q|		elseif estado.levou_dano_em ~= ssiss.dano_antes then resultado = "LEVOU DANO";|,
q|		elseif estado.levou_dano_em ~= ssiss.dano_antes and (estado.levou_dano_em or 0) >= (ssiss.iss_em or 0) - 0.05 then resultado = "LEVOU DANO"; -- (1.26) so dano depois do ISS|, "iss");

# FS seguidos: qualquer esquiva que nao seja FS zera
troca(q|			elseif tipo == 0 or tipo == 1 then
				estado.fs_seguidos = 0;|,
q|			elseif tipo ~= 6 and tipo ~= 7 then -- (1.26) qualquer esquiva que nao seja FS (bolhas, mantos...)
				estado.fs_seguidos = 0;|, "fs zera");

# esquiva forcada: qualquer acao de esquiva ou invencibilidade nova (nao FS)
troca(q|		estado.forcado_pendente = { tipo = tipo, em = os.clock(), wt = tipo_arma(), padrao = padrao,|,
q|		estado.forcado_pendente = { tipo = tipo, em = os.clock(), em_agora = agora(), wt = tipo_arma(), padrao = padrao,|, "em_agora");
troca(q|				or (fp.tipo == "esquiva" and (nome == "cKijinDodge" or nome == "cAxeDodge"|,
q|				or (fp.tipo == "esquiva" and (string.find(nome, "Dodge", 1, true) ~= nil -- (1.26) esquivas com outro nome (bolhas, mantos)
					or (function()
						local inv_f = n78.invencibilidade or {};
						return inv_f.desde ~= nil and fp.em_agora ~= nil and inv_f.desde >= fp.em_agora - 0.02 and inv_f.tipo ~= 6 and inv_f.tipo ~= 7;
					end)()
					or nome == "cKijinDodge" or nome == "cAxeDodge"|, "confere esquiva");

# relatorio
troca(q|		ct.passou or 0, ct.falhou or 0, ct["na invencibilidade"] or 0));|,
q|		ct.passou or 0, ct.falhou or 0, ct["na invencibilidade"] or 0));
	local gj = estado.golpes_jogo or {}; -- (1.26)
	linha(string.format("Golpes do jogo em voce (evHit_Damage %s): acertou %d (sem perder vida, escudo / skill: %d), guardou %d, evitou %d",
		(estado.ganchos_078 or {}).golpe_jogo and "ok" or "NAO", gj.acertou or 0, estado.golpes_sem_vida or 0, gj.guardou or 0, gj.evitou or 0));|, "relatorio");
print $s;
