local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.38 - |, q|	Versao 0.39 - Iai: aperta o M5 enquanto a espada estiver na bainha (postura), ate o Iai sair
	0.38 - |, "cab");
$s =~ s/versao_mod = "0\.38"/versao_mod = "0.39"/ or die "vm";
$s =~ s/== Defesa Automatica v0\.38 ==/== Defesa Automatica v0.39 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.38"\)/imgui.tree_node("Defesa Automatica v0.39")/ or die "tit";

# toque do M5 do Special Sheathe: so os primeiros quadros (o aperto + o buffer curto)
troca(q|		if #m5 > 0 then
			if e.quadro <= #m5 then marcar("toque:m5:" .. e.quadro); end
		elseif desde < 0.1 then
			marcar("guarda");
		end
		if #espaco > 0 then|, q|		local curto = math.min(#m5, 6); -- (0.39) o aperto + 5 quadros de buffer
		if #m5 > 0 then
			if e.quadro <= curto then marcar("toque:m5:" .. e.quadro); end
		elseif desde < 0.1 then
			marcar("guarda");
		end
		if #espaco > 0 then|, "sheathe_curto");

$s =~ s/\t\t-- 2\. Iai Spirit Slash: toque do M5 de novo; se a animacao nao mudar em 0,3s, repete\n.*?\n\t\tend\n\tend\n\};/\t\t--[[
			2. Iai Spirit Slash (0.39). No teste da 0.38 o Special Sheathe saiu e o Iai nao. Causa
			provavel: o mod apertava o M5 do Iai uma vez e so repetia se a animacao continuasse
			a MESMA; quando a animacao do Special Sheathe virava a da postura, ele achava que
			o Iai tinha saido e parava. Agora a referencia e a ESPADA: na postura ela fica na
			bainha e o Iai a tira. Enquanto a espada estiver na bainha (e ainda der tempo), o
			mod aperta o M5 (1 quadro + buffer curto) a cada 0,25s.
		]]
		local hora_iai = (op.ls_sheathe_ms - op.ls_iai_ms) \/ 1000;
		local limite = hora_iai + (p.teste and 1.5 or (op.ls_iai_ms \/ 1000 + 0.15));
		if desde >= hora_iai and (desde <= limite or e.tocando) then
			if e.tocando then
				e.iai_quadro = e.iai_quadro + 1;
				if e.iai_quadro > math.max(curto, 6) then
					e.tocando = false;
					e.espera_ate = desde + 0.25;
				end
			end
			if not e.tocando and desde <= limite and desde >= (e.espera_ate or 0) and espada_na_bainha() then
				e.tocando, e.iai_quadro = true, 1;
				e.tentativas = (e.tentativas or 0) + 1;
				if p.diag ~= nil then p.diag.toques = e.tentativas; end
			end
			if e.tocando then
				if #m5 > 0 then
					if e.iai_quadro <= curto then marcar("toque:m5:" .. e.iai_quadro); end
				else
					marcar("guarda");
				end
			end
		end
	end
};/s or die "iai";

# funcao: espada na bainha?
troca(q|local function em_combo_espada_longa()|, q|-- (0.39) a espada esta na bainha? (na postura do Special Sheathe ela fica; o Iai a tira)
local function espada_na_bainha()
	local ok, sacada = pcall(function() return meu_cacador():call("get_IsWeaponOn"); end);
	return ok and sacada == false;
end

local function em_combo_espada_longa()|, "bainha");

print $s;
