local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

# 1. opcoes
troca(q{	usar_power_guard = false,}, q{	usar_power_guard = true,

	-- golpe vindo de lado/tras: se o angulo entre para onde o cacador olha e o monstro
	-- passar disso (graus), a guarda e o contra-ataque (so de frente) sao pulados
	angulo_frontal = 70,}, "op");

# migracao: Power Guard volta ligado (modo seguro nao fechou o jogo na 0.18)
troca(q{		op.acao_guardavel = "contra_ataque";
		op.versao_campos = 2;
	end}, q{		op.acao_guardavel = "contra_ataque";
		op.versao_campos = 2;
	end

	-- 0.19: Power Guard e o nivel 3 da prioridade; liga uma vez (o modo seguro da 0.18
	-- nao fechou o jogo)
	if (salvo.versao_campos or 1) < 3 then
		op.usar_power_guard = true;
		op.versao_campos = 3;
	end}, "migracao");

# 2. origem das previsoes
troca(q{				novos[#novos + 1] = { tempo = momento + g.tempo, guarda = g.guarda, vezes = g.vezes };}, q{				-- "origem": a animacao que previu o golpe (identifica o golpe no aprendizado das defesas)
				novos[#novos + 1] = { tempo = momento + g.tempo, guarda = g.guarda, vezes = g.vezes, origem = animacao };}, "origem");

# 3. tabelas e conferencia no impacto
troca(q{local function ao_impacto(argumentos)}, q{-- defesas aprendidas por golpe ("id do monstro:animacao que previu" = nivel 1 a 4) e
-- golpes esperando a conferencia (o jogo confirmou a defesa?)
local defesas_aprendidas = {};
local verificacoes_defesa = {};

pcall(function()
	local salvo = json.load_file("aviso_lanca_defesas.json");
	if type(salvo) == "table" and type(salvo.golpes) == "table" then defesas_aprendidas = salvo.golpes; end
end);

local function ao_impacto(argumentos)}, "tabelas");

troca(q{	local menor = nil;
	for _, p in ipairs(m.previstos) do
		local erro = momento - p.tempo;
		if menor == nil or math.abs(erro) < math.abs(menor) then menor = erro; end
	end
	if menor ~= nil and math.abs(menor) <= 0.3 then
		estado.ultimo_erro_ms = math.floor(menor * 1000 + 0.5);
		estado.avisos_certos = estado.avisos_certos + 1;
	else
		estado.ultimo_erro_ms = nil;
	end}, q{	local menor, casado = nil, nil;
	for _, p in ipairs(m.previstos) do
		local erro = momento - p.tempo;
		if menor == nil or math.abs(erro) < math.abs(menor) then menor, casado = erro, p; end
	end
	if menor ~= nil and math.abs(menor) <= 0.3 then
		estado.ultimo_erro_ms = math.floor(menor * 1000 + 0.5);
		estado.avisos_certos = estado.avisos_certos + 1;

		-- o mod defendeu este golpe? confere daqui a 0,3s se o jogo confirmou a defesa
		if casado.defesa ~= nil and not casado.conferido then
			casado.conferido = true;
			verificacoes_defesa[#verificacoes_defesa + 1] = {
				chave = tostring(m.id) .. ":" .. tostring(casado.origem),
				nivel = casado.nivel, defesa = casado.defesa, em = os.clock()
			};
		end
	else
		estado.ultimo_erro_ms = nil;
	end}, "impacto");

# 4. sucesso de defesa (antes do filtro de meio segundo)
troca(q{			local agora_lua = os.clock();
			local ultima = ultima_chamada_defesa[d.conta] or -10;}, q{			local agora_lua = os.clock();
			estado.ultimo_sucesso_defesa = agora_lua; -- usado na conferencia das defesas
			local ultima = ultima_chamada_defesa[d.conta] or -10;}, "sucesso");

# 5. angulo
troca(q{			local mx, my, mz = posicao(m.objeto);
			m.distancia = distancia(mx, my, mz, cx, cy, cz);}, q{			local mx, my, mz = posicao(m.objeto);
			m.distancia = distancia(mx, my, mz, cx, cy, cz);

			-- angulo entre para onde o cacador olha e a direcao do monstro (no chao)
			m.angulo = nil;
			if frente_x ~= nil and mx ~= nil and cx ~= nil then
				local dx, dz = mx - cx, mz - cz;
				local tamanho = math.sqrt(dx * dx + dz * dz);
				if tamanho > 0.01 then
					local cosseno = (dx * frente_x + dz * frente_z) / tamanho;
					m.angulo = math.deg(math.acos(math.max(-1, math.min(1, cosseno))));
				end
			end}, "angulo");

troca(q{	local cx, cy, cz;
	if objeto_cacador ~= nil then cx, cy, cz = posicao(objeto_cacador); end

	-- so anota qual arma}, q{	local cx, cy, cz;
	if objeto_cacador ~= nil then cx, cy, cz = posicao(objeto_cacador); end

	-- para onde o cacador esta olhando (vetor "frente", so no chao)
	local frente_x, frente_z = nil, nil;
	if objeto_cacador ~= nil then
		pcall(function()
			local eixo = objeto_cacador:call("get_Transform"):call("get_AxisZ");
			local tamanho = math.sqrt(eixo.x * eixo.x + eixo.z * eixo.z);
			if tamanho > 0.01 then frente_x, frente_z = eixo.x / tamanho, eixo.z / tamanho; end
		end);
	end

	-- so anota qual arma}, "frente");

print $s;
