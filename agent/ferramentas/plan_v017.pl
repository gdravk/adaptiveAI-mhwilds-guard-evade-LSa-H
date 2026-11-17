local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q{local function marcar_power_guard(desde_inicio)
	if #(op.campos.power_guard or {}) > 0 then
		marcar("power_guard");
		return;
	end
	marcar("guarda");}, q{local function marcar_power_guard(desde_inicio)
	-- versao 0.17: sempre montado. A captura do Power Guard pegou so M5 + M2 (sem o
	-- Espaco), porque o Espaco e um toque e a captura antiga so via botoes segurados.
	marcar("guarda");}, "power");

troca(q{	--   esquiva: um toque de 0,1s por segundo;
	--   contra-ataque: refaz a sequencia M5 -> M2 a cada segundo;
	--   Power Guard: monta a sequencia uma vez e segura os 5 segundos.
	if momento >= entrada.forcar_de and momento < entrada.forcar_ate then
		local desde = momento - entrada.forcar_de;
		local no_segundo = desde % 1.0;
		if entrada.alvo == "esquiva" then
			if no_segundo < 0.1 then marcar("esquiva"); end
		elseif entrada.alvo == "contra_ataque" then
			if no_segundo < 0.7 then marcar_contra_ataque(no_segundo); end}, q{	--   esquiva: toca o toque gravado uma vez por segundo (ou o toque antigo de 0,1s);
	--   contra-ataque: faz a sequencia M5 -> M2 UMA vez (repetir no meio do contra-ataque
	--   anterior so fazia o jogo ignorar o M2);
	--   Power Guard: monta a sequencia uma vez e segura os 5 segundos.
	if momento >= entrada.forcar_de and momento < entrada.forcar_ate then
		local desde = momento - entrada.forcar_de;
		local no_segundo = desde % 1.0;
		if entrada.alvo == "esquiva" then
			if #(op.toques.esquiva or {}) > 0 then
				if no_segundo < 0.05 then comecar_toque(); end
			elseif no_segundo < 0.1 then
				marcar("esquiva");
			end
		elseif entrada.alvo == "contra_ataque" then
			if desde < 1.5 then marcar_contra_ataque(desde); end}, "teste");

troca(q{	-- esquiva tem prioridade: solta o resto, senao o jogo pode fazer outra coisa com o Espaco
	if vai_esquivar then
		teclas_agora = {};
		marcar("esquiva");
	end
end

local function planejar_defesa()
	teclas_agora = {};
	fechar_diagnostico_do_quadro();
	decidir_botoes();
	preparar_escrita();
end}, q{	-- esquiva tem prioridade: solta o resto, senao o jogo pode fazer outra coisa com o Espaco
	if vai_esquivar then
		teclas_agora = {};
		if #(op.toques.esquiva or {}) > 0 then
			comecar_toque();
		else
			marcar("esquiva");
		end
	end
end

local function planejar_defesa()
	teclas_agora = {};
	fechar_diagnostico_do_quadro();
	decidir_botoes();

	-- toque gravado em andamento: um quadro da gravacao por quadro do jogo, sozinho
	-- (nada mais e apertado enquanto a esquiva acontece)
	if toque.quadro ~= nil then
		local quadros = op.toques.esquiva or {};
		if toque.quadro > #quadros then
			toque.quadro = nil;
		else
			teclas_agora = {};
			marcar("toque:" .. toque.quadro);
			toque.quadro = toque.quadro + 1;
		end
	end

	preparar_escrita();
end}, "planejar");

troca(q{local function decidir_botoes()}, q{-- toque gravado (esquiva): quadro atual da reproducao (nil = parado)
local toque = { quadro = nil };

function comecar_toque()
	if toque.quadro == nil then toque.quadro = 1; end
end

local function decidir_botoes()}, "toque");
print $s;
