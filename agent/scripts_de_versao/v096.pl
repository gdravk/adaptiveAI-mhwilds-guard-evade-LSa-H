local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.95 - |, q|	Versao 0.96 - ACOES DOS SEUS TESTES (arena, 14 armas): Charged Step = cChargeDodgeToCharge (2,73);
	Counter da Switch Axe = cSwordCounterSlash (2,31), botao M5+M1; Perfect Block da Heavy Bowgun (R+F) =
	cGuard (1,141); Dual Blades no modo demon esquiva com cKijinDodge (2,42). A esquiva aprendida nao pega
	mais as transicoes (cDodgeToMove, cDodgeTurn180ToMove...).
	0.95 - |, "cab");
$s =~ s/versao_mod = "0\.95"/versao_mod = "0.96"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.95 ==/== Defesa Automatica v0.96 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.95"\)/imgui.tree_node("Defesa Automatica v0.96")/ or die "tit";

# --- numeros padrao ---
troca(q|	local a = por[tipo];
	if a ~= nil and a.cat ~= nil and not a.ruim then return a.cat, a.idx, false; end|, q|	-- (0.96) Dual Blades no modo demon: a esquiva do demon (cKijinDodge), vista nos seus testes
	if tipo == "esquiva" and wt == 2 and n78.db_demonio() then return 2, 42, true; end
	local a = por[tipo];
	if a ~= nil and a.cat ~= nil and not a.ruim then return a.cat, a.idx, false; end
	-- (0.96) Charged Step do Hammer (cChargeDodgeToCharge, visto nos seus testes)
	if tipo == "passo" and wt == 4 and not por.passo_padrao_ruim then return 2, 73, true; end|, "acao_de1");
troca(q|	if tipo == "bloqueio" and wt == 12 and not por.bloqueio_padrao_ruim then return 1, 146, true; end|,
q|	-- (0.96) o seu R+F na Heavy Bowgun e o cGuard (1,141); o 1,146 dos mods e a reacao depois do golpe
	if tipo == "bloqueio" and wt == 12 and not por.bloqueio_padrao_ruim then return 1, 141, true; end|, "acao_de2");
troca(q|n78.modo_machado = function()|, q|-- (0.96) Dual Blades: modo demon ligado?
n78.db_demonio = function()
	local sim = false;
	pcall(function() sim = meu_cacador():call("get_WeaponHandling"):call("get_IsKijinOn") == true; end);
	return sim;
end;
n78.modo_machado = function()|, "demon");

# --- aprender / conferir pelo nome ---
troca(q|			if cacador:call("get_WeaponType") == 4 and string.find(nome, "Step", 1, true) ~= nil then tipo = "passo"; -- (0.91) Charged Step
			elseif string.sub(nome, 1, 6) == "cDodge" then tipo = "esquiva";|,
q|			if cacador:call("get_WeaponType") == 4 and nome == "cChargeDodgeToCharge" then tipo = "passo"; -- (0.96) Charged Step
			-- (0.96) so a esquiva em si: as transicoes (cDodgeToMove, cDodgeTurn180ToMove, cDodgeToRun) nao contam
			elseif string.sub(nome, 1, 6) == "cDodge" and string.find(nome, "To", 7, true) == nil then tipo = "esquiva";|, "nomes");
troca(q|			if fp ~= nil and fp.tipo == "bloqueio" and cat == 1 and idx == 146 then tipo = "bloqueio"; end -- (0.92)
			-- (0.95) Counter da Switch Axe: so confere (2,54 / 2,31 / 2,32), nao guarda como acao aprendida
			local confere_sa = fp ~= nil and fp.tipo == "contra_sa" and cat == 2 and (idx == 54 or idx == 31 or idx == 32);|,
q|			-- (0.96) acoes que so conferem o pedido (nao viram acao aprendida): Perfect Block da Heavy Bowgun,
			-- Counter da Switch Axe (o 2,54 e o cSwordMove, nao conta) e a esquiva do demon das Dual Blades
			local confere_sa = fp ~= nil and ((fp.tipo == "bloqueio" and cat == 1 and (idx == 141 or idx == 146))
				or (fp.tipo == "contra_sa" and cat == 2 and (idx == 31 or idx == 32))
				or (fp.tipo == "esquiva" and nome == "cKijinDodge"));|, "confere");
troca(q|(fp.tipo == "esquiva" or fp.tipo == "bloqueio" or fp.tipo == "contra_sa")|,
	q|(fp.tipo == "esquiva" or fp.tipo == "bloqueio" or fp.tipo == "contra_sa" or fp.tipo == "passo")|, "ruim");

# --- esquiva aprendida errada (transicao) e descartada ---
troca(q|				local atual = op.acoes_aprendidas[wt][tipo];|, q|				local atual = op.acoes_aprendidas[wt][tipo];
				if atual ~= nil and string.find(tostring(atual.nome), "To", 7, true) ~= nil then atual = nil; end -- (0.96)|, "transicao");

# --- botao do Counter: M5 + M1 ---
troca(q|toque_rm1 = "TOQUE DO R+M1 (Counter da Switch Axe, forma espada)"|, q|toque_rm1 = "TOQUE DO M5+M1 (Counter da Switch Axe, forma espada)"|, "rot1");
troca(q|"Gravar toque do R+M1 (Counter da Switch Axe)"|, q|"Gravar toque do M5+M1 (Counter da Switch Axe)"|, "rot2");
troca(q|		-- (0.95) 1. pedido direto (2,54 + 2,31, como os mods testados)  2. R+M1 gravado  3. esquiva|,
	q|		-- (0.95) 1. pedido direto (2,54 + 2,31, como os mods testados)  2. M5+M1 gravado  3. esquiva|, "rot3");
troca(q|return "indisponivel", "R+M1 nao gravado";|, q|return "indisponivel", "M5+M1 nao gravado";|, "rot4");

print $s;
