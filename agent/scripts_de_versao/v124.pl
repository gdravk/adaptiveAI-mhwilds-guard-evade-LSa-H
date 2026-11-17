local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }
sub troca_todas { my ($velho, $novo, $nome) = @_; my $n = ($s =~ s/\Q$velho\E/$novo/g); die "$nome nao achado" unless $n; return $n; }

troca(q|	Versao 1.23 - (luta 1.22 contra o Gore Magala) NO MAXIMO 3 FS SEGUIDOS:|,
q|	Versao 1.24 - VERIFICACAO DA REGRA DOS 3 FS: 1. golpe que o FS atual ja cobre (contra de 0,4s) nao faz mais
	nada - antes, se a barra tivesse acabado ou ja fossem 3 FS, o mod forcava uma esquiva POR CIMA do FS que
	estava protegendo (a barra cai justamente porque o FS a gasta); 2. no 4o FS, se o golpe chega ainda na
	invencibilidade do 3o FS (750 ms), o mod nao faz nada (a esquiva cortaria a protecao); so esquiva quando o
	golpe chega depois dela; 3. um FS so conta uma vez (dois avisos de invencibilidade em menos de 0,3s = 1 FS).
	1.23 - (luta 1.22 contra o Gore Magala) NO MAXIMO 3 FS SEGUIDOS:|, "cabecalho");
troca_todas(q|versao_mod = "1.23"|, q|versao_mod = "1.24"|, "versao");

troca(q|			if tipo == 6 or tipo == 7 then
				if invencibilidade.desde - (estado.fs_seguido_em or -100) > 3 then estado.fs_seguidos = 0; end
				estado.fs_seguidos = (estado.fs_seguidos or 0) + 1;
				estado.fs_seguido_em = invencibilidade.desde;|,
q|			if (tipo == 6 or tipo == 7) and invencibilidade.desde - (estado.fs_seguido_em or -100) >= 0.3 then -- (1.24) 1 FS = 1
				if invencibilidade.desde - (estado.fs_seguido_em or -100) > 3 then estado.fs_seguidos = 0; end
				estado.fs_seguidos = (estado.fs_seguidos or 0) + 1;
				estado.fs_seguido_em = invencibilidade.desde;|, "conta uma vez");

troca(q|				p.estado_pg.ignorar = true;
				p.sem_combo = true; -- nao conta como falha do FS
			end
			if desde >= 0.1 then return "indisponivel", "sem tempo"; end|,
q|				p.estado_pg.ignorar = true;
				p.sem_combo = true; -- nao conta como falha do FS
				return; -- (1.24) o FS atual cobre: nada de esquiva por cima dele
			end
			if desde >= 0.1 then return "indisponivel", "sem tempo"; end|, "cobre");

troca(q|			if n78.fs_limite() then
				estado.fs_limite_vezes = (estado.fs_limite_vezes or 0) + 1;|,
q|			if n78.fs_limite() then
				-- (1.24) o golpe chega ainda na invencibilidade do FS anterior: nao faz nada
				local inv_l = n78.invencibilidade or {};
				if (inv_l.tipo == 6 or inv_l.tipo == 7) and inv_l.ate ~= nil and inv_l.ate >= p.tempo + 0.05 then
					p.estado_pg.ignorar = true;
					p.sem_combo = true;
					if p.diag ~= nil then p.diag.resultado = "4o FS: golpe na invencibilidade do 3o"; end
					return;
				end
				estado.fs_limite_vezes = (estado.fs_limite_vezes or 0) + 1;|, "na invencibilidade");
print $s;
