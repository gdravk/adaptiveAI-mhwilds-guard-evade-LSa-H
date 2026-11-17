local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.81 - |, q|	Versao 0.82 - (tudo so lendo o jogo / botoes reais)
	  - PROJETEIS (bolas de fogo, raios...): o mod tambem ve a area de ataque deles;
	  - ALCANCE E GEOMETRIA: a area de ataque ligada e acompanhada quadro a quadro; o mod mede a
	    distancia ate o seu corpo e, se ela vem chegando, preve o contato (funciona ate em golpe que
	    o mod nunca viu - opcao "Defesa pela geometria");
	  - RUGIDOS: o rugido (sem dano) e reconhecido pelo tipo do golpe e tambem e aprendido;
	  - MONSTRO COM RAIVA / CANSADO: o mod mede se os golpes chegam antes ou depois nesses estados
	    e corrige a previsao sozinho; VELOCIDADE das animacoes medida por monstro;
	  - Long Sword: nome real de cada golpe seu (jogo) e tabela de golpes da LS salva em arquivo;
	  - resultado da guarda direto do jogo (perfeita, normal, guard point, power guard);
	  - funcoes do jogo achadas mesmo se uma atualizacao mudar o final do nome;
	  - leitura da sua animacao logo antes da tela ser desenhada (FS / ISS mais precisos);
	  - aba de pesquisa no Diagnostico (acao, animacao e comparar valores ao vivo)
	0.81 - |, "cab");
$s =~ s/versao_mod = "0\.81"/versao_mod = "0.82"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.81 ==/== Defesa Automatica v0.82 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.81"\)/imgui.tree_node("Defesa Automatica v0.82")/ or die "tit";

troca(q|	aprender_por_ativacao = true,|, q|	aprender_por_ativacao = true,
	defesa_geometria = true, -- (0.82) contato previsto pela geometria vira golpe previsto (botoes reais)|, "op");

# ---------------------------------------------------- 14. achar funcao mesmo com nome mudado
troca(q|-- Animacao atual: numero, banco (grupo), quadro atual e final
local tipo_motion = sdk.typeof("via.motion.Motion");|, q|--[[
	(0.82) ATUALIZACOES DO JOGO: a cada atualizacao a Capcom pode mudar o FINAL do nome das funcoes
	(ex.: "getBadConditionByHitDef280817"). O mod procura primeiro pelo nome exato e, se nao achar,
	pelo comeco do nome. As achadas pelo comeco aparecem no relatorio.
]]
local function achar_metodo(nome_tipo, nome_metodo)
	local tipo = sdk.find_type_definition(nome_tipo);
	if tipo == nil then return nil; end
	local metodo = nil;
	pcall(function() metodo = tipo:get_method(nome_metodo); end);
	if metodo ~= nil then return metodo; end
	local base = string.match(nome_metodo, "^([^%(]+)") or nome_metodo;
	pcall(function()
		for _, candidato in ipairs(tipo:get_methods()) do
			local n = candidato:get_name();
			if type(n) == "string" and string.sub(n, 1, #base) == base then metodo = candidato; break; end
		end
	end);
	if metodo ~= nil then
		estado.metodos_por_prefixo = estado.metodos_por_prefixo or {};
		estado.metodos_por_prefixo[#estado.metodos_por_prefixo + 1] = nome_tipo .. "." .. base;
	end
	return metodo;
end
estado.achar_metodo = achar_metodo;

-- Animacao atual: numero, banco (grupo), quadro atual e final
local tipo_motion = sdk.typeof("via.motion.Motion");|, "achar");

# 6. velocidade da animacao
troca(q|	local ok_dados, id, banco, quadro, fim = pcall(function()
		return camada:call("get_MotionID"), camada:call("get_MotionBankID"),
			camada:call("get_Frame"), camada:call("get_EndFrame");
	end);
	if not ok_dados then return nil; end

	return id, banco, quadro, fim;|, q|	local ok_dados, id, banco, quadro, fim = pcall(function()
		return camada:call("get_MotionID"), camada:call("get_MotionBankID"),
			camada:call("get_Frame"), camada:call("get_EndFrame");
	end);
	if not ok_dados then return nil; end
	local vel = nil;
	pcall(function() vel = camada:call("get_Speed"); end); -- (0.82)

	return id, banco, quadro, fim, vel;|, "vel_ler");

troca(q|			local id, banco, quadro, fim = animacao_de(m.objeto);
			if id ~= nil then
				local quadro_antes = m.quadro; -- (0.78)|, q|			local id, banco, quadro, fim, vel = animacao_de(m.objeto);
			if id ~= nil then
				m.velocidade = tonumber(vel); -- (0.82)
				local quadro_antes = m.quadro; -- (0.78)|, "vel_monstro");

troca(q|				if animacao ~= m.animacao or reiniciou then
					m.animacao, m.animacao_desde = animacao, momento;|, q|				if animacao ~= m.animacao or reiniciou then
					m.animacao, m.animacao_desde = animacao, momento;
					-- (0.82) velocidade das animacoes de golpe deste monstro
					if m.velocidade ~= nil and grupos_de(m.variante, animacao) ~= nil then
						estado.velocidades = estado.velocidades or {};
						local v = estado.velocidades[m.variante] or { n = 0, soma = 0, menor = 99, maior = 0 };
						v.n, v.soma = v.n + 1, v.soma + m.velocidade;
						v.menor, v.maior = math.min(v.menor, m.velocidade), math.max(v.maior, m.velocidade);
						estado.velocidades[m.variante] = v;
					end|, "vel_stats");

# 5. contexto do monstro guardado + raiva pela resposta do proprio jogo
troca(q|		monstros[chave] = m;|, q|		monstros[chave] = m;
		m.contexto = contexto; -- (0.82) para ler raiva / cansaco|, "ctx");
troca(q|sdk.hook(sdk.find_type_definition("app.cEnemyContext"):get_method("get_IsAngry"), function(argumentos)
	pcall(function() conhecer_monstro(sdk.to_managed_object(argumentos[2])); end);
end, function(retorno)
	return retorno;
end);|, q|sdk.hook(achar_metodo("app.cEnemyContext", "get_IsAngry"), function(argumentos)
	pcall(function() conhecer_monstro(sdk.to_managed_object(argumentos[2])); end);
	local guardado = thread.get_hook_storage();
	if guardado ~= nil then guardado.ctx_082 = argumentos[2]; end
end, function(retorno)
	-- (0.82) a resposta do jogo diz se o monstro esta com raiva
	pcall(function()
		local guardado = thread.get_hook_storage();
		local ptr = guardado and guardado.ctx_082;
		if ptr == nil then return; end
		guardado.ctx_082 = nil;
		local m = monstros[endereco_de(sdk.to_managed_object(ptr))];
		if m ~= nil then m.raiva = (sdk.to_int64(retorno) & 1) == 1; end
	end);
	return retorno;
end);|, "raiva");

# 5. correcao da previsao por estado (nova_animacao)
troca(q|				novos[#novos + 1] = { tempo = momento + g.tempo, guarda = g.guarda, vezes = g.vezes, origem = animacao,
					dist_max = dist_max };|, q|				local correcao = 0; -- (0.82) raiva / cansaco
				if estado.n82 ~= nil and estado.n82.correcao ~= nil then
					local ok_c, valor_c = pcall(estado.n82.correcao, m);
					if ok_c and type(valor_c) == "number" then correcao = valor_c; end
				end
				novos[#novos + 1] = { tempo = momento + g.tempo + correcao, guarda = g.guarda, vezes = g.vezes, origem = animacao,
					dist_max = dist_max, correcao = correcao };|, "correcao");
troca(q|	if menor ~= nil and math.abs(menor) <= 0.3 then
		estado.ultimo_erro_ms = math.floor(menor * 1000 + 0.5);|, q|	if menor ~= nil and math.abs(menor) <= 0.3 then
		if estado.n82 ~= nil and estado.n82.anotar_erro ~= nil then
			pcall(estado.n82.anotar_erro, m, menor + (casado.correcao or 0)); -- (0.82) erro sem a correcao
		end
		estado.ultimo_erro_ms = math.floor(menor * 1000 + 0.5);|, "erro");

# 14. ganchos principais pelo achar_metodo
troca(q|local funcao_impacto = tipo_monstro_char and tipo_monstro_char:get_method("evHit_AttackPreProcess");|,
q|local funcao_impacto = achar_metodo("app.EnemyCharacter", "evHit_AttackPreProcess");|, "impacto");

# ---------------------------------------------------- 4. rugidos (tipo do golpe) + 1. projeteis
troca(q|-- dados do golpe (forca e tipo de guarda) da primeira area ligada
local function dados_da_area(a)
	local ataque, guarda = nil, 0;
	pcall(function()
		local col = a.rsc:call("getCollidable", a.res, a.req, 0);
		local dados = col and col:call("get_UserData");
		dados = dados and dados:call("get_ParentUserData");
		if dados ~= nil and dados:get_type_definition():is_a("app.col_user_data.AttackParamEm") then
			ataque = dados:get_field("_Attack");
			guarda = dados:call("get_GuardType") or 0;
		end
	end);
	return ataque, guarda;
end|, q|--[[
	(0.82) TIPO DO GOLPE: nome do tipo de dano (enum do jogo). Golpes sem dano (forca 0) sao
	ignorados, MENOS o rugido (nomes com ROAR / HOWL / VOICE / SHOUT): ele atordoa, entao e golpe.
	Os tipos sem dano vistos aparecem no relatorio (para conferir os nomes).
]]
local nomes_tipo_dano = nil;
local function nome_tipo_dano(valor)
	if valor == nil then return nil; end
	if nomes_tipo_dano == nil then
		nomes_tipo_dano = {};
		pcall(function()
			for _, campo in ipairs(sdk.find_type_definition("app.HitDef.DAMAGE_TYPE"):get_fields()) do
				if campo:is_static() then
					local v = campo:get_data(nil);
					if type(v) == "number" then nomes_tipo_dano[v] = campo:get_name(); end
				end
			end
		end);
	end
	return nomes_tipo_dano[tonumber(valor) or -999] or ("tipo " .. tostring(valor));
end
local function e_rugido(nome)
	if type(nome) ~= "string" then return false; end
	local n = string.upper(nome);
	return string.find(n, "ROAR", 1, true) ~= nil or string.find(n, "HOWL", 1, true) ~= nil
		or string.find(n, "VOICE", 1, true) ~= nil or string.find(n, "SHOUT", 1, true) ~= nil;
end
local function anotar_sem_dano(nome)
	estado.tipos_sem_dano = estado.tipos_sem_dano or {};
	estado.tipos_sem_dano[tostring(nome)] = (estado.tipos_sem_dano[tostring(nome)] or 0) + 1;
end

local function dados_do_collider(col)
	local ataque, guarda, tipo = nil, 0, nil;
	pcall(function()
		local dados = col and col:call("get_UserData");
		dados = dados and dados:call("get_ParentUserData");
		if dados ~= nil and dados:get_type_definition():is_a("app.col_user_data.AttackParamEm") then
			ataque = dados:get_field("_Attack");
			guarda = dados:call("get_GuardType") or 0;
			tipo = nome_tipo_dano(dados:call("get_DamageType"));
		end
	end);
	return ataque, guarda, tipo;
end

-- dados do golpe (forca, tipo de guarda e tipo de dano) da primeira area ligada
local function dados_da_area(a)
	if a.dados ~= nil then return a.dados[1], a.dados[2], a.dados[3]; end
	local col = nil;
	pcall(function() col = a.rsc:call("getCollidable", a.res, a.req, 0); end);
	return dados_do_collider(col);
end

--[[
	(0.82) PROJETEIS: bola de fogo, raio, cuspe... nascem como um objeto separado. Quando a area
	deles e criada (app.mcShellColHit.setupCollision), o mod acha o monstro dono (subindo ate a
	raiz do objeto) e trata como uma area de ataque ligando.
]]
local tipo_shell = sdk.typeof("ace.ShellBase");
local function projetil_criado(ponteiro)
	local sch = sdk.to_managed_object(ponteiro);
	if sch == nil then return; end
	local dono = nil;
	pcall(function()
		local base = sch:call("get_Owner"):call("getComponent(System.Type)", tipo_shell);
		dono = base and base:call("get_ShellOwner");
	end);
	if dono == nil then return; end
	local m = monstro_do_objeto(dono);
	if m == nil then
		pcall(function()
			local tr = dono:call("get_Transform");
			for _ = 1, 16 do
				local pai = tr:call("get_Parent");
				if pai == nil then break; end
				tr = pai;
			end
			m = monstro_do_objeto(tr:call("get_GameObject"));
		end);
	end
	if m == nil or m.invalido then return; end
	local col = sch:get_field("_FirstCollider");
	local ataque, guarda, tipo = dados_do_collider(col);
	estado.projeteis_vistos = (estado.projeteis_vistos or 0) + 1;
	local cols = { col };
	pcall(function()
		local subs = sch:get_field("_SubColliders");
		for i = 0, math.min(subs:call("get_Count"), 8) - 1 do cols[#cols + 1] = subs:call("get_Item", i); end
	end);
	fila_ativacoes[#fila_ativacoes + 1] = { m = m, em = agora(), dados = { ataque, guarda, tipo }, cols = cols, projetil = true };
end
pcall(function()
	local metodo = achar_metodo("app.mcShellColHit", "setupCollision()");
	if metodo == nil then return; end
	sdk.hook(metodo, function(args)
		local guardado = thread.get_hook_storage();
		if guardado ~= nil then guardado.shell_082 = args[2]; end
	end, function(retorno)
		local guardado = thread.get_hook_storage();
		local ptr = guardado and guardado.shell_082;
		if guardado ~= nil then guardado.shell_082 = nil; end
		if ptr ~= nil and op.aprender_por_ativacao then pcall(projetil_criado, ptr); end
		return retorno;
	end);
	estado.ganchos_078.projetil = true;
end);|, "dados_area");

troca(q|		local ataque, guarda = dados_da_area(a);
		if not m.invalido and (ataque == nil or ataque > 0) then|, q|		local ataque, guarda, tipo_dano = dados_da_area(a);
		local rugido = e_rugido(tipo_dano);
		if ataque ~= nil and ataque <= 0 then anotar_sem_dano(tipo_dano); end
		if rugido then estado.rugidos_vistos = (estado.rugidos_vistos or 0) + 1; end
		-- (0.82) acompanha a forma da area (alcance / geometria)
		if not m.invalido and (ataque == nil or ataque > 0 or rugido) and estado.n82 ~= nil then
			pcall(estado.n82.rastrear, a, guarda);
		end
		if not m.invalido and (ataque == nil or ataque > 0 or rugido) then|, "fila_rugido");

# contato: rugido tambem ensina
troca(q|		local forca = nil;
		pcall(function()
			local dados = acerto:call("get_AttackData");
			if dados ~= nil then
				guarda = dados:get_field("_GuardType") or 0;
				forca = dados:get_field("_Attack");
			end
		end);
		-- (0.80) rugido, vento, dano continuo de area: sem dano, nao e golpe
		if type(forca) == "number" and forca <= 0 then return; end|, q|		local forca, tipo_dano = nil, nil;
		pcall(function()
			local dados = acerto:call("get_AttackData");
			if dados ~= nil then
				guarda = dados:get_field("_GuardType") or 0;
				forca = dados:get_field("_Attack");
				tipo_dano = nome_tipo_dano(dados:get_field("_DamageType"));
			end
		end);
		-- (0.80) vento, dano continuo de area: sem dano, nao e golpe; (0.82) o rugido e
		if type(forca) == "number" and forca <= 0 and not e_rugido(tipo_dano) then return; end|, "contato_rugido");

# FS / ISS: leitura do cacador antes da tela ser desenhada (15)
troca(q|local function animacao_cacador()
	local cacador = meu_cacador();
	local objeto = cacador and objeto_de_jogo(cacador);
	if objeto == nil then return nil; end
	local id, banco, quadro = animacao_de(objeto);
	return id, banco, quadro, cacador;
end|, q|local function animacao_cacador()
	-- (0.82) leitura feita logo antes da tela ser desenhada (mesmo quadro que voce ve)
	local f = estado.foto_cacador;
	if f ~= nil and os.clock() - f.em < 0.05 and f.cacador ~= nil then
		return f.id, f.banco, f.quadro, f.cacador;
	end
	local cacador = meu_cacador();
	local objeto = cacador and objeto_de_jogo(cacador);
	if objeto == nil then return nil; end
	local id, banco, quadro = animacao_de(objeto);
	return id, banco, quadro, cacador;
end|, "foto");

# ---------------------------------------------------- bloco 0.82 (depois do bloco da 0.78)
troca(q|n78.processar_ativacoes = processar_ativacoes;|, q|n78.processar_ativacoes = processar_ativacoes;
n78.nome_tipo_dano = nome_tipo_dano;|, "exp");

troca(q|
end)();
|, q|
end)();

-- =====================================================================================
-- (0.82) GEOMETRIA, RAIVA / CANSACO, RESULTADO DA GUARDA, GOLPES DA LS, LEITURA E PESQUISA
-- (tudo so leitura; o unico efeito no jogo continua sendo os seus botoes)
-- =====================================================================================
(function()
local n82 = {};
estado.n82 = n82;

-- ---------- 2 / 3. ALCANCE E GEOMETRIA
local nomes_forma = nil;
local function nome_forma(valor)
	if nomes_forma == nil then
		nomes_forma = {};
		pcall(function()
			for _, campo in ipairs(sdk.find_type_definition("via.physics.ShapeType"):get_fields()) do
				if campo:is_static() then
					local v = campo:get_data(nil);
					if type(v) == "number" then nomes_forma[v] = campo:get_name(); end
				end
			end
		end);
	end
	return nomes_forma[tonumber(valor) or -1];
end

-- forma da area em coordenadas do mundo: segmento a-b com raio r (esfera: a = b)
local function forma_de(col)
	local forma = col:call("get_TransformedShape");
	if forma == nil then return nil; end
	local nome = nome_forma(forma:call("get_ShapeType")) or "";
	local function f(off) return forma:read_float(off); end
	if nome == "Sphere" or nome == "ContinuousSphere" then
		local c = { f(0x60), f(0x64), f(0x68) };
		return { a = c, b = c, r = f(0x6C) };
	elseif nome == "Capsule" or nome == "Cylinder" or nome == "ContinuousCapsule" then
		return { a = { f(0x60), f(0x64), f(0x68) }, b = { f(0x70), f(0x74), f(0x78) }, r = f(0x80) };
	elseif nome == "Box" or nome == "Triangle" then
		local c = { f(0x90), f(0x94), f(0x98) };
		local ex, ey, ez = f(0xA0), f(0xA4), f(0xA8);
		return { a = c, b = c, r = math.sqrt(ex * ex + ey * ey + ez * ez) };
	end
	return nil;
end

-- menor distancia entre dois segmentos (descontando os raios)
local function distancia_segmentos(s1, s2)
	local d1, d2, r = {}, {}, {};
	local a, e, b, c, ff = 0, 0, 0, 0, 0;
	for i = 1, 3 do
		d1[i] = s1.b[i] - s1.a[i]; d2[i] = s2.b[i] - s2.a[i]; r[i] = s1.a[i] - s2.a[i];
		a = a + d1[i] * d1[i]; e = e + d2[i] * d2[i]; b = b + d1[i] * d2[i];
		c = c + d1[i] * r[i]; ff = ff + d2[i] * r[i];
	end
	local function lim(x) return math.max(0, math.min(1, x)); end
	local s, t = 0, 0;
	if a <= 1e-9 and e <= 1e-9 then
		s, t = 0, 0;
	elseif a <= 1e-9 then
		t = lim(ff / e);
	elseif e <= 1e-9 then
		s = lim(-c / a);
	else
		local den = a * e - b * b;
		if den > 1e-9 then s = lim((b * ff - c * e) / den); end
		t = (b * s + ff) / e;
		if t < 0 then t = 0; s = lim(-c / a); elseif t > 1 then t = 1; s = lim((b - c) / a); end
	end
	local soma = 0;
	for i = 1, 3 do
		local dd = (s1.a[i] + s * d1[i]) - (s2.a[i] + t * d2[i]);
		soma = soma + dd * dd;
	end
	return math.sqrt(soma) - (s1.r or 0) - (s2.r or 0);
end

-- corpo do cacador: segmento dos pes ate a cabeca
local function corpo_do_cacador()
	local cacador = meu_cacador();
	local objeto = cacador and objeto_de_jogo(cacador);
	if objeto == nil then return nil; end
	local ok, p = pcall(function() return objeto:call("get_Transform"):call("get_Position"); end);
	if not ok or p == nil then return nil; end
	return { a = { p.x, p.y + 0.3, p.z }, b = { p.x, p.y + 1.5, p.z }, r = 0.45 };
end

local rastreadas = {};
function n82.rastrear(a, guarda)
	local cols = a.cols;
	if cols == nil then
		cols = {};
		pcall(function()
			local n = a.rsc:call("getNumCollidables", a.res, a.req);
			for i = 0, math.min(n, 8) - 1 do cols[#cols + 1] = a.rsc:call("getCollidable", a.res, a.req, i); end
		end);
	end
	for _, col in ipairs(cols) do
		if col ~= nil and #rastreadas < 48 then
			rastreadas[#rastreadas + 1] = { m = a.m, col = col, em = a.em, guarda = guarda or 0, projetil = a.projetil };
		end
	end
end

local function processar_geometria(momento)
	if #rastreadas == 0 then return; end
	local corpo = corpo_do_cacador();
	local restantes = {};
	for _, r in ipairs(rastreadas) do
		local manter = not r.m.invalido and momento - r.em < 4;
		if manter and corpo ~= nil then
			local ligada = false;
			pcall(function() ligada = r.col:call("get_Enabled") == true; end);
			if ligada then
				r.vista = true;
				local ok, forma = pcall(forma_de, r.col);
				if ok and forma ~= nil then
					local gap = distancia_segmentos(forma, corpo);
					if r.gap ~= nil and momento > r.t then
						local chegando = (r.gap - gap) / (momento - r.t);
						r.tti = (gap <= 0 and 0) or (chegando > 0.05 and gap / chegando) or nil;
					end
					r.gap, r.t = gap, momento;
					r.menor = math.min(r.menor or 99, gap);
					-- 3. contato previsto pela geometria vira golpe previsto (o mod defende com botoes reais)
					if op.defesa_geometria and not r.previsto and r.tti ~= nil and r.tti <= 0.35 and gap <= 2.5 then
						local quando = momento + r.tti;
						local ja_previsto = false;
						for _, p in ipairs(r.m.previstos or {}) do
							if math.abs(p.tempo - quando) <= 0.3 then ja_previsto = true; end
						end
						r.previsto = true;
						if not ja_previsto then
							r.m.previstos = r.m.previstos or {};
							r.m.previstos[#r.m.previstos + 1] = { tempo = quando, guarda = r.guarda, vezes = 1,
								origem = "geometria", dist_max = 0, geometria = true };
							estado.previstos_geometria = (estado.previstos_geometria or 0) + 1;
						end
					end
				end
			elseif r.vista then
				manter = false; -- ligou e desligou: acabou
			end
		end
		if manter then
			restantes[#restantes + 1] = r;
		elseif r.vista then
			estado.areas_medidas = (estado.areas_medidas or 0) + 1;
			if (r.menor or 99) <= 0.3 then estado.areas_alcancaram = (estado.areas_alcancaram or 0) + 1;
			elseif (r.menor or 99) <= 3 then estado.areas_passaram_perto = (estado.areas_passaram_perto or 0) + 1;
			else estado.areas_longe = (estado.areas_longe or 0) + 1; end
		end
	end
	rastreadas = restantes;
end

-- ---------- 5. RAIVA / CANSACO
local function estado_do_monstro(m)
	if m.cansado then return "cansado"; end
	if m.raiva then return "raiva"; end
	return "normal";
end
function n82.anotar_erro(m, erro)
	estado.erro_por_estado = estado.erro_por_estado or {};
	local por_v = estado.erro_por_estado[m.variante] or {};
	estado.erro_por_estado[m.variante] = por_v;
	local chave = estado_do_monstro(m);
	local s = por_v[chave] or { n = 0, soma = 0 };
	s.n, s.soma = s.n + 1, s.soma + erro;
	if s.n > 40 then s.soma, s.n = s.soma * 40 / s.n, 40; end
	por_v[chave] = s;
end
function n82.correcao(m)
	local por_v = (estado.erro_por_estado or {})[m.variante];
	local s = por_v and por_v[estado_do_monstro(m)];
	if s == nil or s.n < 8 then return 0; end
	local media = s.soma / s.n;
	if math.abs(media) < 0.02 then return 0; end
	return math.max(-0.2, math.min(0.2, media));
end
local cansaco_lido_em = 0;
local function ler_cansaco()
	if os.clock() - cansaco_lido_em < 0.5 then return; end
	cansaco_lido_em = os.clock();
	for _, m in pairs(monstros) do
		if not m.invalido and m.contexto ~= nil then
			pcall(function()
				local lista = m.contexto:get_field("Conditions"):get_field("_Conditions");
				local cansado = false;
				for i = 0, math.min(lista:call("get_Count"), 64) - 1 do
					local cond = lista:call("get_Item", i);
					if cond ~= nil and cond:get_type_definition():get_name() == "cEnemyTiredCondition" then
						cansado = cond:call("get_IsActive") == true;
					end
				end
				m.cansado = cansado;
			end);
		end
	end
end

-- ---------- 12. RESULTADO DA GUARDA PELO JOGO
local nomes_reacao = nil;
local function nome_reacao(valor)
	if nomes_reacao == nil then
		nomes_reacao = {};
		pcall(function()
			for _, campo in ipairs(sdk.find_type_definition("app.HunterDef.GUARD_REACTION"):get_fields()) do
				if campo:is_static() then
					local v = campo:get_data(nil);
					if type(v) == "number" then nomes_reacao[v] = campo:get_name(); end
				end
			end
		end);
	end
	return nomes_reacao[tonumber(valor) or -1] or ("reacao " .. tostring(valor));
end
pcall(function()
	local metodo = estado.achar_metodo("app.HunterCharacter", "evHit_Damage(app.HitInfo)");
	if metodo == nil then return; end
	sdk.hook(metodo, function(args)
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
	end);
	estado.ganchos_078.resultado_guarda = true;
end);

-- ---------- 11. GOLPES DA LONG SWORD PELO NOME DO JOGO
estado.nomes_golpes = estado.nomes_golpes or {};
local function ler_acao_cacador(cacador)
	local cat, idx, nome = nil, nil, nil;
	pcall(function()
		local ctrl = cacador:call("get_BaseActionController");
		local id = ctrl:call("get_CurrentActionID");
		cat, idx = id:get_field("_Category"), id:get_field("_Index");
		nome = ctrl:call("get_CurrentAction"):get_type_definition():get_name();
	end);
	return cat, idx, nome;
end

local tabela_ls_salva = false;
local function salvar_tabela_ls()
	if tabela_ls_salva then return; end
	local saida = {};
	local ok = pcall(function()
		local ajuste = sdk.get_managed_singleton("app.VariousDataManager"):get_field("_Setting"):get_field("_ActionGuideSetting");
		for _, campo in ipairs({ "_ActionGuideName_Wp03", "_ActionGuideData_Wp03", "_ActionGuideData_Wp03Always",
			"_ActionGuideData_Wp03Combo", "_ActionGuideData_Wp03ComboDetail" }) do
			local tabela = ajuste:get_field(campo);
			local linhas = {};
			if tabela ~= nil then
				local tipo = tabela:get_type_definition();
				local quantos = 0;
				pcall(function() quantos = tabela:call("getDataNum"); end);
				for i = 0, math.min(quantos or 0, 2000) - 1 do
					local linha_t = nil;
					pcall(function() linha_t = tabela:call("getDataByIndex(System.Int32)", i); end);
					if linha_t ~= nil then
						local reg = {};
						for _, f in ipairs(linha_t:get_type_definition():get_fields()) do
							if not f:is_static() then
								local ok_v, v = pcall(f.get_data, f, linha_t);
								if ok_v and (type(v) == "number" or type(v) == "boolean" or type(v) == "string") then reg[f:get_name()] = v; end
							end
						end
						linhas[#linhas + 1] = reg;
					end
				end
			end
			saida[campo] = linhas;
		end
	end);
	tabela_ls_salva = true;
	if ok then
		json.dump_file("aviso_lanca_ls_tabela.json", saida);
		estado.tabela_ls = {};
		for campo, linhas in pairs(saida) do estado.tabela_ls[campo] = #linhas; end
	end
end

-- ---------- 15. LEITURA DO CACADOR LOGO ANTES DA TELA SER DESENHADA
re.on_pre_application_entry("BeginRendering", function()
	pcall(function()
		local cacador = meu_cacador();
		local objeto = cacador and objeto_de_jogo(cacador);
		if objeto == nil then estado.foto_cacador = nil; return; end
		local id, banco, quadro, _, vel = animacao_de(objeto);
		local cat, idx, nome = ler_acao_cacador(cacador);
		estado.foto_cacador = { em = os.clock(), cacador = cacador, id = id, banco = banco, quadro = quadro,
			vel = vel, cat = cat, idx = idx, acao = nome };
		if banco ~= nil and id ~= nil and nome ~= nil and cacador:call("get_WeaponType") == 3 then
			estado.nomes_golpes[tostring(banco) .. ":" .. tostring(id)] = nome;
			if not tabela_ls_salva then pcall(salvar_tabela_ls); end
		end
	end);
end);

-- ---------- por quadro
function n82.processar()
	local momento = agora();
	pcall(processar_geometria, momento);
	pcall(ler_cansaco);
end

-- ---------- 16. PESQUISA (Diagnostico): tudo ao vivo, nada e escrito no jogo
local base_pesquisa, mudancas = nil, {};
local function valores_da_arma()
	local valores = {};
	pcall(function()
		local arma = meu_cacador():call("get_WeaponHandling");
		local tipo = arma:get_type_definition();
		while tipo ~= nil do
			for _, f in ipairs(tipo:get_fields()) do
				if not f:is_static() then
					local ok_v, v = pcall(f.get_data, f, arma);
					if ok_v and (type(v) == "number" or type(v) == "boolean") then valores[f:get_name()] = tostring(v); end
				end
			end
			tipo = tipo:get_parent_type();
		end
	end);
	return valores;
end
function n82.desenhar_pesquisa()
	if not imgui.tree_node("Pesquisa ao vivo (so leitura)") then return; end
	local f = estado.foto_cacador or {};
	imgui.text(string.format("Voce: acao %s / %s (%s) - animacao %s:%s quadro %s velocidade %s",
		tostring(f.cat), tostring(f.idx), tostring(f.acao), tostring(f.banco), tostring(f.id),
		f.quadro and string.format("%.1f", f.quadro) or "-", f.vel and string.format("%.2f", f.vel) or "-"));
	pcall(function()
		local arma = meu_cacador():call("get_WeaponHandling");
		imgui.text(string.format("Long Sword: barra %s - aura %s",
			tostring(arma:call("get_RenkiGauge"):call("get_Value")), tostring(arma:call("get_AuraLevel"))));
	end);
	for _, m in pairs(monstros) do
		if not m.invalido then
			imgui.text(string.format("%s: animacao %s velocidade %s - raiva %s - cansado %s",
				tostring(m.nome_completo), tostring(m.animacao), m.velocidade and string.format("%.2f", m.velocidade) or "-",
				tostring(m.raiva == true), tostring(m.cansado == true)));
		end
	end
	imgui.text(string.format("Areas de ataque acompanhadas agora: %d", #rastreadas));
	if imgui.button("Capturar valores da arma (antes)") then base_pesquisa = valores_da_arma(); mudancas = {}; end
	if base_pesquisa ~= nil then
		local agora_v = valores_da_arma();
		for k, v in pairs(agora_v) do
			if base_pesquisa[k] ~= nil and base_pesquisa[k] ~= v then mudancas[k] = base_pesquisa[k] .. " -> " .. v; end
		end
		local n = 0;
		for k, v in pairs(mudancas) do
			n = n + 1;
			if n <= 40 then imgui.text("   " .. k .. ": " .. v); end
		end
		if n == 0 then imgui.text("   (nada mudou ainda)"); end
	end
	imgui.tree_pop();
end

end)();
|, "bloco82");

# chamada por quadro
troca(q|	pcall(n78.processar_ativacoes);  -- (0.78)|, q|	pcall(n78.processar_ativacoes);  -- (0.78)
	if estado.n82 ~= nil then pcall(estado.n82.processar); end -- (0.82)|, "chamada");

# 12. conferir defesa: guarda confirmada pelo jogo
troca(q|			if perfil_v ~= nil and perfil_v.confere_por_dano then
				return (estado.levou_dano_em or -100) < v.em - 0.05;|, q|			if perfil_v ~= nil and perfil_v.confere_por_dano then
				-- (0.82) o jogo disse que guardou (perfeita, normal, guard point...)
				if (estado.guarda_jogo_em or -100) >= v.em - 0.05 then return true; end
				return (estado.levou_dano_em or -100) < v.em - 0.05;|, "conferir");

# 16. aba de pesquisa
troca(q|	if imgui.tree_node("Diagnostico (so se eu pedir)") then|, q|	if imgui.tree_node("Diagnostico (so se eu pedir)") then
		if estado.n82 ~= nil then pcall(estado.n82.desenhar_pesquisa); end -- (0.82)|, "pesquisa");

# menu: opcao da geometria
troca(q|		imgui.text("O mod so le o jogo e aperta botoes reais: nada do jogo e modificado.");|,
q|		m78, op.defesa_geometria = imgui.checkbox("Defesa pela geometria (golpe que o mod nao conhece, vindo em voce)", op.defesa_geometria);
		mudou_78 = mudou_78 or m78;
		imgui.text("O mod so le o jogo e aperta botoes reais: nada do jogo e modificado.");|, "menu");

# relatorio
troca(q|	local ct = estado.contatos_em_voce or {};|, q|	-- (0.82)
	linha(string.format("Geometria: areas medidas %d (encostaram em voce %d, passaram perto %d, longe %d) - golpes previstos pela geometria %d - projeteis vistos %d - rugidos %d",
		estado.areas_medidas or 0, estado.areas_alcancaram or 0, estado.areas_passaram_perto or 0, estado.areas_longe or 0,
		estado.previstos_geometria or 0, estado.projeteis_vistos or 0, estado.rugidos_vistos or 0));
	local sd_txt = {};
	for nome, n in pairs(estado.tipos_sem_dano or {}) do sd_txt[#sd_txt + 1] = nome .. " " .. n; end
	linha("Tipos de golpe sem dano vistos: " .. (#sd_txt > 0 and table.concat(sd_txt, ", ") or "nenhum"));
	local ep_txt = {};
	for var, por in pairs(estado.erro_por_estado or {}) do
		for est, s in pairs(por) do
			ep_txt[#ep_txt + 1] = string.format("%s %s: %+d ms (%d)", tostring(nomes_monstros[var] or var), est,
				math.floor(s.soma / math.max(1, s.n) * 1000 + 0.5), s.n);
		end
	end
	linha("Golpes por estado do monstro (chegam antes - / depois +): " .. (#ep_txt > 0 and table.concat(ep_txt, " - ") or "sem dados"));
	local vel_txt = {};
	for var, v in pairs(estado.velocidades or {}) do
		vel_txt[#vel_txt + 1] = string.format("%s %.2f (%.2f a %.2f)", tostring(nomes_monstros[var] or var), v.soma / math.max(1, v.n), v.menor, v.maior);
	end
	linha("Velocidade das animacoes de golpe: " .. (#vel_txt > 0 and table.concat(vel_txt, " - ") or "sem dados"));
	local rg_txt = {};
	for nome, n in pairs(estado.reacoes_jogo or {}) do rg_txt[#rg_txt + 1] = nome .. " " .. n; end
	linha("Guardas confirmadas pelo jogo: " .. (#rg_txt > 0 and table.concat(rg_txt, ", ") or "nenhuma"));
	local ng, ng_txt = 0, {};
	for anim, nome in pairs(estado.nomes_golpes or {}) do
		ng = ng + 1;
		if ng <= 30 then ng_txt[#ng_txt + 1] = anim .. "=" .. nome; end
	end
	local tl_txt = {};
	for campo, n in pairs(estado.tabela_ls or {}) do tl_txt[#tl_txt + 1] = campo .. " " .. n; end
	linha(string.format("Long Sword - golpes com nome do jogo: %d (%s) - tabela salva: %s", ng, table.concat(ng_txt, ", "),
		#tl_txt > 0 and table.concat(tl_txt, ", ") or "ainda nao"));
	if estado.metodos_por_prefixo ~= nil then
		linha("Funcoes achadas pelo comeco do nome (o jogo mudou o nome): " .. table.concat(estado.metodos_por_prefixo, ", "));
	end
	local ct = estado.contatos_em_voce or {};|, "prints");

print $s;
