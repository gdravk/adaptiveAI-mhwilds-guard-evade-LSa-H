local $/; my $s = <STDIN>;
open(my $fc, "<", "C:/Users/<usuario>/AppData/Local/Temp/claude/51384b687d73fb02/81a0a51e-3866-4ec1-ad32-dcb23497a1eb/scratchpad/controle059.lua") or die "controle";
my $controle = <$fc>; close $fc;
sub troca { my ($velho, $novo, $nome) = @_; my $i = index($s, $velho); die "$nome nao achado" if $i < 0; substr($s, $i, length($velho)) = $novo; }

troca(q|	Versao 0.58 - |, q|	Versao 0.59 - SS+ISS: seus botoes de ataque (M1, M2, M5) e o Espaco ficam soltos ate o SS sair;
	o SS e apertado de novo se o seu golpe ainda prende o personagem; aprende em quais animacoes suas
	o SS sai e quanto tempo cada golpe seu prende o personagem; mede o tempo maximo da postura;
	o tempo do golpe nas defesas certas e medido no instante certo (o aviso do jogo vinha ~0,3s
	atrasado e empurrou o tempo do ISS para 80 ms); o tempo do ISS volta a 150 ms
	0.58 - |, "cab");
$s =~ s/versao_mod = "0\.58"/versao_mod = "0.59"/g or die "vm";
$s =~ s/== Defesa Automatica v0\.58 ==/== Defesa Automatica v0.59 ==/g or die "pr";
$s =~ s/imgui\.tree_node\("Defesa Automatica v0\.58"\)/imgui.tree_node("Defesa Automatica v0.59")/ or die "tit";

troca(q|	iss_ajuste_auto = true,|, q|	iss_ajuste_auto = true,
	postura_medida_ms = 0,  -- (0.59) tempo maximo da postura do SS, medido no jogo (0 = ainda nao medido)
	reset_iss_059 = false,  -- (0.59) volta o ls_iss_ms a 150 uma vez (o ajuste da 0.58 usava o aviso atrasado)|, "op");

# tabelas aprendidas
troca(q|local FS_FALHAS_PARA_SS = 2;|, q|local FS_FALHAS_PARA_SS = 2;
local ss_animacoes = {};  -- (0.59) [sua animacao] = { ok, falha, atraso } do SS apertado nela
local ss_sem_golpe = {};  -- (0.59) [golpe] = { sem, ok }: SS feito e o golpe nao veio / ISS certo|, "tabelas");
troca(q|	if type(salvo) == "table" and type(salvo.fs_falhas) == "table" then fs_falhas = salvo.fs_falhas; end|,
q|	if type(salvo) == "table" and type(salvo.fs_falhas) == "table" then fs_falhas = salvo.fs_falhas; end
	if type(salvo) == "table" and type(salvo.ss_animacoes) == "table" then ss_animacoes = salvo.ss_animacoes; end
	if type(salvo) == "table" and type(salvo.ss_sem_golpe) == "table" then ss_sem_golpe = salvo.ss_sem_golpe; end|, "load");
$s =~ s/bloqueios = bloqueios_ls, fs_falhas = fs_falhas \}\);/bloqueios = bloqueios_ls, fs_falhas = fs_falhas, ss_animacoes = ss_animacoes, ss_sem_golpe = ss_sem_golpe });/g or die "save";

# grupos: M2 e M5 separados
troca(q|	m2_m5 = { 13, 36, 43, 15, 22 },|, q|	m2_m5 = { 13, 36, 43, 15, 22 },
	m2 = { 13, 36, 43 }, -- (0.59) separados: o SS escreve o M5 e precisa soltar o seu M2
	m5 = { 15, 22 },|, "grupos");
troca(q|		local usa_m2_m5, usa_espaco = false, false;
		for acao in pairs(teclas_agora) do
			if acao == "guarda" or acao == "especial" or string.sub(acao, 1, 9) == "toque:m5:" or string.sub(acao, 1, 9) == "toque:m2:" then
				usa_m2_m5 = true;|, q|		local usa_m2, usa_m5, usa_espaco = false, false, false;
		for acao in pairs(teclas_agora) do
			if acao == "guarda" or acao == "especial" then
				usa_m2, usa_m5 = true, true;
			elseif string.sub(acao, 1, 9) == "toque:m5:" then
				usa_m5 = true;
			elseif string.sub(acao, 1, 9) == "toque:m2:" then
				usa_m2 = true;|, "usa");
troca(q|		if not usa_m2_m5 then marcar("bloquear:m2_m5"); end|, q|		-- (0.59) M2 e M5 soltos separadamente (no SS o mod aperta o M5 e solta o seu M2)
		if not usa_m2 then marcar("bloquear:m2"); end
		if not usa_m5 then marcar("bloquear:m5"); end|, "bloq");

# controlador novo
{
	my $ini = index($s, "local function controlar_ss_iss(");
	my $fim = index($s, "local function decidir_botoes()");
	die "controlador" if $ini < 0 or $fim < $ini;
	substr($s, $ini, $fim - $ini) = $controle;
}

# os avisos do jogo nao ensinam mais (vinham atrasados); quem ensina e o sinal da espada
troca(q|						estado.fs_certo_em = os.clock();
						aprender_por_contra_ataque();|, q|						estado.fs_certo_em = os.clock();|, "hook_fs");
$s =~ s/\t\t\tpcall\(aprender_por_contra_ataque\); -- \(0\.58\)\n.*?\n\t\t\tend\n(?=\t\t\tif not estado\.leitura_ss_iss)//s or die "hook_iss";

troca(q|local salvar_relatorio; -- (0.44) definido depois da aba Prints|, q|--[[
	(0.59) SINAIS DA ESPADA NO INSTANTE DO GOLPE. No teste, o aviso do jogo "contra-ataque do ISS
	deu certo" chegou SEMPRE ~300 ms depois do M5 (287 a 343 ms), nao importa quando o golpe
	chegou: ele vem no fim do contra-ataque. O ajuste da 0.58 achou que o golpe chegava tarde e
	levou o tempo do ISS ate 80 ms. Nas leituras, o SINAL da espada (IsIaiKijinMikiriSuccessed)
	liga no instante do golpe (48 a 301 ms depois do M5). Agora:
	  - o tempo do golpe para o aprendizado e o do sinal (FS: IsMikiriSuccessed);
	  - o ajuste do ISS usa o sinal.
]]
local sinais_ls = {};

local function ajustar_iss(golpe_em)
	if not op.iss_ajuste_auto or ssiss == nil or not ssiss.mod_apertou or ssiss.iss_em == nil then return; end
	local depois_ms = (golpe_em - ssiss.iss_em) * 1000;
	if depois_ms < 0 or depois_ms > 450 then return; end
	local novo = op.ls_iss_ms + (160 - depois_ms) * 0.25;
	op.ls_iss_ms = math.floor(math.max(80, math.min(300, novo)) + 0.5);
	estado.iss_medidas = estado.iss_medidas or {};
	table.insert(estado.iss_medidas, 1, math.floor(depois_ms + 0.5));
	if #estado.iss_medidas > 8 then table.remove(estado.iss_medidas); end
	salvar_opcoes();
end

local function vigiar_sinais_ls()
	if estado.perfil ~= PERFIS.espada_longa then sinais_ls = {}; return; end
	local cacador = meu_cacador();
	local arma = cacador and cacador:call("get_WeaponHandling");
	if arma == nil then return; end
	for _, nome in ipairs({ "IsIaiKijinMikiriSuccessed", "IsMikiriSuccessed" }) do
		local ligado = arma:get_field(nome) == true;
		if ligado and not sinais_ls[nome] then
			local agora_lua = os.clock();
			pcall(aprender_por_contra_ataque);
			if nome == "IsIaiKijinMikiriSuccessed" then
				estado.iss_certo_em = agora_lua;
				pcall(ajustar_iss, agora_lua);
			end
		end
		sinais_ls[nome] = ligado;
	end
end

local salvar_relatorio; -- (0.44) definido depois da aba Prints|, "vigia");

troca(q|	local ok_leitura, erro_leitura = pcall(ler_ss_iss);|, q|	pcall(vigiar_sinais_ls); -- (0.59)
	local ok_leitura, erro_leitura = pcall(ler_ss_iss);|, "frame");

# Prints
troca(q|		linha(string.format("Leitura do SS+ISS: %s|, q|		local lista_ss, bloqueadas = {}, 0;
		for anim_ss, a in pairs(ss_animacoes) do
			if (a.ok or 0) > 0 then
				lista_ss[#lista_ss + 1] = string.format("%s %dms (%d/%d)", anim_ss, a.atraso or 0, a.ok or 0, (a.ok or 0) + (a.falha or 0));
			elseif (a.falha or 0) >= 2 then
				bloqueadas = bloqueadas + 1;
			end
		end
		table.sort(lista_ss);
		linha(string.format("SS: postura maxima %s - SS sai de %d animacoes suas (tempo que o seu golpe prende: %s) - %d animacoes onde o SS nao sai",
			(op.postura_medida_ms or 0) > 0 and (op.postura_medida_ms .. " ms medida") or (op.ls_postura_max_ms .. " ms (ainda nao medida)"),
			#lista_ss, #lista_ss > 0 and table.concat(lista_ss, ", ") or "-", bloqueadas));
		linha(string.format("Leitura do SS+ISS: %s|, "prints");

# volta o tempo do ISS a 150 uma vez
troca(q|pcall(carregar_conhecimento);
|, q|pcall(carregar_conhecimento);

pcall(function()
	if op.reset_iss_059 == true then return; end
	op.ls_iss_ms = 150;
	op.reset_iss_059 = true;
	salvar_opcoes();
end);
|, "reset");

print $s;
