local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; die "$nome repetido" if index($s, $velho, $i + length($novo)) >= 0; }
sub troca_todas { my ($velho, $novo, $nome) = @_; my $n = ($s =~ s/\Q$velho\E/$novo/g); die "$nome nao achado" unless $n; return $n; }
troca(q|	Versao 1.36 - NOME DO SAVAGE OMEGA PLANETES:|,
q|	Versao 1.37 - 1. OMEGA PLANETES E SAVAGE ZERADOS (pedido do usuario, uma vez so): o aprendizado dos golpes, as
	areas de ataque e as defesas aprendidas dos dois (34 e 34:t) sao apagados na primeira vez que a 1.37 carrega.
	2. DEFESA QUE COMECOU TARDE NAO MUDA O APRENDIZADO: um golpe previsto em cima da hora (ex.: pela geometria,
	30 ms antes de um contra-ataque que precisa de 250 ms) falha pela falta de tempo, nao por ser a defesa
	errada. Antes (com a 1.35, que passou a aprender os danos da Lanca) isso subiria a defesa daquele golpe -
	todos os golpes da geometria de um monstro tem a mesma chave e subiriam juntos. Agora a defesa que comecou
	com menos da metade do tempo dela fica "LEVOU DANO (comecou tarde)" e o aprendizado nao muda (vale para
	todas as armas).
	1.36 - NOME DO SAVAGE OMEGA PLANETES:|, "cabecalho");
troca_todas(q|versao_mod = "1.36"|, q|versao_mod = "1.37"|, "versao");
troca(q|Defesa Automatica v1.36") then|, q|Defesa Automatica v1.37") then|, "menu");
troca(q|linha("== Defesa Automatica v1.36 ==");|, q|linha("== Defesa Automatica v1.37 ==");|, "relatorio");

troca(q|	versao_campos = 9,
|, q|	versao_campos = 9,
	zerou_omega_137 = false, -- (1.37) o Omega Planetes e o Savage ja foram zerados (uma vez so)
|, "op");

troca(q|local function conferir_defesas()
|, q|-- (1.37) a defesa comecou com menos da metade do tempo dela: a falha e falta de tempo, nao a defesa errada
n78.defesa_tarde = function(v)
	local perfil_t = PERFIS[v.perfil or "lanca"];
	local opcao = perfil_t and perfil_t.antecedencia and perfil_t.antecedencia[v.defesa];
	local ms = v.diag and tonumber(v.diag.ms);
	if opcao == nil or ms == nil or (op[opcao] or 0) <= 0 then return false; end
	return ms < op[opcao] * 0.5;
end;

local function conferir_defesas()
|, "funcao tarde");
troca(q|		elseif v.sem_combo then
			if v.diag ~= nil then v.diag.resultado = "LEVOU DANO"; end
			estado.ultimo_resultado = "FALHOU com a esquiva de reserva (" .. v.chave .. ") - aprendizado nao muda";|,
q|		elseif v.sem_combo then
			if v.diag ~= nil then v.diag.resultado = "LEVOU DANO"; end
			estado.ultimo_resultado = "FALHOU com a esquiva de reserva (" .. v.chave .. ") - aprendizado nao muda";
		elseif n78.defesa_tarde(v) then
			if v.diag ~= nil then v.diag.resultado = "LEVOU DANO (comecou tarde)"; end
			estado.defesas_tarde = (estado.defesas_tarde or 0) + 1;
			estado.ultimo_resultado = "FALHOU com " .. NOME_NIVEL[v.defesa] .. " que comecou tarde (" .. v.chave .. ") - aprendizado nao muda";|, "conferir tarde");

troca(q|pcall(ligar_pontos_de_escrita);
pcall(carregar_conhecimento);
|, q|pcall(ligar_pontos_de_escrita);
pcall(carregar_conhecimento);
-- (1.37) uma vez so (pedido do usuario): zera o Omega Planetes (34) e o Savage Omega Planetes (34:t)
if not op.zerou_omega_137 then
	pcall(function()
		conhecimento["34"], conhecimento["34:t"] = nil, nil;
		grupos_cache = {};
		salvar_conhecimento();
		local tab = n78.ativacoes_tab();
		tab["34"], tab["34:t"] = nil, nil;
		n78.marcar_ativacoes();
		local function sem_omega(t)
			if type(t) ~= "table" then return; end
			for k in pairs(t) do
				if type(k) == "string" and string.find(k, "^[%a_]+:34:") then t[k] = nil; end
			end
		end
		sem_omega(defesas_aprendidas); sem_omega(fs_falhas); sem_omega(ss_sem_golpe); sem_omega(n78.fs_descontos);
		sem_omega(op.iss_ajuste_golpe);
		n78.salvar_defesas();
	end);
	op.zerou_omega_137 = true;
	salvar_opcoes();
end
|, "zerar omega");
troca(q|voce preso num golpe seu: %d (sem trava antes: %d) - sem dado de aviso: %d",
			falhas, curto, preso, preso_sem_trava, sem_aviso));|, q|voce preso num golpe seu: %d (sem trava antes: %d) - sem dado de aviso: %d - comecaram tarde (sem aprender, 1.37): %d",
			falhas, curto, preso, preso_sem_trava, sem_aviso, estado.defesas_tarde or 0));|, "relatorio tarde");
troca(q|		marcar_power_guard(desde, p.estado_pg);
	end
	-- a esquiva e tratada a parte (toque gravado, exclusivo)|, q|		-- (1.37) os botoes contam do 1o aperto: no Power Guard que comeca tarde, M2 e Espaco nao saem todos
		-- no 1o quadro (sem a postura, o Espaco vira esquiva / corrida com guarda)
		p.estado_pg = p.estado_pg or {};
		if p.estado_pg.pg_ini == nil then p.estado_pg.pg_ini = desde; end
		marcar_power_guard(desde - p.estado_pg.pg_ini, p.estado_pg);
	end
	-- a esquiva e tratada a parte (toque gravado, exclusivo)|, "pg do 1o aperto");
troca(q|	todas as armas).
	1.36 - NOME DO SAVAGE OMEGA PLANETES:|, q|	todas as armas). 3. POWER GUARD QUE COMECA TARDE: os botoes (M5, M2 aos 0,05s, Espaco aos 0,35s) contavam
	do inicio da janela (500 ms antes do golpe); comecando 30 ms antes, os tres saiam no 1o quadro, antes da
	postura. Agora contam do 1o aperto (o pedido direto ao jogo continua igual).
	1.36 - NOME DO SAVAGE OMEGA PLANETES:|, "cabecalho 3");
troca(q|				if not p.esquiva_feita and falta <= antes.esquiva and falta >= antes.esquiva - 0.1 then
					vai_esquivar = true;
					anotar_defesa(p, "esquiva", falta);
				end|, q|				-- (1.37) 0,1s a partir do 1o quadro na janela: o golpe previsto em cima da hora (menos de
				-- "antes - 0,1s") tambem ganha a esquiva (antes nunca saia)
				if not p.esquiva_feita and falta <= antes.esquiva and falta > -0.03 then
					p.esquiva_ini = p.esquiva_ini or momento;
					if momento - p.esquiva_ini <= 0.1 then
						vai_esquivar = true;
						anotar_defesa(p, "esquiva", falta);
					end
				end|, "esquiva tarde");
troca(q|	postura. Agora contam do 1o aperto (o pedido direto ao jogo continua igual).|, q|	postura. Agora contam do 1o aperto (o pedido direto ao jogo continua igual). 4. ESQUIVA EM CIMA DA HORA: a
	esquiva so saia com o golpe entre 150 e 50 ms de distancia; golpe previsto mais tarde nunca ganhava esquiva
	(todas as armas). Agora sai do 1o quadro em que der, ate 30 ms depois da hora prevista, uma vez so.|, "cabecalho 4");
print $s;
