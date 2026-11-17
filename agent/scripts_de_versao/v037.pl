local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.36 - Iai|, q|	Versao 0.37 - Special Sheathe e Iai com apertos de 1 quadro (como o jogo grava); esquiva nunca depois do golpe
	0.36 - Iai|, "cab");
$s =~ s/versao_mod = "0\.36"/versao_mod = "0.37"/ or die "vm";
$s =~ s/== Defesa Automatica v0\.36 ==/== Defesa Automatica v0.37 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.36"\)/imgui.tree_node("Defesa Automatica v0.37")/ or die "tit";

# --- novo Iai
$s =~ s/\tiai = function\(desde, p\)\n.*?\n\tend\n\};/\tiai = function(desde, p)
		local e = p.estado_pg;
		if not p.teste and not e.conferiu then
			e.conferiu = true;
			if desde >= 0.1 then return "indisponivel", "sem tempo"; end
			if not em_combo_espada_longa() then return "indisponivel", "fora do combo"; end
		end

		--[[
			(0.37) O toque do M5 que voce gravou mostrou como o jogo ve um aperto de verdade:
			o botao fica apertado UM quadro so, com "_OnTrigger" (acabou de apertar), e no
			quadro seguinte ja vem "_OffTrigger" (soltou). O mod apertava o M5 como a guarda
			(segurado por 0,1s, sem "_OnTrigger"): para a guarda serve, para o Iai nao.
			Agora o Special Sheathe toca o toque gravado do M5 e o do Espaco no MESMO quadro,
			e o Iai toca de novo o toque do M5 - cada um no seu proprio contador de quadros
			(antes o Iai esperava o toque do Espaco terminar e podia nem tocar).
		]]
		local m5 = op.toques.m5 or {};
		local espaco = op.toques.esquiva or {};
		e.quadro = (e.quadro or 0) + 1;

		-- 1. Special Sheathe: M5 + Espaco no mesmo quadro
		if e.quadro == 1 and not p.teste then
			-- a espada vai para a bainha: o mod continua ate o Iai (ver pode_defender)
			estado.postura_ls_ate = os.clock() + (op.ls_sheathe_ms \/ 1000) - desde + 0.6;
		end
		if #m5 > 0 then
			if e.quadro <= #m5 then marcar("toque:m5:" .. e.quadro); end
		elseif desde < 0.1 then
			marcar("guarda");
		end
		if #espaco > 0 then
			if e.quadro <= #espaco then marcar("toque:esquiva:" .. e.quadro); end
		elseif desde < 0.1 then
			marcar("esquiva");
		end

		-- 2. Iai Spirit Slash: toque do M5 de novo; se a animacao nao mudar em 0,3s, repete
		local hora_iai = (op.ls_sheathe_ms - op.ls_iai_ms) \/ 1000;
		if desde >= hora_iai then
			if e.iai_quadro == nil then
				e.iai_quadro, e.tentativas, e.anim_iai = 0, 1, combo.animacao;
			end
			e.iai_quadro = e.iai_quadro + 1;
			if e.iai_quadro > 18 and combo.animacao == e.anim_iai and desde <= hora_iai + op.ls_iai_ms \/ 1000 + 0.15 then
				e.iai_quadro, e.tentativas = 1, e.tentativas + 1;
			end
			if p.diag ~= nil then p.diag.toques = e.tentativas; end
			if #m5 > 0 then
				if e.iai_quadro <= #m5 then marcar("toque:m5:" .. e.iai_quadro); end
			elseif e.iai_quadro <= 6 then
				marcar("guarda");
			end
		end
	end
};/s or die "iai";

# --- esquiva de reserva nunca depois da hora do golpe
troca(q|					if reserva == "esquiva" and falta < (antes.esquiva or 0.15) - 0.1 then|,
q|					if reserva == "esquiva" and falta < (antes.esquiva or 0.15) - 0.1 and falta > -0.03 then|, "reserva");

print $s;
