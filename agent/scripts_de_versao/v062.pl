local $/; my $s = <STDIN>;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.61 - |, q|	Versao 0.62 - CORRECAO do SS+ISS: a 0.61 mediu a postura maxima errado (1761 ms - era o ISS
	"20:263", que o mod nao conhecia) e passou a achar que nenhum golpe cabia na postura: o ISS nao
	saia e o "CANCELAR SS" aparecia sempre. Agora: 20:263 e ISS, animacoes do ISS sao aprendidas
	pelo sinal da espada, a postura so e medida acima de 3s e a medida errada foi apagada
	0.61 - |, "cab");
$s =~ s/versao_mod = "0\.61"/versao_mod = "0.62"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.61 ==/== Defesa Automatica v0.62 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.61"\)/imgui.tree_node("Defesa Automatica v0.62")/ or die "tit";

troca(q|	reset_iss_059 = false, |, q|	reset_postura_062 = false, -- (0.62) apaga a postura maxima medida errado na 0.61
	reset_iss_059 = false, |, "op");

troca(q|local ANIM_ISS = { ["20:264"] = true, ["20:265"] = true };|,
q|-- (0.62) 20:263 tambem e ISS (no relatorio da 0.58: 20:250 -> 20:263 com contra-ataque certo).
-- Outras animacoes do ISS sao aprendidas pelo sinal da espada (ver vigiar_sinais_ls).
local ANIM_ISS = { ["20:263"] = true, ["20:264"] = true, ["20:265"] = true };|, "anim_iss");

# medicao da postura: so acima de 3s (nas leituras o ISS saiu 3,9s depois do SS)
troca(q|				if dur_ms >= 1500 then|, q|				if dur_ms >= 3000 then -- (0.62) nas suas leituras a postura durou pelo menos ~3,8s|, "medida");

# aprende animacoes do ISS pelo sinal
troca(q|	for _, nome in ipairs({ "IsIaiKijinMikiriSuccessed", "IsMikiriSuccessed" }) do|,
q|	-- (0.62) o ISS acertou / contra-atacou: a animacao de agora e do ISS
	local iss_sinal = arma:get_field("IsIaiKijinSlashHitted") == true or arma:get_field("IsIaiKijinMikiriSuccessed") == true;
	if iss_sinal and not sinais_ls.iss and string.sub(anim_agora, 1, 3) == "20:" and not ANIM_SS[anim_agora]
		and not ANIM_ISS[anim_agora] then
		ANIM_ISS[anim_agora] = true;
		estado.bloqueio_mudou = true;
	end
	sinais_ls.iss = iss_sinal;

	for _, nome in ipairs({ "IsIaiKijinMikiriSuccessed", "IsMikiriSuccessed" }) do|, "aprende_iss");

# salvar / carregar as animacoes do ISS
$s =~ s/janela_combo = janela_combo_dados, anim_fs = ANIM_FS \}\);/janela_combo = janela_combo_dados, anim_fs = ANIM_FS, anim_iss = ANIM_ISS });/g or die "save";

# ANIM_ISS e definido depois do carregamento: le de novo o arquivo na hora de definir
troca(q|local ANIM_ISS = { ["20:263"] = true, ["20:264"] = true, ["20:265"] = true };|,
q|local ANIM_ISS = { ["20:263"] = true, ["20:264"] = true, ["20:265"] = true };
pcall(function()
	local salvo = json.load_file("aviso_lanca_defesas.json");
	if type(salvo) == "table" and type(salvo.anim_iss) == "table" then
		for anim_iss in pairs(salvo.anim_iss) do ANIM_ISS[anim_iss] = true; end
	end
end);|, "load_iss");

# apaga a medida errada uma vez
troca(q|pcall(function()
	if op.reset_iss_059 == true then return; end|, q|pcall(function()
	if op.reset_postura_062 == true then return; end
	op.postura_medida_ms = 0;
	op.reset_postura_062 = true;
	salvar_opcoes();
end);

pcall(function()
	if op.reset_iss_059 == true then return; end|, "reset");

print $s;
