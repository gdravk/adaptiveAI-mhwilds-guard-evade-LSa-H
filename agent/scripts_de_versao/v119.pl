local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 1.18 - |, q|	Versao 1.19 - PREPARACAO PARA O SOS: 1. os avisos do jogo de guarda / contra-ataque / esquiva perfeita
	agora so contam quando sao da SUA arma (antes a guarda de outro jogador contava como defesa sua);
	2. com outros jogadores, o SS+ISS so comeca se o monstro estiver virado para voce (ate 100 graus) - de
	costas o golpe quase sempre e em outro jogador e a postura prendia voce a toa (FS e esquiva seguem
	normais); 3. "SS+ISS trocado por FS" conta uma vez por golpe (antes contava a cada quadro).
	1.18 - |, "cab");
$s =~ s/versao_mod = "1\.18"/versao_mod = "1.19"/g or die "vm";
$s =~ s/== Defesa Automatica v1\.18 ==/== Defesa Automatica v1.19 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v1\.18"\)/imgui.tree_node("Defesa Automatica v1.19")/ or die "tit";

# 1. eventos so da sua arma
troca(q|		local ok = pcall(sdk.hook, funcao, function(args)
			-- (0.58) FS da Long Sword deu certo|, q|		local ok = pcall(sdk.hook, funcao, function(args)
			-- (1.19) SOS: so a SUA arma (estas funcoes sao chamadas na arma de cada jogador)
			local minha = nil;
			pcall(function() minha = meu_cacador():call("get_WeaponHandling"); end);
			if minha == nil or sdk.to_int64(args[2]) ~= minha:get_address() then return; end
			-- (0.58) FS da Long Sword deu certo|, "eventos");

# 2. monstro virado para voce
troca(q|					m.angulo = math.deg(math.acos(math.max(-1, math.min(1, cosseno))));
				end
			end
|, q|					m.angulo = math.deg(math.acos(math.max(-1, math.min(1, cosseno))));
				end
			end
			-- (1.19) para onde o MONSTRO olha em relacao a voce (0 = de frente para voce, 180 = de costas)
			m.virado = nil;
			if mx ~= nil and cx ~= nil then
				pcall(function()
					local eixo_m = m.objeto:call("get_Transform"):call("get_AxisZ");
					local fx, fz = eixo_m.x, eixo_m.z;
					local tam_f = math.sqrt(fx * fx + fz * fz);
					local vx, vz = cx - mx, cz - mz;
					local tam_v = math.sqrt(vx * vx + vz * vz);
					if tam_f > 0.01 and tam_v > 0.01 then
						local cos_v = (fx * vx + fz * vz) / (tam_f * tam_v);
						m.virado = math.deg(math.acos(math.max(-1, math.min(1, cos_v))));
					end
				end);
			end
|, "virado");
troca(q|			-- (1.18) outro acerto previsto ate 0,9s depois: o ISS (so 0,3s de contra) nao cobre -> FS|,
q|			-- (1.19) SOS: monstro de costas para voce -> o golpe e em outro jogador; sem SS+ISS
			if (estado.jogadores or 1) > 1 and m ~= nil and m.virado ~= nil and m.virado > 100 then
				if not p.ss_sos_contado then p.ss_sos_contado = true; estado.ss_sos_costas = (estado.ss_sos_costas or 0) + 1; end
				return false;
			end
			-- (1.18) outro acerto previsto ate 0,9s depois: o ISS (so 0,3s de contra) nao cobre -> FS|, "sos");

# 3. contagem uma vez por golpe
troca(q|						estado.ss_trocado_por_fs = (estado.ss_trocado_por_fs or 0) + 1;|,
	q|						if not p.ss_trocado then p.ss_trocado = true; estado.ss_trocado_por_fs = (estado.ss_trocado_por_fs or 0) + 1; end -- (1.19)|, "conta");
troca(q|		linha("SS+ISS trocado por FS (outro acerto ate 0,9s depois): " .. tostring(estado.ss_trocado_por_fs or 0) .. " vezes"); -- (1.18)|,
q|		linha("SS+ISS trocado por FS (outro acerto ate 0,9s depois): " .. tostring(estado.ss_trocado_por_fs or 0) .. " golpes"
			.. " - SOS, monstro de costas (sem SS+ISS): " .. tostring(estado.ss_sos_costas or 0) .. " golpes"); -- (1.18 / 1.19)|, "linha");
print $s;
