local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|			-- (0.34) os golpes da espada longa aprendidos ate a 0.33 voltam ao Foresight
			if not (op.ls_zerado_034 ~= true and string.sub(chave, 1, 13) == "espada_longa:") then
				defesas_aprendidas[chave] = nivel;
			end
		end
		if op.ls_zerado_034 ~= true then
			op.ls_zerado_034 = true;
			json.dump_file("aviso_lanca_opcoes.json", op);
			json.dump_file("aviso_lanca_defesas.json", { golpes = defesas_aprendidas });
		end|, q|			defesas_aprendidas[chave] = nivel;
		end|, "desfaz");

troca(q|pcall(carregar_opcoes);
pcall(ligar_pontos_de_escrita);|, q|pcall(carregar_opcoes);

-- (0.34) zera UMA vez os golpes da espada longa aprendidos ate a 0.33 (feitos com o Iai
-- sem funcionar e com o dano medido pelo banco 14): voltam todos ao Foresight Slash.
-- Fica aqui, depois de carregar as opcoes, para nao sobrescrever as opcoes salvas.
pcall(function()
	if op.ls_zerado_034 == true then return; end
	for chave in pairs(defesas_aprendidas) do
		if string.sub(chave, 1, 13) == "espada_longa:" then defesas_aprendidas[chave] = nil; end
	end
	op.ls_zerado_034 = true;
	salvar_opcoes();
	json.dump_file("aviso_lanca_defesas.json", { golpes = defesas_aprendidas });
end);

pcall(ligar_pontos_de_escrita);|, "inicio");
print $s;
