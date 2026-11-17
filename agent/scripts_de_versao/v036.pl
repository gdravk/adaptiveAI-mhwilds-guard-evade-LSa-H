local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

# --- versao
troca(q|	Versao 0.35 - Hammer removido|, q|	Versao 0.36 - Iai com o buffer do M5; Foresight repetido ate sair
	0.35 - Hammer removido|, "cab");
$s =~ s/versao_mod = "0\.35"/versao_mod = "0.36"/ or die "vm";
$s =~ s/== Defesa Automatica v0\.35 ==/== Defesa Automatica v0.36 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.35"\)/imgui.tree_node("Defesa Automatica v0.36")/ or die "tit";

# =====================================================================================
# 1. IAI: o toque do M5 era escrito em "modo seguro" (sem o buffer de entrada e sem o
#    "acabou de ser apertado"), igual ao Espaco. Sem isso o jogo nao ve um aperto NOVO do
#    M5 na postura. O modo seguro fica so para o Espaco (o motivo dele era o Espaco).
# =====================================================================================
troca(q|			local modo_seguro = (acao == "esquiva" or acao == "espaco" or string.sub(acao, 1, 6) == "toque:");|,
q|			-- (0.36) o toque gravado do M5 (Iai) precisa do buffer: so o toque do Espaco e seguro
			local modo_seguro = (acao == "esquiva" or acao == "espaco" or string.sub(acao, 1, 14) == "toque:esquiva:");|, "modo_seguro");

# =====================================================================================
# 2. FORESIGHT REPETIDO: no historico da luta, o Foresight apertado ~100 ms antes do golpe
#    no meio de um ataque seu (20:211, 20:250) nao mudou a animacao: o jogo ignorou (voce
#    ainda nao podia cancelar o ataque) e o golpe acertou. Agora o mod comeca um pouco
#    antes (200 ms) e aperta de novo a cada 0,12s ate a sua animacao mudar ou o golpe chegar.
# =====================================================================================
troca(q|	ls_foresight_ms = 120,  -- Foresight Slash (M5 + M2) este tanto antes do golpe|,
q|	ls_foresight_ms = 200,  -- Foresight Slash (M5 + M2) comeca este tanto antes do golpe (repete ate sair)|, "op");
troca(q|	versao_campos = 7,|, q|	versao_campos = 8,|, "versao_campos");
troca(q|	op.versao_campos = 7;|, q|	-- 0.36: o Foresight passa a ser repetido ate sair; comeca 200 ms antes (era 120)
	if (salvo.versao_campos or 1) < 8 and op.ls_foresight_ms == 120 then
		op.ls_foresight_ms = 200;
	end
	op.versao_campos = 8;|, "migracao");

troca(q|		if desde < 0.1 then marcar("guarda"); marcar("especial"); end
	end,
	iai = function(desde, p)|, q|		-- (0.36) aperta; se a sua animacao nao mudar, o jogo ignorou: aperta de novo
		local e = p.estado_pg;
		local limite = op.ls_foresight_ms / 1000; -- a hora do golpe
		if e.anim_inicio == nil then e.anim_inicio = combo.animacao or "?"; e.proximo = 0; end
		if desde >= e.proximo and desde <= limite then
			if e.toques_fs ~= nil and (combo.animacao or "?") ~= e.anim_inicio then
				e.proximo = math.huge; -- a animacao mudou: o Foresight saiu
			else
				e.toques_fs = (e.toques_fs or 0) + 1;
				e.ate = desde + 0.06;
				e.proximo = desde + 0.12;
				if p.diag ~= nil then p.diag.toques = e.toques_fs; end
			end
		end
		if e.ate ~= nil and desde < e.ate then marcar("guarda"); marcar("especial"); end
	end,
	iai = function(desde, p)|, "foresight");

# historico: quantos toques
troca(q|		linha(string.format("   %s - %d ms - %s -> %s - %s", NOME_ACAO[d.defesa] or tostring(d.defesa), d.ms,
			tostring(d.antes), tostring(d.depois or "..."), tostring(d.resultado)));|,
q|		linha(string.format("   %s - %d ms - %s -> %s - %s%s", NOME_ACAO[d.defesa] or tostring(d.defesa), d.ms,
			tostring(d.antes), tostring(d.depois or "..."), tostring(d.resultado),
			d.toques and (" - apertou " .. d.toques .. "x") or ""));|, "prints");

print $s;
