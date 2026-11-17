local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.86 - |, q|	Versao 0.87 - MEIO-TERMO (aprovado): o FS e o ISS podem ser pedidos DIRETO ao jogo (como os mods
	testados fazem), mas SO quando o jogo aceitaria de um jogador - FS: o seu golpe ja passou do quadro em
	que o FS e aceito e tem barra de espirito (ou aura vermelha); ISS: na postura ou a partir do quadro 75
	da entrada do SS. Nada e anulado nem ganha invencibilidade. Fora dessas janelas, continuam os botoes
	0.86 - |, "cab");
$s =~ s/versao_mod = "0\.86"/versao_mod = "0.87"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.86 ==/== Defesa Automatica v0.87 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.86"\)/imgui.tree_node("Defesa Automatica v0.87")/ or die "tit";

troca(q|	ls_trava_fixa_ms = 2000,|, q|	ls_acao_direta = true, -- (0.87) FS / ISS pedidos direto ao jogo, so nas janelas em que o jogo aceita
	ls_trava_fixa_ms = 2000,|, "op");

troca(q|n78.fs_vai_sair = fs_vai_sair;|, q|n78.fs_vai_sair = fs_vai_sair;

--[[
	(0.87) PEDIDO DIRETO DE ACAO (meio-termo): pede ao jogo a acao do jogador (o mesmo pedido que o
	botao gera), SO dentro das janelas acima. Acoes da Long Sword: FS = (2, 16); ISS = (2, 25 + aura).
	Nao anula golpe, nao da invencibilidade, nao muda nenhum valor do jogo.
]]
local tipo_acao_id = sdk.find_type_definition("ace.ACTION_ID");
n78.acao_direta = function(categoria, indice, nome)
	local cacador = meu_cacador();
	if cacador == nil or tipo_acao_id == nil then return false; end
	local ok = pcall(function()
		local id = ValueType.new(tipo_acao_id);
		id._Category = categoria;
		id._Index = indice;
		local feito = pcall(function()
			cacador:call("changeActionRequest(app.AppActionDef.LAYER, ace.ACTION_ID, System.Boolean)", 0, id, false);
		end);
		if not feito then cacador:call("changeActionRequest", 0, id, false); end
	end);
	if ok then
		estado.acoes_diretas = estado.acoes_diretas or {};
		estado.acoes_diretas[nome or "?"] = (estado.acoes_diretas[nome or "?"] or 0) + 1;
	end
	return ok;
end;
n78.nivel_aura = function()
	local nivel = nil;
	pcall(function() nivel = meu_cacador():call("get_WeaponHandling"):call("get_AuraLevel"); end);
	return tonumber(nivel);
end;|, "acao");

# FS direto
troca(q|		local m5, m2 = op.toques.m5 or {}, op.toques.m2 or {};
		if #m5 > 0 and #m2 > 0 then
			e.quadro = (e.quadro or 0) + 1;|, q|		local m5, m2 = op.toques.m5 or {}, op.toques.m2 or {};
		-- (0.87) janela do FS ja aberta no 1o quadro: pede o FS direto (sem botoes, para nao sair dobrado)
		if e.direta == nil and not p.teste then
			e.direta = false;
			if op.ls_acao_direta and n78.fs_vai_sair ~= nil and n78.fs_vai_sair(0) == true
				and n78.acao_direta(2, 16, "FS") then
				e.direta = true;
				registrar_fs();
				if p.diag ~= nil then p.diag.toques = "direto"; end
			end
		end
		if e.direta then return; end
		if #m5 > 0 and #m2 > 0 then
			e.quadro = (e.quadro or 0) + 1;|, "fs");

# ISS direto
troca(q|				ssiss.fase, ssiss.iss_em, ssiss.quadro, ssiss.mod_apertou = "iss", os.clock(), 0, true;|,
q|				ssiss.fase, ssiss.iss_em, ssiss.quadro, ssiss.mod_apertou = "iss", os.clock(), 0, true;
				-- (0.87) o jogo ja aceita o ISS: pede direto (ISS = 25 + nivel da aura)
				local aura = n78.nivel_aura and n78.nivel_aura() or nil;
				if op.ls_acao_direta and pronto == true and aura ~= nil and n78.acao_direta(2, 25 + aura, "ISS") then
					ssiss.quadro = math.huge;
				end|, "iss");

# menu
troca(q|			alterado, op.ls_m2_automatico = imgui.checkbox("Parado: M2 automatico para soltar o SS+ISS", op.ls_m2_automatico);
			mudou_arma = mudou_arma or alterado;|, q|			alterado, op.ls_m2_automatico = imgui.checkbox("Parado: M2 automatico para soltar o SS+ISS", op.ls_m2_automatico);
			mudou_arma = mudou_arma or alterado;
			alterado, op.ls_acao_direta = imgui.checkbox("FS / ISS pedidos direto ao jogo (so quando o jogo aceita)", op.ls_acao_direta);
			mudou_arma = mudou_arma or alterado;|, "menu");

# relatorio
troca(q|	local ct = estado.contatos_em_voce or {};|, q|	do
		local ad = {};
		for nome, n in pairs(estado.acoes_diretas or {}) do ad[#ad + 1] = nome .. " " .. n; end
		linha("Pedidos diretos ao jogo (so nas janelas): " .. (#ad > 0 and table.concat(ad, ", ") or "nenhum"));
	end
	local ct = estado.contatos_em_voce or {};|, "prints");

print $s;
