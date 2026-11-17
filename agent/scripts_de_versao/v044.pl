local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.43 - |, q|	Versao 0.44 - RELATORIO AUTOMATICO: a aba Prints e todas as defesas da sessao sao salvas sozinhas
	em reframework/data/aviso_lanca_prints (um arquivo por vez que o jogo abre)
	0.43 - |, "cab");
$s =~ s/== Defesa Automatica v0\.43 ==/== Defesa Automatica v0.44 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.43"\)/imgui.tree_node("Defesa Automatica v0.44")/ or die "tit";

# --- cada defesa entra tambem na lista da sessao (para o relatorio)
troca(q|	local d = { defesa = defesa, ms = math.floor(falta * 1000 + 0.5), antes = combo.animacao or "?",
		em = os.clock(), depois = nil, resultado = "..." };
	p.diag = d;
	estado.historico = estado.historico or {};
	table.insert(estado.historico, 1, d);
	if #estado.historico > 8 then table.remove(estado.historico); end|, q|	local d = { defesa = defesa, ms = math.floor(falta * 1000 + 0.5), antes = combo.animacao or "?",
		em = os.clock(), depois = nil, resultado = "..." };
	p.diag = d;
	estado.historico = estado.historico or {};
	table.insert(estado.historico, 1, d);
	if #estado.historico > 8 then table.remove(estado.historico); end

	-- (0.44) relatorio automatico: guarda tambem a arma, o golpe e a hora
	d.arma, d.golpe = estado.chave_perfil, p.chave;
	local ok_hora, hora = pcall(os.date, "%H:%M:%S");
	d.hora = ok_hora and hora or nil;
	estado.defesas_sessao = estado.defesas_sessao or {};
	estado.defesas_sessao[#estado.defesas_sessao + 1] = d;
	if #estado.defesas_sessao > 3000 then table.remove(estado.defesas_sessao, 1); end|, "anotar");

# --- forward declaration usada no on_frame
troca(q|re.on_frame(function()
	local ok, erro = pcall(acompanhar);|, q|local salvar_relatorio; -- (0.44) definido depois da aba Prints

re.on_frame(function()
	if salvar_relatorio ~= nil then pcall(salvar_relatorio, false); end

	local ok, erro = pcall(acompanhar);|, "on_frame");

# --- a aba Prints vira "montar_prints(linha)" + desenho; relatorio usa as mesmas linhas
troca(q|local function desenhar_aba_prints()
	if not imgui.tree_node("Prints (abra esta aba e tire um print)") then return; end

	local momento = agora();
	local function linha(texto) imgui.text(texto); end|, q|-- (0.44) monta as linhas da aba Prints; "linha" recebe cada linha (na tela ou no relatorio)
local function montar_prints(linha)
	local momento = agora();|, "prints_ini");

troca(q|	if estado.mensagem ~= "" then linha("Mensagem: " .. estado.mensagem); end

	imgui.tree_pop();
end|, q|	if estado.mensagem ~= "" then linha("Mensagem: " .. estado.mensagem); end
end

local function desenhar_aba_prints()
	if not imgui.tree_node("Prints (abra esta aba e tire um print)") then return; end
	montar_prints(function(texto) imgui.text(texto); end);

	local r = estado.relatorio or {};
	imgui.text(string.format("Relatorio automatico: reframework/data/%s (salvo ha %.0fs, %d defesas)",
		tostring(r.arquivo), os.clock() - (r.salvo_em or os.clock()), #(estado.defesas_sessao or {})));
	if imgui.button("Salvar relatorio agora") then pcall(salvar_relatorio, true); end

	imgui.tree_pop();
end

--[[
	(0.44) RELATORIO AUTOMATICO
	Um arquivo por vez que o jogo abre, em reframework/data/aviso_lanca_prints/. Tem as
	linhas da aba Prints (do momento em que foi salvo) e TODAS as defesas da sessao (hora,
	arma, golpe, defesa, ms antes, animacao antes/depois, resultado). Salva:
	  - 10s depois de cada defesa nova (juntando as que vierem nesse meio tempo);
	  - a cada 60s enquanto houver monstro grande por perto;
	  - quando voce clica em "Salvar relatorio agora".
]]
salvar_relatorio = function(forcar)
	local r = estado.relatorio;
	if r == nil then
		local ok_nome, nome = pcall(os.date, "%Y-%m-%d_%H-%M-%S");
		r = { arquivo = "aviso_lanca_prints/relatorio_" .. (ok_nome and nome or tostring(math.floor(os.time and os.time() or 0))) .. ".json",
			salvo_em = os.clock(), defesas_salvas = 0, nova_desde = nil };
		estado.relatorio = r;
	end

	local agora_lua = os.clock();
	local total = #(estado.defesas_sessao or {});
	if total ~= r.defesas_salvas and r.nova_desde == nil then r.nova_desde = agora_lua; end

	local tem_monstro = next(monstros) ~= nil;
	local salvar = forcar
		or (r.nova_desde ~= nil and agora_lua - r.nova_desde >= 10)
		or (tem_monstro and agora_lua - r.salvo_em >= 60);
	if not salvar then return; end

	local linhas = {};
	pcall(montar_prints, function(texto) linhas[#linhas + 1] = texto; end);

	local defesas = {};
	for _, d in ipairs(estado.defesas_sessao or {}) do
		defesas[#defesas + 1] = {
			hora = d.hora, arma = d.arma, golpe = d.golpe, defesa = d.defesa, ms_antes = d.ms,
			animacao_antes = d.antes, animacao_depois = d.depois, resultado = d.resultado, apertos = d.toques
		};
	end

	local ok_hora, hora = pcall(os.date, "%Y-%m-%d %H:%M:%S");
	json.dump_file(r.arquivo, {
		versao_mod = "0.44", salvo_as = ok_hora and hora or nil,
		prints = linhas, defesas = defesas
	});
	r.salvo_em, r.defesas_salvas, r.nova_desde = agora_lua, total, nil;
end|, "prints_fim");

print $s;
