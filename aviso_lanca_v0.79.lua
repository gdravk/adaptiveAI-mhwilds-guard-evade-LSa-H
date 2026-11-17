---@diagnostic disable: undefined-global

--[[
	Aviso de Guarda (Lanca) - Monster Hunter Wilds (REFramework)
	Versao 0.79 - aprendizado novo ajustado pelo 1o teste: o contato do golpe que "passou" (o
	jogo testa o contato como acerto e so depois decide que voce esquivou) agora tambem ensina
	quando nenhum outro caminho aprendeu; area de ataque conferida pela MAIORIA das medicoes (antes
	uma medicao fora derrubava a animacao inteira); relatorio mostra os contatos em voce; armas com
	defesa na hora do golpe aparecem certo no Prints
	0.78 - APRENDIZADO NOVO (tudo lido no seu proprio jogo, nada pela internet):
	  - CONTATO DO GOLPE: quando o golpe encosta em voce e NAO acerta (esquiva, FS, ISS com
	    invencibilidade), o jogo ainda testa o contato. Agora cada esquiva ensina o tempo do golpe;
	  - AREA DE ATAQUE: o mod ve quando a area de ataque do monstro liga (mesmo errando todo mundo).
	    Quando, numa animacao, a area liga sempre o mesmo tanto antes do golpe chegar (conferido),
	    ela passa a ensinar e a acertar o relogio da previsao na hora;
	  - previsao: golpe repetido (a mesma animacao comecando de novo) agora tambem e previsto;
	  - invencibilidade: mede quando a invencibilidade do FS / esquiva comeca e quanto dura;
	  - FIM DA QUEST / TROCA DE CENA: o mod solta os monstros na hora (travamento no fim da luta);
	  - OUTRAS ARMAS: defesa na hora do golpe para Great Sword, Sword and Shield, Dual Blades,
	    Switch Axe, Charge Blade, Bow, Heavy Bowgun e Light Bowgun;
	  - relatorio com tudo isso
	0.77 - barra de previsao: opcao "Desligar a barra" (nunca mostra a barra); a aba
	"Configurar Barra de previsao" ja vem aberta na primeira vez
	0.76 - barra de previsao: opcao "Sempre visivel" (a barra fica na tela mesmo sem golpe
	vindo; desligada = automatico, como antes: aparece so quando um golpe vem)
	0.75 - nova aba "Configurar Barra de previsao" no menu: tamanho, opacidade, posicao
	vertical e horizontal da barra (com uma barra de exemplo enquanto a aba esta aberta)
	0.74 - barra de previsao fixa: mostra sempre 4s (o maximo que o mod preve), mais larga
	para caber os 4s; sem menu e sem numeros (a altura volta a ser a de antes)
	0.73 - barra de previsao: ajustes no menu ("Barra de previsao"): quanto tempo ela mostra
	(1,2s a 4s; padrao agora 3s - o mod ja previa golpes ate 4s a frente, a barra so mostrava 1,2s),
	largura, altura na tela, segundos que faltam em cada golpe e marcas de 1 em 1 segundo
	0.72 - trava: o FS e o ISS tambem sao medidos (quanto prendem e o que vem depois deles: o M1
	no lugar ou os 2 golpes pulando para frente do M5); antes, depois de um FS o mod nao sabia quanto
	tempo o seu proximo aperto ia prender
	0.71 - trava dos seus ataques: o mod descobre sozinho botoes de ataque que escapavam da trava
	(ex.: M1 + M2 juntos podem ser outro "comando" do jogo) e passa a trava-los tambem; o SS de uma
	sequencia nao comeca mais 0,5s antes (os SS de 3,5s eram previsoes longas e erravam)
	0.70 - GOLPES MULTIPLOS (ex.: golpe triplo do Chatacabra, golpes a ~0,3s um do outro): a trava
	dos seus ataques agora se prepara para o SS+ISS tambem com a barra vermelha quando o golpe vem em
	sequencia (antes ela se preparava para o FS, voce continuava atacando e o SS nao cabia mais); o SS
	de uma sequencia pode comecar ate 0,5s mais cedo
	0.69 - Long Sword: GOLPES MULTIPLOS - com a barra vermelha, golpe que vem em sequencia
	(outro golpe do mesmo monstro ate 1,2s depois) usa SS+ISS quando da tempo (o FS cobre so um
	golpe); FS nao e apertado de novo se o personagem ja esta no meio de um FS
	0.68 - TRAVAMENTO NO FIM DA LUTA: o log mostrou o mod chamando a posicao e a animacao de um
	monstro ja destruido (18:04:21) e o jogo parou logo depois. Agora o mod le a VIDA do monstro e,
	quando ele morre, nao chama mais nada nele; se a posicao falhar, nao chama mais nada no mesmo
	quadro. Long Sword: abaixo da barra vermelha o FS vira esquiva (o FS zerava o carregamento da
	barra); durante o ISS e o FS o mod nao aperta mais nada (golpes multiplos)
	0.67 - SEGURANCA: o buffer de entrada e achado de novo a cada escrita (antes o mod guardava
	o objeto e podia escrever num buffer que o jogo ja tinha trocado - suspeita do travamento no fim
	da luta); sem monstro grande vivo o SS+ISS para na hora; golpes seus novos sao aprendidos pelo
	seu aperto (antes so quando a espada acertava o monstro)
	0.66 - botoes travados agora APAGAM tambem o aperto guardado no buffer do jogo: spamando,
	o seu ultimo M1 / M2 / M5 ficava guardado (~0,6s) e saia no lugar do SS / FS / esquiva
	0.65 - trava dos seus golpes corrigida: o FS (20:226), o SS (20:249) e o ISS (20:263/264/
	265) eram medidos como "golpes seus" (1,3 a 1,5s) e o mod achava que todo ataque seu prendia 2s;
	o SS so e tentado se o que FALTA do seu golpe atual (medido) + bainha cabem antes do golpe do
	monstro (antes usava uma media); limpeza unica das medidas erradas
	0.64 - Long Sword: TRAVA PELO TEMPO DOS SEUS GOLPES. O mod aprende quanto tempo cada golpe
	seu prende o personagem e qual golpe vem depois no combo; um ataque seu so e aceito se ele (e o
	que ja esta saindo) acabar antes da hora em que o SS, o FS ou a esquiva precisam sair
	0.63 - SS+ISS: seus ataques (M1, M2, M5) ficam travados 0,6s ANTES do SS (um golpe seu
	apertado antes ficava guardado e cancelava a postura); a postura continua travada se o golpe
	previsto "sumir" de repente (ate a hora dele passar); o "CANCELAR SS" so aparece depois de 0,4s
	seguidos sem golpe vindo
	0.62 - CORRECAO do SS+ISS: a 0.61 mediu a postura maxima errado (1761 ms - era o ISS
	"20:263", que o mod nao conhecia) e passou a achar que nenhum golpe cabia na postura: o ISS nao
	saia e o "CANCELAR SS" aparecia sempre. Agora: 20:263 e ISS, animacoes do ISS sao aprendidas
	pelo sinal da espada, a postura so e medida acima de 3s e a medida errada foi apagada
	0.61 - postura do SS: com golpe vindo, M1, M2, M5 e Espaco ficam TRAVADOS (tambem no SS
	feito por voce) - o M1 soltava um golpe sem invencibilidade e cancelava o ISS; sem golpe vindo,
	aparece o quadrado vermelho "CANCELAR SS" e so entao o M1 e o M5 ficam livres para voce cancelar.
	O mod nao cancela mais a postura sozinho
	0.60 - Long Sword: JANELA DO COMBO APRENDIDA (ate quanto tempo depois do seu golpe o FS e o
	SS saem, medido em cada tentativa); passou da janela = esquiva normal (tambem no "Somente SS+ISS");
	na postura do SS o seu M1 fica livre (cancelar com o Iai Slash) e, se o golpe nao vier, o proprio
	mod cancela com o M1
	0.59 - SS+ISS: seus botoes de ataque (M1, M2, M5) e o Espaco ficam soltos ate o SS sair;
	o SS e apertado de novo se o seu golpe ainda prende o personagem; aprende em quais animacoes suas
	o SS sai e quanto tempo cada golpe seu prende o personagem; mede o tempo maximo da postura;
	o tempo do golpe nas defesas certas e medido no instante certo (o aviso do jogo vinha ~0,3s
	atrasado e empurrou o tempo do ISS para 80 ms); o tempo do ISS volta a 150 ms
	0.58 - revisao do SS+ISS e mais aprendizado: aprende o tempo do golpe tambem quando o FS
	ou o ISS DEFENDEM (antes so aprendia levando dano); o tempo do ISS se ajusta sozinho pelos
	contra-ataques certos; golpe que o FS defende volta a ser do FS; varias correcoes
	0.57 - Long Sword: prioridade pelo Spirit Gauge. Barra abaixo do vermelho: SS+ISS (sobe a
	barra) > FS > esquiva. Barra VERMELHA: FS > esquiva, e SS+ISS so nos golpes que o FS nao defende
	(aprendidos: FS levou dano 2 vezes no mesmo golpe). Opcao "Somente SS+ISS" (sem FS e sem esquiva)
	0.56 - Long Sword: SS+ISS automatico (Special Sheathe + Iai Spirit Slash), montado com as
	suas 18 leituras manuais. Prioridade: 1. SS+ISS (quando o golpe vem com tempo para o SS)
	2. FS (golpe em cima da hora) 3. esquiva. Se VOCE fizer o SS, o mod solta o ISS na hora do golpe
	0.55 - Long Sword: LEITURA DO SS+ISS (Special Sheathe + Iai Spirit Slash). Com a leitura
	ligada o mod nao defende: so le, quadro a quadro, os seus SS+ISS manuais (botoes, buffer, suas
	animacoes, golpes do monstro, dano e contra-ataque do ISS) e salva um arquivo por SS+ISS
	0.54 - fora os golpes em voce, aprende SO com golpes no Palico (nunca com bots / cacadores
	de suporte, outros jogadores ou objetos); limpeza unica das medicoes de origem incerta
	0.53 - limpeza unica COMPLETA do Arkveld e de todos os monstros enfrentados no SOS
	(golpes aprendidos e defesas aprendidas desses monstros comecam do zero)
	0.52 - ONLINE: nao aprende mais com golpes em outros jogadores (chegam atrasados pela rede);
	limpeza unica do que foi aprendido assim no SOS; no multiplayer so defende golpes que ja
	acertaram VOCE alguma vez
	0.51 - Long Sword: bloqueio dos seus botoes APRENDIDO por animacao (prende menos, solta antes
	o Foresight); sem bloqueio fora do combo (primeiro golpe e esquiva livres); a esquiva fora do combo
	sai no tempo certo; nao mexe mais em monstros que ja sairam do jogo (erro no fim da missao)
	0.50 - revisao das versoes 0.45 a 0.49: o bloqueio dos botoes nao sobra depois de desligar /
	guardar a arma; o teste do M4 nao para a si mesmo; aviso claro no Prints quando o M4 gravado nao
	tem comando proprio
	0.49 - cada VARIANTE de monstro (normal, Tempered, Arch-tempered) tem o seu proprio
	aprendizado; M4 (guardar a arma e correr) e a prioridade 0: o mod nunca interrompe
	0.48 - Long Sword: o Foresight tem prioridade sobre TODOS os seus botoes de acao (M1, M2, M5
	e Espaco), nao so o M1
	0.47 - Long Sword: o Foresight tem prioridade maxima (o seu M1 fica bloqueado perto do golpe);
	nome de cada monstro salvo no aprendizado (para a lista de monstros com a porcentagem)
	0.46 - Long Sword: o combo conta tambem os seus botoes de ataque (M1, M2, M5), mesmo sem
	acertar; menu e aba Prints mais simples (so o que importa para a arma atual); limpeza de
	opcoes e codigo antigos que nao eram mais usados
	0.45 - aprende tambem com golpes no Palico e em outros jogadores; cobertura do
	conhecimento por monstro (Prints e relatorio); 80 medicoes por animacao
	0.44 - RELATORIO AUTOMATICO: a aba Prints e todas as defesas da sessao sao salvas sozinhas
	em reframework/data/aviso_lanca_prints (um arquivo por vez que o jogo abre)
	0.43 - LIMPEZA: sem mudar o que funciona, saiu o codigo que nao era mais usado (ferramentas
	de pesquisa, gravador, exportacoes, painel, Special Sheathe + Iai). Voltou ao menu a gravacao dos
	toques do M5 e do M2 (o Foresight da Long Sword usa essas gravacoes).
	0.42 - Long Sword: Foresight e esquiva apertados como um aperto de verdade (com o buffer de entrada)
	0.41 - Long Sword so com Foresight Slash (1) e esquiva (2); Special Sheathe + Iai desativado;
	ataque automatico da 0.40 removido (feita a partir da 0.39)
	0.39 - Iai: aperta o M5 enquanto a espada estiver na bainha (postura), ate o Iai sair
	0.38 - Foresight e Iai no mesmo tempo da guarda (linha amarela, 120 ms)
	0.37 - Special Sheathe e Iai com apertos de 1 quadro (como o jogo grava); esquiva nunca depois do golpe
	0.36 - Iai com o buffer do M5; Foresight repetido ate sair
	0.35 - Hammer removido; Long Sword continua defendendo na postura do Special Sheathe; historico das defesas no Prints
	(o Hammer foi removido a seu pedido: com ele o mod nao faz nada)
	0.34 - toque gravado do M5 (Iai) e dano pela vida; 0.33 - Long Sword: combo dura 2,5s, Iai com repeticao do M5; 0.32 - guarda segurada em golpes seguidos; 0.31 - Guard Up: golpes "impossiveis" sao guardados; 0.30 - revisao da Long Sword e do Hammer; 0.29 - Long Sword (Foresight Slash, Special Sheathe + Iai) e Hammer (Charged Step); menu simples. ARMAS: lanca, dual blades, bowgun leve, berrante, espada e escudo, espada longa

	O que faz:
	  - Mostra uma BARRA DE AVISO no centro da tela quando um monstro grande comeca um golpe que o
	    mod conhece. Um marcador anda em direcao a uma linha e chega nela no momento do
	    impacto (como jogo de ritmo). Pouco antes, pisca "AGORA!".
	  - O texto diz o que fazer: GUARDA, POWER GUARD ou IMPOSSIVEL DE GUARDAR (esquive).
	  - APRENDE sozinho: cada golpe de qualquer monstro grande que chega em voce vira uma medicao.
	    Quanto mais voce luta, mais golpes ele conhece e mais preciso fica.
	  - Ja vem com o que foi medido nas gravacoes (Arkveld normal, lanca, solo).

	Como funciona por dentro:
	  Cada golpe do monstro e uma sequencia de animacoes (preparacao -> golpe). O tempo entre
	  o inicio de cada animacao e o impacto quase nao varia (cerca de 0,05s). Entao, quando o
	  monstro comeca uma animacao conhecida, o mod ja sabe quando o golpe vai chegar.

	Arquivos (em <pasta do jogo>/reframework/data/):
	  - aviso_lanca_opcoes.json       suas opcoes
	  - aviso_lanca_aprendizado.json  tudo o que o mod ja aprendeu
	  - aviso_lanca_estrutura.json    exportacao para pesquisa (botao no menu)
	  - aviso_lanca_gravacao_v27_N.json gravacoes para pesquisa (botao no menu)

	Partes do arquivo:
	  1. Ajustes e opcoes          2. Relogio, jogador e animacoes
	  3. Conhecimento e previsao   4. Monstros (todos os grandes)
	  5. Impactos e aprendizado    6. Arma atual
	  7. Barra de aviso na tela    8. Menu
]]


-- =====================================================================================
-- 1. AJUSTES E OPCOES
-- =====================================================================================

local AJUSTES = {
	-- monstros cobertos (ID da lista do HunterPie). Normal, temperado, arquitemperado e todas
	-- as dificuldades usam o mesmo ID.
	-- (versao 0.23: todos os monstros grandes; a lista fixa do Arkveld nao e mais usada)

	-- enderecos dentro do monstro (conferidos no HunterPie, versoes 1.20 a 1.42.0.2 do jogo)
	dados_basicos = 0x108,
	id_nos_dados_basicos = 0x48,
	inteligencia = 0xE8, -- gerenciador de IA (tem o "objeto de jogo" do monstro)

	-- aprendizado
	historico_animacoes = 4,     -- quantas animacoes recentes de cada monstro guardar
	animacoes_por_impacto = 3,   -- cada impacto ensina as 3 ultimas animacoes
	idade_maxima_animacao = 4.0, -- animacao que comecou ha mais que isso nao conta
	maximo_amostras = 80,        -- medicoes guardadas por animacao (0.45: era 40; com 40, golpes raros
	                             -- de animacoes com muitos golpes eram esquecidos)
	juntar_ate = 0.12,           -- impactos com diferenca menor que isso sao o mesmo impacto
	confirmar_ate = 0.20,        -- tolerancia para uma animacao nova "confirmar" um aviso
	minimo_amostras = 2,         -- precisa ter visto o golpe pelo menos 2 vezes para avisar
	minimo_antecedencia = 0.20   -- nao cria aviso para impacto em menos que isso (nao da tempo)
};

-- Opcoes do jogador (salvas em aviso_lanca_opcoes.json)
local op = {
	ativado = true,
	antecedencia_ms = 120,  -- "AGORA!" aparece este tanto antes do impacto
	janela = 1.2,           -- o marcador aparece este tanto de segundos antes do impacto
	altura_tela = 0.70,     -- altura da barra na tela (0 = topo, 1 = embaixo)
	-- (0.75) aba "Configurar Barra de previsao"
	barra_tamanho = 1.0,    -- tamanho da barra (1 = normal)
	barra_opacidade = 1.0,  -- 0,1 = quase transparente, 1 = solida
	barra_desligada = false, -- (0.77) true = a barra de previsao nunca aparece
	-- (0.78) fontes novas de aprendizado e defesa na hora do golpe (outras armas)
	aprender_por_contato = true,
	aprender_por_ativacao = true,
	defesa_na_hora_ligada = true,
	na_hora_so_sacada = true,
	na_hora = { gs = true, sns = true, db = true, sa = true, cb = true, arco = true, hbg = true, lbg = true },
	barra_sempre_visivel = false, -- (0.76) false = automatico (so aparece com golpe vindo)
	barra_horizontal = 0.5, -- centro da barra na tela (0 = esquerda, 0,5 = meio, 1 = direita)
	aprender = true,
	-- (0.45) aprende tambem com golpes do monstro no Palico, em outros jogadores e em objetos
	-- (o tempo do golpe depois da animacao e o mesmo, nao importa quem ele acerta)
	aprender_com_outros = true,
	limpeza_bots_054 = false, -- (0.54) limpeza unica de medicoes que podem ter vindo de bots
	limpeza_sos_053 = false, -- (0.53) limpeza unica e completa dos monstros enfrentados no SOS

	-- defesa automatica
	guarda_automatica = true,

	-- so defende golpes que ja chegaram em voce desta distancia (+ margem). Evita defender
	-- golpes contra outros jogadores no multiplayer (e golpes que nao alcancam no solo)
	checar_distancia = true,
	margem_distancia = 3.0,
	antecedencia_guarda_ms = 120, -- levanta a guarda este tanto antes do impacto
	segurar_depois_ms = 250,      -- continua segurando este tanto depois do impacto
	esquivar = true,              -- esquiva nos golpes impossiveis de guardar (se a esquiva foi aprendida)
	antecedencia_esquiva_ms = 150,   -- esquiva da lanca

	-- esquiva das outras armas (cada arma tem invencibilidade diferente; ajuste no Avancado)
	esquiva_ms_dual = 150,
	esquiva_ms_bowgun_leve = 150,
	esquiva_ms_berrante = 150,
	esquiva_ms_espada_escudo = 150,
	esquiva_ms_espada_longa = 150,

	-- Espada Longa (0.29)
	ls_foresight_ms = 120,  -- Foresight Slash (M5 + M2) na hora do golpe, como a guarda (repete se o jogo ignorar)
	-- (0.49) depois de voce apertar o M4 (guardar a arma e correr), o mod fica parado este tanto
	m4_pausa_ms = 1500,
	ls_bloqueio_ms = 400,   -- (0.47) os seus botoes de acao ficam soltos este tanto antes do golpe (o Foresight tem prioridade)
	--[[
		(0.56) SS+ISS. Das suas leituras (Chatacabra, 14/11):
		  - SS = M5 + Espaco juntos; a bainha (animacao 20:249) comeca ~0,12s depois e o ISS so
		    fica disponivel ~1,38s depois do SS (antes disso o M5 fica no buffer);
		  - ISS = M5 na postura (20:247 / 248 / 250); o ISS (20:264 / 265) sai no mesmo quadro;
		  - o contra-ataque deu certo com o golpe chegando de 50 a 300 ms depois do M5;
		  - na bainha e na postura voce NAO esta protegido (golpes aos 0,3s e 1,1s acertaram).
		Por isso o SS so e feito quando o PROXIMO golpe vem entre "ls_ss_min_ms" e "ls_ss_max_ms"
		(nenhum golpe antes dele). Golpe mais em cima da hora: FS (prioridade 2).
	]]
	usar_ss_iss = true,
	-- (0.57) so SS+ISS: sem FS e sem esquiva (o SS+ISS serve em todos os golpes; o FS e a esquiva nao)
	somente_ss_iss = false,
	-- (0.71) comandos de ataque descobertos que escapavam da trava: [numero] = true
	comandos_ataque_extra = {},
	vazamentos = {},        -- (0.71) [numero] = { golpe = vezes que veio junto de um golpe seu, nada = vezes sem }
	-- (0.68) abaixo da barra vermelha o FS zera o carregamento do proximo nivel: usa a esquiva no lugar
	ls_sem_fs_abaixo_vermelho = true,
	ls_iss_ms = 150,        -- ISS (M5) quantos ms antes do golpe (0.58: se ajusta sozinho)
	iss_ajuste_auto = true,
	postura_medida_ms = 0,  -- (0.59) tempo maximo da postura do SS, medido no jogo (0 = ainda nao medido)
	reset_postura_062 = false,
	limpeza_golpes_065 = false, -- (0.65) tira FS / SS / ISS / esquiva das medidas dos seus golpes -- (0.62) apaga a postura maxima medida errado na 0.61
	reset_iss_059 = false,  -- (0.59) volta o ls_iss_ms a 150 uma vez (o ajuste da 0.58 usava o aviso atrasado) -- (0.58) ajusta o ls_iss_ms pelos contra-ataques certos do ISS
	ls_ss_min_ms = 1700,    -- SS so se o golpe vier pelo menos este tanto depois
	ls_ss_max_ms = 3000,    -- ... e no maximo este tanto depois
	ls_postura_max_ms = 4000, -- sem golpe ate este tanto depois do SS: a postura e liberada para voce
	ls_janela_combo_ms = 2300, -- (0.33) o Foresight fica disponivel ate este tanto depois de um golpe
	animacoes_ataque_ls = {}, -- animacoes de ataque da espada longa (aprendidas sozinhas)



	--[[
		As defesas da lanca (como voce explicou):
		  - guarda: M5;
		  - contra-ataque: M5 e depois M2. Fica numa postura que defende e, ao receber o
		    golpe, ataca na hora;
		  - Power Guard: M5, depois M2 e por ultimo Espaco, os tres segurados. Guarda
		    plantada no chao, gasta stamina e bloqueia em 360 graus;
		  - esquiva: Espaco.
	]]
	-- golpes guardaveis: "contra_ataque" ou "guarda"
	acao_guardavel = "contra_ataque",
	antecedencia_contra_ms = 250,  -- o contra-ataque entra este tanto antes do impacto

	--[[
		GUARD UP (0.31): com a habilidade Guard Up, os golpes que o jogo marca como
		"impossiveis de guardar" (correntes e explosoes do Arkveld, agarroes, explosoes do
		chao do Ajarakan, ondas do Uth Duna, gases do Gravios...) PODEM ser guardados: basta
		segurar a guarda. Com esta opcao ligada:
		  - esses golpes usam a GUARDA SEGURADA (sem contra-ataque);
		  - nas armas de guarda o aprendizado nunca desce para a esquiva. A esquiva so fica
		    para os golpes de lado (Espada e Escudo) e para os ataques de arena inteira que nem
		    o Guard Up segura (Zoh Shia, Jin Dahaad e o Delta Attack do Omega Planetes).
	]]
	tenho_guard_up = true,

	--[[
		GOLPES SEGUIDOS (0.32): antes a guarda era solta entre um golpe e outro (250 ms depois
		de cada impacto) e o contra-ataque era usado no meio das sequencias. Em combos rapidos
		(ex.: dois golpes rapidos e a correntada dupla do Arkveld) a guarda caia e o golpe
		seguinte acertava. Agora, depois que a guarda sobe:
		  - continua segurada enquanto houver outro golpe previsto em ate "ponte_guarda_ms";
		  - continua segurada por "manter_apos_golpe_ms" depois de cada golpe que chega em
		    voce (o golpe seguinte do combo pode ainda nao ter sido previsto);
		  - no meio de uma sequencia o contra-ataque vira guarda (o contra-ataque e um ataque
		    e deixa voce aberto para o golpe seguinte).
	]]
	ponte_guarda_ms = 900,
	manter_apos_golpe_ms = 600,

	-- Power Guard na defesa automatica (desligado: o teste da 0.17 fechou o jogo; os golpes
	-- tipo 3 usam o contra-ataque ate o Power Guard ser confirmado em modo seguro)
	usar_power_guard = true,

	-- golpe vindo de lado/tras: se o angulo entre para onde o cacador olha e o monstro
	-- passar disso (graus), a guarda e o contra-ataque (so de frente) sao pulados
	angulo_frontal = 70,

	-- Power Guard: o toque do Espaco vem este tanto (ms) depois de o M5 ser apertado
	-- (o M2 vem aos 50 ms; o Espaco precisa vir ja na postura do contra-ataque)
	pg_espaco_ms = 350,

	-- SEQUENCIAS DE GOLPES: se vierem pelo menos "pg_multi_golpes" impactos do mesmo monstro
	-- em ate "pg_multi_janela_ms", o mod usa Power Guard na sequencia inteira (so o primeiro
	-- golpe gasta stamina; com a guarda normal cada golpe gasta e a stamina acaba)
	pg_multi_golpes = 3,
	pg_multi_janela_ms = 2000,
	antecedencia_power_ms = 500,   -- o Power Guard entra este tanto antes do impacto

	-- numero do comando de cada botao (so para mostrar no menu)
	botoes = { guarda = {}, contra_ataque = {}, power_guard = {}, esquiva = {} },

	-- O QUE ESCREVER para "apertar" cada acao: lista de { t = numero do comando,
	-- l = se o campo fica no buffer de entrada (LagWorker), c = campo, v = valor }.
	-- Preenchido pelo "Aprender botoes"; os valores abaixo vieram das suas capturas.
	campos = {},

	-- versao do formato dos campos (2 = contra-ataque e Power Guard separados)
	versao_campos = 9,

	-- TOQUE GRAVADO (versao 0.17): sequencia quadro a quadro do que muda nos botoes quando
	-- voce aperta e solta uma tecla (usado na esquiva). E o "segurado" e o quadro do meio
	-- desse toque (usado para segurar o Espaco no Power Guard).
	toques = {},
	espaco_segurado = {}
};

--[[
	Valores padrao, vindos das suas capturas no teclado/mouse:
	  - guarda: comandos 15 e 22 (botao M5);
	  - contra_ataque: M5 + M2: comandos 13, 15, 22, 36 e 43 (a captura que na 0.8 a 0.12
	    eu chamava de "power_guard" - era na verdade o contra-ataque);
	  - power_guard: sem padrao. Se nao for aprendido, o mod monta com guarda + especial
	    (a parte do M2 no contra-ataque) + Espaco (da captura da esquiva);
	  - esquiva: comandos 24, 25, 32, 42 e 51 (so usam o buffer de entrada).
	"Apertado" = ligado (_On), apertado de verdade (_RawOn), totalmente (_AnalogValue),
	acabou de ser apertado (_LastRawTriggerIndex) e o buffer de entrada (_LagFrameCounter
	e _LagTimer). Sem o buffer, o jogo nao reconhece o aperto (foi o erro da versao 0.8).
]]
local function aperto_completo(lista, comando)
	lista[#lista + 1] = { t = comando, l = false, c = "_On", v = true };
	lista[#lista + 1] = { t = comando, l = false, c = "_RawOn", v = true };
	lista[#lista + 1] = { t = comando, l = false, c = "_AnalogValue", v = 1.0 };
	lista[#lista + 1] = { t = comando, l = false, c = "_LastRawTriggerIndex", v = 0 };
	lista[#lista + 1] = { t = comando, l = true, c = "_LagFrameCounter", v = -1 };
	lista[#lista + 1] = { t = comando, l = true, c = "_LagTimer", v = -0.06666667 };
end

local function aperto_so_buffer(lista, comando)
	lista[#lista + 1] = { t = comando, l = false, c = "_LastRawTriggerIndex", v = 0 };
	lista[#lista + 1] = { t = comando, l = true, c = "_LagFrameCounter", v = -1 };
	lista[#lista + 1] = { t = comando, l = true, c = "_LagTimer", v = -0.06666667 };
end

local function campos_padrao(alvo)
	local lista = {};
	if alvo == "guarda" then
		aperto_completo(lista, 15); aperto_completo(lista, 22);
	elseif alvo == "contra_ataque" then
		for _, n in ipairs({ 13, 15, 22, 43 }) do aperto_completo(lista, n); end
		lista[#lista + 1] = { t = 36, l = false, c = "_On", v = true };
		lista[#lista + 1] = { t = 36, l = false, c = "_RawOn", v = true };
		lista[#lista + 1] = { t = 36, l = false, c = "_AnalogValue", v = 1.0 };
		lista[#lista + 1] = { t = 36, l = false, c = "_Success", v = true };
	elseif alvo == "esquiva" then
		for _, n in ipairs({ 24, 25, 32, 42, 51 }) do aperto_so_buffer(lista, n); end
	end
	return lista;
end

-- numeros de comando usados por uma lista de campos (para mostrar no menu)
local function comandos_de(lista)
	local vistos, numeros = {}, {};
	for _, item in ipairs(lista or {}) do
		if not vistos[item.t] then vistos[item.t] = true; numeros[#numeros + 1] = item.t; end
	end
	table.sort(numeros);
	return numeros;
end

local function garantir_campos()
	if type(op.botoes) ~= "table" then op.botoes = {}; end
	if type(op.campos) ~= "table" then op.campos = {}; end

	for _, alvo in ipairs({ "guarda", "contra_ataque", "esquiva" }) do
		if type(op.campos[alvo]) ~= "table" or #op.campos[alvo] == 0 then
			op.campos[alvo] = campos_padrao(alvo);
		end
	end
	if type(op.campos.power_guard) ~= "table" then op.campos.power_guard = {}; end

	for _, alvo in ipairs({ "guarda", "contra_ataque", "power_guard", "esquiva" }) do
		op.botoes[alvo] = comandos_de(op.campos[alvo]);
	end

	if op.acao_guardavel ~= "guarda" and op.acao_guardavel ~= "contra_ataque" then op.acao_guardavel = "contra_ataque"; end
end

garantir_campos();

local function carregar_opcoes()
	local salvo = json.load_file("aviso_lanca_opcoes.json");
	if type(salvo) ~= "table" then return; end
	for chave, valor in pairs(op) do
		if type(salvo[chave]) == type(valor) then op[chave] = salvo[chave]; end
	end

	-- (0.46) as migracoes das versoes antigas (0.8 a 0.38) sairam: o seu arquivo ja esta atualizado
	op.versao_campos = 9;

	garantir_campos();
end

local function salvar_opcoes()
	json.dump_file("aviso_lanca_opcoes.json", op);
end

local estado = {
	mensagem = "",
	ultimo_erro_ms = nil,   -- diferenca entre o impacto previsto e o real (ultimo golpe)
	avisos_certos = 0,
	impactos_vistos = 0,
	defesas = { perfeita = 0, normal = 0, power = 0, esquiva_perfeita = 0 }, -- contadas pelos eventos do jogo
	motivo_parado = ""      -- por que a defesa automatica nao esta agindo agora
};


-- =====================================================================================
-- 2. RELOGIO, JOGADOR E ANIMACOES
-- =====================================================================================

local relogio = nil;

-- Relogio do proprio jogo (mais preciso); se nao der, usa o do Lua
local function agora()
	if relogio == nil then
		local aplicacao = sdk.get_native_singleton("via.Application");
		local tipo_aplicacao = sdk.find_type_definition("via.Application");
		local relogio_jogo = function()
			return sdk.call_native_func(aplicacao, tipo_aplicacao, "get_UpTimeSecond");
		end;
		local ok, valor = pcall(relogio_jogo);
		relogio = (ok and type(valor) == "number") and relogio_jogo or os.clock;
	end
	return relogio();
end

local function arredondar(valor, casas)
	if type(valor) ~= "number" then return valor; end
	local fator = 10 ^ (casas or 3);
	return math.floor(valor * fator + 0.5) / fator;
end

local function meu_cacador()
	local gerente = sdk.get_managed_singleton("app.PlayerManager");
	local info = gerente and gerente:call("getMasterPlayer");
	return info and info:call("get_Character");
end

local function objeto_de_jogo(personagem)
	local ok, objeto = pcall(personagem.call, personagem, "get_GameObject");
	return ok and objeto or nil;
end

local function posicao(objeto)
	local ok, p = pcall(function() return objeto:call("get_Transform"):call("get_Position"); end);
	if ok and p ~= nil then return p.x, p.y, p.z; end
	return nil;
end

local function distancia(x1, y1, z1, x2, y2, z2)
	if x1 == nil or x2 == nil then return nil; end
	local dx, dy, dz = x1 - x2, y1 - y2, z1 - z2;
	return math.sqrt(dx * dx + dy * dy + dz * dz);
end

local function seguir(objeto, deslocamento)
	if objeto == nil then return nil; end
	local endereco = objeto:read_qword(deslocamento);
	if endereco == nil or endereco == 0 then return nil; end
	return sdk.to_managed_object(endereco);
end

-- Animacao atual: numero, banco (grupo), quadro atual e final
local tipo_motion = sdk.typeof("via.motion.Motion");

local function animacao_de(objeto)
	if objeto == nil or tipo_motion == nil then return nil; end

	local ok, camada = pcall(function()
		local motion = objeto:call("getComponent(System.Type)", tipo_motion);
		return motion and motion:call("getLayer", 0);
	end);
	if not ok or camada == nil then return nil; end

	local ok_dados, id, banco, quadro, fim = pcall(function()
		return camada:call("get_MotionID"), camada:call("get_MotionBankID"),
			camada:call("get_Frame"), camada:call("get_EndFrame");
	end);
	if not ok_dados then return nil; end

	return id, banco, quadro, fim;
end

-- Tamanho da tela (para posicionar a barra)
local tipo_cena = sdk.find_type_definition("via.SceneManager");
local metodo_tamanho = sdk.find_type_definition("via.SceneView"):get_method("get_Size");

local function tamanho_tela()
	local ok, l, a = pcall(function()
		local cena = sdk.get_native_singleton("via.SceneManager");
		local visao = sdk.call_native_func(cena, tipo_cena, "get_MainView");
		local tamanho = metodo_tamanho:call(visao);
		return tamanho.w, tamanho.h;
	end);
	if ok and l and a then return l, a; end
	return 1920, 1080;
end


-- =====================================================================================
-- 3. CONHECIMENTO E PREVISAO
--
-- Para cada monstro e cada animacao ("banco:numero"), guardamos medicoes de quanto tempo
-- depois do inicio daquela animacao veio um impacto. Cada medicao = { segundos, tipo de
-- guarda do golpe, distancia }. Tipo de guarda: 0 normal, 1 qualquer direcao,
-- 2 impossivel de guardar, 3 so com habilidade/Power Guard.
-- =====================================================================================

-- O que ja foi medido nas gravacoes (Arkveld normal, lanca, solo, The Chains of Life)
local CONHECIMENTO_INICIAL = {
	["27"] = {
		["2:108"] = { {1.473,1,10.6}, {3.488,0,10.0} },
		["2:109"] = { {1.743,1,19.3} },
		["2:123"] = { {0.162,0,9.4} },
		["2:136"] = { {0.220,0,6.8}, {0.427,0,5.7}, {0.198,0,8.6}, {0.394,0,7.1}, {3.081,0,7.2}, {0.225,0,7.2}, {0.420,0,7.1} },
		["2:137"] = { {0.393,0,7.2}, {0.186,0,7.0} },
		["2:147"] = { {0.093,0,11.6}, {0.118,0,11.1} },
		["2:172"] = { {1.277,0,3.3}, {1.331,0,3.3}, {1.306,0,3.2}, {1.391,0,3.2}, {1.284,0,2.8}, {1.445,0,2.9} },
		["2:175"] = { {0.094,0,3.3}, {0.148,0,3.3}, {0.134,0,3.2}, {0.219,0,3.2}, {0.078,0,2.8}, {0.239,0,2.9} },
		["2:177"] = { {1.383,0,11.6}, {1.413,0,11.1}, {2.556,1,10.6} },
		["2:178"] = { {0.062,0,2.5}, {0.058,0,2.4}, {0.079,0,2.7}, {0.170,0,3.0} },
		["2:180"] = { {1.326,0,3.8} },
		["2:181"] = { {1.292,0,2.5}, {1.217,0,2.4}, {1.178,0,2.7}, {1.269,0,3.0} },
		["2:191"] = { {0.374,0,5.1}, {0.674,2,2.8}, {0.344,0,2.0}, {0.669,2,0.3}, {0.667,2,15.9}, {0.677,2,5.2}, {0.407,0,10.6}, {0.663,2,10.9} },
		["2:201"] = { {1.358,0,5.2} },
		["2:219"] = { {2.175,0,16.8} },
		["2:221"] = { {3.055,1,19.3} },
		["2:240"] = { {0.130,0,2.9}, {0.167,0,4.4} },
		["2:241"] = { {0.147,0,3.8} },
		["2:26"] = { {0.010,0,3.8}, {0.170,0,3.3} },
		["2:295"] = { {0.110,0,16.8}, {0.064,0,8.9} },
		["2:302"] = { {2.306,0,3.3} },
		["2:305"] = { {0.069,0,11.6}, {0.041,0,10.0} },
		["2:4"] = { {0.160,0,6.5} },
		["2:43"] = { {0.074,0,9.1} },
		["2:50"] = { {1.756,1,6.9} },
		["2:58"] = { {0.011,0,1.7}, {3.092,3,4.7} },
		["2:68"] = { {1.12,1,11.5}, {2.176,2,10.3} },
		["4:106"] = { {1.938,0,7.3} },
		["4:14"] = { {1.542,0,3.6} },
		["5:13"] = { {0.709,3,4.7} },
		["5:14"] = { {1.449,0,8.2} },
		["5:23"] = { {2.110,0,4.1}, {1.386,0,8.2} },
		["50:150"] = { {2.366,0,6.5} },
		["50:160"] = { {0.936,0,3.8} },
		["50:161"] = { {1.593,0,16.8}, {1.529,0,8.9} },
		["50:170"] = { {1.512,0,9.1} },
		["50:174"] = { {1.299,0,1.7} },
		["50:178"] = { {3.613,1,11.5} },
		["50:184"] = { {2.190,1,10.6} },
		["50:185"] = { {2.478,1,19.3} },
		["50:188"] = { {1.622,0,6.8}, {1.829,0,5.7}, {1.624,0,8.6}, {1.820,0,7.1}, {1.687,0,7.2}, {1.882,0,7.1} },
		["50:191"] = { {1.844,0,7.2}, {1.576,0,7.0} },
		["50:195"] = { {1.488,0,11.6}, {1.432,0,10.0} },
		["50:196"] = { {1.015,0,11.6}, {1.040,0,11.1} },
		["50:200"] = { {2.206,0,9.4} },
		["50:210"] = { {0.453,0,3.3}, {0.507,0,3.3}, {0.491,0,3.2}, {0.576,0,3.2}, {0.467,0,2.8}, {0.628,0,2.9} },
		["50:211"] = { {0.480,0,2.5}, {0.468,0,2.4}, {0.454,0,2.7}, {0.545,0,3.0} },
		["50:215"] = { {2.627,0,5.1}, {2.927,2,2.8}, {2.600,0,2.0}, {2.925,2,0.3}, {2.875,2,15.9}, {2.982,2,5.2}, {2.645,0,10.6}, {2.901,2,10.9} },
		["50:217"] = { {2.227,0,5.1}, {2.527,2,2.8}, {2.194,0,2.0}, {2.519,2,0.3}, {2.508,2,15.9}, {2.518,2,5.2}, {2.251,0,10.6}, {2.507,2,10.9} },
		["50:23"] = { {3.069,0,6.5} },
		["50:241"] = { {0.748,0,7.7} },
		["50:244"] = { {0.735,0,8.2} },
		["50:255"] = { {1.412,0,4.1} },
		["50:257"] = { {0.587,0,4.1} },
		["50:266"] = { {2.173,3,4.7} },
		["50:270"] = { {2.182,0,2.9}, {2.226,0,4.4} },
		["50:271"] = { {2.198,0,3.8} },
		["50:272"] = { {1.427,0,2.9}, {1.445,0,4.4} },
		["50:273"] = { {1.437,0,3.8} },
		["50:285"] = { {2.637,0,1.7} },
		["50:300"] = { {2.247,0,5.2} },
		["50:312"] = { {1.598,0,3.3} },
		["50:65"] = { {3.085,0,7.3} }
	}
};

-- conhecimento atual: [id do monstro como texto][animacao] = lista de medicoes
local conhecimento = {};
local nomes_monstros = {}; -- (0.47) id -> nome do monstro no jogo (salvo junto com o aprendizado)
local grupos_cache = {};    -- impactos ja agrupados, por monstro e animacao
local precisa_salvar = false;
local salvo_em = 0;

local function copiar(tabela)
	local nova = {};
	for chave, valor in pairs(tabela) do
		nova[chave] = (type(valor) == "table") and copiar(valor) or valor;
	end
	return nova;
end

local function carregar_conhecimento()
	conhecimento = copiar(CONHECIMENTO_INICIAL);

	local salvo = json.load_file("aviso_lanca_aprendizado.json");
	if type(salvo) == "table" and type(salvo.monstros) == "table" then
		conhecimento = salvo.monstros;
	end
	if type(salvo) == "table" and type(salvo.nomes) == "table" then nomes_monstros = salvo.nomes; end
	for chave_nome, nome in pairs(nomes_monstros) do -- (0.51) conserta "Tempered Tempered ..."
		nomes_monstros[chave_nome] = string.gsub(string.gsub(tostring(nome), "^Tempered Tempered ", "Tempered "),
			"^Arch%-tempered Arch%-tempered ", "Arch-tempered ");
	end

	grupos_cache = {};
end

local function salvar_conhecimento()
	json.dump_file("aviso_lanca_aprendizado.json", { versao = 1, monstros = conhecimento, nomes = nomes_monstros });
	precisa_salvar = false;
	salvo_em = agora();
end

--[[
	Agrupa as medicoes de uma animacao em "impactos": medicoes com tempos parecidos (ate
	0,12s de diferenca) sao o mesmo impacto. Para cada impacto devolve o tempo tipico
	(mediana), quantas vezes foi visto e o tipo de guarda mais restritivo visto nele.
]]
local RESTRICAO = { [0] = 0, [1] = 0, [3] = 1, [4] = 1, [2] = 2 }; -- 2 (impossivel) e o pior

local function agrupar(medicoes)
	local tempos = {};
	for _, m in ipairs(medicoes) do tempos[#tempos + 1] = m; end
	table.sort(tempos, function(a, b) return a[1] < b[1]; end);

	local grupos, atual = {}, nil;

	local function fechar()
		if atual == nil then return; end
		local n = #atual.lista;
		local meio = atual.lista[math.floor((n + 1) / 2)];
		atual.tempo = meio[1];
		atual.vezes = n;
		grupos[#grupos + 1] = atual;
	end

	for _, m in ipairs(tempos) do
		if atual ~= nil and m[1] - atual.lista[#atual.lista][1] <= AJUSTES.juntar_ate then
			atual.lista[#atual.lista + 1] = m;
		else
			fechar();
			atual = { lista = { m }, guarda = 0 };
		end
		local g = m[2] or 0;
		if (RESTRICAO[g] or 0) > (RESTRICAO[atual.guarda] or 0) then atual.guarda = g; end
	end
	fechar();

	return grupos;
end

local function grupos_de(id, animacao)
	local monstro = conhecimento[tostring(id)];
	local medicoes = monstro and monstro[animacao];
	if medicoes == nil then return nil; end

	local cache_monstro = grupos_cache[tostring(id)];
	if cache_monstro == nil then
		cache_monstro = {};
		grupos_cache[tostring(id)] = cache_monstro;
	end

	if cache_monstro[animacao] == nil then
		cache_monstro[animacao] = agrupar(medicoes);
	end

	return cache_monstro[animacao];
end

local function aprender(id, animacao, segundos, guarda, dist)
	local chave_monstro = tostring(id);
	conhecimento[chave_monstro] = conhecimento[chave_monstro] or {};
	local lista = conhecimento[chave_monstro][animacao] or {};
	conhecimento[chave_monstro][animacao] = lista;

	lista[#lista + 1] = { arredondar(segundos, 3), guarda or 0, arredondar(dist or 0, 1) };
	while #lista > AJUSTES.maximo_amostras do table.remove(lista, 1); end

	if grupos_cache[chave_monstro] then grupos_cache[chave_monstro][animacao] = nil; end
	precisa_salvar = true;
end


-- =====================================================================================
-- 4. MONSTROS (ARKVELD)
-- Acha os monstros cobertos, acompanha a animacao de cada um e, a cada animacao nova,
-- atualiza a lista de impactos previstos daquele monstro.
-- =====================================================================================

local monstros = {}; -- chave: endereco do contexto

local function endereco_de(objeto)
	local ok, endereco = pcall(objeto.get_address, objeto);
	return (ok and endereco) or objeto;
end

--[[
	TODOS OS MONSTROS GRANDES (versao 0.23)
	Em vez de uma lista fixa (so o Arkveld), o mod acompanha todo monstro que o proprio jogo
	marca como monstro grande ("get_IsBoss"). Assim monstros de atualizacoes futuras tambem
	entram sozinhos. O nome vem do jogo, ja com a variacao (Tempered, Arch-tempered,
	Guardian...). O aprendizado continua separado por ID do monstro.

	IDs (lista do HunterPie): 0 Rathian, 1 Rathalos, 2 Guardian Rathalos, 3 Gravios,
	4 Yian Kut-Ku, 5 Gypceros, 6 Congalala, 7 Blangonga, 8 Lagiacrus, 9 Nerscylla,
	10 Gore Magala, 11 Seregios, 12 Gogmazios, 13 Mizutsune, 14 Guardian Fulgur Anjanath,
	15 Guardian Ebony Odogaron, 16 Doshaguma, 17 Guardian Doshaguma, 18 Balahara,
	19 Chatacabra, 20 Quematrice, 21 Lala Barina, 22 Rompopolo, 23 Rey Dau, 24 Uth Duna,
	25 Nu Udra, 26 Ajarakan, 27 Arkveld, 28 Guardian Arkveld, 29 Hirabami, 30 Jin Dahaad,
	31 Xu Wu, 32 Zoh Shia, 34 Omega Planetes. O 33 e o boneco da arena (fica de fora).
]]
local IDS_IGNORADOS = { [33] = true };
local nao_sao_grandes = {}; -- monstros ja conferidos que nao sao grandes (para nao conferir de novo)
local metodo_nome_do_monstro = sdk.find_type_definition("app.EnemyDef"):get_method("NameString");

local function nome_do_monstro(contexto, id)
	local ok, nome = pcall(function()
		return metodo_nome_do_monstro:call(nil, contexto:call("get_EmID"), contexto:call("get_RoleID"),
			contexto:call("get_LegendaryID"));
	end);
	if ok and type(nome) == "string" and nome ~= "" then return nome; end
	return "Monstro " .. tostring(id);
end

local function conhecer_monstro(contexto)
	-- (0.78) fim da quest / troca de cena: nao registra nem atualiza monstros
	if (estado.parar_monstros_ate or 0) > os.clock() then return; end
	local chave = endereco_de(contexto);
	local m = monstros[chave];

	if m == nil then
		-- a marcacao expira em 30s: o jogo reaproveita enderecos entre missoes
		local marcado_em = nao_sao_grandes[chave];
		if marcado_em ~= nil and os.clock() - marcado_em < 30 then return; end

		if contexto:call("get_IsBoss") ~= true then
			nao_sao_grandes[chave] = os.clock();
			return;
		end

		local dados = seguir(contexto, AJUSTES.dados_basicos);
		local id = dados and dados:read_dword(AJUSTES.id_nos_dados_basicos);
		if id == nil or IDS_IGNORADOS[id] then
			nao_sao_grandes[chave] = os.clock();
			return;
		end

		local inteligencia = seguir(contexto, AJUSTES.inteligencia);
		local objeto = inteligencia and inteligencia:get_field("OwnerObject");
		if objeto == nil then return; end

		local legendary = contexto:call("get_LegendaryID");

		-- (0.68) onde ler a vida (mesmo caminho do seu mod de barras de vida)
		local gerenciador_vida = nil;
		pcall(function()
			local navegador = contexto:call("get_Browser");
			local portador = navegador and navegador:get_field("_Context");
			local personagem = portador and portador:call("get_Chara");
			gerenciador_vida = personagem and personagem:call("get_HealthManager");
		end);

		m = {
			gerenciador_vida = gerenciador_vida,
			id = id,
			nome = nome_do_monstro(contexto, id),
			variacao = (legendary == 2 and "arquitemperado") or (legendary == 1 and "temperado") or "normal",
			objeto = objeto,
			animacao = nil, animacao_desde = 0, quadro = 0, fim = 0,
			historico = {},  -- ultimas animacoes: { chave, inicio }
			previstos = {},  -- impactos previstos: { tempo, guarda }
			distancia = nil,
			visto_em = 0
		};
		monstros[chave] = m;

		--[[
			(0.49) VARIANTES SEPARADAS: normal, Tempered e Arch-tempered tem golpes, sequencias e
			velocidades diferentes (ex.: o Arch-tempered Arkveld e mais rapido e faz ate 4 golpes
			seguidos). Cada variante tem o seu proprio aprendizado:
			  normal = "27" (o mesmo de antes: tudo que ja foi aprendido era da versao normal),
			  Tempered = "27:t", Arch-tempered = "27:at".
			(Os Guardian ja sao monstros separados no jogo, com outro numero.)
		]]
		local sufixo, prefixo = "", "";
		if legendary == 1 then sufixo, prefixo = ":t", "Tempered ";
		elseif legendary == 2 then sufixo, prefixo = ":at", "Arch-tempered "; end
		m.variante = tostring(id) .. sufixo;
		-- (0.51) o nome do jogo ja vem com "Tempered" / "Arch-tempered": nao repete
		if string.find(string.lower(tostring(m.nome)), "tempered", 1, true) then prefixo = ""; end
		m.nome_completo = prefixo .. tostring(m.nome);

		-- (0.47) guarda o nome do monstro (para a lista de monstros com a porcentagem)
		if m.nome ~= nil and nomes_monstros[m.variante] ~= m.nome_completo then
			nomes_monstros[m.variante] = m.nome_completo;
			precisa_salvar = true;
		end
	end

	m.visto_em = agora();
end

sdk.hook(sdk.find_type_definition("app.cEnemyContext"):get_method("get_IsAngry"), function(argumentos)
	pcall(function() conhecer_monstro(sdk.to_managed_object(argumentos[2])); end);
end, function(retorno)
	return retorno;
end);

local function monstro_do_objeto(objeto)
	for _, m in pairs(monstros) do
		if m.objeto == objeto then return m; end
	end
	return nil;
end

local function monstro_mais_perto()
	local melhor = nil;
	for _, m in pairs(monstros) do
		if m.distancia ~= nil and (melhor == nil or m.distancia < melhor.distancia) then melhor = m; end
	end
	return melhor;
end

--[[
	Uma animacao nova comecou. Regras:
	  - impactos ja previstos continuam so se a nova animacao "confirma" (ela tambem tem um
	    impacto medido perto daquele momento). O tempo e corrigido pela medicao mais nova.
	    Isso derruba avisos de golpes que o monstro interrompeu (ex.: levou um derrube);
	  - impactos da nova animacao vistos pelo menos 2 vezes viram avisos novos.
]]
local function nova_animacao(m, animacao, momento)
	local grupos = grupos_de(m.variante, animacao);
	local novos = {};
	local usados = {};

	if grupos ~= nil then
		for _, p in ipairs(m.previstos) do
			if p.tempo > momento - 0.1 then
				local relativo = p.tempo - momento;
				for i, g in ipairs(grupos) do
					if not usados[i] and math.abs(g.tempo - relativo) <= AJUSTES.confirmar_ate then
						usados[i] = true;
						p.tempo = momento + g.tempo;
						if (RESTRICAO[g.guarda] or 0) > (RESTRICAO[p.guarda] or 0) then p.guarda = g.guarda; end
						novos[#novos + 1] = p;
						break;
					end
				end
			end
		end

		for i, g in ipairs(grupos) do
			if not usados[i] and g.vezes >= AJUSTES.minimo_amostras and g.tempo >= AJUSTES.minimo_antecedencia then
				-- "origem": a animacao que previu o golpe (identifica o golpe no aprendizado das defesas)
				-- maior distancia em que este golpe ja chegou em voce (para o multiplayer)
				local dist_max = 0;
				for _, medicao in ipairs(g.lista) do
					if (medicao[3] or 0) > dist_max then dist_max = medicao[3]; end
				end
				novos[#novos + 1] = { tempo = momento + g.tempo, guarda = g.guarda, vezes = g.vezes, origem = animacao,
					dist_max = dist_max };
			end
		end
	end

	m.previstos = novos;
end


-- =====================================================================================
-- 5. IMPACTOS E APRENDIZADO
-- Quando um golpe do monstro acerta VOCE (guardando ou nao), o mod anota quanto tempo
-- passou desde cada uma das ultimas animacoes do monstro. E assim que ele aprende.
-- =====================================================================================


-- defesas aprendidas por golpe ("id do monstro:animacao que previu" = nivel 1 a 4) e
-- golpes esperando a conferencia (o jogo confirmou a defesa?)
local defesas_aprendidas = {};
local verificacoes_defesa = {};

--[[
	(0.51) BLOQUEIO APRENDIDO (Long Sword). No relatorio, os Foresights que falharam eram de
	quando voce estava preso numa animacao de ataque (ex.: 20:201, 20:212, 20:289): o Foresight
	foi apertado mas a sua animacao nao mudou e o golpe acertou. Para cada animacao SUA, o mod
	aprende com quanta antecedencia precisa segurar os seus botoes soltos para o Foresight
	conseguir sair:
	  - Foresight falhou e voce continuou preso na animacao (ou levou o golpe): +150 ms;
	  - Foresight deu certo: -20 ms (volta devagar ao padrao "ls_bloqueio_ms").
	Limite: 950 ms. Fica salvo em aviso_lanca_defesas.json.
]]
local bloqueios_ls = {};

--[[
	(0.57) GOLPES QUE O FS NAO DEFENDE (ex.: os trovoes seguidos da ult do Lagiacrus): quando o FS
	leva dano no mesmo golpe 2 vezes, ele entra nesta lista. Com a barra vermelha (onde o FS e a
	prioridade 1), esses golpes usam o SS+ISS. Chave: "espada_longa:monstro:banco:animacao".
	Fica salvo em aviso_lanca_defesas.json.
]]
local fs_falhas = {};
local FS_FALHAS_PARA_SS = 2;
local ss_animacoes = {};  -- (0.59) [sua animacao] = { ok, falha, atraso } do SS apertado nela
local ss_sem_golpe = {};
-- (0.60) tentativas de FS e SS: { idade do combo em segundos, 1 = saiu / 0 = nao saiu }
local janela_combo_dados = { fs = {}, ss = {} };
-- (0.64) [seu golpe] = { ms = quanto tempo ele prende o personagem, n = medicoes, prox = { [golpe seguinte] = true } }
local duracao_golpes = {};
-- (0.60) animacoes do FS (dos relatorios: 20:226 e 20:290; aprende outras pelo sinal da espada)
local ANIM_FS = { ["20:226"] = true, ["20:290"] = true };  -- (0.59) [golpe] = { sem, ok }: SS feito e o golpe nao veio / ISS certo

local function aprender_bloqueio(d, deu_certo)
	if d == nil or d.antes == nil or d.antes == "?" then return; end
	local atual = bloqueios_ls[d.antes] or op.ls_bloqueio_ms;
	local preso = d.depois == d.antes or string.sub(tostring(d.depois), 1, 3) == "14:";
	if deu_certo then
		atual = math.max(atual - 20, op.ls_bloqueio_ms);
	elseif preso then
		atual = math.min(atual + 150, 950);
	else
		return;
	end
	bloqueios_ls[d.antes] = atual;
	estado.bloqueio_mudou = true;
end

pcall(function()
	local salvo = json.load_file("aviso_lanca_defesas.json");
	if type(salvo) == "table" and type(salvo.bloqueios) == "table" then bloqueios_ls = salvo.bloqueios; end
	if type(salvo) == "table" and type(salvo.fs_falhas) == "table" then fs_falhas = salvo.fs_falhas; end
	if type(salvo) == "table" and type(salvo.ss_animacoes) == "table" then ss_animacoes = salvo.ss_animacoes; end
	if type(salvo) == "table" and type(salvo.ss_sem_golpe) == "table" then ss_sem_golpe = salvo.ss_sem_golpe; end
	if type(salvo) == "table" and type(salvo.janela_combo) == "table" then
		janela_combo_dados.fs = type(salvo.janela_combo.fs) == "table" and salvo.janela_combo.fs or {};
		janela_combo_dados.ss = type(salvo.janela_combo.ss) == "table" and salvo.janela_combo.ss or {};
	end
	if type(salvo) == "table" and type(salvo.duracao_golpes) == "table" then duracao_golpes = salvo.duracao_golpes; end
	if type(salvo) == "table" and type(salvo.anim_fs) == "table" then
		for anim_fs in pairs(salvo.anim_fs) do ANIM_FS[anim_fs] = true; end
	end
	if type(salvo) == "table" and type(salvo.golpes) == "table" then
		-- versao 0.24: as chaves passaram a ter a arma na frente ("lanca:27:50:210").
		-- Chaves antigas ("27:50:210") eram todas da lanca.
		for chave, nivel in pairs(salvo.golpes) do
			if string.match(chave, "^%d") then chave = "lanca:" .. chave; end
			defesas_aprendidas[chave] = nivel;
		end
	end
end);

-- (0.54) o alvo e um Palico? (bots / cacadores de suporte sao cacadores, nao Palicos)
local tipo_palico = sdk.typeof("app.OtomoCharacter");

local function e_palico(objeto)
	if tipo_palico == nil or objeto == nil then return false; end
	local ok, componente = pcall(function() return objeto:call("getComponent(System.Type)", tipo_palico); end);
	return ok and componente ~= nil;
end

local function ao_impacto(argumentos)
	local monstro_char = sdk.to_managed_object(argumentos[2]);
	local acerto = sdk.to_managed_object(argumentos[3]);
	if monstro_char == nil or acerto == nil then return; end

	local cacador = meu_cacador();
	local alvo = acerto:call("get_DamageOwner");
	if cacador == nil or alvo == nil then return; end

	local m = monstro_do_objeto(monstro_char:call("get_GameObject"));
	if m == nil then return; end

	--[[
		(0.45) Antes so os golpes em VOCE ensinavam. Agora os golpes no Palico, em outros
		jogadores e em objetos tambem ensinam o TEMPO do golpe (ele nao depende de quem e
		acertado). So nao contam golpes em outro monstro (briga entre monstros). A conferencia
		das defesas, a guarda de golpes seguidos e as estatisticas continuam so com voce.
	]]
	local em_mim = (alvo == objeto_de_jogo(cacador));
	if not em_mim then
		if not op.aprender_com_outros then return; end
		--[[
			(0.52) So quando voce esta sem outros jogadores (voce + Palico). No SOS, o golpe
			num outro jogador chega ao seu jogo ATRASADO pela rede: o relatorio mostrou a Lala
			Barina com 91% de conhecimento (461 de 473 medicoes vindas de outros) e 0 de 4
			golpes em voce previstos. Golpes no Palico com voce sozinho continuam ensinando.
		]]
		if (estado.jogadores or 1) > 1 then return; end
		-- (0.54) e so com o PALICO: golpes em bots (cacadores de suporte), em objetos ou em
		-- qualquer outro alvo nao ensinam nada
		if not e_palico(alvo) then return; end
		if monstro_do_objeto(alvo) ~= nil then return; end
	end

	local momento = agora();
	-- um golpe que acerta varios alvos no mesmo instante ensina uma vez so
	local repetido = m.ultimo_aprendizado ~= nil and math.abs(momento - m.ultimo_aprendizado) < 0.05;

	if not em_mim then
		if op.aprender and not repetido then
			local guarda_o = 0;
			pcall(function()
				local golpe_o = acerto:call("get_AttackData");
				if golpe_o ~= nil then guarda_o = golpe_o:get_field("_GuardType") or 0; end
			end);
			local usadas = 0;
			for i = #m.historico, 1, -1 do
				local h = m.historico[i];
				local passou = momento - h.inicio;
				if passou > AJUSTES.idade_maxima_animacao or usadas >= AJUSTES.animacoes_por_impacto then break; end
				aprender(m.variante, h.chave, passou, guarda_o, 0); -- distancia 0: nao mexe no alcance ate voce
				usadas = usadas + 1;
			end
			m.ultimo_aprendizado = momento;
			estado.aprendidos_outros = (estado.aprendidos_outros or 0) + 1;
		end
		return;
	end

	estado.ultimo_impacto_em = momento; -- (0.32) usado para manter a guarda em golpes seguidos

	-- (0.45) previsao por monstro (para saber quanto o mod ja conhece de cada um)
	estado.por_monstro = estado.por_monstro or {};
	local stat = estado.por_monstro[m.variante] or { nome = m.nome_completo, vistos = 0, certos = 0 };
	estado.por_monstro[m.variante] = stat;
	stat.vistos = stat.vistos + 1;

	local guarda, forca = 0, nil;
	local golpe = acerto:call("get_AttackData");
	if golpe ~= nil then
		guarda = golpe:get_field("_GuardType") or 0;
		forca = golpe:get_field("_VersusGuardPower");
	end

	-- confere a previsao: qual impacto previsto estava mais perto do real?
	estado.impactos_vistos = estado.impactos_vistos + 1;
	local menor, casado = nil, nil;
	for _, p in ipairs(m.previstos) do
		local erro = momento - p.tempo;
		if menor == nil or math.abs(erro) < math.abs(menor) then menor, casado = erro, p; end
	end
	if menor ~= nil and math.abs(menor) <= 0.3 then
		estado.ultimo_erro_ms = math.floor(menor * 1000 + 0.5);
		estado.avisos_certos = estado.avisos_certos + 1;
		stat.certos = stat.certos + 1;

		-- o mod defendeu este golpe? confere daqui a 0,3s se o jogo confirmou a defesa
		if casado.defesa ~= nil and not casado.conferido then
			casado.conferido = true;
			verificacoes_defesa[#verificacoes_defesa + 1] = {
				chave = casado.chave or ("lanca:" .. m.variante .. ":" .. tostring(casado.origem)),
				perfil = casado.perfil, nivel = casado.nivel, defesa = casado.defesa, em = os.clock(),
				monstro = m.nome,
				sem_combo = casado.sem_combo, diag = casado.diag
			};
		end
	else
		estado.ultimo_erro_ms = nil;
	end

	-- aprende: as ultimas animacoes do monstro antes deste impacto
	if op.aprender and not repetido then
		m.ultimo_aprendizado = momento;
		local usadas = 0;
		for i = #m.historico, 1, -1 do
			local h = m.historico[i];
			local passou = momento - h.inicio;
			if passou > AJUSTES.idade_maxima_animacao or usadas >= AJUSTES.animacoes_por_impacto then break; end
			aprender(m.variante, h.chave, passou, guarda, m.distancia);
			usadas = usadas + 1;
		end
	end
end

--[[
	(0.58) APRENDER TAMBEM QUANDO VOCE DEFENDE. Nas leituras do SS+ISS, quando o contra-ataque
	do ISS deu certo o jogo NAO chamou o "golpe acertou" (por isso o mod so aprendia golpes com
	a Long Sword quando voce LEVAVA o golpe). Agora, quando o jogo avisa que o FS ou o ISS
	defendeu, o momento do aviso e o momento do golpe: se algum golpe estava previsto para
	ate 0,25s dali, vira uma medicao nova (reforca e corrige o tempo daquele golpe).
]]
local function aprender_por_contra_ataque()
	if not op.aprender then return; end
	local momento = agora();
	local melhor_m, melhor_p, menor = nil, nil, nil;
	for _, m in pairs(monstros) do
		if not m.invalido then
			for _, p in ipairs(m.previstos or {}) do
				local erro = momento - p.tempo;
				if math.abs(erro) <= 0.25 and (menor == nil or math.abs(erro) < math.abs(menor)) then
					melhor_m, melhor_p, menor = m, p, erro;
				end
			end
		end
	end
	if melhor_m == nil then return; end
	if melhor_m.ultimo_aprendizado ~= nil and math.abs(momento - melhor_m.ultimo_aprendizado) < 0.3 then return; end
	melhor_m.ultimo_aprendizado = momento;
	local usadas = 0;
	for i = #melhor_m.historico, 1, -1 do
		local h = melhor_m.historico[i];
		local passou = momento - h.inicio;
		if passou > AJUSTES.idade_maxima_animacao or usadas >= AJUSTES.animacoes_por_impacto then break; end
		aprender(melhor_m.variante, h.chave, passou, melhor_p.guarda or 0, melhor_m.distancia or 0);
		usadas = usadas + 1;
	end
	estado.aprendidos_contra = (estado.aprendidos_contra or 0) + 1;
	estado.ultimo_erro_ms = math.floor(menor * 1000 + 0.5);
end

local tipo_monstro_char = sdk.find_type_definition("app.EnemyCharacter");
local funcao_impacto = tipo_monstro_char and tipo_monstro_char:get_method("evHit_AttackPreProcess");
if funcao_impacto ~= nil then
	pcall(sdk.hook, funcao_impacto, function(argumentos)
		local ok, erro = pcall(ao_impacto, argumentos);
		if not ok then estado.mensagem = "erro impacto: " .. tostring(erro); end
	end, function(retorno)
		return retorno;
	end);
end

-- =====================================================================================
-- (0.78) NOVAS FONTES DE APRENDIZADO, FIM DA QUEST E DEFESA NA HORA DO GOLPE
--
-- Tudo aqui e lido no SEU jogo (nada vem pela internet, como os golpes em outros jogadores
-- no SOS, que chegavam atrasados e foram tirados na 0.52).
-- =====================================================================================

local n78 = {}; -- (0.78) o arquivo ja esta no limite de variaveis locais do Lua: tudo da 0.78 fica aqui dentro
(function()
estado.ganchos_078 = {};

local function ponteiro_para_objeto(ponteiro)
	local ok, objeto = pcall(function()
		local valor = sdk.to_valuetype(ponteiro, "System.UInt64");
		local endereco = valor and valor:get_field("m_value");
		if endereco == nil or endereco == 0 then return nil; end
		return sdk.to_managed_object(endereco);
	end);
	return ok and objeto or nil;
end

-- aprende um golpe que chegou em "momento" (pode ser no passado): todas as ultimas animacoes
-- do monstro que comecaram antes dele
local function aprender_golpe_em(m, momento, guarda, contador)
	local usadas = 0;
	for i = #m.historico, 1, -1 do
		local h = m.historico[i];
		local passou = momento - h.inicio;
		if passou >= 0 then
			if passou > AJUSTES.idade_maxima_animacao or usadas >= AJUSTES.animacoes_por_impacto then break; end
			aprender(m.variante, h.chave, passou, guarda or 0, m.distancia or 0);
			usadas = usadas + 1;
		end
	end
	m.ultimo_aprendizado = momento;
	estado[contador] = (estado[contador] or 0) + 1;
end

--[[
	A. INVENCIBILIDADE (esquiva, FS...): o jogo avisa quando ela comeca e de que tipo e.
	Tipos: 0 esquiva rolando, 1 passo, 6 FS, 7 FS vermelho (os outros sao de outras armas).
	A duracao vem do proprio jogo (ja com a skill Evade Window).
]]
local NOMES_INVENCIBILIDADE = { [0] = "esquiva", [1] = "passo", [6] = "FS", [7] = "FS vermelho" };
local invencibilidade = { desde = nil, ate = nil, tipo = nil, stats = {} };

pcall(function()
	local tipo_cacador = sdk.find_type_definition("app.HunterCharacter");
	local metodo = tipo_cacador and tipo_cacador:get_method("beginDodgeNoHit");
	if metodo == nil then return; end
	sdk.hook(metodo, function(args)
		pcall(function()
			local cacador = meu_cacador();
			if cacador == nil or sdk.to_managed_object(args[2]) ~= cacador then return; end
			local tipo = sdk.to_int64(args[3]) & 0xFFFFFFFF;
			local duracao = nil;
			pcall(function() duracao = cacador:call("get_HunterSkill"):call("getDodgeNoHitTime", tipo); end);
			invencibilidade.desde = agora();
			invencibilidade.tipo = tipo;
			invencibilidade.ate = invencibilidade.desde + (tonumber(duracao) or 0.25);
			invencibilidade.duracao = tonumber(duracao);
		end);
	end, function(retorno) return retorno; end);
	estado.ganchos_078.invencibilidade = true;
end);

local function anotar_invencibilidade(momento)
	if invencibilidade.desde == nil or momento > (invencibilidade.ate or 0) + 0.05 or momento < invencibilidade.desde then return; end
	local nome = NOMES_INVENCIBILIDADE[invencibilidade.tipo] or ("tipo " .. tostring(invencibilidade.tipo));
	local s = invencibilidade.stats[nome] or { n = 0, soma = 0, janela = 0 };
	s.n = s.n + 1;
	s.soma = s.soma + (momento - invencibilidade.desde) * 1000;
	s.janela = math.floor((invencibilidade.duracao or 0) * 1000 + 0.5);
	invencibilidade.stats[nome] = s;
end

--[[
	B. CONTATO DO GOLPE. Antes de decidir se um golpe acertou, o jogo testa o CONTATO da area
	de ataque com o corpo (app.HitController.checkHitSuccess). O teste acontece tambem quando
	voce esta invencivel (esquiva, FS, ISS) - so que ai ele "falha". O acerto que passa ja ensina
	pelo caminho de sempre (ao_impacto); aqui entram so os que FALHARAM em voce: as defesas.
	Cuidados (so medicao precisa):
	  - 0,6s depois de um golpe ja aprendido do mesmo monstro, nada (a area continua encostando
	    nos quadros seguintes);
	  - se o monstro ja tem golpe previsto mas o contato veio longe (> 0,3s) de um golpe que o mod
	    conhece bem (5 vezes ou mais), o contato e descartado e so contado no relatorio.
]]
--[[
	(0.79) 1o teste: em ~30 esquivas so 3 contatos "falharam". O jogo testa o contato como acerto
	("passou") e so DEPOIS decide que voce esquivou - e nesse caso o aviso de acerto que o mod ja
	usava (ao_impacto) nem sempre vem. Agora o contato que passou fica guardado 0,15s: se nenhum
	outro caminho aprendeu aquele golpe, ele ensina.
]]
local contatos_pendentes = {};
local function anotar_contato(chave_contagem)
	estado.contatos_em_voce = estado.contatos_em_voce or {};
	estado.contatos_em_voce[chave_contagem] = (estado.contatos_em_voce[chave_contagem] or 0) + 1;
end

local function contato_falhou(info_ptr, acerto_ptr, passou)
	if not op.aprender or not op.aprender_por_contato then return; end
	local cacador = meu_cacador();
	local meu_objeto = cacador and objeto_de_jogo(cacador);
	if meu_objeto == nil then return; end

	local atacante, alvo, guarda = nil, nil, 0;
	local acerto = acerto_ptr and ponteiro_para_objeto(acerto_ptr);
	if acerto ~= nil then
		pcall(function()
			atacante = acerto:call("getActualAttackOwner");
			alvo = acerto:call("getActualDamageOwner");
		end);
		pcall(function()
			local dados = acerto:call("get_AttackData");
			if dados ~= nil then guarda = dados:get_field("_GuardType") or 0; end
		end);
	end
	if alvo == nil and info_ptr ~= nil then
		pcall(function()
			local info = sdk.to_valuetype(sdk.to_int64(info_ptr) & 0x7FFFFFFFFFFFFFFF, "ace.UNIVERSAL_COLLISION_INFO");
			local a = info:get_field("CollidableA"):call("get_GameObject");
			local b = info:get_field("CollidableB"):call("get_GameObject");
			if b == meu_objeto then atacante, alvo = a, b; elseif a == meu_objeto then atacante, alvo = b, a; end
		end);
	end
	if alvo == nil or alvo ~= meu_objeto or atacante == nil then return; end

	local m = monstro_do_objeto(atacante);
	if m == nil or m.invalido then return; end

	local momento = agora();
	-- os quadros seguintes do mesmo contato nao contam
	if m.ultimo_contato ~= nil and momento - m.ultimo_contato < 0.6 and momento >= m.ultimo_contato then return; end
	m.ultimo_contato = momento;
	anotar_contato(passou and "passou" or "falhou");
	if invencibilidade.desde ~= nil and momento >= invencibilidade.desde and momento <= (invencibilidade.ate or 0) + 0.05 then
		anotar_contato("na invencibilidade");
		anotar_invencibilidade(momento);
	end
	if m.ultimo_aprendizado ~= nil and math.abs(momento - m.ultimo_aprendizado) < 0.6 then return; end
	if passou then
		contatos_pendentes[#contatos_pendentes + 1] = { m = m, em = momento, guarda = guarda };
		return;
	end

	local mais_perto, conhecido = nil, false;
	for _, p in ipairs(m.previstos or {}) do
		local erro = math.abs(momento - p.tempo);
		if mais_perto == nil or erro < mais_perto then mais_perto = erro; end
		if (p.vezes or 0) >= 5 then conhecido = true; end
	end
	if mais_perto ~= nil and mais_perto > 0.3 and conhecido then
		estado.contatos_descartados = (estado.contatos_descartados or 0) + 1;
		m.ultimo_aprendizado = momento; -- os quadros seguintes do mesmo contato tambem nao contam
		return;
	end

	aprender_golpe_em(m, momento, guarda, "aprendidos_contato");
end

pcall(function()
	local tipo_hit = sdk.find_type_definition("app.HitController");
	local metodo = tipo_hit and tipo_hit:get_method("checkHitSuccess(ace.UNIVERSAL_COLLISION_INFO, app.CollisionFilter.LAYER, app.HitInfo)");
	if metodo == nil then return; end
	sdk.hook(metodo, function(args)
		local guardado = thread.get_hook_storage();
		if guardado == nil then return; end
		if not op.aprender_por_contato then guardado.info_078 = nil; return; end
		guardado.info_078, guardado.acerto_078 = args[3], args[5];
	end, function(retorno)
		local guardado = thread.get_hook_storage();
		if guardado == nil or guardado.info_078 == nil then return retorno; end
		local info_ptr, acerto_ptr = guardado.info_078, guardado.acerto_078;
		guardado.info_078 = nil;
		local passou = false;
		pcall(function() passou = (sdk.to_int64(retorno) & 1) == 1; end);
		pcall(contato_falhou, info_ptr, acerto_ptr, passou); -- (0.79) passou tambem
		return retorno;
	end);
	estado.ganchos_078.contato = true;
end);

--[[
	C. AREA DE ATAQUE LIGANDO (app.ColliderSwitcher.activateAttack): o jogo liga a area de
	ataque do monstro, acertando alguem ou nao. "Ligar" nao e "encostar" (num golpe que anda, a
	area fica ligada um tempo), entao o mod CONFERE antes de usar: para cada animacao ele mede
	quanto tempo depois de a area ligar o golpe chega (pelos golpes ja aprendidos). Quando isso
	e sempre igual (4 medicoes ou mais, variando no maximo 0,08s), a animacao fica CONFIAVEL e:
	  - o relogio do golpe previsto e acertado na hora em que a area liga;
	  - se o golpe errar todo mundo, ele ensina mesmo assim (no tempo conferido).
	Guardado em aviso_lanca_ativacoes.json.
]]
local ativacoes = {};
pcall(function()
	local salvo = json.load_file("aviso_lanca_ativacoes.json");
	if type(salvo) == "table" then ativacoes = salvo; end
end);
local ativacoes_mudou, ativacoes_salvo_em = false, 0;
local fila_ativacoes, golpes_pendentes = {}, {};

pcall(function()
	local tipo_sw = sdk.find_type_definition("app.ColliderSwitcher");
	local metodo = tipo_sw and tipo_sw:get_method("activateAttack(System.Boolean, System.UInt32, System.UInt32, System.Nullable`1<System.Boolean>, app.Hit.HIT_ID_GROUP, System.Nullable`1<System.Single>, System.Nullable`1<System.Single>)");
	if metodo == nil then return; end
	sdk.hook(metodo, function(args)
		if not op.aprender_por_ativacao then return; end
		pcall(function()
			if (sdk.to_int64(args[3]) & 1) ~= 1 then return; end
			local sw = sdk.to_managed_object(args[2]);
			if sw == nil then return; end
			local dono = sw:get_field("_HitController"):call("get_Owner");
			local m = monstro_do_objeto(dono);
			if m == nil or m.invalido then return; end
			local momento = agora();
			if m.ultima_ativacao ~= nil and momento - m.ultima_ativacao < 0.1 then return; end
			m.ultima_ativacao = momento;
			fila_ativacoes[#fila_ativacoes + 1] = {
				m = m, em = momento, rsc = sw:get_field("_RequestSetCollider"),
				res = sdk.to_int64(args[4]) & 0xFFFFFFFF, req = sdk.to_int64(args[5]) & 0xFFFFFFFF
			};
		end);
	end, function(retorno) return retorno; end);
	estado.ganchos_078.ativacao = true;
end);

-- dados do golpe (forca e tipo de guarda) da primeira area ligada
local function dados_da_area(a)
	local ataque, guarda = nil, 0;
	pcall(function()
		local col = a.rsc:call("getCollidable", a.res, a.req, 0);
		local dados = col and col:call("get_UserData");
		dados = dados and dados:call("get_ParentUserData");
		if dados ~= nil and dados:get_type_definition():is_a("app.col_user_data.AttackParamEm") then
			ataque = dados:get_field("_Attack");
			guarda = dados:call("get_GuardType") or 0;
		end
	end);
	return ataque, guarda;
end

--[[
	(0.79) 1o teste: 34 animacoes com area vista e so 1 confiavel. Nas animacoes com varios golpes
	uma medicao cai no golpe vizinho (ex.: 2:23 do Chatacabra: 0,03 0,03 0,03 0,115 0,025...). Agora
	vale a MAIORIA: 5 medicoes ou mais e pelo menos 2 de cada 3 a no maximo 0,04s da mediana; o
	tempo usado e a media dessas.
]]
local function area_confiavel(reg)
	local d = reg and reg.d;
	if d == nil or #d < 5 then return nil; end
	local copia = {};
	for _, v in ipairs(d) do copia[#copia + 1] = v; end
	table.sort(copia);
	local mediana = copia[math.floor((#copia + 1) / 2)];
	local perto, soma = 0, 0;
	for _, v in ipairs(d) do
		if math.abs(v - mediana) <= 0.04 then perto, soma = perto + 1, soma + v; end
	end
	if perto * 3 < #d * 2 then return nil; end
	return soma / perto;
end

local function processar_ativacoes()
	local momento = agora();

	-- golpes que ligaram a area numa animacao confiavel: se ninguem aprendeu, ensina agora
	local restantes = {};
	for _, g in ipairs(golpes_pendentes) do
		if momento < g.impacto + 0.6 then
			restantes[#restantes + 1] = g;
		elseif op.aprender and not g.m.invalido and not (g.m.ultimo_aprendizado ~= nil
			and math.abs(g.m.ultimo_aprendizado - g.impacto) < 0.35) then
			aprender_golpe_em(g.m, g.impacto, g.guarda, "aprendidos_ativacao");
		end
	end
	golpes_pendentes = restantes;

	-- (0.79) contatos que passaram: ensinam se nenhum outro caminho aprendeu o golpe
	local contatos_restantes = {};
	for _, c in ipairs(contatos_pendentes) do
		if momento < c.em + 0.15 then
			contatos_restantes[#contatos_restantes + 1] = c;
		elseif op.aprender and not c.m.invalido and not (c.m.ultimo_aprendizado ~= nil
			and math.abs(c.m.ultimo_aprendizado - c.em) < 0.35) then
			local mais_perto, conhecido = nil, false;
			for _, p in ipairs(c.m.previstos or {}) do
				local erro = math.abs(c.em - p.tempo);
				if mais_perto == nil or erro < mais_perto then mais_perto = erro; end
				if (p.vezes or 0) >= 5 then conhecido = true; end
			end
			if mais_perto ~= nil and mais_perto > 0.3 and conhecido then
				estado.contatos_descartados = (estado.contatos_descartados or 0) + 1;
			else
				aprender_golpe_em(c.m, c.em, c.guarda, "aprendidos_contato");
			end
		end
	end
	contatos_pendentes = contatos_restantes;

	local fila = fila_ativacoes;
	fila_ativacoes = {};
	for _, a in ipairs(fila) do
		local m = a.m;
		local ataque, guarda = dados_da_area(a);
		if not m.invalido and (ataque == nil or ataque > 0) then
			estado.ativacoes_vistas = (estado.ativacoes_vistas or 0) + 1;
			ativacoes[m.variante] = ativacoes[m.variante] or {};
			local agendado = false;
			local usadas = 0;
			for i = #m.historico, 1, -1 do
				local h = m.historico[i];
				local ofs = a.em - h.inicio;
				if ofs >= 0 then
					if ofs > AJUSTES.idade_maxima_animacao or usadas >= AJUSTES.animacoes_por_impacto then break; end
					usadas = usadas + 1;
					local reg = ativacoes[m.variante][h.chave] or { n = 0, d = {} };
					ativacoes[m.variante][h.chave] = reg;
					reg.n = reg.n + 1;
					-- confere com os golpes ja aprendidos desta animacao
					local melhor = nil;
					for _, g in ipairs(grupos_de(m.variante, h.chave) or {}) do
						local dif = g.tempo - ofs;
						if g.vezes >= 3 and dif >= -0.05 and dif <= 0.6 and (melhor == nil or math.abs(dif) < math.abs(melhor)) then
							melhor = dif;
						end
					end
					if melhor ~= nil then
						reg.d[#reg.d + 1] = arredondar(melhor, 3);
						while #reg.d > 20 do table.remove(reg.d, 1); end
					end
					ativacoes_mudou = true;

					local d = area_confiavel(reg);
					local perto_de_golpe = false;
					if d ~= nil then
						for _, g in ipairs(grupos_de(m.variante, h.chave) or {}) do
							if g.vezes >= 3 and math.abs(g.tempo - (ofs + d)) <= 0.15 then perto_de_golpe = true; end
						end
					end
					if d ~= nil and not agendado and perto_de_golpe then
						agendado = true;
						local impacto = a.em + d;
						-- acerta o relogio do golpe previsto
						for _, p in ipairs(m.previstos or {}) do
							if math.abs(p.tempo - impacto) <= 0.2 then
								p.tempo = impacto;
								if (RESTRICAO[guarda] or 0) > (RESTRICAO[p.guarda] or 0) then p.guarda = guarda; end
								estado.relogios_acertados = (estado.relogios_acertados or 0) + 1;
								break;
							end
						end
						golpes_pendentes[#golpes_pendentes + 1] = { m = m, impacto = impacto, guarda = guarda };
					end
				end
			end
		end
	end

	if ativacoes_mudou and os.clock() - ativacoes_salvo_em > 20 then
		ativacoes_mudou, ativacoes_salvo_em = false, os.clock();
		pcall(json.dump_file, "aviso_lanca_ativacoes.json", ativacoes);
	end
end

-- resumo das areas de ataque (relatorio)
local function resumo_ativacoes(variante)
	local vistas, confiaveis, so_area = 0, 0, 0;
	for chave_v, por_anim in pairs(ativacoes) do
		if variante == nil or chave_v == variante then
			for anim, reg in pairs(por_anim) do
				if reg.n >= 3 then
					vistas = vistas + 1;
					if area_confiavel(reg) ~= nil then confiaveis = confiaveis + 1; end
					if grupos_de(chave_v, anim) == nil then so_area = so_area + 1; end
				end
			end
		end
	end
	return vistas, confiaveis, so_area;
end

--[[
	D. FIM DA QUEST E TROCA DE CENA. O jogo avisa quando a quest acaba (qualquer resultado) e
	quando a cena vai trocar. Nesses momentos o mod solta TODOS os monstros na hora (nao chama
	mais nada neles) e nao registra monstros por alguns segundos - era chamando funcoes em
	monstros sendo destruidos que o jogo travava no fim da luta.
]]
local function soltar_monstros(segundos, motivo)
	estado.parar_monstros_ate = math.max(estado.parar_monstros_ate or 0, os.clock() + segundos);
	for _, m in pairs(monstros) do
		m.invalido = true;
		m.previstos = {};
	end
	golpes_pendentes, fila_ativacoes = {}, {};
	if motivo ~= nil then
		estado.solturas = estado.solturas or {};
		estado.solturas[motivo] = (estado.solturas[motivo] or 0) + 1;
	end
end

for _, gancho in ipairs({ { "app.cQuestPlaying", "exit()" }, { "app.cQuestReward", "enter()" } }) do
	pcall(function()
		local tipo = sdk.find_type_definition(gancho[1]);
		local metodo = tipo and (tipo:get_method(gancho[2]) or tipo:get_method((string.gsub(gancho[2], "%(%)", ""))));
		if metodo == nil then return; end
		sdk.hook(metodo, function(args)
			pcall(soltar_monstros, 15, "fim da quest");
		end, function(retorno) return retorno; end);
		estado.ganchos_078.fim_quest = true;
	end);
end

local function vigiar_troca_de_cena()
	local ok, proximo = pcall(function()
		local fluxo = sdk.get_managed_singleton("app.GameFlowManager");
		return fluxo and fluxo:call("get_NextGameStateType");
	end);
	if ok and proximo ~= nil then
		-- seguranca: se o jogo disser "trocando de cena" por mais de 20s seguidos, a leitura nao serve
		if not estado.trocando_cena then estado.troca_desde = os.clock(); end
		if os.clock() - (estado.troca_desde or os.clock()) > 20 then
			estado.troca_leitura_ruim = true;
			return;
		end
		if not estado.trocando_cena then soltar_monstros(3, "troca de cena"); end
		estado.trocando_cena = true;
		estado.parar_monstros_ate = math.max(estado.parar_monstros_ate or 0, os.clock() + 3);
	else
		estado.trocando_cena = false;
	end
end

--[[
	E. OUTRAS ARMAS: DEFESA NA HORA DO GOLPE. Para as armas abaixo o jogo aceita que a defesa
	seja pedida no instante em que o golpe chega no cacador: o mod pede a acao (guarda perfeita,
	esquiva...) e o golpe e tratado como defendido. Nao depende de previsao, entao funciona ate
	em golpes que o mod nunca viu. Nao age se voce ja esta invencivel / guardando (o jogo
	resolve sozinho), montado, ou (opcao) com a arma guardada.
	Tipo da arma (get_WeaponType): 0 GS, 1 SnS, 2 DB, 8 SA, 9 CB, 11 Bow, 12 HBG, 13 LBG.
	Sem dados para: Hammer (4), Hunting Horn (5), Lance (6), Gunlance (7), Insect Glaive (10);
	a Long Sword (3) continua com o FS / SS+ISS do mod.
]]
local ARMAS_NA_HORA = {
	[0] = { chave = "gs", nome = "Great Sword", defesa = "guarda" },
	[1] = { chave = "sns", nome = "Sword and Shield", defesa = "guarda" },
	[2] = { chave = "db", nome = "Dual Blades", defesa = "esquiva_db" },
	[8] = { chave = "sa", nome = "Switch Axe", defesa = "contra_sa" },
	[9] = { chave = "cb", nome = "Charge Blade", defesa = "guarda" },
	[11] = { chave = "arco", nome = "Bow", defesa = "esquiva_arco" },
	[12] = { chave = "hbg", nome = "Heavy Bowgun", defesa = "guarda" },
	[13] = { chave = "lbg", nome = "Light Bowgun", defesa = "esquiva" }
};
local ORDEM_ARMAS_NA_HORA = { 0, 1, 2, 8, 9, 11, 12, 13 };
local tipo_id_acao = sdk.find_type_definition("ace.ACTION_ID");
local na_hora_ultima = 0;

local function pedir_acao(cacador, categoria, indice)
	local ok, controle = pcall(function() return cacador:call("get_BaseActionController"); end);
	if not ok or controle == nil then return false; end
	if tipo_id_acao ~= nil then
		local feito = pcall(function()
			local id = ValueType.new(tipo_id_acao);
			id._Category = categoria;
			id._Index = indice;
			controle:call("changeActionRequest(ace.ACTION_ID)", id);
		end);
		if feito then return true; end
	end
	return pcall(function() controle:call("changeActionRequest(System.Int32,System.Int32)", categoria, indice); end);
end

-- a arma desta defesa esta ligada e o cacador pode defender agora?
local function arma_na_hora(cacador)
	if not op.defesa_na_hora_ligada then return nil; end
	local ok_t, tipo = pcall(function() return cacador:call("get_WeaponType"); end);
	local def = ok_t and ARMAS_NA_HORA[tonumber(tipo) or -1] or nil;
	if def == nil or (op.na_hora or {})[def.chave] == false then return nil; end
	local montado = false;
	pcall(function() montado = cacador:call("get_IsPorterRiding") == true; end);
	if montado then return nil; end
	if op.na_hora_so_sacada then
		local sacada = true;
		pcall(function() sacada = cacador:call("get_IsWeaponOn") == true; end);
		if not sacada then return nil; end
	end
	if os.clock() - na_hora_ultima < 0.3 then return nil; end
	return def;
end

local function ja_protegido(cacador)
	local protegido = false;
	pcall(function()
		local seq = cacador:get_field("_HunterMotionSupporter"):get_field("_BaseBasicMotionSeq");
		protegido = seq:get_field("_NoHit") == true;
	end);
	if protegido then return true; end
	pcall(function()
		local flags = cacador:call("get_HunterStatus"):get_field("_HunterStatusFlag");
		for _, f in ipairs({ 2, 3, 4 }) do -- GUARD, POWER_GUARD, TECHNICAL_GUARD
			if flags:call("check(System.UInt32)", f) == true then protegido = true; end
		end
	end);
	return protegido;
end

local function contar_na_hora(nome)
	estado.na_hora_contagem = estado.na_hora_contagem or {};
	estado.na_hora_contagem[nome] = (estado.na_hora_contagem[nome] or 0) + 1;
end

local function defesa_na_hora(args)
	local cacador = meu_cacador();
	if cacador == nil then return nil; end
	local alvo = sdk.to_managed_object(args[2]);
	if alvo == nil or alvo:call("get_IsMaster") ~= true then return nil; end
	local def = arma_na_hora(cacador);
	if def == nil or def.defesa == "contra_sa" then return nil; end

	local acerto = sdk.to_managed_object(args[3]);
	local dono = acerto and acerto:get_field("<AttackOwner>k__BackingField");
	local etiqueta = dono and dono:call("get_Tag");
	if type(etiqueta) ~= "string" or not string.find(etiqueta, "Enemy", 1, true) then return nil; end
	if ja_protegido(cacador) then return nil; end

	na_hora_ultima = os.clock();
	if def.defesa == "guarda" then
		pcall(function() cacador:call("startNoHitTimer(System.Single)", 0.25); end);
		pedir_acao(cacador, 1, 146);
	elseif def.defesa == "esquiva" then
		pedir_acao(cacador, 1, 19);
	elseif def.defesa == "esquiva_arco" then
		pedir_acao(cacador, 2, 9);
	elseif def.defesa == "esquiva_db" then
		pedir_acao(cacador, 2, 53);
		pedir_acao(cacador, 2, 47);
	end
	contar_na_hora(def.nome);
	return sdk.PreHookResult.SKIP_ORIGINAL;
end

pcall(function()
	local tipo_cacador = sdk.find_type_definition("app.HunterCharacter");
	local metodo = tipo_cacador and tipo_cacador:get_method("evHit_Damage");
	if metodo == nil then return; end
	sdk.hook(metodo, function(args)
		local ok, resultado = pcall(defesa_na_hora, args);
		if ok and resultado ~= nil then return resultado; end
	end, function(retorno) return retorno; end);
	estado.ganchos_078.na_hora = true;
end);

-- Switch Axe: contra-ataque (espada) / offset (machado) no instante do golpe
local function contra_sa(args)
	local cacador = meu_cacador();
	if cacador == nil then return; end
	local def = arma_na_hora(cacador);
	if def == nil or def.defesa ~= "contra_sa" then return; end
	local acerto = sdk.to_managed_object(args[3]);
	if acerto == nil then return; end
	local dono_dano = acerto:get_field("<DamageOwner>k__BackingField");
	if dono_dano == nil or dono_dano:call("get_Name") ~= "MasterPlayer" then return; end
	local dono = acerto:get_field("<AttackOwner>k__BackingField");
	local etiqueta = dono and dono:call("get_Tag");
	if type(etiqueta) ~= "string" or not string.find(etiqueta, "Enemy", 1, true) or string.find(etiqueta, "Shell", 1, true) then return; end
	local dados = acerto:get_field("<AttackData>k__BackingField");
	local forca = dados and dados:get_field("_Attack");
	if type(forca) ~= "number" or forca <= 0 then return; end
	if ja_protegido(cacador) then return; end

	local espada = false;
	pcall(function() espada = cacador:call("get_WeaponHandling"):get_field("_Mode") == 1; end);
	na_hora_ultima = os.clock();
	pcall(function()
		acerto:set_field("<CollisionLayer>k__BackingField", 18);
		local parametro = sdk.create_instance("app.cAttackParamPl", true);
		acerto:call("set_DamageAttackData", parametro);
		local dano = acerto:get_field("<DamageAttackData>k__BackingField");
		dano:set_field("_HitEffectType", 18);
		dano:set_field("_ParryDamage", espada and 600 or 150);
		dano:set_field("_HitEffectOverwriteConnectID", -1);
	end);
	pcall(function() cacador:call("startNoHitTimer(System.Single)", 0.4); end);
	if espada then
		pedir_acao(cacador, 2, 54);
		pedir_acao(cacador, 2, 31);
	else
		pedir_acao(cacador, 2, 5);
	end
	contar_na_hora(def.nome);
end

if funcao_impacto ~= nil then
	pcall(sdk.hook, funcao_impacto, function(argumentos)
		pcall(contra_sa, argumentos);
	end, function(retorno) return retorno; end);
end

n78.processar_ativacoes = processar_ativacoes;
n78.vigiar_troca_de_cena = vigiar_troca_de_cena;
n78.resumo_ativacoes = resumo_ativacoes;
n78.invencibilidade = invencibilidade;
n78.ARMAS = ARMAS_NA_HORA;
n78.ORDEM = ORDEM_ARMAS_NA_HORA;
end)();


-- =====================================================================================
-- 6. ARMA ATUAL (para a aba Prints)
-- =====================================================================================

local pesquisa = {
	arma_tipo = nil,         -- classe real da sua arma (ex.: lanca)
	arma_ganchos = {}        -- funcoes da arma com gancho ligado
};

--[[
	TESTE DA GUARDA AUTOMATICA (2)

	Na versao 0.6 o mod escutava "perguntas" do tipo "o botao esta apertado?", mas o jogo
	quase nao faz essas perguntas: ele guarda o estado dos botoes em CAMPOS (numeros e bits)
	dentro dos objetos de entrada e le esses campos direto.

	Entao agora o mod tira uma "foto" de todos os numeros dentro desses objetos, a cada
	quadro, em duas capturas de 3 segundos:
	  1) parado, com a lanca sacada, sem apertar nada;
	  2) parado, segurando a guarda.
	O que ficou sempre igual na captura 1 e mudou na captura 2 e o botao de guarda.

	No teste, o mod ESCREVE esses valores a cada quadro, como se voce estivesse apertando.

	Objetos fotografados:
	  - app.GameInputManager (entrada do controle e de mouse/teclado);
	  - as marcacoes de comando do seu cacador (_HunterBTableCommandFlag).
]]
local entrada = {
	fase = "parado",       -- parado | esperando | capturando
	captura_numero = 0,    -- 1 = parado, 2 = segurando a guarda
	fase_ate = 0,
	valores = { {}, {} },  -- por captura: [caminho] = { [valor] = vezes }
	onde = {},             -- [caminho] = { objeto, campo ou indice } (para escrever no teste)
	achados = {},          -- campos da guarda: { caminho, valor }
	forcar_de = 0,          -- o teste comeca aqui (8 segundos depois do clique)
	forcar_ate = 0,
	forcando = false,
	nos_ultima_foto = 0
};

local LIMITE_NOS = 4000; -- limite de valores por foto (evita pesar o jogo)

-- percorre um objeto e anota todos os numeros e verdadeiro/falso dentro dele
local function fotografar(objeto, caminho, profundidade, foto, visitados)
	if objeto == nil or foto.nos >= LIMITE_NOS then return; end

	local ok_end, endereco = pcall(objeto.get_address, objeto);
	if ok_end and endereco ~= nil then
		if visitados[endereco] then return; end
		visitados[endereco] = true;
	end

	-- lista (array): anota cada item
	local ok_tam, tamanho = pcall(function() return objeto:get_size(); end);
	if ok_tam and type(tamanho) == "number" then
		for i = 0, math.min(tamanho, 64) - 1 do
			local ok_item, item = pcall(objeto.get_element, objeto, i);
			if ok_item then
				local caminho_item = caminho .. "[" .. i .. "]";
				if type(item) == "number" or type(item) == "boolean" then
					foto.valores[caminho_item] = item;
					foto.onde[caminho_item] = { objeto = objeto, indice = i };
					foto.nos = foto.nos + 1;
				elseif type(item) == "userdata" and profundidade > 0 then
					fotografar(item, caminho_item, profundidade - 1, foto, visitados);
				end
			end
		end
		return;
	end

	-- objeto comum: anota os campos dele e das classes-mae
	local ok_tipo, tipo = pcall(objeto.get_type_definition, objeto);
	while ok_tipo and tipo ~= nil do
		local nome_tipo = tipo:get_full_name();
		if nome_tipo == "System.Object" or nome_tipo == "System.ValueType" then break; end

		for _, campo in ipairs(tipo:get_fields() or {}) do
			if not campo:is_static() then
				local ok_v, valor = pcall(campo.get_data, campo, objeto);
				if ok_v then
					local caminho_campo = caminho .. "." .. campo:get_name();
					if type(valor) == "number" or type(valor) == "boolean" then
						foto.valores[caminho_campo] = valor;
						foto.onde[caminho_campo] = { objeto = objeto, campo = campo:get_name() };
						foto.nos = foto.nos + 1;
					elseif type(valor) == "userdata" and profundidade > 0 then
						fotografar(valor, caminho_campo, profundidade - 1, foto, visitados);
					end
				end
			end
		end

		tipo = tipo:get_parent_type();
	end
end

local function tirar_foto()
	local foto = { valores = {}, onde = {}, nos = 0 };
	local visitados = {};

	local gerente = sdk.get_managed_singleton("app.GameInputManager");
	if gerente ~= nil then
		for _, nome in ipairs({ "_PadPlayerInput", "_MkbPlayerInput", "_PlayerButtonMaskBit", "_PlayerButtonMaskFlagStore" }) do
			local ok, valor = pcall(gerente.get_field, gerente, nome);
			if ok and type(valor) == "userdata" then
				fotografar(valor, "Entrada." .. nome, 5, foto, visitados);
			elseif ok and type(valor) == "number" then
				foto.valores["Entrada." .. nome] = valor;
				foto.onde["Entrada." .. nome] = { objeto = gerente, campo = nome };
			end
		end
	end

	local cacador = meu_cacador();
	local marcas = cacador and cacador:get_field("_HunterBTableCommandFlag");
	if marcas ~= nil then fotografar(marcas, "Cacador.Comandos", 4, foto, visitados); end

	entrada.nos_ultima_foto = foto.nos;
	return foto;
end

-- qual botao esta sendo aprendido: "guarda", "esquiva" ou "power_guard"
entrada.alvo = "guarda";

-- botoes gravados como TOQUE (quadro a quadro): alvo -> nome da gravacao
local ALVO_TOQUE = { toque_m5 = "m5", toque_m2 = "m2", toque_m4 = "m4" };

local function alvo_de_toque(alvo)
	return alvo == "esquiva" or ALVO_TOQUE[alvo] ~= nil;
end

local NOME_DO_ALVO = { toque_m4 = "TOQUE DO M4 (guardar a arma e correr)", toque_m5 = "TOQUE DO M5 (Foresight da Long Sword)", toque_m2 = "TOQUE DO M2 (Foresight da Long Sword)", foresight = "FORESIGHT SLASH (M5 + M2)", guarda = "GUARDA (M5)", contra_ataque = "CONTRA-ATAQUE (M5 e depois M2)", power_guard = "POWER GUARD (M5, M2 e Espaco)", esquiva = "ESQUIVA (Espaco)" };

local function comecar_captura(numero)
	entrada.captura_numero = numero;
	entrada.valores[numero] = {};
	entrada.fase = "esperando";
	entrada.fase_ate = agora() + 3;

	-- esquiva: o passo 2 grava um TOQUE. Para saber o que mudou em cada quadro, guardamos
	-- o valor "parado" (da captura 1) de cada campo que nao variou nela.
	entrada.base, entrada.quadros = nil, {};
	if numero == 2 and alvo_de_toque(entrada.alvo) then
		entrada.base = {};
		for caminho, vistos in pairs(entrada.valores[1] or {}) do
			local unico, quantos = nil, 0;
			for valor in pairs(vistos) do unico = valor; quantos = quantos + 1; end
			if quantos == 1 then entrada.base[caminho] = unico; end
		end
	end
end

-- transforma um caminho de foto ("..._Keys[N]...Campo") num item de escrita { t, l, c, v }
local function item_de_caminho(caminho, texto_valor)
	local n, resto = string.match(caminho, "_Keys%[(%d+)%]%.(.+)$");
	if n == nil then return nil; end
	local campo = string.match(resto, "([%w_]+)$");
	local valor = texto_valor;
	if valor == "true" then valor = true; elseif valor == "false" then valor = false; else valor = tonumber(valor); end
	if campo == nil or valor == nil then return nil; end
	return { t = tonumber(n), l = string.find(resto, "LagWorker", 1, true) ~= nil, c = campo, v = valor };
end

--[[
	TOQUE GRAVADO (esquiva)
	Do primeiro quadro em que algo mudou ate o ultimo (no maximo 1,5s), guarda a lista de
	mudancas de cada quadro. Na hora de esquivar, o mod repete essa sequencia quadro a
	quadro, como uma macro. O quadro com mais mudancas vira o "Espaco segurado" do Power Guard.
]]
local function calcular_toque()
	local primeiro, ultimo = nil, nil;
	for i, diferentes in ipairs(entrada.quadros) do
		if next(diferentes) ~= nil then
			primeiro = primeiro or i;
			ultimo = i;
		end
	end
	if primeiro == nil then
		estado.mensagem = "Toque nao gravado: nenhuma mudanca. Aperte e solte o botao durante a captura.";
		return;
	end
	ultimo = math.min(ultimo, primeiro + 90);

	local quadros, maior = {}, {};
	for i = primeiro, ultimo do
		local itens = {};
		for caminho, texto in pairs(entrada.quadros[i]) do
			local item = item_de_caminho(caminho, texto);
			if item ~= nil then itens[#itens + 1] = item; end
		end
		quadros[#quadros + 1] = itens;
		if #itens > #maior then maior = itens; end
	end

	-- toques do M5 e do M2 (Foresight Slash da espada longa)
	local nome_toque = ALVO_TOQUE[entrada.alvo];
	if nome_toque ~= nil then
		op.toques[nome_toque] = quadros;
		json.dump_file("aviso_lanca_opcoes.json", op);
		estado.mensagem = string.format("Toque do %s gravado: %d quadros.", string.upper(nome_toque), #quadros);
		return;
	end

	op.toques.esquiva = quadros;
	op.espaco_segurado = maior;
	json.dump_file("aviso_lanca_opcoes.json", op);
	json.dump_file("aviso_lanca_toque_esquiva.json", { quadros = quadros, segurado = maior });
	estado.mensagem = string.format("Toque da esquiva gravado: %d quadros.", #quadros);
end

-- O que foi sempre igual parado e ficou diferente segurando a guarda
local function calcular_achados()
	entrada.achados = {};
	local parado, segurando = entrada.valores[1], entrada.valores[2];

	for caminho, vistos2 in pairs(segurando) do
		local vistos1 = parado[caminho];
		if vistos1 ~= nil then
			local distintos1, unico1 = 0, nil;
			for valor in pairs(vistos1) do distintos1 = distintos1 + 1; unico1 = valor; end

			-- parado: sempre o mesmo valor. Segurando: o valor mais visto e outro.
			if distintos1 == 1 then
				local melhor, vezes_melhor, total = nil, 0, 0;
				for valor, vezes in pairs(vistos2) do
					total = total + vezes;
					if vezes > vezes_melhor then melhor, vezes_melhor = valor, vezes; end
				end
				if melhor ~= nil and melhor ~= unico1 and vezes_melhor >= total * 0.6 then
					entrada.achados[#entrada.achados + 1] = {
						caminho = caminho, parado = unico1, segurando = melhor
					};
				end
			end
		end
	end

	table.sort(entrada.achados, function(a, b) return a.caminho < b.caminho; end);

	--[[
		Cada campo achado vira uma instrucao de escrita. Os caminhos tem a forma
		  Entrada._MkbPlayerInput[0]._Keys[N]._Campo                         (no botao)
		  Entrada._MkbPlayerInput[0]._Keys[N].<LagWorker>k__BackingField[0]._Campo (no buffer)
		N e o numero do comando. Guardamos tudo nas opcoes: e o que a defesa "aperta".
	]]
	local campos = {};
	for _, a in ipairs(entrada.achados) do
		local n, resto = string.match(a.caminho, "_Keys%[(%d+)%]%.(.+)$");
		if n ~= nil then
			local no_buffer = string.find(resto, "LagWorker", 1, true) ~= nil;
			local campo = string.match(resto, "([%w_]+)$");
			local valor = a.segurando;
			if valor == "true" then valor = true; elseif valor == "false" then valor = false; else valor = tonumber(valor); end
			if campo ~= nil and valor ~= nil then
				campos[#campos + 1] = { t = tonumber(n), l = no_buffer, c = campo, v = valor };
			end
		end
	end

	local indices = comandos_de(campos);
	if #campos > 0 then
		op.campos[entrada.alvo] = campos;
		op.botoes[entrada.alvo] = indices;
		json.dump_file("aviso_lanca_opcoes.json", op);
	end

	local lista = {};
	for _, a in ipairs(entrada.achados) do lista[#lista + 1] = a.caminho .. " : " .. a.parado .. " -> " .. a.segurando; end
	json.dump_file("aviso_lanca_botao_" .. entrada.alvo .. ".json",
		{ comandos = indices, achados = lista, valores_por_foto = entrada.nos_ultima_foto });
end

local function atualizar_captura()
	local momento = agora();
	entrada.forcando = momento >= entrada.forcar_de and momento < entrada.forcar_ate;

	if entrada.fase == "esperando" and momento >= entrada.fase_ate then
		entrada.fase = "capturando";
		entrada.fase_ate = momento + 3;
	elseif entrada.fase == "capturando" then
		-- foto deste quadro: conta quantas vezes cada valor apareceu em cada campo
		local foto = tirar_foto();
		local destino = entrada.valores[entrada.captura_numero];
		for caminho, valor in pairs(foto.valores) do
			local chave = tostring(valor);
			destino[caminho] = destino[caminho] or {};
			destino[caminho][chave] = (destino[caminho][chave] or 0) + 1;
		end

		-- esquiva (toque): guarda, quadro a quadro, so o que esta diferente do "parado"
		if entrada.captura_numero == 2 and alvo_de_toque(entrada.alvo) and entrada.base ~= nil then
			local diferentes = {};
			for caminho, valor in pairs(foto.valores) do
				local base = entrada.base[caminho];
				if base ~= nil and tostring(valor) ~= base and string.find(caminho, "_Keys[", 1, true) then
					diferentes[caminho] = tostring(valor);
				end
			end
			entrada.quadros[#entrada.quadros + 1] = diferentes;
		end

		if momento >= entrada.fase_ate then
			entrada.fase = "parado";
			if entrada.captura_numero == 2 and alvo_de_toque(entrada.alvo) then
				pcall(calcular_toque);
			end
			if entrada.captura_numero == 2 then
				pcall(calcular_achados);

				-- libera a memoria das capturas (milhares de valores) e avisa que os campos
				-- mudaram, para a escrita rapida refazer a lista de posicoes
				entrada.capturou_2 = true;
				entrada.valores = { {}, {} };
				entrada.onde = {};
				entrada.campos_mudaram = true;
				collectgarbage("collect");
			end
			estado.mensagem = string.format("Captura %d terminada (%d valores por foto).",
				entrada.captura_numero, entrada.nos_ultima_foto);
		end
	end
end

--[[
	"APERTAR" BOTOES
	Cada botao do jogo vira um objeto em "_Keys[N]" (N = numero do comando), dentro da
	entrada de mouse/teclado e da entrada de controle. Para "apertar" uma acao, o mod
	escreve exatamente os valores que o jogo tinha quando VOCE apertou de verdade (vieram
	das capturas): o estado do botao e o buffer de entrada (LagWorker), que e onde o jogo
	anota "acabou de ser apertado". A versao 0.8 nao escrevia o buffer, por isso a guarda
	so funcionava junto com o seu M5 e a esquiva nao funcionava.

	"teclas_agora" diz quais acoes ("guarda", "especial", "esquiva") estao apertadas
	neste quadro. Quem decide e o planejador da defesa (mais abaixo) ou o botao de teste.
	A escrita vai POR CIMA da sua entrada: voce pode continuar atacando normalmente.

	Versao 0.11 (contra o travamento):
	  - escreve SO na entrada de mouse/teclado (opcao no menu para incluir o controle).
	    Escrever no controle pode fazer o jogo trocar a interface para "modo controle" e
	    voltar logo depois, o que costuma travar;
	  - os objetos dos botoes sao achados UMA vez por quadro ("preparar_escrita"); os
	    ganchos so repetem os valores, sem procurar nada;
]]
local teclas_agora = {};
local escrita = {};       -- preparada a cada quadro: lista de { objeto, campo, valor }

-- comandos de uma lista de campos, como conjunto
local function conjunto_de_comandos(lista)
	local c = {};
	for _, item in ipairs(lista or {}) do c[item.t] = true; end
	return c;
end

-- campos que cada acao escreve
--[[
	(0.42) GRAVACOES. As gravacoes dos seus apertos (M5, M2, Espaco) mostram que um aperto
	de verdade e: 1 quadro com "acabou de apertar" e, depois, ~0,6s de BUFFER (o jogo guarda o
	aperto e executa assim que der - por exemplo no fim de um ataque). O mod apertava o
	Foresight por 4 quadros e o Espaco sem o buffer: no meio de um ataque seu o jogo ignorava.
	"esquivab" e a gravacao do Espaco escrita COM o buffer (usada na espada longa).
]]
local function gravacao(nome)
	if nome == "esquivab" then nome = "esquiva"; end
	return op.toques[nome or "esquiva"] or {};
end

--[[
	(0.48) GRUPOS DE BOTOES (comandos tirados das suas gravacoes):
	  M1 = 12, 21, 46, 50, 55   M2 = 13, 36, 43   M5 = 15, 22   Espaco = 24, 25, 32, 42, 51
	(o 42 aparece no M1 e no Espaco; fica so no grupo do Espaco)
]]
local GRUPOS_DE_BOTOES = {
	m1 = { 12, 21, 46, 50, 55 },
	m2_m5 = { 13, 36, 43, 15, 22 },
	m2 = { 13, 36, 43 }, -- (0.59) separados: o SS escreve o M5 e precisa soltar o seu M2
	m5 = { 15, 22 },
	espaco = { 24, 25, 32, 42, 51 }
};

local function campos_da_acao(acao)
	if acao == "guarda" then
		return op.campos.guarda or {};

	elseif acao == "especial" then
		-- o "especial" (M2) e o que a captura do contra-ataque (M5 + M2) tem a mais que a guarda
		local da_guarda = conjunto_de_comandos(op.campos.guarda);
		local lista = {};
		for _, item in ipairs(op.campos.contra_ataque or {}) do
			if not da_guarda[item.t] then lista[#lista + 1] = item; end
		end
		return lista;

	elseif string.sub(acao, 1, 6) == "toque:" then
		-- um quadro de um toque gravado ("toque:esquiva:12" ou "toque:m5:3")
		local nome, quadro = string.match(acao, "^toque:([%w_]+):(%d+)$");
		return gravacao(nome)[tonumber(quadro or 0)] or {};

	elseif string.sub(acao, 1, 9) == "bloquear:" then
		-- (0.48) BOTAO SOLTO: escreve "nao apertado" nos comandos de um grupo de botoes, por cima
		-- do que voce estiver apertando (usado na prioridade do Foresight)
		local lista = {};
		local grupo_b = GRUPOS_DE_BOTOES[string.sub(acao, 10)];
		if string.sub(acao, 10) == "extra" then
			grupo_b = {};
			for numero in pairs(op.comandos_ataque_extra or {}) do grupo_b[#grupo_b + 1] = tonumber(numero); end
		end
		for _, n in ipairs(grupo_b or {}) do
			lista[#lista + 1] = { t = n, l = false, c = "_On", v = false };
			lista[#lista + 1] = { t = n, l = false, c = "_RawOn", v = false };
			lista[#lista + 1] = { t = n, l = false, c = "_OnTrigger", v = false };
			lista[#lista + 1] = { t = n, l = false, c = "_Repeat", v = false };
			lista[#lista + 1] = { t = n, l = false, c = "_Success", v = false };
			lista[#lista + 1] = { t = n, l = false, c = "_AnalogValue", v = 0.0 };
			--[[
				(0.66) BUFFER: um aperto seu fica guardado no buffer do jogo (~0,6s) e sai quando o
				golpe atual deixa - mesmo com o botao ja solto. Spamando, o seu ultimo ataque saia no
				lugar do SS. As suas capturas mostram o buffer PARADO (sem aperto guardado) como
				_LagFrameCounter = 0 e _LagTimer = 0.0 (com aperto: -1 e um tempo negativo); o mod
				escreve o parado. O _LastRawTriggerIndex continua de fora (suspeito do travamento da 0.17).
			]]
			lista[#lista + 1] = { t = n, l = true, c = "_LagFrameCounter", v = 0 };
			lista[#lista + 1] = { t = n, l = true, c = "_LagTimer", v = 0.0 };
		end
		return lista;

	elseif acao == "espaco" and #(op.espaco_segurado or {}) > 0 then
		-- Espaco segurado (Power Guard): o quadro com mais mudancas do toque gravado
		return op.espaco_segurado;

	elseif acao == "esquiva" or acao == "espaco" then
		-- a captura da esquiva so pegou o buffer; somamos o aperto completo do botao
		local lista = {};
		for _, item in ipairs(op.campos.esquiva or {}) do lista[#lista + 1] = item; end
		for n in pairs(conjunto_de_comandos(op.campos.esquiva)) do
			lista[#lista + 1] = { t = n, l = false, c = "_On", v = true };
			lista[#lista + 1] = { t = n, l = false, c = "_RawOn", v = true };
			lista[#lista + 1] = { t = n, l = false, c = "_AnalogValue", v = 1.0 };
		end
		return lista;
	end

	return op.campos[acao] or {};
end

--[[
	ESCRITA SEGURA (versao 0.15)

	Historico:
	  - 0.7 a 0.11: escrita pelo nome do campo ("set_field"), feita dentro de ganchos em
	    onApplyFromMouseKeyboard/onApplyFromPad. Funcionava, mas TRAVAVA;
	  - 0.12 a 0.14: escrita direta na memoria. O jogo FECHOU: o log mostrou o erro dentro
	    de app.PressController, que processa os botoes em VARIAS linhas de execucao ao mesmo
	    tempo ("executeParallel"). Escrever ali sem protecao, enquanto o jogo le, derruba.

	A causa mais provavel do travamento: aqueles ganchos rodam DENTRO do processamento
	paralelo dos botoes. Cada vez que um gancho do Lua roda numa dessas linhas, ela espera
	o Lua ficar livre, e o jogo todo espera junto.

	Agora:
	  - escrita segura do REFramework (pelo campo ja encontrado, sem buscar pelo nome toda
	    vez e sem escrever direto na memoria);
	  - SO na linha principal do jogo: logo depois de ler mouse/teclado ("UpdateHID") e antes
	    de os personagens agirem ("UpdateBehavior");
	  - os ganchos dentro do processamento paralelo ficam DESLIGADOS. Ha uma opcao no menu
	    para religar (precisa reiniciar os scripts), caso a guarda nao funcione sem eles.
]]
local cache_escrita = { chave_entrada = nil, conferido_em = 0, acoes = {} };

-- acha o campo (procurando tambem nas classes-mae)
local function campo_do_objeto(objeto, nome)
	local tipo = objeto:get_type_definition();
	while tipo ~= nil do
		local campo = tipo:get_field(nome);
		if campo ~= nil then return campo; end
		tipo = tipo:get_parent_type();
	end
	return nil;
end

-- objeto de entrada do mouse/teclado
local function entradas_ativas()
	local gerente = sdk.get_managed_singleton("app.GameInputManager");
	if gerente == nil then return {}; end

	local nomes = { "_MkbPlayerInput" };

	local lista_entradas = {};
	for _, nome in ipairs(nomes) do
		local ok, entrada_jogador = pcall(function()
			local lista = gerente:get_field(nome);
			return lista and lista:get_element(0);
		end);
		if ok and entrada_jogador ~= nil then lista_entradas[#lista_entradas + 1] = entrada_jogador; end
	end
	return lista_entradas;
end

-- monta (uma vez) a lista de escritas de uma acao: { objeto, campo, nome do campo, valor }
local function montar_escritas(acao, lista_entradas)
	local escritas = {};
	for _, entrada_jogador in ipairs(lista_entradas) do
		pcall(function()
			local teclas = entrada_jogador:get_field("_Keys");
			if teclas == nil then return; end

			-- MODO SEGURO do Espaco (versao 0.18): o teste do Power Guard da 0.17 fechou o jogo
			-- dentro da interface (GUIBase.update). Suspeita: "_LastRawTriggerIndex" e um
			-- INDICE para uma lista ligada a tecla fisica; fingindo o aperto, ele aponta para
			-- uma lista vazia e a interface le fora dela. Nas acoes do Espaco (esquiva, Espaco
			-- do Power Guard e o toque gravado) o mod nao escreve esse indice nem o buffer.
			-- (0.36) o toque gravado do M5 (Iai) precisa do buffer: so o toque do Espaco e seguro
			local modo_seguro = (acao == "esquiva" or acao == "espaco" or string.sub(acao, 1, 14) == "toque:esquiva:");

			for _, item in ipairs(campos_da_acao(acao)) do
				local pular = modo_seguro and (item.l or item.c == "_LastRawTriggerIndex");
				-- (0.42) Espaco da espada longa: escreve o buffer; so o indice (suspeito do
				-- travamento da 0.17) continua de fora
				if string.sub(acao, 1, 15) == "toque:esquivab:" and item.c == "_LastRawTriggerIndex" then pular = true; end
				if not pular then

				local alvo = teclas:get_element(item.t);
				if alvo ~= nil and item.l then
					--[[
						(0.67) BUFFER: guarda a TECLA (fixa) e acha o buffer dela na hora de escrever.
						Antes o objeto do buffer ficava guardado; se o jogo o trocasse (fim da luta,
						corte de camera), o mod escrevia num objeto que nao existia mais.
					]]
					local buffer = alvo:get_field("<LagWorker>k__BackingField");
					local amostra = buffer and buffer:get_element(0);
					local campo = amostra and campo_do_objeto(amostra, item.c);
					if campo ~= nil then escritas[#escritas + 1] = { alvo, campo, item.c, item.v, true }; end
				elseif alvo ~= nil then
					local campo = campo_do_objeto(alvo, item.c);
					if campo ~= nil then escritas[#escritas + 1] = { alvo, campo, item.c, item.v }; end
				end

				end
			end
		end);
	end
	return escritas;
end

-- confere (no maximo a cada meio segundo) se o objeto de entrada ainda e o mesmo
local function conferir_cache()
	local momento = os.clock();
	if momento - cache_escrita.conferido_em < 0.5 and cache_escrita.chave_entrada ~= nil then return; end
	cache_escrita.conferido_em = momento;

	local lista_entradas = entradas_ativas();
	local chave = "mkb";
	for _, e in ipairs(lista_entradas) do
		local ok, endereco = pcall(e.get_address, e);
		chave = chave .. ":" .. tostring(ok and endereco or "?");
	end

	if chave ~= cache_escrita.chave_entrada then
		cache_escrita.chave_entrada = chave;
		cache_escrita.acoes = {};
		cache_escrita.entradas = lista_entradas;
	end
end

-- escolhe as escritas deste quadro (chamado uma vez por quadro)
local function preparar_escrita()
	escrita = {};

	-- campos aprendidos de novo: refaz a lista
	if entrada.campos_mudaram then
		entrada.campos_mudaram = false;
		cache_escrita.acoes = {};
	end

	if next(teclas_agora) == nil then return; end

	conferir_cache();
	for acao in pairs(teclas_agora) do
		local lista = cache_escrita.acoes[acao];
		if lista == nil then
			lista = montar_escritas(acao, cache_escrita.entradas or {});
			cache_escrita.acoes[acao] = lista;
		end
		for i = 1, #lista do escrita[#escrita + 1] = lista[i]; end
	end
end

-- escreve os valores (chamado na linha principal do jogo, 2 vezes por quadro)
local function apertar_teclas()
	if #escrita == 0 then return; end

	for i = 1, #escrita do
		local e = escrita[i];
		if e[5] then
			-- (0.67) buffer: achado agora (o objeto pode ter sido trocado pelo jogo)
			pcall(function()
				local buffer = e[1]:get_field("<LagWorker>k__BackingField");
				local alvo = buffer and buffer:get_element(0);
				if alvo ~= nil then
					local ok = pcall(e[2].set_data, e[2], alvo, e[4]);
					if not ok then alvo:set_field(e[3], e[4]); end
				end
			end);
		else
			local ok = pcall(e[2].set_data, e[2], e[1], e[4]);
			if not ok then pcall(e[1].set_field, e[1], e[3], e[4]); end
		end
	end
end

-- Liga os pontos onde a escrita acontece (chamado no INICIO, depois de ler as opcoes)
local pontos_de_escrita = {};

local function ligar_pontos_de_escrita()
	--[[
		Versao 0.16: na 0.15 o mod escrevia em "UpdateHID" e antes de "UpdateBehavior", mas
		o jogo recalculava os botoes a partir do mouse DEPOIS disso e apagava a escrita
		(nao travava, mas nao fazia nada).

		O GameInputManager atualiza a entrada do jogador em "updatePlayerInput", uma vez por
		quadro, na linha principal (ele e um componente normal do jogo). Escrevendo logo
		DEPOIS dessa funcao, o mod fica depois da leitura do mouse e antes de o cacador
		agir, sem entrar no processamento paralelo. "update" fica como reserva.
	]]
	local gerente_tipo = sdk.find_type_definition("app.GameInputManager");
	for _, nome_funcao in ipairs({ "updatePlayerInput", "update" }) do
		local funcao = gerente_tipo and gerente_tipo:get_method(nome_funcao);
		if funcao ~= nil and pcall(sdk.hook, funcao, nil, function(retorno)
			apertar_teclas();
			return retorno;
		end) then
			pontos_de_escrita[#pontos_de_escrita + 1] = "depois de GameInputManager." .. nome_funcao;
		end
	end

end


-- mensagem grande no meio da tela durante a captura e o teste
local function desenhar_status_entrada()
	local texto = nil;
	local momento = agora();
	local acao = "FIQUE PARADO (sem apertar nada)";
	if entrada.captura_numero == 2 then
		if entrada.alvo == "esquiva" then acao = "APERTE E SOLTE O ESPACO UMA VEZ";
		elseif ALVO_TOQUE[entrada.alvo] then acao = "APERTE E SOLTE O " .. string.upper(ALVO_TOQUE[entrada.alvo]) .. " UMA VEZ";
		else acao = "SEGURE " .. NOME_DO_ALVO[entrada.alvo]; end
	end

	if entrada.fase == "esperando" then
		texto = string.format("Prepare-se: %s em %.0f...", acao, math.max(0, entrada.fase_ate - momento));
	elseif entrada.fase == "capturando" then
		texto = string.format("CAPTURANDO: %s (%.1fs)", acao, math.max(0, entrada.fase_ate - momento));
	elseif entrada.forcando then
		texto = string.format("TESTE: o mod esta apertando %s (%.1fs)", NOME_DO_ALVO[entrada.alvo], entrada.forcar_ate - momento);
	elseif momento < entrada.forcar_de then
		texto = string.format("Feche o menu: o teste de %s comeca em %.0f...", NOME_DO_ALVO[entrada.alvo], entrada.forcar_de - momento);
	end

	if texto ~= nil then
		local largura, altura = tamanho_tela();
		draw.text(texto, largura / 2 - 150 + 1, altura * 0.3 + 1, 0xFF000000);
		draw.text(texto, largura / 2 - 150, altura * 0.3, 0xFF00FFFF);
	end
end

--[[
	CONTAGEM DE DEFESAS
	Ganchos em 4 funcoes da lanca, que o jogo chama quando cada defesa da certo:
	  - callJustGuardSuccessEffect: GUARDA PERFEITA ("Just Guard");
	  - callGuardSuccessEffect: guarda normal;
	  - callPowerGuardEffect: Power Guard;
	  - onParrySuccess: contra-ataque.
	IMPORTANTE: os ganchos sao ligados AGORA, quando o mod carrega (antes de entrar no
	save). Ate a versao 0.9 eles eram ligados com o jogo rodando, em 14 funcoes, e isso
	fez o jogo fechar ao entrar no save.
]]
estado.defesas.contra = 0;

local ultima_chamada_defesa = {};

--[[
	PERFIS DE ARMA (versao 0.24)

	O mod tem duas partes:
	  - NUCLEO, igual para todas as armas: previsao dos golpes, aprendizado dos monstros,
	    escrita de botoes, toque gravado, aviso na tela e aba Prints. O conhecimento dos
	    golpes e por MONSTRO e vale para qualquer arma;
	  - PERFIL DE ARMA, um para cada arma: a classe da arma no jogo, as defesas que ela tem
	    (na ordem de prioridade), quais so protegem de frente, qual defesa usar nos golpes
	    fortes/de lado e nas sequencias, os tempos de cada defesa, os eventos do jogo que
	    confirmam cada defesa e como executar cada uma (definido mais abaixo, em "executar").

	Para criar o perfil de uma arma nova, basta adicionar outra entrada aqui.
]]
local NOME_ACAO = {
	contra_ataque = "contra-ataque", guarda = "guarda", power_guard = "Power Guard", esquiva = "esquiva",
	foresight = "Foresight Slash", ss_iss = "SS+ISS"
};

local PERFIS = {
	lanca = {
		nome = "Lanca",
		classe = "app.cHunterWp06Handling",

		-- defesas na ordem de prioridade
		niveis = { "contra_ataque", "guarda", "power_guard", "esquiva" },

		-- defesas que so protegem de frente
		so_de_frente = { contra_ataque = true, guarda = true },
		tempos_extras = {
			{ opcao = "ponte_guarda_ms", nome = "Golpes seguidos: manter a guarda se o proximo vier em ate (ms)", maximo = 2000 },
			{ opcao = "manter_apos_golpe_ms", nome = "Golpes seguidos: manter a guarda depois de cada golpe (ms)", maximo = 2000 }
		},

		-- (0.31) com Guard Up o aprendizado para no Power Guard (nunca vira esquiva)
		teto_com_guard_up = 3,

		-- defesa para golpes impossiveis de guardar, que exigem guarda forte ou que vem de lado
		forte = "power_guard",

		-- defesa para sequencias de golpes (segurada do primeiro ao ultimo)
		sequencia = "power_guard",

		-- opcao (em "op") com quantos ms antes do impacto cada defesa comeca
		antecedencia = {
			contra_ataque = "antecedencia_contra_ms", guarda = "antecedencia_guarda_ms",
			power_guard = "antecedencia_power_ms", esquiva = "antecedencia_esquiva_ms"
		},

		-- opcao (em "op") que liga/desliga cada defesa (as que nao estao aqui estao sempre ligadas)
		desligavel = { power_guard = "usar_power_guard", esquiva = "esquivar" },

		-- funcoes do jogo chamadas quando cada defesa da certo
		eventos = {
			{ classe = "app.cHunterWp06Handling", funcao = "callJustGuardSuccessEffect", conta = "perfeita" },
			{ classe = "app.cHunterWp06Handling", funcao = "callGuardSuccessEffect", conta = "normal" },
			{ classe = "app.cHunterWp06Handling", funcao = "callPowerGuardEffect", conta = "power" },
			{ classe = "app.cHunterWeaponHandlingBase", funcao = "onParrySuccess", conta = "contra" }
		}
	},

	--[[
		ARMAS SO COM ESQUIVA (versao 0.27). A esquiva usa o toque gravado do Espaco, que e
		o mesmo para todas as armas. Muda so o tempo ideal (invencibilidade de cada arma).
		Armas sem evento proprio de sucesso: o mod considera que a defesa FALHOU quando o
		cacador entra numa animacao de levar dano (banco 14) logo depois do impacto.
	]]
	dual = {
		nome = "Dual Blades",
		classe = "app.cHunterWp02Handling",
		niveis = { "esquiva" },
		so_de_frente = {},
		antecedencia = { esquiva = "esquiva_ms_dual" },
		confere_por_dano = true, -- sucesso = nao levou dano (veja conferir_defesas)
		desligavel = {},
		-- esquiva perfeita das Dual Blades ("Mikiri")
		eventos = {
			{ classe = "app.cHunterWp02Handling", funcao = "doMikiriSuccess", conta = "esquiva_perfeita" }
		}
	},

	bowgun_leve = {
		nome = "Light Bowgun",
		classe = "app.cHunterWp13Handling",
		niveis = { "esquiva" },
		so_de_frente = {},
		antecedencia = { esquiva = "esquiva_ms_bowgun_leve" },
		confere_por_dano = true, -- sucesso = nao levou dano (veja conferir_defesas)
		desligavel = {},
		eventos = {}
	},

	berrante = {
		nome = "Hunting Horn",
		classe = "app.cHunterWp05Handling",
		niveis = { "esquiva" },
		so_de_frente = {},
		antecedencia = { esquiva = "esquiva_ms_berrante" },
		confere_por_dano = true, -- sucesso = nao levou dano (veja conferir_defesas)
		desligavel = {},
		eventos = {}
	},

	-- Espada e Escudo: guarda (so de frente) e esquiva. A guarda usa os mesmos comandos da
	-- guarda da lanca (M5); se nao funcionar, e so ensinar a guarda com a espada sacada.
	espada_escudo = {
		nome = "Sword and Shield",
		classe = "app.cHunterWp01Handling",
		niveis = { "guarda", "esquiva" },
		so_de_frente = { guarda = true },
		forte = "esquiva",
		tempos_extras = {
			{ opcao = "ponte_guarda_ms", nome = "Golpes seguidos: manter a guarda se o proximo vier em ate (ms)", maximo = 2000 },
			{ opcao = "manter_apos_golpe_ms", nome = "Golpes seguidos: manter a guarda depois de cada golpe (ms)", maximo = 2000 }
		},
		-- (0.31) com Guard Up a frente e sempre guarda (a esquiva fica para os golpes de lado)
		teto_com_guard_up = 1,
		antecedencia = { guarda = "antecedencia_guarda_ms", esquiva = "esquiva_ms_espada_escudo" },
		confere_por_dano = true, -- sucesso = nao levou dano (veja conferir_defesas)
		desligavel = { esquiva = "esquivar" },
		eventos = {}
	},

	--[[
		ESPADA LONGA (0.29):
		  1. Foresight Slash (M5 + M2 juntos);
		  2. Special Sheathe (M5 + Espaco juntos) e depois Iai Spirit Slash (M5);
		  3. esquiva normal.
		Os dois primeiros so existem logo depois de um golpe da espada (no meio do combo).
		Se na hora voce nao estiver num combo, o mod esquiva no lugar.
	]]
	espada_longa = {
		nome = "Long Sword",
		classe = "app.cHunterWp03Handling",
		--[[
			(0.41) como voce pediu: 1. Foresight Slash   2. esquiva (quando o Foresight nao
			serve: fora do combo ou sem tempo). O Special Sheathe + Iai foi DESATIVADO (o codigo
			dele continua no arquivo, mas a espada longa nao usa mais).
		]]
		niveis = { "foresight", "esquiva" },
		toque_esquiva = "esquivab", -- (0.42) esquiva com o buffer (sai no fim do seu ataque)
		so_de_frente = {},
		antecedencia = { foresight = "ls_foresight_ms", esquiva = "esquiva_ms_espada_longa" },
		rotulo_tempo = {
			foresight = "Foresight Slash: M5 + M2 quantos ms antes do golpe"
		},
		tempos_extras = {
			{ opcao = "ls_iss_ms", nome = "SS+ISS: ISS (M5) quantos ms antes do golpe", maximo = 400 },
			{ opcao = "ls_ss_min_ms", nome = "SS+ISS: SS so se o golpe vier daqui a pelo menos (ms)", maximo = 4000 },
			{ opcao = "ls_ss_max_ms", nome = "SS+ISS: ... e no maximo (ms)", maximo = 5000 },
			{ opcao = "ls_janela_combo_ms", nome = "Combo: Foresight ate quantos ms depois de um golpe seu", maximo = 4000 },
			{ opcao = "ls_bloqueio_ms", nome = "Prioridade do Foresight: bloquear os seus botoes quantos ms antes do golpe", maximo = 1500 }
		},
		-- prioridade fixa: sempre o Foresight; o aprendizado nunca troca para a esquiva
		nivel_maximo_aprendido = 1,
		reserva = {},
		confere_por_dano = true, -- sucesso = nao levou dano
		desligavel = {},
		eventos = {
			{ classe = "app.cHunterWp03Handling", funcao = "doSuccessMikiri", conta = "esquiva_perfeita" }
		}
	}
};

-- todos os eventos de defesa de todos os perfis (sem repetir)
local EVENTOS_DE_DEFESA, eventos_vistos = {}, {};
for _, perfil in pairs(PERFIS) do
	for _, d in ipairs(perfil.eventos) do
		local chave_evento = d.classe .. "." .. d.funcao;
		if not eventos_vistos[chave_evento] then
			eventos_vistos[chave_evento] = true;
			EVENTOS_DE_DEFESA[#EVENTOS_DE_DEFESA + 1] = d;
		end
	end
end

-- perfil da arma que o cacador esta usando (nil se a arma ainda nao tem perfil)
local function perfil_da_arma(cacador)
	local ok, classe = pcall(function()
		return cacador:call("get_WeaponHandling"):get_type_definition():get_full_name();
	end);
	if not ok or classe == nil then return nil, nil, nil; end
	for chave_perfil, perfil in pairs(PERFIS) do
		if perfil.classe == classe then return chave_perfil, perfil, classe; end
	end
	return nil, nil, classe;
end

--[[
	COMBO DA ESPADA LONGA (0.29): o Foresight Slash e o Special Sheathe so existem logo
	depois de um golpe da espada. O mod sabe que voce esta num combo quando:
	  - a sua espada acertou o monstro ha menos de 0,6s; ou
	  - voce esta numa animacao de ataque da espada. Estas animacoes sao aprendidas
	    sozinhas: toda vez que a espada acerta, a animacao daquele momento e anotada.
]]
local combo = { ultimo_acerto = -100, ultimo_ataque_em = -100, animacao = nil };

-- (0.46) comandos que so os botoes de ataque usam (das suas gravacoes): M1 = 12, 21, 46, 50, 55;
-- M2 = 13, 36, 43; M5 = 15, 22. (O 42 tambem e do Espaco, por isso fica de fora.)
local COMANDOS_DE_ATAQUE = { 12, 21, 46, 50, 55, 13, 36, 43, 15, 22 };

local tipo_espada_longa = sdk.find_type_definition("app.cHunterWp03Handling");
local acerto_espada_longa = tipo_espada_longa and tipo_espada_longa:get_method("doOnHit_AttackPre");
if acerto_espada_longa ~= nil then
	pcall(sdk.hook, acerto_espada_longa, function(args)
		pcall(function()
			local cacador = meu_cacador();
			local minha_arma = cacador and cacador:call("get_WeaponHandling");
			if minha_arma == nil then return; end
			if sdk.to_int64(args[2]) ~= minha_arma:get_address() then return; end -- espada de outro jogador
			combo.ultimo_acerto = os.clock();
			if combo.animacao ~= nil and not op.animacoes_ataque_ls[combo.animacao] then
				op.animacoes_ataque_ls[combo.animacao] = true;
				salvar_opcoes();
			end
		end);
	end, function(retorno) return retorno; end);
end

--[[
	(0.33) Voce testou: depois de um golpe, o Foresight e o Special Sheathe podem ser usados
	ate ~2,5 segundos depois. Na 0.32 o mod so considerava "em combo" DURANTE a animacao de
	ataque (ou 0,6s depois de acertar), por isso nunca saiam sozinhos.
	Agora: em combo = o ultimo golpe da espada (animacao de ataque ou acerto) foi ha menos
	de "ls_janela_combo_ms" (2300 ms, um pouco abaixo dos 2,5s por seguranca).
]]
--[[
	(0.60) JANELA DO COMBO APRENDIDA. "Idade do combo" = quanto tempo faz que o seu ultimo golpe
	acabou (0 enquanto voce esta numa animacao de ataque). Cada FS e cada SS que o mod aperta
	vira uma tentativa: idade naquela hora e se saiu (FS: sua animacao virou 20:226 / 20:290;
	SS: a bainha 20:249 comecou). A janela fica no meio entre a MAIOR idade em que saiu e a
	2a MENOR idade (acima dela) em que nao saiu (2, para uma falha por outro motivo nao
	encolher a janela). Sem dados, usa "ls_janela_combo_ms". Fora da janela: esquiva normal.
]]
local function idade_combo()
	if combo.animacao ~= nil and op.animacoes_ataque_ls[combo.animacao] == true then return 0; end
	return math.max(0, os.clock() - math.max(combo.ultimo_acerto, combo.ultimo_ataque_em));
end

local function janela_combo(tipo)
	local lista = janela_combo_dados[tipo or "fs"] or {};
	local saiu = nil;
	for _, t in ipairs(lista) do
		if t[2] == 1 and (saiu == nil or t[1] > saiu) then saiu = t[1]; end
	end
	local falhas = {};
	for _, t in ipairs(lista) do
		if t[2] == 0 and t[1] > (saiu or 0) then falhas[#falhas + 1] = t[1]; end
	end
	table.sort(falhas);
	local falhou = falhas[2];
	local padrao = op.ls_janela_combo_ms / 1000;
	if saiu ~= nil and falhou ~= nil then return (saiu + falhou) / 2, saiu, falhou, #lista; end
	if falhou ~= nil then return math.min(padrao, falhou), saiu, falhou, #lista; end
	if saiu ~= nil then return math.max(padrao, saiu + 0.1), saiu, falhou, #lista; end
	return padrao, saiu, falhou, #lista;
end

local function anotar_janela(tipo, idade, saiu)
	if idade == nil then return; end
	local lista = janela_combo_dados[tipo];
	lista[#lista + 1] = { math.floor(idade * 1000 + 0.5) / 1000, saiu and 1 or 0 };
	while #lista > 40 do table.remove(lista, 1); end
	estado.bloqueio_mudou = true; -- salva junto com as defesas
end

-- FS apertado agora: confere nos proximos 0,5s se saiu
local tentativas_fs = {};
local function registrar_fs()
	tentativas_fs[#tentativas_fs + 1] = { idade = idade_combo(), em = os.clock(), dano_antes = estado.levou_dano_em };
end

local function em_combo_espada_longa(tipo)
	return idade_combo() < janela_combo(tipo or "fs");
end

for _, d in ipairs(EVENTOS_DE_DEFESA) do
	local tipo = sdk.find_type_definition(d.classe);
	local funcao = tipo and tipo:get_method(d.funcao);
	if funcao ~= nil then
		local ok = pcall(sdk.hook, funcao, function(args)
			-- (0.58) FS da Long Sword deu certo: aprende o tempo do golpe (so a SUA espada)
			-- (so na primeira chamada: o jogo repete esta funcao enquanto o efeito dura)
			if d.funcao == "doSuccessMikiri" and os.clock() - (ultima_chamada_defesa[d.conta] or -10) >= 0.5 then
				pcall(function()
					local cacador = meu_cacador();
					local minha_arma = cacador and cacador:call("get_WeaponHandling");
					if minha_arma ~= nil and sdk.to_int64(args[2]) == minha_arma:get_address() then
						estado.fs_certo_em = os.clock();
					end
				end);
			end
			-- algumas destas funcoes sao chamadas a cada quadro enquanto o efeito dura (o Power
			-- Guard chegou a 9 mil). So conta quando passou meio segundo desde a ultima chamada.
			local agora_lua = os.clock();
			estado.ultimo_sucesso_defesa = agora_lua; -- usado na conferencia das defesas
			local ultima = ultima_chamada_defesa[d.conta] or -10;
			ultima_chamada_defesa[d.conta] = agora_lua;
			if agora_lua - ultima < 0.5 then return; end
			estado.defesas[d.conta] = (estado.defesas[d.conta] or 0) + 1;
		end, function(retorno) return retorno; end);
		if ok then pesquisa.arma_ganchos[#pesquisa.arma_ganchos + 1] = d.classe .. "." .. d.funcao; end
	end
end


-- =====================================================================================
-- DEFESA AUTOMATICA
-- A cada quadro decide quais botoes apertar, olhando os impactos previstos:
--   - golpe guardavel (tipo 0 ou 1): segura a GUARDA de um pouco antes ate um pouco depois;
--   - golpe so com Power Guard (tipo 3): POWER GUARD, se aprendido (senao, guarda normal);
--   - golpe impossivel de guardar (tipo 2): toque rapido na ESQUIVA, se aprendida.
-- So age com a lanca sacada e, por padrao, so quando voce esta sozinho na cacada.
-- =====================================================================================

local contagem_jogadores = { valor = 1, lida_em = -10 };

-- quantos jogadores estao na cacada (lido a cada 2 segundos)
local function jogadores_na_cacada()
	local momento = agora();
	if momento - contagem_jogadores.lida_em < 2 then return contagem_jogadores.valor; end
	contagem_jogadores.lida_em = momento;

	local total = 0;
	pcall(function()
		local gerente = sdk.get_managed_singleton("app.PlayerManager");
		local lista = gerente and gerente:get_field("_PlayerList");
		if lista == nil then return; end

		local ok_t, tamanho = pcall(function() return lista:get_size(); end);
		if not ok_t or type(tamanho) ~= "number" then tamanho = lista:call("get_Count"); end

		for i = 0, (tamanho or 0) - 1 do
			local ok_i, item = pcall(lista.get_element, lista, i);
			if not ok_i or item == nil then item = lista:call("get_Item", i); end
			local info = item and item:get_field("_PlayerInfo");
			if info and info:get_field("<Character>k__BackingField") ~= nil then total = total + 1; end
		end
	end);

	contagem_jogadores.valor = math.max(total, 1);
	return contagem_jogadores.valor;
end

-- pode agir agora? (devolve verdadeiro/falso e o motivo quando nao pode)
local function pode_defender()
	local cacador = meu_cacador();
	if cacador == nil then return false, "sem cacador"; end

	local chave_perfil, perfil, classe = perfil_da_arma(cacador);
	estado.perfil, estado.chave_perfil = perfil, chave_perfil;
	if perfil == nil then
		-- (0.79) armas so com a defesa na hora do golpe
		local ok_t, tipo = pcall(function() return cacador:call("get_WeaponType"); end);
		local def = ok_t and n78.ARMAS and n78.ARMAS[tonumber(tipo) or -1] or nil;
		if def ~= nil then return false, "so defesa na hora do golpe (" .. def.nome .. ")"; end
		return false, "arma sem perfil ainda (" .. tostring(classe) .. ")";
	end

	if cacador:call("get_IsWeaponOn") ~= true then return false, string.lower(perfil.nome) .. " guardada"; end

	return true, "";
end

local function marcar(acao)
	if #campos_da_acao(acao) > 0 then teclas_agora[acao] = true; end
end

--[[
	CONTRA-ATAQUE = M5 e depois M2: guarda desde o inicio e, de 0,05s a 0,15s depois,
	um toque no especial. (Apertar os dois juntos e segurar so faz a guarda.)
]]
local function marcar_contra_ataque(desde_inicio)
	marcar("guarda");
	if desde_inicio >= 0.05 and desde_inicio < 0.15 then marcar("especial"); end
end

--[[
	TOQUE GRAVADO: reproduz a gravacao do Espaco quadro a quadro.
	  - exclusivo (esquiva): nada mais e apertado enquanto toca;
	  - junto (Power Guard): toca por cima da guarda + especial que estao segurados.
]]
local toque = { quadro = nil, exclusivo = true, nome = "esquiva" };

-- (0.34) "nome": qual gravacao tocar ("esquiva" = Espaco, padrao; "m5" = M5 do Iai)
local function comecar_toque(exclusivo, nome)
	nome = nome or "esquiva";
	if toque.quadro == nil and #gravacao(nome) > 0 then
		toque.quadro = 1;
		toque.exclusivo = exclusivo;
		toque.nome = nome;
		return true;
	end
	return false;
end

--[[
	POWER GUARD (versao 0.21, como voce explicou): segurar os TRES, sem soltar.
	  1. M5 (guarda) segurado desde o inicio;
	  2. M2 segurado a partir de 0,05s;
	  3. Espaco a partir de "pg_espaco_ms" (padrao 350 ms), depois de a postura do M2 se
	     formar: toque gravado no aperto e, em seguida, Espaco SEGURADO;
	  4. os tres continuam segurados ate o fim (soltar qualquer um sai do Power Guard).
	Na 0.19 o Espaco vinha so 0,05s depois do M2 (antes da postura) e virava esquiva; na
	0.20 o M2 e o Espaco eram soltos.
	"estado_pg" guarda, para cada golpe, se o toque ja foi feito.
]]
local function marcar_power_guard(desde_inicio, estado_pg)
	marcar("guarda");
	if desde_inicio >= 0.05 then marcar("especial"); end

	if desde_inicio >= op.pg_espaco_ms / 1000 then
		if not estado_pg.tocou then
			estado_pg.tocou = true;
			comecar_toque(false);
		end
		-- depois do toque (ou sem toque gravado), o Espaco fica segurado
		if toque.quadro == nil then marcar("espaco"); end
	end
end

--[[
	PRIORIDADE DAS DEFESAS (como voce pediu):
	  1. contra-ataque   2. guarda (perfeita ou normal)   3. Power Guard   4. esquiva

	Por onde comecar em cada golpe:
	  - golpe impossivel de guardar (tipo 2) ou que exige guarda forte (tipo 3): Power Guard;
	  - golpe vindo de LADO ou de TRAS (o cacador nao esta virado para o monstro): a guarda e
	    o contra-ataque da lanca so protegem de frente, entao comeca no Power Guard (360
	    graus). Golpes que podem ser guardados de qualquer direcao (tipo 1) nao contam;
	  - o resto: contra-ataque (ou guarda, se voce escolheu "so a guarda").

	APRENDIZADO: depois de cada golpe que chega em voce, o mod confere se o jogo confirmou a
	defesa (guarda perfeita, guarda, contra-ataque ou Power Guard). Se nao confirmou, aquele
	golpe sobe um nivel e, da proxima vez, ja comeca no nivel de cima. Fica salvo em
	aviso_lanca_defesas.json.
]]
-- Como a lanca executa cada defesa ("desde" = segundos desde o inicio da defesa; "p" = o golpe)
PERFIS.espada_escudo.executar = {
	guarda = function(desde, p) marcar("guarda"); end
};
PERFIS.dual.executar = {};
PERFIS.bowgun_leve.executar = {};
PERFIS.berrante.executar = {};
--[[
	ESPADA LONGA - Foresight Slash: M5 + M2 juntos (toques gravados, com o buffer).
	Devolve "indisponivel" (e o mod esquiva) quando:
	  - voce nao esta num combo (o Foresight so aparece depois de um golpe da espada);
	  - o golpe foi previsto tarde demais para comecar a tempo.
]]
PERFIS.espada_longa.executar = {
	foresight = function(desde, p)
		if not p.teste and not p.estado_pg.conferiu then
			p.estado_pg.conferiu = true;
			-- (0.69) ja no meio de um FS (golpe anterior da sequencia): outro FS nao sai
			if ANIM_FS[combo.animacao or "?"] then
				if p.diag ~= nil then p.diag.resultado = "FS ja em andamento"; end
				p.estado_pg.ignorar = true;
				p.sem_combo = true; -- nao conta como falha do FS
			end
			if desde >= 0.1 then return "indisponivel", "sem tempo"; end
			if not em_combo_espada_longa() then return "indisponivel", "fora do combo"; end
		end
		--[[
			(0.42) Com os toques gravados do M5 e do M2: os dois no MESMO quadro, como voce
			aperta (1 quadro + buffer). O jogo guarda o aperto e solta o Foresight assim que o
			seu ataque deixar. Sem as gravacoes, usa o jeito antigo (abaixo).
		]]
		local e = p.estado_pg;
		if e.ignorar then return; end
		local m5, m2 = op.toques.m5 or {}, op.toques.m2 or {};
		if #m5 > 0 and #m2 > 0 then
			e.quadro = (e.quadro or 0) + 1;
			if e.quadro == 1 and not p.teste then registrar_fs(); end -- (0.60) janela do combo
			if e.quadro <= #m5 then marcar("toque:m5:" .. e.quadro); end
			if e.quadro <= #m2 then marcar("toque:m2:" .. e.quadro); end
			if p.diag ~= nil then p.diag.toques = 1; end
			return;
		end

		-- (0.36) aperta; se a sua animacao nao mudar, o jogo ignorou: aperta de novo
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
	end
};

PERFIS.lanca.executar = {
	contra_ataque = function(desde, p) marcar_contra_ataque(desde); end,
	guarda = function(desde, p) marcar("guarda"); end,
	power_guard = function(desde, p) marcar_power_guard(desde, p.estado_pg); end
	-- a esquiva e tratada a parte (toque gravado, exclusivo)
};

local NOME_NIVEL = NOME_ACAO;

-- (0.32) defesas que seguram o botao de guarda (M5)
local DEFESAS_DE_GUARDA = { guarda = true, contra_ataque = true, power_guard = true };

-- posicao de uma defesa na lista de prioridade do perfil
local function posicao_no_perfil(perfil, acao)
	for i, nome in ipairs(perfil.niveis) do
		if nome == acao then return i; end
	end
	return nil;
end

-- (0.31) monstros com ataques de arena inteira que nem o Guard Up segura (pesquisa: Game8)
local IMBLOQUEAVEIS = { "zoh shia", "jin dahaad", "omega" };

local function monstro_imbloqueavel(nome)
	local texto = string.lower(tostring(nome or ""));
	for _, parte in ipairs(IMBLOQUEAVEIS) do
		if string.find(texto, parte, 1, true) then return true; end
	end
	return false;
end

-- golpe que o jogo marca como "especial" (2 impossivel, 3 e 4 guarda forte)
local function golpe_especial(p)
	return p.guarda == 2 or p.guarda == 3 or p.guarda == 4;
end

-- (0.31) maior nivel que o aprendizado pode alcancar nesta arma e neste monstro
local function teto_do_aprendizado(perfil, nome_monstro)
	local teto = perfil.nivel_maximo_aprendido or #perfil.niveis;
	if op.tenho_guard_up and perfil.teto_com_guard_up and not monstro_imbloqueavel(nome_monstro) then
		teto = math.min(teto, perfil.teto_com_guard_up);
	end
	return teto;
end

local function nivel_inicial(p, m, perfil)
	local de_lado = p.guarda ~= 1 and m.angulo ~= nil and m.angulo > op.angulo_frontal;

	if golpe_especial(p) then
		local guarda = posicao_no_perfil(perfil, "guarda");
		if op.tenho_guard_up and guarda ~= nil and not de_lado and not monstro_imbloqueavel(m.nome) then
			-- com Guard Up: e so segurar a guarda
			return guarda;
		end
		local forte = perfil.forte and posicao_no_perfil(perfil, perfil.forte);
		if forte then return forte; end
	end

	-- golpe de lado/tras: pula as defesas que so protegem de frente
	if p.guarda ~= 1 and m.angulo ~= nil and m.angulo > op.angulo_frontal then
		for i, nome in ipairs(perfil.niveis) do
			if not perfil.so_de_frente[nome] then return i; end
		end
	end

	return (op.acao_guardavel == "guarda" and posicao_no_perfil(perfil, "guarda")) or 1;
end

-- primeiro nivel disponivel a partir de "nivel" (pula as defesas desligadas no menu)
local function nivel_disponivel(nivel, perfil)
	for n = nivel, #perfil.niveis do
		local opcao = perfil.desligavel[perfil.niveis[n]];
		if opcao == nil or op[opcao] then return n; end
	end
	return nil;
end

-- chave do golpe no aprendizado das defesas: arma, monstro e animacao que previu o golpe
local function chave_do_golpe(chave_perfil, m, p)
	return chave_perfil .. ":" .. m.variante .. ":" .. tostring(p.origem); -- (0.49) por variante
end

local function escolher_defesa(p, m, chave_perfil, perfil)
	local nivel = nivel_inicial(p, m, perfil);
	local aprendido = defesas_aprendidas[chave_do_golpe(chave_perfil, m, p)] or 1;
	local teto = teto_do_aprendizado(perfil, m.nome);
	if aprendido > teto then aprendido = teto; end
	-- (0.31) golpe especial com Guard Up: fica na guarda segurada (o contra-ataque aprendido
	-- para este golpe nao vale; so sobe se a propria guarda falhar)
	if aprendido > nivel then nivel = aprendido; end
	if nivel > teto and nivel_inicial(p, m, perfil) <= teto then nivel = teto; end
	return nivel_disponivel(nivel, perfil);
end

--[[
	(0.35) HISTORICO DAS DEFESAS: as ultimas 8, para a aba Prints. Serve para ver, numa
	luta, se o Foresight/Iai/esquiva realmente sairam: a animacao do cacador antes do
	aperto e 0,25s depois (se ficou igual, o jogo ignorou o botao) e se voce levou dano.
]]
local function anotar_defesa(p, defesa, falta)
	if p.diag ~= nil then return; end
	local d = { defesa = defesa, ms = math.floor(falta * 1000 + 0.5), antes = combo.animacao or "?",
		em = os.clock(), depois = nil, resultado = "..." };
	p.diag = d;
	estado.historico = estado.historico or {};
	table.insert(estado.historico, 1, d);
	if #estado.historico > 8 then table.remove(estado.historico); end

	-- (0.44) relatorio automatico: guarda tambem a arma, o golpe e a hora
	d.arma, d.golpe = estado.chave_perfil, p.chave;
	local ok_hora, hora = pcall(os.date, "%H:%M:%S");
	d.hora = ok_hora and hora or nil;
	estado.defesas_sessao = estado.defesas_sessao or {};
	estado.defesas_sessao[#estado.defesas_sessao + 1] = d;
	if #estado.defesas_sessao > 3000 then table.remove(estado.defesas_sessao, 1); end
end

--[[
	(0.56) SS+ISS - PRIORIDADE 1 DA LONG SWORD
	O FS tem poucos quadros de invencibilidade e falha em golpes rapidos seguidos (ex.: os
	trovoes da ult do Lagiacrus); o ISS tem muito mais e ainda sobe o Spirit Gauge quando o
	contra-ataque da certo. Fases:
	  1. "ss": o proximo golpe vem com tempo (ls_ss_min_ms a ls_ss_max_ms) e voce esta no
	     combo: M5 + Espaco juntos (toques gravados, com o buffer). Para de escrever assim que a
	     bainha (20:249) comeca. Se a bainha nao vier em 0,8s, desiste (o FS / esquiva assumem);
	  2. "postura": espera o golpe. Se surgir um golpe antes, o alvo passa a ser ele. Sem golpe
	     ate "ls_postura_max_ms" depois do SS, a postura e liberada para voce;
	  3. "iss": M5 "ls_iss_ms" antes do golpe. Resultado: contra-ataque do ISS deu certo (o jogo
	     avisa), levou dano, ou o ISS saiu sem golpe.
	Do SS ao fim do ISS os seus botoes de acao ficam soltos (como no FS); o M4 continua acima
	de tudo. Se VOCE fizer o SS na mao, o mod so solta o ISS na hora certa (sem bloquear nada).
]]
local ANIM_SS = { ["20:249"] = true, ["20:247"] = true, ["20:248"] = true, ["20:250"] = true };
-- (0.62) 20:263 tambem e ISS (no relatorio da 0.58: 20:250 -> 20:263 com contra-ataque certo).
-- Outras animacoes do ISS sao aprendidas pelo sinal da espada (ver vigiar_sinais_ls).
local ANIM_ISS = { ["20:263"] = true, ["20:264"] = true, ["20:265"] = true };
pcall(function()
	local salvo = json.load_file("aviso_lanca_defesas.json");
	if type(salvo) == "table" and type(salvo.anim_iss) == "table" then
		for anim_iss in pairs(salvo.anim_iss) do ANIM_ISS[anim_iss] = true; end
	end
end);
local ssiss = nil;

--[[
	(0.57) SPIRIT GAUGE: nivel da barra da Long Sword (app.Wp03Def.AURA_LEVEL, lido do jogo).
	O nivel "vermelho" e achado pelo nome no proprio jogo (o nome que tem "RED"); se nao achar, 3.
]]
local NOMES_AURA, AURA_VERMELHA = {}, nil;
pcall(function()
	local tipo_aura = sdk.find_type_definition("app.Wp03Def.AURA_LEVEL");
	for _, campo in ipairs(tipo_aura:get_fields()) do
		if campo:is_static() then
			local ok, valor = pcall(campo.get_data, campo, nil);
			local nome = campo:get_name();
			if ok and type(valor) == "number" then
				NOMES_AURA[valor] = nome;
				local maiusculo = string.upper(nome);
				-- (0.58) o jogo tem um "quase vermelho" (isPreRedAura): nomes com "PRE" nao contam
				if string.find(maiusculo, "RED", 1, true) and not string.find(maiusculo, "PRE", 1, true)
					and (AURA_VERMELHA == nil or valor < AURA_VERMELHA) then AURA_VERMELHA = valor; end
			end
		end
	end
end);

local function nivel_spirit_gauge()
	local cacador = meu_cacador();
	local ok, nivel = pcall(function()
		local arma = cacador:call("get_WeaponHandling");
		local n = arma:call("get_AuraLevel");
		if n == nil then n = arma:get_field("<AuraLevel>k__BackingField"); end
		return n;
	end);
	if ok and type(nivel) == "number" then return nivel; end
	return nil;
end

local function barra_vermelha()
	local nivel = nivel_spirit_gauge();
	return nivel ~= nil and nivel >= (AURA_VERMELHA or 3);
end

-- o proximo golpe previsto que alcanca voce (de qualquer monstro)
local function golpe_mais_proximo(momento)
	local melhor, melhor_m = nil, nil;
	for _, m in pairs(monstros) do
		if not m.invalido then
			for _, p in ipairs(m.previstos) do
				local falta = p.tempo - momento;
				local fora = op.checar_distancia and m.distancia ~= nil and (p.dist_max or 0) > 0
					and m.distancia > p.dist_max + op.margem_distancia;
				if (estado.jogadores or 1) > 1 and (p.dist_max or 0) <= 0 then fora = true; end
				if falta > -0.05 and not fora and (melhor == nil or p.tempo < melhor.tempo) then melhor, melhor_m = p, m; end
			end
		end
	end
	return melhor, melhor_m;
end

--[[
	(0.64) TRAVA PELO TEMPO DOS SEUS GOLPES
	Problema: spamando M1 / M2 / M5, cada golpe novo prende o personagem de novo e o SS, o FS e a
	esquiva nao conseguem sair quando o monstro ataca. Solucao:
	  1. o mod mede quanto tempo cada golpe seu PRENDE o personagem: do inicio da animacao ate a
	     proxima acao sair (outro golpe, FS, SS, ISS ou esquiva). Fica a MENOR medida (o ponto
	     mais cedo em que da para sair do golpe). Tambem anota qual golpe vem depois de qual
	     (o combo: o 1o M2 e uma estocada, o 2o e de baixo para cima...);
	  2. quando um golpe do monstro esta vindo, o mod calcula a hora em que o personagem precisa
	     estar livre (a ultima hora para o SS, ou a hora do FS / esquiva);
	  3. um ataque seu so passa se o golpe atual (o que falta dele) + o proximo golpe do combo
	     acabarem antes dessa hora. Se nao, M1, M2 e M5 ficam soltos ate a defesa sair.
	Ainda sem medida de um golpe: usa 700 ms.
]]
local golpe_atual = { anim = nil, inicio = 0 };

-- (0.65) golpe SEU = animacao de ataque que NAO e FS, SS, ISS nem esquiva (o mod aprende como
-- "ataque" toda animacao em que a espada acerta, e o FS / ISS tambem acertam)
local function e_golpe_seu(anim)
	return anim ~= nil and op.animacoes_ataque_ls[anim] == true and not ANIM_FS[anim] and not ANIM_SS[anim]
		and not ANIM_ISS[anim] and anim ~= "20:61";
end

local function trava_do_golpe(anim)
	local g = duracao_golpes[anim];
	return g and g.ms and (g.ms / 1000) or nil;
end

-- o golpe que viria se voce apertasse agora: o mais longo dos que ja vieram depois deste
local function proximo_golpe_s(anim)
	local g = duracao_golpes[anim];
	local maior = nil;
	for seguinte in pairs((g and g.prox) or {}) do
		local t = e_golpe_seu(seguinte) and trava_do_golpe(seguinte) or nil;
		if t ~= nil and (maior == nil or t > maior) then maior = t; end
	end
	if maior ~= nil then return maior; end
	-- (0.65) sem combo conhecido: o tempo TIPICO (mediana) dos seus golpes medidos (ou 700 ms);
	-- o mais longo de todos travava demais
	local lista = {};
	for anim_g, outro in pairs(duracao_golpes) do
		if outro.ms ~= nil and e_golpe_seu(anim_g) then lista[#lista + 1] = outro.ms / 1000; end
	end
	if #lista == 0 then return 0.7; end
	table.sort(lista);
	return lista[math.floor((#lista + 1) / 2)];
end

-- quanto falta para o golpe atual soltar o personagem
local function resto_do_golpe_atual()
	local anim = golpe_atual.anim;
	-- (0.72) o FS e o ISS tambem prendem o personagem (medidos a parte)
	if not (e_golpe_seu(anim) or ANIM_FS[anim] or ANIM_ISS[anim]) then return 0; end
	local t = trava_do_golpe(anim) or 0.7;
	return math.max(0, t - (os.clock() - golpe_atual.inicio));
end

-- mede os seus golpes (chamado a cada quadro com a Long Sword)
local function medir_golpes(anim)
	if anim == golpe_atual.anim then return; end
	--[[
		(0.67) GOLPES NOVOS: a Long Sword tem muitos golpes e combos. Antes um golpe so virava
		"ataque" quando a espada acertava o monstro (os que erravam nunca eram medidos). Agora,
		se voce apertou M1 / M2 / M5 e logo em seguida (0,4s) comecou uma animacao nova da espada
		que nao e FS, SS, ISS, esquiva nem o neutro, ela vira golpe seu e passa a ser medida.
	]]
	if os.clock() - (estado.apertou_ataque_em or -100) < 0.4 and string.sub(anim, 1, 3) == "20:"
		and anim ~= "20:0" and not ANIM_FS[anim] and not ANIM_SS[anim] and not ANIM_ISS[anim]
		and anim ~= "20:61" and anim ~= "20:62" and anim ~= "20:63" and not op.animacoes_ataque_ls[anim] then
		op.animacoes_ataque_ls[anim] = true;
		salvar_opcoes();
	end
	local antes, durou = golpe_atual.anim, os.clock() - golpe_atual.inicio;
	golpe_atual.anim, golpe_atual.inicio = anim, os.clock();
	--[[
		(0.72) SEGUIMENTOS DO FS / ISS: depois do FS (esquiva curta para tras) o M1 da um golpe no
		lugar e o M5 da 2 golpes pulando para frente (otimo para reposicionar). O FS e o ISS agora
		tambem sao medidos: quanto prendem e quais golpes vem depois deles. Eles NAO entram como
		"proximo golpe" dos seus ataques (isso travava demais na 0.64).
	]]
	if not (e_golpe_seu(antes) or ANIM_FS[antes] or ANIM_ISS[antes]) or durou < 0.08 or durou > 3 then return; end
	-- so conta quando saiu uma ACAO sua (nao dano nem fim natural do golpe)
	local acao = op.animacoes_ataque_ls[anim] or ANIM_FS[anim] or ANIM_SS[anim] or ANIM_ISS[anim] or anim == "20:61";
	if not acao then return; end
	local g = duracao_golpes[antes] or { n = 0 };
	local ms = math.floor(durou * 1000 + 0.5);
	g.ms = (g.ms == nil) and ms or math.min(g.ms, ms);
	g.n = (g.n or 0) + 1;
	if e_golpe_seu(anim) then
		g.prox = g.prox or {};
		g.prox[anim] = true;
	end
	duracao_golpes[antes] = g;
	estado.bloqueio_mudou = true; -- salva junto com as defesas
end

--[[
	(0.70) GOLPE EM SEQUENCIA: outro golpe do mesmo monstro ate 1,2s depois deste. No golpe triplo
	do Chatacabra (aprendido: 2,52s e 2,71s depois da animacao 50:150; 3,14s e 3,47s depois da
	50:22) os golpes vem a ~0,3s um do outro: o FS e a esquiva cobrem so o 1o, e o personagem
	ainda esta no FS / rolando quando o 2o chega. So o SS+ISS cobre a sequencia.
]]
local function golpe_em_sequencia(p, m)
	for _, outro in ipairs((m and m.previstos) or {}) do
		if outro ~= p and outro.tempo > p.tempo + 0.05 and outro.tempo <= p.tempo + 1.2 then return true; end
	end
	return false;
end

-- decide se os seus ataques ficam soltos agora
local function travar_por_golpe(momento, chave_perfil)
	estado.trava_golpe = nil;
	local p, m = golpe_mais_proximo(momento);
	if p == nil then return; end
	local falta = p.tempo - momento;
	if falta > 4 or falta < -0.1 then return; end

	local somente = op.somente_ss_iss and op.usar_ss_iss;
	local chave = chave_do_golpe(chave_perfil, m, p);
	local ss_vale = op.usar_ss_iss and (somente or not barra_vermelha() or (fs_falhas[chave] or 0) >= FS_FALHAS_PARA_SS
		or golpe_em_sequencia(p, m)); -- (0.70) sequencia: prepara para o SS+ISS mesmo no vermelho
	local ss_minimo = math.max(op.ls_ss_min_ms / 1000, 1.55);

	-- hora (daqui a quantos segundos) em que o personagem precisa estar livre
	local livre_em;
	if ss_vale and falta >= ss_minimo and em_combo_espada_longa("ss") then
		livre_em = falta - ss_minimo;          -- a ultima hora para o SS
	elseif somente and em_combo_espada_longa("ss") then
		return;                                 -- somente SS+ISS e sem tempo para ele: nada a fazer
	else
		livre_em = falta - math.max(op.ls_foresight_ms, op.esquiva_ms_espada_longa) / 1000 - 0.05; -- FS / esquiva
	end

	-- apertar agora: o que falta do golpe atual + o proximo golpe do combo (+ 0,1s de margem)
	local fim = resto_do_golpe_atual() + proximo_golpe_s(golpe_atual.anim) + 0.1;
	if fim > livre_em then
		estado.bloquear_ataques_ate = math.max(estado.bloquear_ataques_ate or 0, momento + 0.1);
		estado.trava_golpe = string.format("golpe daqui a %d ms: seus ataques soltos (um golpe seu agora acabaria em %d ms, a defesa precisa de voce livre em %d ms)",
			math.floor(falta * 1000 + 0.5), math.floor(fim * 1000 + 0.5), math.floor(livre_em * 1000 + 0.5));
	end
end

-- este golpe e do SS+ISS (o resto da defesa nao mexe nele)
local function reservar_golpe(p, m, chave_perfil)
	p.nivel, p.defesa, p.perfil, p.conferido, p.ss_iss = 1, "ss_iss", chave_perfil, true, true;
	p.chave = chave_do_golpe(chave_perfil, m, p);
	p.estado_pg = p.estado_pg or {};
end

local function terminar_ss_iss(resultado)
	if ssiss ~= nil and resultado ~= nil then
		if ssiss.diag ~= nil and ssiss.diag.resultado == "..." then ssiss.diag.resultado = resultado; end
		estado.ultimo_resultado = "SS+ISS: " .. resultado;
		estado.ss_iss_resultados = estado.ss_iss_resultados or {};
		local r = estado.ss_iss_resultados;
		r[resultado] = (r[resultado] or 0) + 1;
	end
	ssiss = nil;
end

-- devolve true enquanto o SS+ISS esta no comando (o FS / esquiva nao agem neste quadro)
--[[
	(0.59) O SS PODE SAIR DESTA SUA ANIMACAO? (aprendido)
	Na luta do teste, 55 SS nao sairam: o mod apertava M5 + Espaco em animacoes onde o SS nao
	existe (neutro 20:0, recuperacao do ISS 20:263/264/265, levando dano...) e as vezes saia
	uma esquiva (20:61). Agora, para cada animacao SUA, o mod anota:
	  - ok / falha: quantas vezes o SS saiu ou nao saiu apertando nela;
	  - atraso: quanto tempo o personagem ficou "travado" no seu golpe antes de a bainha
	    (20:249) comecar (o tempo que o seu ataque ainda segura o personagem).
	Animacao nunca vista: so tenta se for um ATAQUE da espada (aprendido nos seus golpes).
]]
local function ss_permitido(anim)
	local a = ss_animacoes[anim];
	if a ~= nil and (a.ok or 0) > 0 then return (a.falha or 0) <= (a.ok or 0) * 3, a; end
	if a ~= nil and (a.falha or 0) >= 2 then return false, a; end
	return op.animacoes_ataque_ls[anim] == true, a;
end

local function anotar_ss(anim, deu_certo, atraso_ms)
	if anim == nil or anim == "?" then return; end
	local a = ss_animacoes[anim] or { ok = 0, falha = 0 };
	if deu_certo then
		a.ok = (a.ok or 0) + 1;
		if atraso_ms ~= nil then
			a.atraso = a.atraso and math.floor(a.atraso * 0.7 + atraso_ms * 0.3 + 0.5) or atraso_ms;
		end
	else
		a.falha = (a.falha or 0) + 1;
	end
	ss_animacoes[anim] = a;
	estado.bloqueio_mudou = true; -- salva junto com as defesas
end

-- (0.59) golpe que ja "sumiu" depois do SS (o monstro mudou de golpe): conta para nao gastar SS nele
local function anotar_sem_golpe(chave, deu_certo)
	if chave == nil then return; end
	local s = ss_sem_golpe[chave] or { sem = 0, ok = 0 };
	if deu_certo then s.ok = s.ok + 1; else s.sem = s.sem + 1; end
	ss_sem_golpe[chave] = s;
	estado.bloqueio_mudou = true;
end

local function golpe_bom_para_ss(chave)
	local s = ss_sem_golpe[chave];
	return s == nil or s.sem < 2 or s.sem <= s.ok * 2;
end

-- (0.59) quanto tempo a postura dura sozinha (medido quando ela acaba sem ninguem apertar nada)
local function postura_maxima()
	local medida = op.postura_medida_ms or 0;
	if medida > 0 then return math.min(medida, op.ls_postura_max_ms) / 1000; end
	return op.ls_postura_max_ms / 1000;
end

-- devolve true enquanto o SS+ISS esta no comando (o FS / esquiva nao agem neste quadro)
local function controlar_ss_iss(momento, chave_perfil)
	local anim = combo.animacao or "?";

	-- (0.67) nenhum monstro grande vivo por perto (morreu, captura, fim da missao): para tudo
	local vivo = false;
	for _, m in pairs(monstros) do
		if not m.invalido and momento - (m.visto_em or -100) <= 0.25 then vivo = true; break; end
	end
	if not vivo then
		if ssiss ~= nil then terminar_ss_iss(nil); estado.bloquear_acoes_ate = nil; end
		return false;
	end
	local m5, espaco = op.toques.m5 or {}, op.toques.esquiva or {};

	if ssiss == nil then
		if ANIM_SS[anim] then
			-- voce fez o SS: o mod solta o ISS na hora certa
			ssiss = { fase = "postura", manual = true, inicio = momento, postura_em = momento, dano_antes = estado.levou_dano_em };
			estado.ultima_decisao = "SS seu -> o mod solta o ISS no golpe";
		else
			if not op.usar_ss_iss or #m5 == 0 or #espaco == 0 then return false; end
			local p, m = golpe_mais_proximo(momento);
			if p == nil or p.nivel ~= nil then return false; end
			local falta = p.tempo - momento;
			-- (0.59) o golpe precisa vir depois do seu ataque acabar (atraso aprendido) + bainha + ISS
			local pode, info = ss_permitido(anim);
			-- (0.65) o SS sai quando o seu golpe atual soltar: o que falta dele (medido) + bainha + ISS
			local atraso = resto_do_golpe_atual();
			if falta < math.max(op.ls_ss_min_ms / 1000, 1.55 + atraso) then return false; end
			-- (0.70) sequencia: o SS pode comecar ate 0,5s mais cedo (a postura dura ~3,8s)
			local em_sequencia = golpe_em_sequencia(p, m);
			-- (0.71) sem os 0,5s a mais da 0.70: os SS de ~3,5s vinham de previsoes longas e erravam
			local ss_max = op.ls_ss_max_ms / 1000;
			-- (0.63) golpe um pouco alem da janela do SS: o SS vem logo; trava ja os seus ataques
			local antes_do_ss = falta > ss_max;
			if antes_do_ss and falta > ss_max + 0.6 then return false; end
			if not em_combo_espada_longa("ss") or not pode then return false; end
			local chave = chave_do_golpe(chave_perfil, m, p);
			if not golpe_bom_para_ss(chave) then return false; end
			--[[
				(0.57) PRIORIDADE PELA BARRA:
				  - "Somente SS+ISS": sempre SS+ISS;
				  - barra abaixo do vermelho: SS+ISS (o ISS certo sobe a barra);
				  - barra VERMELHA: o FS volta a ser o 1 (mais dano); SS+ISS so nos golpes que o FS
				    nao defende.
			]]
			--[[
				(0.69) GOLPES MULTIPLOS: o FS cobre um golpe so (no golpe triplo do Chatacabra o FS
				saiu no 1o e os outros acertaram). Se vier outro golpe do mesmo monstro ate 1,2s
				depois deste, mesmo com a barra vermelha o mod usa SS+ISS (o ISS tem muito mais
				invencibilidade e corre para frente).
			]]
			if not op.somente_ss_iss and barra_vermelha() and not em_sequencia and (fs_falhas[chave] or 0) < FS_FALHAS_PARA_SS then
				return false;
			end
			if antes_do_ss then
				--[[
					(0.63) TRAVA ANTECIPADA: um M1 / M2 / M5 seu apertado logo antes do SS fica guardado
					no buffer do jogo e sai DEPOIS, na postura, cancelando o SS. Nos 0,6s antes do SS
					os seus botoes de ataque ja ficam soltos (o Espaco continua livre).
				]]
				estado.bloquear_ataques_ate = momento + 0.1;
				return false;
			end
			reservar_golpe(p, m, chave_perfil);
			anotar_defesa(p, "ss_iss", falta);
			ssiss = { fase = "ss", inicio = momento, quadro = 0, dano_antes = estado.levou_dano_em, diag = p.diag,
				alvo = p, chave = chave, anim_inicio = anim, idade = idade_combo() };
			estado.ultima_decisao = string.format("SS+ISS em %s (golpe daqui a %d ms, sua animacao %s)",
				tostring(p.origem), math.floor(falta * 1000 + 0.5), anim);
		end
	end

	local desde = momento - ssiss.inicio;
	-- (0.59) do SS ao fim do ISS os seus botoes de ATAQUE (M1, M2, M5) e o Espaco ficam soltos: o
	-- seu golpe atual termina e o SS sai (antes so o M1 era solto e o M2 / M5 continuavam o combo)
	if not ssiss.manual then estado.bloquear_acoes_ate = math.max(estado.bloquear_acoes_ate or 0, momento + 0.1); end

	if ssiss.fase == "ss" then
		if ANIM_SS[anim] then
			anotar_ss(ssiss.anim_inicio, true, math.floor(desde * 1000 + 0.5));
			if not ssiss.manual then anotar_janela("ss", ssiss.idade, true); end
			ssiss.fase, ssiss.postura_em = "postura", momento; -- o jogo ja usou o aperto: para de escrever
		else
			local falta = ssiss.alvo and (ssiss.alvo.tempo - momento) or 0;
			local dano = string.sub(anim, 1, 3) == "14:";
			local esquivou = anim == "20:61";
			-- tarde demais para o SS (o golpe chegaria na bainha), levou dano, saiu esquiva ou 2s sem sair
			if dano or esquivou or desde > 2.0 or falta < op.ls_ss_min_ms / 1000 - 0.35 then
				if not dano then anotar_ss(ssiss.anim_inicio, false); anotar_janela("ss", ssiss.idade, false); end
				terminar_ss_iss(esquivou and "SS nao saiu (saiu esquiva)" or "SS nao saiu");
				estado.bloquear_acoes_ate = nil;
				return false;
			end
			ssiss.quadro = ssiss.quadro + 1;
			-- (0.59) o aperto (com buffer) dura ~0,6s; se o seu golpe ainda segura o personagem,
			-- aperta de novo enquanto der tempo
			if ssiss.quadro > math.max(#m5, #espaco) then
				if not ss_permitido(anim) then
					anotar_ss(ssiss.anim_inicio, false);
					anotar_janela("ss", ssiss.idade, false);
					terminar_ss_iss("SS nao saiu");
					estado.bloquear_acoes_ate = nil;
					return false;
				end
				ssiss.quadro = 1;
				ssiss.repeticoes = (ssiss.repeticoes or 0) + 1;
			end
			if ssiss.quadro <= #m5 then marcar("toque:m5:" .. ssiss.quadro); end
			if ssiss.quadro <= #espaco then marcar("toque:esquivab:" .. ssiss.quadro); end
			return true;
		end
	end

	if ssiss.fase == "postura" then
		if ANIM_ISS[anim] and ssiss.cancelavel then
			-- (0.61) voce cancelou com o M5 (ISS) num momento sem golpe vindo
			terminar_ss_iss("cancelado por voce (M5)");
			estado.bloquear_acoes_ate = nil;
			return false;
		elseif ANIM_ISS[anim] then
			-- o ISS saiu (por voce): so acompanha o resultado
			ssiss.fase, ssiss.iss_em, ssiss.quadro, ssiss.viu_iss = "iss", os.clock(), math.huge, true;
		elseif not ANIM_SS[anim] then
			local levou = estado.levou_dano_em ~= ssiss.dano_antes;
			--[[
				(0.59) TEMPO MAXIMO DA POSTURA: a postura acaba sozinha depois de um tempo. Quando o
				mod faz o SS, os seus botoes ficam soltos; se a postura acabar sem ISS, sem Iai Slash
				(20:251/252) e sem dano, o tempo dela e medido e passa a ser o limite.
			]]
			if not ssiss.manual and not levou and string.sub(anim, 1, 3) ~= "14:" and anim ~= "20:251" and anim ~= "20:252" then
				local dur_ms = math.floor((momento - (ssiss.postura_em or momento)) * 1000 + 0.5);
				if dur_ms >= 3000 then -- (0.62) nas suas leituras a postura durou pelo menos ~3,8s
					op.postura_medida_ms = (op.postura_medida_ms or 0) > 0 and math.min(op.postura_medida_ms, dur_ms) or dur_ms;
					estado.postura_ultima_ms = dur_ms;
					salvar_opcoes();
				end
			end
			local iai_slash = anim == "20:251" or anim == "20:252";
			local por_buffer = iai_slash and not ssiss.cancelavel;
			terminar_ss_iss((levou and "LEVOU DANO na postura")
				or (por_buffer and "cancelado por um M1 seu apertado antes (buffer)")
				or (iai_slash and "cancelado por voce (M1)")
				or ((not ssiss.manual) and "saiu da postura" or nil));
			estado.bloquear_acoes_ate = nil;
			return false;
		else
			local p, m = golpe_mais_proximo(momento);
			local limite = (ssiss.postura_em or ssiss.inicio) + postura_maxima() - 0.25;
			-- (0.63) o golpe alvo saiu da previsao (o monstro mudou de golpe), mas a hora dele ainda nao
			-- passou: continua travado (sem ISS) ate ela passar
			local alvo_pendente = ssiss.alvo ~= nil and ssiss.alvo.tempo + 0.3 > momento
				and (p == nil or p.tempo > limite);
			if alvo_pendente then
				ssiss.cancelavel, ssiss.sem_golpe_desde = false, nil;
				estado.bloquear_acoes_ate = math.max(estado.bloquear_acoes_ate or 0, momento + 0.1);
				return true;
			end
			if p == nil or p.tempo > limite then
				ssiss.sem_golpe_desde = ssiss.sem_golpe_desde or momento;
				--[[
					(0.61) NENHUM GOLPE VINDO na postura: o quadrado vermelho "CANCELAR SS" aparece em
					cima da barra e so o M1 (Iai Slash) e o M5 (ISS) ficam livres - voce decide se cancela.
					O mod nao cancela sozinho. (A bainha, no comeco, nao conta: la nada sai ainda.)
				]]
				if momento - (ssiss.postura_em or ssiss.inicio) > 0.3 and momento - ssiss.sem_golpe_desde >= 0.4 then
					ssiss.cancelavel = true;
					estado.aviso_cancelar_ss_ate = momento + 0.1;
					estado.liberar_m1_ate = momento + 0.1;
					estado.liberar_m5_ate = momento + 0.1;
					if not ssiss.manual and not ssiss.sem_golpe_anotado and momento - (ssiss.postura_em or ssiss.inicio) > 1.3 then
						ssiss.sem_golpe_anotado = true;
						anotar_sem_golpe(ssiss.chave, false);
					end
				end
				return true;
			end
			--[[
				(0.61) GOLPE VINDO: M1, M2, M5 e Espaco TRAVADOS ate o ISS (tambem no SS feito por voce).
				No teste, o M1 na postura soltava um golpe para frente sem invencibilidade, cancelava o
				ISS e o golpe do monstro acertava.
			]]
			ssiss.cancelavel, ssiss.sem_golpe_desde = false, nil;
			estado.bloquear_acoes_ate = math.max(estado.bloquear_acoes_ate or 0, momento + 0.1);
			if p.tempo - momento <= op.ls_iss_ms / 1000 then
				if not p.ss_iss then reservar_golpe(p, m, estado.chave_perfil); end
				if ssiss.manual then
					anotar_defesa(p, "ss_iss", p.tempo - momento);
					ssiss.diag = p.diag;
				end
				ssiss.fase, ssiss.iss_em, ssiss.quadro, ssiss.mod_apertou = "iss", os.clock(), 0, true;
			else
				return true;
			end
		end
	end

	if ssiss.fase == "iss" then
		if ANIM_ISS[anim] then ssiss.viu_iss = true; end
		if not ssiss.viu_iss and ssiss.quadro < #m5 then
			ssiss.quadro = ssiss.quadro + 1;
			marcar("toque:m5:" .. ssiss.quadro);
		end
		if os.clock() - ssiss.iss_em < 0.6 then return true; end
		local resultado;
		if (estado.iss_certo_em or -100) >= ssiss.iss_em - 0.05 then resultado = "OK (contra-ataque do ISS)";
		elseif estado.levou_dano_em ~= ssiss.dano_antes then resultado = "LEVOU DANO";
		elseif ssiss.viu_iss then resultado = "ISS saiu, sem contra-ataque";
		else resultado = "ISS nao saiu"; end
		if not ssiss.manual and resultado == "OK (contra-ataque do ISS)" then anotar_sem_golpe(ssiss.chave, true); end
		if ssiss.diag ~= nil and ssiss.diag.depois == nil then ssiss.diag.depois = anim; end
		terminar_ss_iss(resultado);
		estado.bloquear_acoes_ate = nil;
		return false;
	end
	return false;
end

local function decidir_botoes()
	local momento = agora();

	-- botao de teste do menu: espera 4 segundos (para fechar o menu) e aperta por 5.
	--   esquiva: toca o toque gravado UMA vez;
	--   contra-ataque: faz a sequencia M5 -> M2 UMA vez;
	--   Power Guard: guarda + especial + toque do Espaco, segurado ate o fim do teste.
	if momento >= entrada.forcar_de and momento < entrada.forcar_ate then
		local desde = momento - entrada.forcar_de;
		entrada.teste_estado = entrada.teste_estado or {};
		if entrada.alvo == "esquiva" then
			if not entrada.teste_estado.tocou then
				entrada.teste_estado.tocou = true;
				if not comecar_toque(true) then marcar("esquiva"); end
			end
		elseif ALVO_TOQUE[entrada.alvo] then
			if not entrada.teste_estado.tocou then
				entrada.teste_estado.tocou = true;
				comecar_toque(true, ALVO_TOQUE[entrada.alvo]);
			end
		elseif entrada.alvo == "contra_ataque" then
			if desde < 1.5 then marcar_contra_ataque(desde); end
		elseif entrada.alvo == "power_guard" then
			marcar_power_guard(desde, entrada.teste_estado);
		elseif entrada.alvo == "foresight" then
			-- (0.29) combos: roda a sequencia uma vez, como se o golpe viesse logo depois
			local perfil_teste = PERFIS.espada_longa;
			local duracao = (op[perfil_teste.antecedencia[entrada.alvo]] or 0) / 1000 + 0.3;
			if desde < duracao then
				perfil_teste.executar[entrada.alvo](desde, { teste = true, estado_pg = entrada.teste_estado });
			end
		else
			marcar(entrada.alvo);
		end
		return;
	end
	if momento < entrada.forcar_ate then estado.bloquear_acoes_ate = nil; return; end -- ainda na espera do teste

	-- (0.50) parado: nenhum botao seu fica bloqueado
	if not op.guarda_automatica then estado.motivo_parado = "desligada"; estado.bloquear_acoes_ate = nil; ssiss = nil; return; end

	local pode, motivo = pode_defender();
	estado.motivo_parado = motivo;
	if not pode then estado.bloquear_acoes_ate = nil; ssiss = nil; return; end

	-- perfil da arma atual (definido em pode_defender)
	local perfil, chave_perfil = estado.perfil, estado.chave_perfil;

	-- (0.64) seus ataques so passam se acabarem antes da defesa
	if perfil == PERFIS.espada_longa then pcall(travar_por_golpe, momento, chave_perfil); end

	-- (0.56) SS+ISS primeiro (prioridade 1 da Long Sword)
	if perfil == PERFIS.espada_longa then
		local ok_ss, no_comando = pcall(controlar_ss_iss, momento, chave_perfil);
		if not ok_ss then
			ssiss = nil;
			estado.mensagem = "erro SS+ISS: " .. tostring(no_comando);
		elseif no_comando then
			return;
		end
		-- (0.57) "Somente SS+ISS": sem FS e sem esquiva
		-- (0.60) agora segue: fora da janela do SS sai a esquiva normal; dentro dela, nada de FS
		-- (0.68) GOLPES MULTIPLOS: durante o ISS (muita invencibilidade, corre para frente) o mod nao
		-- aperta mais nada - antes ele tentava FS / esquiva nos golpes seguintes e atrapalhava
		if ANIM_ISS[combo.animacao or "?"] then
			estado.ultima_decisao = "ISS em andamento: espera";
			return;
		end
	else
		ssiss = nil;
	end

	-- quantos segundos antes do impacto cada defesa do perfil comeca
	local antes = {};
	for acao, opcao in pairs(perfil.antecedencia) do antes[acao] = (op[opcao] or 0) / 1000; end
	local depois = op.segurar_depois_ms / 1000;

	-- (0.30) a defesa e escolhida antes da que comeca mais cedo (antes era fixo em 1 segundo:
	-- um Special Sheathe ajustado acima de 1000 ms nunca seria apertado)
	local janela_decisao = 1.0;
	for _, t in pairs(antes) do
		if t + 0.15 > janela_decisao then janela_decisao = t + 0.15; end
	end
	local vai_esquivar = false;

	for _, m in pairs(monstros) do
		for _, p in ipairs(m.previstos) do
			local falta = p.tempo - momento;

			-- MULTIPLAYER (0.25): golpe que nunca chegou em voce desta distancia provavelmente e
			-- contra outro jogador (ou nao alcanca): nao defende. Se voce chegar perto, decide.
			local longe = op.checar_distancia and m.distancia ~= nil and (p.dist_max or 0) > 0
				and m.distancia > p.dist_max + op.margem_distancia;
			-- (0.52) com outros jogadores, golpe que NUNCA acertou voce (so o Palico / outros) nao e
			-- defendido: no SOS o mod soltava Foresight em golpes mirados nos outros
			if (estado.jogadores or 1) > 1 and (p.dist_max or 0) <= 0 then longe = true; end

			-- a defesa e escolhida quando o golpe entra na janela e fica fixa ate o impacto
			if p.nivel == nil and falta <= janela_decisao and not longe then
				--[[
					SEQUENCIA DE GOLPES (versao 0.22): conta os impactos previstos deste monstro
					entre este golpe e "pg_multi_janela_ms" depois. Se forem pelo menos
					"pg_multi_golpes", todos viram um Power Guard so: entra antes do primeiro
					e segura SEM SOLTAR ate depois do ultimo (soltar sai do Power Guard).
				]]
				local sequencia = {};
				local limite = p.tempo + op.pg_multi_janela_ms / 1000;
				for _, outro in ipairs(m.previstos) do
					if outro.nivel == nil and outro.tempo >= p.tempo - 0.01 and outro.tempo <= limite then
						sequencia[#sequencia + 1] = outro;
					end
				end

				local acao_seq = perfil.sequencia;
				local seq_ligada = acao_seq ~= nil and (perfil.desligavel[acao_seq] == nil or op[perfil.desligavel[acao_seq]]);

				if seq_ligada and #sequencia >= op.pg_multi_golpes then
					local ultimo = p.tempo;
					for _, outro in ipairs(sequencia) do if outro.tempo > ultimo then ultimo = outro.tempo; end end

					local compartilhado = {};
					for _, outro in ipairs(sequencia) do
						outro.nivel = posicao_no_perfil(perfil, acao_seq);
						outro.defesa = acao_seq;
						outro.perfil = chave_perfil;
						outro.chave = chave_do_golpe(chave_perfil, m, outro);
						outro.estado_pg = compartilhado;
						outro.janela_ini = p.tempo - (antes[acao_seq] or 0);
						outro.janela_fim = ultimo + depois;
					end
					estado.ultima_decisao = string.format("%s na SEQUENCIA de %d golpes (%.1fs) em %s",
						NOME_NIVEL[acao_seq], #sequencia, ultimo - p.tempo, tostring(p.origem));
				else
					p.nivel = escolher_defesa(p, m, chave_perfil, perfil);
					p.defesa = p.nivel and perfil.niveis[p.nivel] or nil;
					if perfil == PERFIS.espada_longa and p.defesa == "foresight" then
						if ANIM_FS[combo.animacao or "?"] then
							-- (0.68) GOLPES MULTIPLOS: o FS ja esta saindo (outro golpe da sequencia);
							-- apertar outro FS nao faz nada - o mod espera
							p.defesa = nil;
							estado.ultima_decisao = "golpe seguido: FS ja em andamento";
						elseif op.ls_sem_fs_abaixo_vermelho and not barra_vermelha() and not (op.somente_ss_iss and op.usar_ss_iss) then
							--[[
								(0.68) Voce notou: o FS mantem o nivel do Spirit Gauge mas ZERA o
								carregamento para o proximo, e voce ficou no amarelo a luta toda. Abaixo
								do vermelho: SS+ISS (sobe a barra) e, sem tempo para ele, ESQUIVA.
								No vermelho o FS volta a ser o 1.
							]]
							p.defesa, p.sem_combo = "esquiva", true;
							estado.ultima_decisao = "abaixo do vermelho: esquiva no lugar do FS";
						end
					end
					p.perfil = chave_perfil;
					p.chave = chave_do_golpe(chave_perfil, m, p);
					p.estado_pg = {};

					-- (0.32) contra-ataque no meio de golpes seguidos vira guarda
					if p.defesa == "contra_ataque" then
						local ponte = op.ponte_guarda_ms / 1000;
						local seguido = momento - (estado.ultimo_impacto_em or -100) < ponte;
						for _, outro in ipairs(m.previstos) do
							if outro ~= p and math.abs(outro.tempo - p.tempo) < ponte then seguido = true; end
						end
						local pos_guarda = posicao_no_perfil(perfil, "guarda");
						if seguido and pos_guarda ~= nil then
							p.nivel, p.defesa = pos_guarda, "guarda";
						end
					end

					if p.defesa ~= nil then
						estado.ultima_decisao = string.format("%s em %s (nivel %d, angulo %s)",
							NOME_NIVEL[p.defesa], tostring(p.origem), p.nivel,
							m.angulo and string.format("%.0f", m.angulo) or "?");
					end
				end
			end

			--[[
				(0.47/0.48) FORESIGHT COM PRIORIDADE MAXIMA: se voce estiver apertando / segurando
				qualquer botao de acao, o cacador continua fazendo outra coisa e o golpe do monstro
				acerta. Perto do golpe ("ls_bloqueio_ms" antes ate um pouco depois), o mod segura os
				seus botoes de acao soltos; o Foresight (ou a esquiva) sai assim que der.
			]]
			--[[
				(0.51) FORA DO COMBO a esquiva era decidida so na hora do Foresight (120 ms antes)
				e saia atrasada (~90 ms antes; no relatorio varias levaram dano). Agora o combo e
				conferido ja na hora da esquiva (150 ms): fora do combo, esquiva no tempo certo.
			]]
			if perfil == PERFIS.espada_longa and p.defesa == "foresight" and not p.combo_conferido and p.janela_ini == nil
				and falta <= math.max(antes.esquiva or 0, antes.foresight or 0) then
				p.combo_conferido = true;
				local somente = op.somente_ss_iss and op.usar_ss_iss;
				if somente and em_combo_espada_longa("ss") then
					-- (0.60) "Somente SS+ISS": dentro da janela do SS nao usa FS nem esquiva
					p.defesa = nil;
					estado.ultima_decisao = "somente SS+ISS: golpe sem tempo para o SS";
				elseif not em_combo_espada_longa(somente and "ss" or "fs") then
					p.defesa, p.sem_combo, p.estado_pg = "esquiva", true, {};
					estado.ultima_decisao = "fora do combo -> esquiva";
				end
			end

			-- (0.51) so bloqueia DENTRO do combo (fora dele o seu primeiro golpe e a esquiva
			-- ficam livres) e com o tempo aprendido para a animacao em que voce esta agora
			if perfil == PERFIS.espada_longa and not longe and p.defesa == "foresight" and falta >= -depois
				and not (op.somente_ss_iss and op.usar_ss_iss) then
				local antecedencia_bloqueio = (bloqueios_ls[combo.animacao or "?"] or op.ls_bloqueio_ms) / 1000;
				if falta <= antecedencia_bloqueio and em_combo_espada_longa() then
					estado.bloquear_acoes_ate = math.max(estado.bloquear_acoes_ate or 0, p.tempo + depois);
				end
			end

			local defesa = p.defesa;
			local executar = defesa and perfil.executar and perfil.executar[defesa];

			if p.perfil ~= nil and p.perfil ~= chave_perfil then
				-- golpe decidido com outra arma (voce trocou de arma no meio): ignora
			elseif p.janela_ini ~= nil then
				-- parte de uma sequencia: a defesa fica continua da primeira ate a ultima
				if executar and momento >= p.janela_ini and momento <= p.janela_fim then
					executar(momento - p.janela_ini, p);
					if DEFESAS_DE_GUARDA[defesa] then estado.ultima_guarda_em = momento; end
				end
			elseif defesa == "esquiva" then
				-- um toque no tempo certo
				if not p.esquiva_feita and falta <= antes.esquiva and falta >= antes.esquiva - 0.1 then
					vai_esquivar = true;
					anotar_defesa(p, "esquiva", falta);
				end
			elseif executar and falta <= (antes[defesa] or 0) and falta >= -depois then
				anotar_defesa(p, defesa, falta);
				local resultado, motivo = executar((antes[defesa] or 0) - falta, p);
				if resultado ~= "indisponivel" and DEFESAS_DE_GUARDA[defesa] then estado.ultima_guarda_em = momento; end
				if resultado == "indisponivel" then
					-- (0.29) esta defesa nao existe agora (ex.: espada longa fora do combo ou sem
					-- tempo): esquiva no lugar, so neste golpe (nao muda o aprendizado)
					local reserva = (perfil.reserva and perfil.reserva[defesa]) or "esquiva";
					if p.diag ~= nil then p.diag.resultado = "nao deu (" .. tostring(motivo or "?") .. ")"; end
					p.diag = nil;
					p.defesa, p.sem_combo, p.estado_pg = reserva, true, {};
					estado.ultima_decisao = NOME_NIVEL[defesa] .. " indisponivel agora -> " .. NOME_NIVEL[reserva];
					if reserva == "esquiva" and falta < (antes.esquiva or 0.15) - 0.1 and falta > -0.03 then
						vai_esquivar = true; p.esquiva_feita = true;
						anotar_defesa(p, "esquiva", falta);
					end
				end
			end
		end
	end

	--[[
		(0.32) PONTE DE GUARDA: a guarda estava segurada ate o quadro anterior? Continua
		segurada se vem outro golpe logo (previsto) ou se um golpe acabou de chegar em voce
		(o proximo do combo pode ainda nao ter sido previsto).
	]]
	if not vai_esquivar and posicao_no_perfil(perfil, "guarda") ~= nil
		and momento - (estado.ultima_guarda_em or -100) < 0.1 then
		local ponte = op.ponte_guarda_ms / 1000;
		local continuar = momento - (estado.ultimo_impacto_em or -100) < op.manter_apos_golpe_ms / 1000;
		if not continuar then
			for _, m in pairs(monstros) do
				local longe = op.checar_distancia and m.distancia ~= nil;
				for _, p in ipairs(m.previstos) do
					local falta = p.tempo - momento;
					local alcanca = not longe or (p.dist_max or 0) <= 0 or m.distancia <= p.dist_max + op.margem_distancia;
					if falta > 0 and falta <= ponte and alcanca and p.defesa ~= "esquiva" then continuar = true; end
				end
			end
		end
		if continuar then
			marcar("guarda");
			estado.ultima_guarda_em = momento;
		end
	end

	-- esquiva: solta o resto (senao o jogo pode fazer outra coisa com o Espaco)
	if vai_esquivar then
		teclas_agora = {};
		if not comecar_toque(true, perfil.toque_esquiva) and toque.quadro == nil then marcar("esquiva"); end
	end
end

-- confere as defesas: o jogo confirmou a defesa ate 0,3s depois do impacto?
local function conferir_defesas()
	local agora_lua = os.clock();
	local restantes = {};
	local mudou = false;

	for _, v in ipairs(verificacoes_defesa) do
		if agora_lua - v.em < 0.3 then
			restantes[#restantes + 1] = v;
		elseif (function()
			-- deu certo? Com evento: o jogo confirmou a defesa. Sem evento (armas so com esquiva
			-- e a espada e escudo): deu certo se o cacador NAO entrou em animacao de dano.
			-- (nas Dual Blades e na Espada Longa o evento so vem na esquiva PERFEITA, por isso
			-- elas tambem conferem pela animacao de dano)
			local perfil_v = PERFIS[v.perfil or "lanca"];
			if perfil_v ~= nil and perfil_v.confere_por_dano then
				return (estado.levou_dano_em or -100) < v.em - 0.05;
			end
			return (estado.ultimo_sucesso_defesa or -100) >= v.em - 0.05;
		end)() then
			estado.ultimo_resultado = "defendeu com " .. NOME_NIVEL[v.defesa] .. " (" .. v.chave .. ")";
			if v.diag ~= nil then v.diag.resultado = "OK (sem dano)"; end
			if v.perfil == "espada_longa" and v.defesa == "foresight" then
				aprender_bloqueio(v.diag, true);
				-- (0.58) o FS defendeu: este golpe conta uma falha a menos
				if (fs_falhas[v.chave] or 0) > 0 then
					fs_falhas[v.chave] = fs_falhas[v.chave] - 1;
					if fs_falhas[v.chave] <= 0 then fs_falhas[v.chave] = nil; end
					mudou = true;
				end
			end
		elseif v.sem_combo then
			if v.diag ~= nil then v.diag.resultado = "LEVOU DANO"; end
			estado.ultimo_resultado = "FALHOU com a esquiva de reserva (" .. v.chave .. ") - aprendizado nao muda";
		else
			if v.diag ~= nil then v.diag.resultado = "LEVOU DANO"; end
			if v.perfil == "espada_longa" and v.defesa == "foresight" then
				aprender_bloqueio(v.diag, false);
				fs_falhas[v.chave] = (fs_falhas[v.chave] or 0) + 1; -- (0.57)
				mudou = true;
			end
			local perfil_v = PERFIS[v.perfil] or PERFIS.lanca;
			local proximo = math.min((v.nivel or 1) + 1, teto_do_aprendizado(perfil_v, v.monstro));
			if (defesas_aprendidas[v.chave] or 1) < proximo then
				defesas_aprendidas[v.chave] = proximo;
				mudou = true;
			end
			estado.ultimo_resultado = "FALHOU com " .. NOME_NIVEL[v.defesa] .. " (" .. v.chave .. ") -> proxima vez: " .. NOME_NIVEL[perfil_v.niveis[proximo]];
		end
	end

	verificacoes_defesa = restantes;
	if mudou or estado.bloqueio_mudou then
		estado.bloqueio_mudou = false;
		json.dump_file("aviso_lanca_defesas.json", { golpes = defesas_aprendidas, bloqueios = bloqueios_ls, fs_falhas = fs_falhas, ss_animacoes = ss_animacoes, ss_sem_golpe = ss_sem_golpe, janela_combo = janela_combo_dados, anim_fs = ANIM_FS, anim_iss = ANIM_ISS, duracao_golpes = duracao_golpes });
	end
end

--[[
	(0.49) M4 = PRIORIDADE 0, em qualquer arma: guardar a arma e correr (para o Leap of Faith e
	fugir de golpes que matam). Quando voce aperta o M4, o mod para TUDO na hora (defesa,
	toque em andamento, botoes bloqueados) e fica parado ate "m4_pausa_ms" depois de voce
	soltar. Os comandos do M4 saem da gravacao "Gravar toque do M4" (Testar / reaprender botoes).
]]
local m4_cache = { quadros = -1, comandos = {} };

local function comandos_do_m4()
	local gravado = op.toques.m4 or {};
	if #gravado == m4_cache.quadros then return m4_cache.comandos; end
	local nossos = {};
	for _, grupo in pairs(GRUPOS_DE_BOTOES) do for _, n in ipairs(grupo) do nossos[n] = true; end end
	local lista, vistos = {}, {};
	for _, item in ipairs(gravado[1] or {}) do
		if item.c == "_OnTrigger" and not nossos[item.t] and not vistos[item.t] then
			vistos[item.t] = true;
			lista[#lista + 1] = item.t;
		end
	end
	m4_cache.quadros, m4_cache.comandos = #gravado, lista;
	return lista;
end

local function m4_apertado()
	local comandos = comandos_do_m4();
	if #comandos == 0 then return false; end
	local apertado = false;
	pcall(function()
		for _, entrada_jogador in ipairs(entradas_ativas()) do
			local teclas = entrada_jogador:get_field("_Keys");
			for _, n in ipairs(comandos) do
				local tecla = teclas and teclas:get_element(n);
				if tecla ~= nil and (tecla:get_field("_On") == true or tecla:get_field("_OnTrigger") == true) then
					apertado = true;
					return;
				end
			end
		end
	end);
	return apertado;
end

local function planejar_defesa()
	teclas_agora = {};
	pcall(conferir_defesas);

	-- (0.50) o M4 apertado pelo PROPRIO mod (teste do toque do M4) nao conta
	local mod_apertando_m4 = toque.quadro ~= nil and toque.nome == "m4";
	if not mod_apertando_m4 and m4_apertado() then estado.m4_ate = os.clock() + op.m4_pausa_ms / 1000; end
	if estado.m4_ate ~= nil and os.clock() < estado.m4_ate then
		toque.quadro = nil;
		if ssiss ~= nil then terminar_ss_iss("parado pelo seu M4"); end
		estado.bloquear_acoes_ate = nil;
		estado.motivo_parado = "M4 (guardar a arma e correr)";
		preparar_escrita();
		estado.escreveu = false;
		return;
	end

	-- (0.55) LEITURA DO SS+ISS: o mod nao aperta nada (para ler so os SEUS apertos)
	pcall(pode_defender); -- atualiza a arma atual (a leitura so vale na Long Sword)
	if estado.leitura_ss_iss and estado.perfil == PERFIS.espada_longa then
		toque.quadro = nil;
		ssiss = nil;
		estado.bloquear_acoes_ate = nil;
		estado.motivo_parado = "leitura do SS+ISS (so lendo os seus apertos)";
		preparar_escrita();
		estado.escreveu = false;
		return;
	end

	decidir_botoes();

	-- toque gravado em andamento: um quadro da gravacao por quadro do jogo
	if toque.quadro ~= nil then
		local quadros = gravacao(toque.nome);
		if toque.quadro > #quadros then
			toque.quadro = nil;
		else
			if toque.exclusivo then teclas_agora = {}; end
			marcar("toque:" .. (toque.nome or "esquiva") .. ":" .. toque.quadro);
			toque.quadro = toque.quadro + 1;
		end
	end

	--[[
		(0.48) FORESIGHT COM PRIORIDADE MAXIMA: perto do golpe, TODOS os seus botoes de acao
		ficam soltos (M1, M2, M5 e Espaco) - qualquer ataque ou esquiva sua faria o cacador
		comecar outra acao e o Foresight nao sairia. So ficam livres os botoes que o PROPRIO mod
		esta apertando neste quadro (M5 + M2 do Foresight, Espaco da esquiva).
	]]
	local so_ataques = estado.bloquear_ataques_ate ~= nil and agora() < estado.bloquear_ataques_ate; -- (0.63)
	local tudo = estado.bloquear_acoes_ate ~= nil and agora() < estado.bloquear_acoes_ate;
	if (tudo or so_ataques) and estado.perfil == PERFIS.espada_longa then
		local usa_m2, usa_m5, usa_espaco = false, false, not tudo;
		local usa_m1 = estado.liberar_m1_ate ~= nil and agora() < estado.liberar_m1_ate; -- (0.61) cancelar o SS
		local m5_livre = estado.liberar_m5_ate ~= nil and agora() < estado.liberar_m5_ate;
		for acao in pairs(teclas_agora) do
			if string.sub(acao, 1, 9) == "toque:m1:" then
				usa_m1 = true;
			elseif acao == "guarda" or acao == "especial" then
				usa_m2, usa_m5 = true, true;
			elseif string.sub(acao, 1, 9) == "toque:m5:" then
				usa_m5 = true;
			elseif string.sub(acao, 1, 9) == "toque:m2:" then
				usa_m2 = true;
			elseif acao == "esquiva" or acao == "espaco" or string.sub(acao, 1, 14) == "toque:esquiva:" or string.sub(acao, 1, 15) == "toque:esquivab:" then
				usa_espaco = true;
			end
		end
		if not usa_m1 then marcar("bloquear:m1"); end
		-- (0.59) M2 e M5 soltos separadamente (no SS o mod aperta o M5 e solta o seu M2)
		if not usa_m2 then marcar("bloquear:m2"); end
		if not usa_m5 and not m5_livre then marcar("bloquear:m5"); end
		if not usa_espaco then marcar("bloquear:espaco"); end
		if next(op.comandos_ataque_extra or {}) ~= nil then marcar("bloquear:extra"); end -- (0.71)
		estado.trava_ativa_em = os.clock(); -- (0.71) para descobrir botoes que escapam da trava
	end

	preparar_escrita();
	estado.escreveu = next(teclas_agora) ~= nil; -- (0.46) para nao ler os proprios apertos como seus
end


-- =====================================================================================
-- ACOMPANHAMENTO A CADA QUADRO
-- =====================================================================================


local function acompanhar()
	local momento = agora();
	pcall(n78.vigiar_troca_de_cena); -- (0.78)
	pcall(n78.processar_ativacoes);  -- (0.78)
	estado.jogadores = jogadores_na_cacada(); -- (0.52) usado no aprendizado (contado a cada 2s)
	local cacador = meu_cacador();
	local objeto_cacador = cacador and objeto_de_jogo(cacador);
	local cx, cy, cz;

	--[[
		(0.34) DANO PELA VIDA: na 0.33 a espada longa marcou 14 golpes como "falhou" e o
		Foresight virou Iai neles. O mod achava que voce levou dano quando o cacador entrava
		numa animacao do "banco 14", que talvez nao seja so de dano. Agora, se a vida do
		cacador puder ser lida, "levou dano" = a vida caiu.
	]]
	if cacador ~= nil then
		local ok_vida, vida = pcall(function()
			return cacador:call("get_HunterHealth"):call("get_HealthMgr"):call("get_Health");
		end);
		vida = ok_vida and tonumber(vida) or nil;
		if vida ~= nil then
			estado.vida_lida = true;
			if estado.vida_anterior ~= nil and vida < estado.vida_anterior - 0.5 then
				estado.levou_dano_em = os.clock();
			end
			estado.vida_anterior = vida;
		end
	end
	if objeto_cacador ~= nil then cx, cy, cz = posicao(objeto_cacador); end

	-- para onde o cacador esta olhando (vetor "frente", so no chao)
	local frente_x, frente_z = nil, nil;
	if objeto_cacador ~= nil then
		pcall(function()
			local eixo = objeto_cacador:call("get_Transform"):call("get_AxisZ");
			local tamanho = math.sqrt(eixo.x * eixo.x + eixo.z * eixo.z);
			if tamanho > 0.01 then frente_x, frente_z = eixo.x / tamanho, eixo.z / tamanho; end
		end);
	end

	-- quando o cacador entra numa animacao de levar dano (banco 14), anota o momento
	-- (usado para saber se a defesa falhou nas armas sem evento de sucesso)
	if objeto_cacador ~= nil then
		local id_cacador, banco = animacao_de(objeto_cacador);

		--[[
			(0.46) COMBO PELOS SEUS BOTOES: antes o combo so contava quando a espada ACERTAVA
			ou numa animacao de ataque ja aprendida - um golpe que errou o monstro nao abria o
			Foresight. Agora, quando voce aperta M1, M2 ou M5 (lido no aperto de verdade, nos
			quadros em que o mod nao esta escrevendo nada), conta como golpe seu.
		]]
		if estado.perfil == PERFIS.espada_longa and not estado.escreveu then
			pcall(function()
				for _, entrada_jogador in ipairs(entradas_ativas()) do
					local teclas = entrada_jogador:get_field("_Keys");
					for _, n in ipairs(COMANDOS_DE_ATAQUE) do
						local tecla = teclas and teclas:get_element(n);
						if tecla ~= nil and tecla:get_field("_OnTrigger") == true then
							combo.ultimo_ataque_em = os.clock();
							estado.apertou_ataque_em = os.clock(); -- (0.67) aperto SEU de ataque
							return;
						end
					end
				end
			end);
		end
		combo.animacao = tostring(banco) .. ":" .. tostring(id_cacador);
		if op.animacoes_ataque_ls[combo.animacao] then combo.ultimo_ataque_em = os.clock(); end
		-- (0.35) historico: animacao 0,25s depois de cada defesa
		for _, d in ipairs(estado.historico or {}) do
			if d.depois == nil and os.clock() - d.em >= 0.25 then d.depois = combo.animacao or "?"; end
		end
		-- (0.34) se a vida do cacador puder ser lida, ela decide (ver abaixo); o banco 14 so
		-- fica como reserva
		if banco == 14 and estado.banco_cacador ~= 14 and not estado.vida_lida then estado.levou_dano_em = os.clock(); end
		estado.banco_cacador = banco;
	end

	-- so anota qual arma voce esta usando (para o menu). Nenhum gancho e ligado aqui.
	if cacador ~= nil then
		pcall(function()
			local arma = cacador:call("get_WeaponHandling");
			pesquisa.arma_tipo = arma and arma:get_type_definition():get_full_name() or nil;
		end);
	end

	for chave, m in pairs(monstros) do
		if momento - m.visto_em > 1 then
			monstros[chave] = nil;
		elseif momento - m.visto_em > 0.25 or m.invalido then
			--[[
				(0.51) o jogo parou de atualizar este monstro (morreu, foi capturado ou a missao
				acabou). O mod continuava chamando funcoes no objeto dele por ate 1 segundo: no
				fim das missoes o registro do REFramework mostrou ~100 erros por segundo disso, e
				o jogo fechou 1 segundo depois. Agora nao chama mais nada nele.
			]]
		else
			--[[
				(0.68) MONSTRO MORTO: le a vida (objeto de dados, nao o corpo do monstro). Vida 0 =
				morto: o mod nao chama mais NADA no corpo dele (posicao, animacao). No fim da luta o
				jogo destroi o corpo, e chamar funcoes nele trava o jogo (log de 18:04:21: posicao e
				animacao chamadas num monstro destruido, e o jogo parou).
			]]
			if m.gerenciador_vida ~= nil then
				local ok_v, vida_m = pcall(function() return m.gerenciador_vida:call("get_Health"); end);
				if ok_v and type(vida_m) == "number" and vida_m <= 0 then m.invalido, m.morto = true, true; end
			end
			local mx, my, mz = nil, nil, nil;
			if not m.invalido then
				mx, my, mz = posicao(m.objeto);
				if mx == nil then m.invalido = true; end -- objeto ja destruido: para na hora
			end
			if m.invalido then
				m.previstos = {}; -- (0.68) e NAO chama a animacao (antes chamava no mesmo quadro)
			else
			m.distancia = distancia(mx, my, mz, cx, cy, cz);

			-- angulo entre para onde o cacador olha e a direcao do monstro (no chao)
			m.angulo = nil;
			if frente_x ~= nil and mx ~= nil and cx ~= nil then
				local dx, dz = mx - cx, mz - cz;
				local tamanho = math.sqrt(dx * dx + dz * dz);
				if tamanho > 0.01 then
					local cosseno = (dx * frente_x + dz * frente_z) / tamanho;
					m.angulo = math.deg(math.acos(math.max(-1, math.min(1, cosseno))));
				end
			end

			local id, banco, quadro, fim = animacao_de(m.objeto);
			if id ~= nil then
				local quadro_antes = m.quadro; -- (0.78)
				m.quadro, m.fim = quadro or 0, fim or 0;
				local animacao = tostring(banco) .. ":" .. tostring(id);

				--[[
					(0.78) GOLPE REPETIDO: a mesma animacao de ataque comecando de novo (o quadro
					voltou para o inicio). Antes o mod so via animacao NOVA quando o nome mudava, e o
					2o golpe igual seguido nao era previsto. So vale para animacoes que tem golpe
					aprendido (as de andar / parado repetem o tempo todo).
				]]
				local reiniciou = animacao == m.animacao and quadro ~= nil and quadro_antes ~= nil
					and quadro + 5 < quadro_antes and momento - (m.animacao_desde or momento) > 0.3
					and grupos_de(m.variante, animacao) ~= nil;
				if reiniciou then estado.reinicios_vistos = (estado.reinicios_vistos or 0) + 1; end

				if animacao ~= m.animacao or reiniciou then
					m.animacao, m.animacao_desde = animacao, momento;

					m.historico[#m.historico + 1] = { chave = animacao, inicio = momento };
					while #m.historico > AJUSTES.historico_animacoes do table.remove(m.historico, 1); end

					nova_animacao(m, animacao, momento);
				end
			end

			-- tira avisos que ja passaram
			local restantes = {};
			for _, p in ipairs(m.previstos) do
				if p.tempo > momento - 0.25 then restantes[#restantes + 1] = p; end
			end
			m.previstos = restantes;
			end -- (0.68) fim do "monstro vivo"
		end
	end

	-- salva o aprendizado de vez em quando (nao a cada golpe, para nao pesar)
	if precisa_salvar and momento - salvo_em > 10 then
		pcall(salvar_conhecimento);
	end
end


-- =====================================================================================
-- 7. BARRA DE AVISO NA TELA
--
-- Uma trilha horizontal com uma linha-alvo na esquerda. Cada impacto previsto e um
-- marcador que anda da direita para a esquerda e chega na linha no momento do impacto.
-- Em cima, o que fazer (cor pelo tipo de golpe). Pouco antes do impacto, pisca "AGORA!".
-- =====================================================================================

-- cores no formato do REFramework (0xAABBGGRR)
local COR = {
	trilha = 0xA0000000,
	alvo = 0xFFFFFFFF,
	sombra = 0xFF000000,
	texto = 0xFFFFFFFF,
	guarda = 0xFF00D7FF,       -- amarelo
	power_guard = 0xFF0080FF,  -- laranja
	impossivel = 0xFF2020FF,   -- vermelho
	agora = 0xFF40FF40         -- verde
};

local function estilo_do_golpe(guarda)
	if guarda == 2 or guarda == 3 or guarda == 4 then
		if op.tenho_guard_up then return "SEGURE A GUARDA (Guard Up)", COR.power_guard; end
		if guarda == 2 then return "IMPOSSIVEL DE GUARDAR - ESQUIVE", COR.impossivel; end
		return "POWER GUARD", COR.power_guard;
	end
	return "GUARDA", COR.guarda;
end

local function texto_com_sombra(texto, x, y, cor)
	draw.text(texto, x + 1, y + 1, COR.sombra);
	draw.text(texto, x, y, cor);
end

local function desenhar_aviso()
	-- (0.61) "CANCELAR SS": postura do SS sem golpe vindo (o M1 / M5 estao livres)
	if estado.aviso_cancelar_ss_ate ~= nil and agora() < estado.aviso_cancelar_ss_ate then
		local largura_t, altura_t = tamanho_tela();
		local esc = altura_t / 1080 * (op.barra_tamanho or 1); -- (0.75) acompanha a barra
		local larg_q, alt_q = 150 * esc, 30 * esc;
		local xq = largura_t * (op.barra_horizontal or 0.5) - larg_q / 2;
		local yq = altura_t * op.altura_tela - 75 * esc;
		draw.filled_rect(xq, yq, larg_q, alt_q, COR.impossivel);
		texto_com_sombra("CANCELAR SS", xq + 30 * esc, yq + 8 * esc, COR.texto);
	end

	if not op.ativado or op.barra_desligada then return; end -- (0.77) "Desligar a barra"

	local momento = agora();
	-- (0.74) a barra mostra sempre 4s (o mod preve golpes ate 4s depois da animacao do monstro)
	local janela = 4.0;
	local antecedencia = op.antecedencia_ms / 1000;

	-- junta os impactos visiveis de todos os monstros cobertos
	local visiveis = {};
	for _, m in pairs(monstros) do
		for _, p in ipairs(m.previstos) do
			local falta = p.tempo - momento;
			if falta <= janela and falta >= -0.15 then visiveis[#visiveis + 1] = { falta = falta, guarda = p.guarda }; end
		end
	end
	-- (0.75) barra de exemplo enquanto a aba "Configurar Barra de previsao" esta aberta
	if estado.barra_exemplo_ate ~= nil and os.clock() < estado.barra_exemplo_ate then
		local ciclo = os.clock() % 4.0;
		visiveis[#visiveis + 1] = { falta = 4.0 - ciclo, guarda = 0 };
		visiveis[#visiveis + 1] = { falta = (6.0 - ciclo) % 4.0, guarda = 2 };
	end
	if #visiveis == 0 and not op.barra_sempre_visivel then return; end -- (0.76)
	table.sort(visiveis, function(a, b) return a.falta < b.falta; end);

	local largura_tela, altura_tela = tamanho_tela();
	local e = altura_tela / 1080 * (op.barra_tamanho or 1); -- (0.75) tamanho ajustavel

	-- (0.75) opacidade: muda so o canal alfa das cores (formato 0xAABBGGRR)
	local opac = math.max(0.1, math.min(1, op.barra_opacidade or 1));
	local function o(cor)
		local alfa = math.floor(cor / 0x1000000);
		return math.floor(alfa * opac) * 0x1000000 + cor % 0x1000000;
	end
	local function texto_o(txt, x, y, cor)
		draw.text(txt, x + 1, y + 1, o(COR.sombra));
		draw.text(txt, x, y, o(cor));
	end

	local largura = 900 * e; -- (0.74) mais larga para caber os 4s (era 420 para 1,2s)
	local x_centro = largura_tela * (op.barra_horizontal or 0.5); -- (0.75) posicao horizontal
	local x0 = x_centro - largura / 2;
	local y0 = altura_tela * op.altura_tela;
	local x_alvo = x0 + 30 * e;
	local x_fim = x0 + largura;

	-- trilha e linha-alvo
	draw.filled_rect(x0, y0, largura, 10 * e, o(COR.trilha));
	draw.filled_rect(x_alvo - 2 * e, y0 - 8 * e, 4 * e, 26 * e, o(COR.alvo));
	-- (0.73) marcas de 1 em 1 segundo (para ler quanto falta)
	for s = 1, math.floor(janela) do
		local xs = x_alvo + (s / janela) * (x_fim - x_alvo);
		draw.filled_rect(xs - 1 * e, y0 + 10 * e, 2 * e, 6 * e, o(COR.alvo));
	end

	-- marcadores
	for _, v in ipairs(visiveis) do
		local _, cor = estilo_do_golpe(v.guarda);
		local fracao = math.max(0, math.min(1, v.falta / janela));
		local x = x_alvo + fracao * (x_fim - x_alvo);
		draw.filled_rect(x - 5 * e, y0 - 6 * e, 10 * e, 22 * e, o(cor));
	end

	-- o que fazer (pelo proximo impacto)
	local proximo = visiveis[1];
	if proximo == nil then return; end -- (0.76) sempre visivel e nenhum golpe vindo: so a trilha
	local texto, cor = estilo_do_golpe(proximo.guarda);
	texto_o(texto, x0, y0 - 30 * e, cor);

	-- "AGORA!" pouco antes do impacto
	if proximo.falta <= antecedencia then
		draw.filled_rect(x0, y0 + 16 * e, largura, 22 * e, o(COR.agora));
		texto_o("AGORA!", x_centro - 24, y0 + 19 * e, COR.sombra);
	end
end

--[[
	(0.55) LEITURA DO SS+ISS (Special Sheathe + Iai Spirit Slash)
	Em vez de testar o Iai as cegas (nas versoes 0.33 a 0.40 ele nunca saiu), o mod LE os seus
	SS+ISS feitos na mao. Com a leitura ligada (menu, so na Long Sword) e a espada sacada:
	  - a cada quadro anota os campos dos seus botoes (M1, M2, M5, Espaco e M4: estado do botao
	    e buffer de entrada), a sua animacao, o monstro mais perto (animacao, distancia, quanto
	    falta para o proximo golpe previsto), golpes em voce, dano e os sinais da espada
	    (contra-ataque do ISS deu certo, ISS acertou...);
	  - guarda sempre os ultimos 1,5s. Quando voce aperta M5 + Espaco juntos (o SS), comeca uma
	    leitura com esse 1,5s de antes e continua ate 4s depois do seu ultimo M5 (o ISS), no
	    maximo 12s;
	  - salva em reframework/data/aviso_lanca_prints/ss_iss_<data>_<N>.json (pasta Prints).
	Com isso da para montar o SS e o ISS como toques gravados de verdade (com o buffer), como foi
	feito com o FS na 0.42, e saber o tempo certo do ISS em relacao ao golpe do monstro.
]]
local leitura = {
	campos = nil, campos_em = -100, -- lista dos campos lidos { t, l, c } (refeita a cada 5s)
	anterior = {},                  -- valores do quadro anterior (para anotar so o que mudou)
	ultimos = {},                   -- os ultimos quadros (1,5s), antes de o SS comecar
	atual = nil,                    -- leitura em andamento
	salvas = 0, ultima = nil,
	m5_em = -100, espaco_em = -100,
	sinais = {}, eventos = {},
	dano_visto = nil, impacto_visto = nil
};

local SINAIS_ESPADA = { "IsIaiKijinMikiriSuccessed", "IsIaiKijinSlashHitted", "IsIaiSlashHitted",
	"IsRedIaiKijinHitted", "IsMikiriSuccessed", "IsMikiriHitSuccessed" };

-- o contra-ataque do ISS deu certo (funcao do jogo)
local iss_certo = tipo_espada_longa and tipo_espada_longa:get_method("doOnIaiKijinMikiriSuccessed");
if iss_certo ~= nil then
	pcall(sdk.hook, iss_certo, function(args)
		pcall(function()
			local cacador = meu_cacador();
			local minha_arma = cacador and cacador:call("get_WeaponHandling");
			if minha_arma == nil or sdk.to_int64(args[2]) ~= minha_arma:get_address() then return; end
			estado.iss_certo_em = os.clock(); -- (0.56) usado no resultado do SS+ISS
			if not estado.leitura_ss_iss then return; end
			leitura.eventos[#leitura.eventos + 1] = "ISS: CONTRA-ATAQUE DEU CERTO";
		end);
	end, function(retorno) return retorno; end);
end

-- campos lidos: os mesmos que mudaram nas suas gravacoes (M5, M2, Espaco, M4) + estado de
-- todos os comandos dos grupos de botoes
local function campos_da_leitura()
	if leitura.campos ~= nil and os.clock() - leitura.campos_em < 5 then return leitura.campos; end
	local lista, vistos = {}, {};
	local function por(t, l, c)
		local chave = tostring(t) .. (l and "L" or "") .. c;
		if not vistos[chave] then vistos[chave] = true; lista[#lista + 1] = { t = t, l = l, c = c }; end
	end
	for _, quadros in pairs(op.toques or {}) do
		for _, itens in ipairs(quadros) do
			for _, item in ipairs(itens) do por(item.t, item.l == true, item.c); end
		end
	end
	local comandos = {};
	for _, grupo in pairs(GRUPOS_DE_BOTOES) do for _, n in ipairs(grupo) do comandos[#comandos + 1] = n; end end
	for _, n in ipairs(comandos_do_m4()) do comandos[#comandos + 1] = n; end
	for _, n in ipairs(comandos) do
		for _, c in ipairs({ "_On", "_RawOn", "_OnTrigger", "_OffTrigger", "_Repeat" }) do por(n, false, c); end
		por(n, true, "_LagFrameCounter");
		por(n, true, "_LagTimer");
	end
	leitura.campos, leitura.campos_em = lista, os.clock();
	return lista;
end

local function texto_valor(v)
	if type(v) == "number" then
		if v == math.floor(v) then return tostring(math.floor(v)); end
		return string.format("%.3f", v);
	end
	return tostring(v);
end

-- qual botao (grupo) cada comando e
local GRUPO_DO_COMANDO = {};
for nome_grupo, grupo in pairs(GRUPOS_DE_BOTOES) do for _, n in ipairs(grupo) do GRUPO_DO_COMANDO[n] = nome_grupo; end end

local function ler_ss_iss()
	if not estado.leitura_ss_iss or estado.perfil ~= PERFIS.espada_longa then
		leitura.ultimos, leitura.anterior = {}, {};
		return;
	end
	local cacador = meu_cacador();
	if cacador == nil then return; end
	local momento = agora();

	-- 1. botoes: o que mudou desde o quadro anterior
	local mudou, apertados, soltos_agora = {}, {}, {};
	local campos = campos_da_leitura();
	for _, entrada_jogador in ipairs(entradas_ativas()) do
		local teclas = entrada_jogador:get_field("_Keys");
		if teclas ~= nil then
			for _, item in ipairs(campos) do
				local ok, valor = pcall(function()
					local alvo = teclas:get_element(item.t);
					if alvo ~= nil and item.l then
						local buffer = alvo:get_field("<LagWorker>k__BackingField");
						alvo = buffer and buffer:get_element(0);
					end
					return alvo and alvo:get_field(item.c);
				end);
				if ok and valor ~= nil then
					local chave = tostring(item.t) .. (item.l and ".buffer." or ".") .. item.c;
					local texto = texto_valor(valor);
					if leitura.anterior[chave] ~= texto then
						mudou[#mudou + 1] = chave .. "=" .. texto;
						leitura.anterior[chave] = texto;
					end
					if item.c == "_OnTrigger" and not item.l and valor == true then
						apertados[GRUPO_DO_COMANDO[item.t] or ("cmd" .. item.t)] = true;
					end
					if item.c == "_On" and not item.l and valor == true then
						soltos_agora[GRUPO_DO_COMANDO[item.t] or ("cmd" .. item.t)] = true;
					end
				end
			end
		end
	end

	-- M5 = comandos 15 e 22 (grupo m2_m5 junta M2 e M5: separa pelo numero)
	local m5_agora, espaco_agora = false, false;
	pcall(function()
		for _, entrada_jogador in ipairs(entradas_ativas()) do
			local teclas = entrada_jogador:get_field("_Keys");
			for _, n in ipairs({ 15, 22 }) do
				local tecla = teclas and teclas:get_element(n);
				if tecla ~= nil and tecla:get_field("_OnTrigger") == true then m5_agora = true; end
			end
			for _, n in ipairs(GRUPOS_DE_BOTOES.espaco or {}) do
				local tecla = teclas and teclas:get_element(n);
				if tecla ~= nil and tecla:get_field("_OnTrigger") == true then espaco_agora = true; end
			end
		end
	end);
	if m5_agora then leitura.m5_em = momento; end
	if espaco_agora then leitura.espaco_em = momento; end

	-- 2. sinais da espada (o que mudou)
	local eventos = leitura.eventos;
	leitura.eventos = {};
	pcall(function()
		local arma = cacador:call("get_WeaponHandling");
		for _, nome in ipairs(SINAIS_ESPADA) do
			local v = arma and arma:get_field(nome);
			if v ~= nil and leitura.sinais[nome] ~= v then
				if leitura.sinais[nome] ~= nil or v == true then eventos[#eventos + 1] = nome .. "=" .. tostring(v); end
				leitura.sinais[nome] = v;
			end
		end
	end);
	if estado.levou_dano_em ~= leitura.dano_visto then
		if leitura.dano_visto ~= nil then eventos[#eventos + 1] = "LEVOU DANO"; end
		leitura.dano_visto = estado.levou_dano_em;
	end
	if estado.ultimo_impacto_em ~= leitura.impacto_visto then
		if leitura.impacto_visto ~= nil then eventos[#eventos + 1] = "golpe do monstro em voce"; end
		leitura.impacto_visto = estado.ultimo_impacto_em;
	end

	-- 3. sua animacao e o monstro mais perto
	local objeto_cacador = objeto_de_jogo(cacador);
	local id_c, banco_c, quadro_c = animacao_de(objeto_cacador);
	local perto, falta = nil, nil;
	for _, m in pairs(monstros) do
		if not m.invalido and m.distancia ~= nil and (perto == nil or m.distancia < perto.distancia) then perto = m; end
	end
	if perto ~= nil then
		for _, p in ipairs(perto.previstos or {}) do
			local f = p.tempo - momento;
			if f > -0.3 and (falta == nil or f < falta) then falta = f; end
		end
	end

	local quadro = {
		a = tostring(banco_c) .. ":" .. tostring(id_c), q = quadro_c and math.floor(quadro_c) or nil,
		arma = cacador:call("get_IsWeaponOn") == true,
		m = perto and perto.animacao or nil, dist = perto and perto.distancia and arredondar(perto.distancia, 1) or nil,
		golpe_em_ms = falta and math.floor(falta * 1000 + 0.5) or nil,
		apertou = next(apertados) and apertados or nil, segura = next(soltos_agora) and soltos_agora or nil,
		mudou = #mudou > 0 and mudou or nil, ev = #eventos > 0 and eventos or nil,
		_em = momento
	};

	-- 4. comeca / continua / termina a leitura
	local ss = m5_agora and espaco_agora
		or (m5_agora and momento - leitura.espaco_em < 0.15) or (espaco_agora and momento - leitura.m5_em < 0.15);
	local atual = leitura.atual;
	if atual == nil then
		leitura.ultimos[#leitura.ultimos + 1] = quadro;
		while #leitura.ultimos > 0 and momento - leitura.ultimos[1]._em > 1.5 do table.remove(leitura.ultimos, 1); end
		if ss then
			atual = { inicio = momento, quadros = leitura.ultimos, fim = momento + 4,
				monstro = perto and perto.nome_completo or nil };
			leitura.atual, leitura.ultimos = atual, {};
		end
		return;
	end
	atual.quadros[#atual.quadros + 1] = quadro;
	if m5_agora then atual.fim = math.max(atual.fim, momento + 4); end
	if momento < atual.fim and momento - atual.inicio < 12 then return; end

	-- 5. salva (tempos em ms a partir do SS)
	leitura.atual = nil;
	local resumo = { apertos = {}, suas_animacoes = {}, monstro_animacoes = {}, eventos = {} };
	local anim_c, anim_m = nil, nil;
	for _, q in ipairs(atual.quadros) do
		q.t = math.floor((q._em - atual.inicio) * 1000 + 0.5);
		q._em = nil;
		for botao in pairs(q.apertou or {}) do resumo.apertos[#resumo.apertos + 1] = string.format("%d ms: %s", q.t, botao); end
		if q.a ~= anim_c then anim_c = q.a; resumo.suas_animacoes[#resumo.suas_animacoes + 1] = string.format("%d ms: %s", q.t, q.a); end
		if q.m ~= anim_m then
			anim_m = q.m;
			resumo.monstro_animacoes[#resumo.monstro_animacoes + 1] = string.format("%d ms: %s (proximo golpe previsto em %s ms)",
				q.t, tostring(q.m), tostring(q.golpe_em_ms));
		end
		for _, e in ipairs(q.ev or {}) do
			resumo.eventos[#resumo.eventos + 1] = string.format("%d ms: %s", q.t, e);
			if e == "ISS: CONTRA-ATAQUE DEU CERTO" then resumo.iss_deu_certo = true; end
			if e == "LEVOU DANO" then resumo.levou_dano = true; end
		end
	end

	leitura.salvas = leitura.salvas + 1;
	local ok_nome, nome = pcall(os.date, "%Y-%m-%d_%H-%M-%S");
	local arquivo = string.format("aviso_lanca_prints/ss_iss_%s_%d.json", ok_nome and nome or "x", leitura.salvas);
	json.dump_file(arquivo, {
		versao_mod = "0.79", monstro = atual.monstro, ss_em_ms = 0,
		explicacao = "t = ms desde o SS (M5 + Espaco). a = sua animacao (banco:id), q = quadro dela. m = animacao do monstro mais perto, golpe_em_ms = quanto faltava para o proximo golpe previsto. mudou = campos dos botoes que mudaram (comando.campo=valor; buffer = buffer de entrada). apertou = botao apertado neste quadro. ev = eventos.",
		resumo = resumo, quadros = atual.quadros
	});
	leitura.ultima = string.format("%s - %s%s - %d quadros", arquivo, resumo.iss_deu_certo and "ISS deu certo" or "sem contra-ataque do ISS",
		resumo.levou_dano and ", levou dano" or "", #atual.quadros);
	estado.mensagem = "Leitura do SS+ISS salva: " .. arquivo;
end

--[[
	(0.59) SINAIS DA ESPADA NO INSTANTE DO GOLPE. No teste, o aviso do jogo "contra-ataque do ISS
	deu certo" chegou SEMPRE ~300 ms depois do M5 (287 a 343 ms), nao importa quando o golpe
	chegou: ele vem no fim do contra-ataque. O ajuste da 0.58 achou que o golpe chegava tarde e
	levou o tempo do ISS ate 80 ms. Nas leituras, o SINAL da espada (IsIaiKijinMikiriSuccessed)
	liga no instante do golpe (48 a 301 ms depois do M5). Agora:
	  - o tempo do golpe para o aprendizado e o do sinal (FS: IsMikiriSuccessed);
	  - o ajuste do ISS usa o sinal.
]]
local sinais_ls = {};

--[[
	(0.71) BOTOES QUE ESCAPAM DA TRAVA. Voce notou: spamando M1 / M2 o personagem ainda ficava preso
	no golpe e a esquiva nao saia. A trava solta os comandos achados nas suas gravacoes de cada
	botao (M1, M2, M5), mas o jogo pode ter OUTROS comandos de ataque (ex.: M1 + M2 juntos, ou
	um comando diferente no combo). Enquanto a trava esta ativa, o mod olha TODOS os comandos:
	  - um comando desconhecido foi apertado e logo depois (0,4s) comecou um golpe seu = escapou;
	  - foi apertado e nenhum golpe comecou (ex.: andar) = inocente.
	Depois de escapar 3 vezes (e mais vezes do que foi inocente), ele entra na trava.
]]
local vazamento = { candidatos = {}, anim = nil };
local comandos_conhecidos = nil;

local function vigiar_vazamentos(anim)
	if comandos_conhecidos == nil then
		comandos_conhecidos = {};
		for _, grupo in pairs(GRUPOS_DE_BOTOES) do for _, n in ipairs(grupo) do comandos_conhecidos[n] = true; end end
		for _, n in ipairs(comandos_do_m4()) do comandos_conhecidos[n] = true; end
	end
	local agora_lua = os.clock();
	local trava_ativa = agora_lua - (estado.trava_ativa_em or -100) < 0.1;

	-- um golpe seu comecou: os comandos apertados logo antes escaparam da trava
	if anim ~= vazamento.anim then
		if vazamento.anim ~= nil and e_golpe_seu(anim) and trava_ativa then
			for numero, em in pairs(vazamento.candidatos) do
				if agora_lua - em < 0.4 and not (op.comandos_ataque_extra or {})[tostring(numero)] then
					local v = op.vazamentos[tostring(numero)] or { golpe = 0, nada = 0 };
					v.golpe = v.golpe + 1;
					v.contado = true;
					op.vazamentos[tostring(numero)] = v;
					if v.golpe >= 3 and v.golpe > v.nada then
						op.comandos_ataque_extra[tostring(numero)] = true;
						entrada.campos_mudaram = true; -- refaz a lista de escritas
						estado.mensagem = "Trava: comando " .. tostring(numero) .. " escapava e agora e travado tambem";
					end
					salvar_opcoes();
				end
			end
			vazamento.candidatos = {};
		end
		vazamento.anim = anim;
	end

	-- apertados ha mais de 0,4s sem golpe: inocentes
	for numero, em in pairs(vazamento.candidatos) do
		if agora_lua - em >= 0.4 then
			local v = op.vazamentos[tostring(numero)] or { golpe = 0, nada = 0 };
			v.nada = v.nada + 1;
			op.vazamentos[tostring(numero)] = v;
			vazamento.candidatos[numero] = nil;
		end
	end

	if not trava_ativa then return; end
	for _, entrada_jogador in ipairs(entradas_ativas()) do
		local teclas = entrada_jogador:get_field("_Keys");
		local ok_t, tamanho = pcall(function() return teclas:get_size(); end);
		if ok_t and type(tamanho) == "number" then
			for numero = 0, math.min(tamanho, 128) - 1 do
				if not comandos_conhecidos[numero] and not (op.comandos_ataque_extra or {})[tostring(numero)] then
					local tecla = teclas:get_element(numero);
					if tecla ~= nil and tecla:get_field("_OnTrigger") == true then vazamento.candidatos[numero] = agora_lua; end
				end
			end
		end
	end
end

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
	pcall(vigiar_vazamentos, combo.animacao or "?"); -- (0.71)
	pcall(medir_golpes, combo.animacao or "?"); -- (0.64)

	-- (0.60) cada FS apertado: saiu (animacao do FS em ate 0,5s) ou nao (sem dano no meio)
	local anim_agora = combo.animacao or "?";
	local restantes = {};
	for _, t in ipairs(tentativas_fs) do
		if ANIM_FS[anim_agora] then
			anotar_janela("fs", t.idade, true);
		elseif os.clock() - t.em > 0.5 then
			if estado.levou_dano_em == t.dano_antes then anotar_janela("fs", t.idade, false); end
		else
			restantes[#restantes + 1] = t;
		end
	end
	tentativas_fs = restantes;

	-- (0.62) o ISS acertou / contra-atacou: a animacao de agora e do ISS
	local iss_sinal = arma:get_field("IsIaiKijinSlashHitted") == true or arma:get_field("IsIaiKijinMikiriSuccessed") == true;
	if iss_sinal and not sinais_ls.iss and string.sub(anim_agora, 1, 3) == "20:" and not ANIM_SS[anim_agora]
		and not ANIM_ISS[anim_agora] then
		ANIM_ISS[anim_agora] = true;
		estado.bloqueio_mudou = true;
	end
	sinais_ls.iss = iss_sinal;

	for _, nome in ipairs({ "IsIaiKijinMikiriSuccessed", "IsMikiriSuccessed" }) do
		local ligado = arma:get_field(nome) == true;
		if ligado and not sinais_ls[nome] then
			local agora_lua = os.clock();
			if nome == "IsMikiriSuccessed" and anim_agora ~= "?" and not ANIM_FS[anim_agora] then
				ANIM_FS[anim_agora] = true; -- (0.60) o FS deu certo nesta animacao: e animacao do FS
				estado.bloqueio_mudou = true;
			end
			pcall(aprender_por_contra_ataque);
			if nome == "IsIaiKijinMikiriSuccessed" then
				estado.iss_certo_em = agora_lua;
				pcall(ajustar_iss, agora_lua);
			end
		end
		sinais_ls[nome] = ligado;
	end
end

local salvar_relatorio; -- (0.44) definido depois da aba Prints

re.on_frame(function()
	if salvar_relatorio ~= nil then pcall(salvar_relatorio, false); end

	local ok, erro = pcall(acompanhar);
	if not ok then estado.mensagem = "erro: " .. tostring(erro); end

	pcall(desenhar_aviso);

	pcall(vigiar_sinais_ls); -- (0.59)
	local ok_leitura, erro_leitura = pcall(ler_ss_iss);
	if not ok_leitura then estado.mensagem = "erro leitura SS+ISS: " .. tostring(erro_leitura); end

	pcall(atualizar_captura);

	local ok_defesa, erro_defesa = pcall(planejar_defesa);
	if not ok_defesa then teclas_agora = {}; escrita = {}; estado.mensagem = "erro defesa: " .. tostring(erro_defesa); end
	pcall(desenhar_status_entrada);
end);


-- =====================================================================================
-- 8. MENU (REFramework > Script Generated UI > "Aviso de Guarda (Lanca)")
-- =====================================================================================

-- conhecimento de um monstro (ou de todos, se "id" for nil): monstros, animacoes, medicoes
--[[
	(0.45) COBERTURA: de todas as medicoes de um monstro, quantas estao em golpes vistos pelo
	menos 2 vezes (os que o mod ja consegue prever). E uma estimativa de quantos golpes
	daquele monstro o mod ja conhece.
]]
local function cobertura(id)
	local total, cobertas = 0, 0;
	for animacao in pairs(conhecimento[tostring(id)] or {}) do
		for _, g in ipairs(grupos_de(id, animacao) or {}) do
			total = total + g.vezes;
			if g.vezes >= AJUSTES.minimo_amostras then cobertas = cobertas + g.vezes; end
		end
	end
	if total == 0 then return 0; end
	return math.floor(100 * cobertas / total + 0.5);
end

local function contar_conhecimento(id)
	local quantos_monstros, animacoes, medicoes = 0, 0, 0;
	for chave_monstro, golpes in pairs(conhecimento) do
		if id == nil or chave_monstro == tostring(id) then
			quantos_monstros = quantos_monstros + 1;
			for _, lista in pairs(golpes) do
				animacoes = animacoes + 1;
				medicoes = medicoes + #lista;
			end
		end
	end
	return animacoes, medicoes, quantos_monstros;
end

--[[
	ABA "PRINTS"
	Junta num lugar so tudo o que preciso ver para entender um problema. Basta abrir esta
	aba e tirar UM print da tela.
]]
-- (0.44) monta as linhas da aba Prints; "linha" recebe cada linha (na tela ou no relatorio)
local function montar_prints(linha)
	local momento = agora();
	linha("== Defesa Automatica v0.79 ==");

	-- arma e estado
	local cacador = meu_cacador();
	local sacada = cacador and cacador:call("get_IsWeaponOn");
	local _, perfil_atual = perfil_da_arma(cacador or {});
	local m4 = comandos_do_m4();
	linha(string.format("Arma: %s (%s) - sacada: %s - defesa: %s - jogadores: %d - Guard Up: %s - M4: %s",
		perfil_atual and perfil_atual.nome or tostring(pesquisa.arma_tipo),
		perfil_atual and table.concat(perfil_atual.niveis, " > ") or "sem perfil", tostring(sacada),
		not op.guarda_automatica and "desligada" or (estado.motivo_parado == "" and "agindo" or ("parada: " .. estado.motivo_parado)),
		jogadores_na_cacada(), op.tenho_guard_up and "sim" or "nao",
		#m4 > 0 and ("comandos " .. table.concat(m4, ","))
			or (#(op.toques.m4 or {}) > 0 and "gravado, mas sem comando proprio (grave de novo)" or "NAO GRAVADO")));

	local tempos_txt = {};
	if perfil_atual ~= nil then
		for _, acao in ipairs(perfil_atual.niveis) do
			local opcao = perfil_atual.antecedencia[acao];
			if opcao ~= nil then tempos_txt[#tempos_txt + 1] = NOME_ACAO[acao] .. " " .. tostring(op[opcao]); end
		end
		for _, extra in ipairs(perfil_atual.tempos_extras or {}) do
			tempos_txt[#tempos_txt + 1] = extra.opcao .. " " .. tostring(op[extra.opcao]);
		end
	end
	linha("Tempos (ms antes do golpe): " .. (#tempos_txt > 0 and table.concat(tempos_txt, " - ") or "-"));

	-- espada longa
	if perfil_atual == PERFIS.espada_longa then
		local qtd_ataques = 0;
		for _ in pairs(op.animacoes_ataque_ls) do qtd_ataques = qtd_ataques + 1; end
		linha(string.format("Long Sword: em combo = %s - ultimo golpe seu ha %.1fs (janela %d ms) - sua animacao %s - ataques aprendidos %d - toques M5 %d, M2 %d",
			tostring(em_combo_espada_longa()), os.clock() - math.max(combo.ultimo_acerto, combo.ultimo_ataque_em),
			op.ls_janela_combo_ms, tostring(combo.animacao), qtd_ataques, #(op.toques.m5 or {}), #(op.toques.m2 or {})));
		local qtd_bloqueios, maior = 0, 0;
		for _, ms in pairs(bloqueios_ls) do
			qtd_bloqueios = qtd_bloqueios + 1;
			if ms > maior then maior = ms; end
		end
		linha(string.format("Long Sword: bloqueio dos seus botoes na animacao atual %d ms - aprendido em %d animacoes (maior %d ms)",
			bloqueios_ls[combo.animacao or "?"] or op.ls_bloqueio_ms, qtd_bloqueios, maior));
		local res = {};
		for nome, n in pairs(estado.ss_iss_resultados or {}) do res[#res + 1] = nome .. ": " .. n; end
		linha(string.format("SS+ISS (prioridade 1, FS 2, esquiva 3): %s - agora: %s - nesta sessao: %s",
			op.usar_ss_iss and "ligado" or "DESLIGADO", ssiss and (ssiss.fase .. (ssiss.manual and " (SS seu)" or "")) or "-",
			#res > 0 and table.concat(res, ", ") or "nenhum ainda"));
		local nivel_barra = nivel_spirit_gauge();
		local qtd_fs_nao = 0;
		for _, n in pairs(fs_falhas) do if n >= FS_FALHAS_PARA_SS then qtd_fs_nao = qtd_fs_nao + 1; end end
		linha(string.format("Spirit Gauge: nivel %s (%s) - vermelho a partir de %s - %s - modo: %s - golpes que o FS nao defende: %d",
			tostring(nivel_barra), tostring(NOMES_AURA[nivel_barra or -1] or "?"), tostring(AURA_VERMELHA or "3 (padrao)"),
			barra_vermelha() and "VERMELHA: FS > esquiva (SS+ISS so onde o FS falha)" or "abaixo do vermelho: SS+ISS > FS > esquiva",
			(op.somente_ss_iss and op.usar_ss_iss) and "SOMENTE SS+ISS" or "normal", qtd_fs_nao));
		linha(string.format("ISS: %d ms antes do golpe (%s) - golpe chegou depois do M5 nos ultimos ISS certos: %s",
			op.ls_iss_ms, op.iss_ajuste_auto and "ajusta sozinho" or "fixo",
			#(estado.iss_medidas or {}) > 0 and (table.concat(estado.iss_medidas, ", ") .. " ms") or "-"));
		local lista_ss, bloqueadas = {}, 0;
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
		local j_fs, s_fs, f_fs, n_fs = janela_combo("fs");
		local j_ss, s_ss, f_ss, n_ss = janela_combo("ss");
		local function ms(v) return v and tostring(math.floor(v * 1000 + 0.5)) or "-"; end
		linha(string.format("Janela do combo (aprendida): FS ate %s ms (saiu ate %s, nao saiu a partir de %s, %d tentativas) - SS ate %s ms (saiu ate %s, nao saiu %s, %d) - idade do combo agora %s ms",
			ms(j_fs), ms(s_fs), ms(f_fs), n_fs, ms(j_ss), ms(s_ss), ms(f_ss), n_ss, ms(idade_combo())));
		local qtd_golpes, maior_golpe = 0, 0;
		for _, g in pairs(duracao_golpes) do
			qtd_golpes = qtd_golpes + 1;
			if (g.ms or 0) > maior_golpe then maior_golpe = g.ms; end
		end
		local extras_txt = {};
		for numero in pairs(op.comandos_ataque_extra or {}) do extras_txt[#extras_txt + 1] = numero; end
		linha("Trava: comandos extras descobertos: " .. (#extras_txt > 0 and table.concat(extras_txt, ", ") or "nenhum"));
		linha(string.format("Seus golpes: %d medidos (o mais longo prende %d ms) - golpe atual %s prende %s ms - %s",
			qtd_golpes, maior_golpe, tostring(golpe_atual.anim), tostring(duracao_golpes[golpe_atual.anim or "?"] and duracao_golpes[golpe_atual.anim].ms or "-"),
			estado.trava_golpe or "ataques livres"));
		linha(string.format("Leitura do SS+ISS: %s - %d leituras salvas nesta sessao%s",
			estado.leitura_ss_iss and (leitura.atual and "LENDO AGORA" or "ligada") or "desligada", leitura.salvas,
			leitura.ultima and (" - ultima: " .. leitura.ultima) or ""));
	end

	linha(string.format("Vida: %s - ultimo dano ha %.1fs",
		estado.vida_lida and string.format("%.0f", estado.vida_anterior or 0) or "NAO LIDA",
		os.clock() - (estado.levou_dano_em or -1000)));

	-- historico das defesas
	linha("Ultimas defesas (nova primeiro): defesa - ms antes do golpe - sua animacao antes -> 0,25s depois - resultado");
	if #(estado.historico or {}) == 0 then linha("   (nenhuma ainda)"); end
	for _, d in ipairs(estado.historico or {}) do
		linha(string.format("   %s - %d ms - %s -> %s - %s%s", NOME_ACAO[d.defesa] or tostring(d.defesa), d.ms,
			tostring(d.antes), tostring(d.depois or "..."), tostring(d.resultado),
			d.toques and (" - apertou " .. d.toques .. "x") or ""));
	end
	linha("Ultima decisao: " .. (estado.ultima_decisao or "-"));
	linha("Ultimo resultado: " .. (estado.ultimo_resultado or "-"));

	-- monstro mais perto e conhecimento
	local m = monstro_mais_perto();
	if m ~= nil then
		local proximo = nil;
		for _, p in ipairs(m.previstos) do
			local falta = p.tempo - momento;
			if falta >= 0 and (proximo == nil or falta < proximo.falta) then proximo = { falta = falta, guarda = p.guarda }; end
		end
		local a_m, med_m = contar_conhecimento(m.variante);
		local stat = (estado.por_monstro or {})[m.variante] or { vistos = 0, certos = 0 };
		linha(string.format("Monstro: %s (%s) - %.1f m - animacao %s%s",
			m.nome_completo, m.variante, m.distancia or -1, tostring(m.animacao),
			proximo and string.format(" - proximo golpe em %.2fs (tipo %d)", proximo.falta, proximo.guarda) or ""));
		linha(string.format("Conhecimento deste monstro: %d animacoes, %d medicoes - cobertura %d%% - previstos nesta sessao: %d de %d",
			a_m, med_m, cobertura(m.variante), stat.certos, stat.vistos));
	else
		linha("Monstro: nenhum monstro grande por perto");
	end
	local animacoes, medicoes, quantos = contar_conhecimento(nil);
	linha(string.format("Conhecimento (todos): %d monstros, %d animacoes, %d medicoes - previstos nesta sessao: %d de %d - ultimo erro: %s - aprendidos no seu Palico: %d - aprendidos defendendo (FS/ISS): %d",
		quantos, animacoes, medicoes, estado.avisos_certos, estado.impactos_vistos,
		estado.ultimo_erro_ms and (estado.ultimo_erro_ms .. " ms") or "-", estado.aprendidos_outros or 0, estado.aprendidos_contra or 0));

	-- (0.78) fontes novas de aprendizado, invencibilidade, outras armas, fim da quest
	local g78 = estado.ganchos_078 or {};
	local vistas_a, conf_a, so_area = n78.resumo_ativacoes(nil);
	linha(string.format("Aprendizado novo: por contato (esquivas / FS / ISS) %d - contatos descartados %d - pela area de ataque %d (areas vistas %d, relogios acertados %d) - golpes repetidos vistos %d",
		estado.aprendidos_contato or 0, estado.contatos_descartados or 0, estado.aprendidos_ativacao or 0,
		estado.ativacoes_vistas or 0, estado.relogios_acertados or 0, estado.reinicios_vistos or 0));
	linha(string.format("Area de ataque: %d animacoes com area vista, %d confiaveis, %d so com area (golpe nunca chegou em ninguem) - ganchos: contato %s, area %s, invencibilidade %s, fim da quest %s, defesa na hora %s",
		vistas_a, conf_a, so_area, g78.contato and "ok" or "NAO", g78.ativacao and "ok" or "NAO",
		g78.invencibilidade and "ok" or "NAO", g78.fim_quest and "ok" or "NAO", g78.na_hora and "ok" or "NAO"));
	local inv_txt = {};
	for nome, s in pairs(n78.invencibilidade.stats) do
		inv_txt[#inv_txt + 1] = string.format("%s: %d golpes, chegaram em media %d ms depois do inicio (invencibilidade de %d ms)",
			nome, s.n, math.floor(s.soma / math.max(1, s.n) + 0.5), s.janela);
	end
	local ct = estado.contatos_em_voce or {};
	linha(string.format("Contatos de golpes em voce: %d passaram, %d falharam, %d na sua invencibilidade",
		ct.passou or 0, ct.falhou or 0, ct["na invencibilidade"] or 0));
	linha("Invencibilidade: " .. (#inv_txt > 0 and table.concat(inv_txt, " - ") or "nenhum golpe pego na invencibilidade ainda"));
	local nh_txt = {};
	for nome, n in pairs(estado.na_hora_contagem or {}) do nh_txt[#nh_txt + 1] = nome .. " " .. n; end
	linha("Defesa na hora do golpe (outras armas): " .. (#nh_txt > 0 and table.concat(nh_txt, ", ") or "nenhuma nesta sessao"));
	local so_txt = {};
	for motivo, n in pairs(estado.solturas or {}) do so_txt[#so_txt + 1] = motivo .. " " .. n; end
	linha("Monstros soltos (fim da quest / troca de cena): " .. (#so_txt > 0 and table.concat(so_txt, ", ") or "nenhuma vez"));

	if estado.mensagem ~= "" then linha("Mensagem: " .. estado.mensagem); end
end

local function desenhar_aba_prints()
	if not imgui.tree_node("Prints (abra esta aba e tire um print)") then return; end
	montar_prints(function(texto) imgui.text(texto); end);

	local r = estado.relatorio or {};
	imgui.text(string.format("Relatorio automatico: reframework/data/%s (salvo ha %.0fs, %d defesas)",
		tostring(r.arquivo), os.clock() - (r.salvo_em or os.clock()), #(estado.defesas_sessao or {})));
	if imgui.button("Salvar relatorio agora") then pcall(salvar_relatorio, true); end

	imgui.tree_pop();
end

--[[
	(0.44) RELATORIO AUTOMATICO
	Um arquivo por vez que o jogo abre, em reframework/data/aviso_lanca_prints/. Tem as
	linhas da aba Prints (do momento em que foi salvo) e TODAS as defesas da sessao (hora,
	arma, golpe, defesa, ms antes, animacao antes/depois, resultado). Salva:
	  - 10s depois de cada defesa nova (juntando as que vierem nesse meio tempo);
	  - a cada 60s enquanto houver monstro grande por perto;
	  - quando voce clica em "Salvar relatorio agora".
]]
salvar_relatorio = function(forcar)
	local r = estado.relatorio;
	if r == nil then
		local ok_nome, nome = pcall(os.date, "%Y-%m-%d_%H-%M-%S");
		r = { arquivo = "aviso_lanca_prints/relatorio_" .. (ok_nome and nome or tostring(math.floor(os.time and os.time() or 0))) .. ".json",
			salvo_em = os.clock(), defesas_salvas = 0, nova_desde = nil };
		estado.relatorio = r;
	end

	local agora_lua = os.clock();
	local total = #(estado.defesas_sessao or {});
	if total ~= r.defesas_salvas and r.nova_desde == nil then r.nova_desde = agora_lua; end

	local tem_monstro = next(monstros) ~= nil;
	local salvar = forcar
		or (r.nova_desde ~= nil and agora_lua - r.nova_desde >= 10)
		or (tem_monstro and agora_lua - r.salvo_em >= 60);
	if not salvar then return; end

	local linhas = {};
	pcall(montar_prints, function(texto) linhas[#linhas + 1] = texto; end);

	local defesas = {};
	for _, d in ipairs(estado.defesas_sessao or {}) do
		defesas[#defesas + 1] = {
			hora = d.hora, arma = d.arma, golpe = d.golpe, defesa = d.defesa, ms_antes = d.ms,
			animacao_antes = d.antes, animacao_depois = d.depois, resultado = d.resultado, apertos = d.toques
		};
	end

	local ok_hora, hora = pcall(os.date, "%Y-%m-%d %H:%M:%S");
	local por_monstro = {};
	for chave_monstro in pairs(conhecimento) do
		local id = chave_monstro;
		local stat = (estado.por_monstro or {})[chave_monstro] or {};
		local a_m, med_m = contar_conhecimento(chave_monstro);
		por_monstro[#por_monstro + 1] = {
			id = id, nome = nomes_monstros[chave_monstro] or stat.nome, animacoes = a_m, medicoes = med_m, cobertura = cobertura(chave_monstro),
			golpes_em_voce_sessao = stat.vistos, previstos_sessao = stat.certos
		};
	end

	json.dump_file(r.arquivo, {
		versao_mod = "0.79", salvo_as = ok_hora and hora or nil,
		aprendidos_com_outros = estado.aprendidos_outros or 0,
		monstros = por_monstro, prints = linhas, defesas = defesas
	});
	-- (0.47) so a cobertura de cada monstro (para atualizar a "Lista de monstros.txt")
	json.dump_file("aviso_lanca_prints/cobertura.json", { salvo_as = ok_hora and hora or nil, monstros = por_monstro });
	r.salvo_em, r.defesas_salvas, r.nova_desde = agora_lua, total, nil;
end

re.on_draw_ui(function()
	if not imgui.tree_node("Defesa Automatica v0.79") then return; end

	--[[
		MENU SIMPLES: liga/desliga, aviso na tela, status e resumo da sessao.
	]]
	local alterou_simples = false;
	local mudou_simples;

	mudou_simples, op.guarda_automatica = imgui.checkbox("Defesa automatica", op.guarda_automatica);
	alterou_simples = alterou_simples or mudou_simples;

	mudou_simples, op.ativado = imgui.checkbox("Mostrar aviso na tela", op.ativado);
	alterou_simples = alterou_simples or mudou_simples;

	mudou_simples, op.tenho_guard_up = imgui.checkbox("Tenho Guard Up (guardar golpes \"impossiveis\")", op.tenho_guard_up);
	alterou_simples = alterou_simples or mudou_simples;

	if alterou_simples then salvar_opcoes(); end

	-- (0.75) aba da barra de previsao (com uma barra de exemplo enquanto esta aberta)
	-- (0.78) aprendizado novo e defesa na hora do golpe das outras armas
	if imgui.tree_node("Aprendizado e outras armas") then
		local mudou_78, m78 = false, false;
		m78, op.aprender_por_contato = imgui.checkbox("Aprender pelo contato do golpe (esquivas, FS, ISS)", op.aprender_por_contato);
		mudou_78 = mudou_78 or m78;
		m78, op.aprender_por_ativacao = imgui.checkbox("Aprender pela area de ataque do monstro (so animacoes conferidas)", op.aprender_por_ativacao);
		mudou_78 = mudou_78 or m78;
		m78, op.defesa_na_hora_ligada = imgui.checkbox("Outras armas: defesa na hora do golpe", op.defesa_na_hora_ligada);
		mudou_78 = mudou_78 or m78;
		m78, op.na_hora_so_sacada = imgui.checkbox("... so com a arma sacada", op.na_hora_so_sacada);
		mudou_78 = mudou_78 or m78;
		op.na_hora = op.na_hora or {};
		for _, tipo in ipairs(n78.ORDEM) do
			local def = n78.ARMAS[tipo];
			local ligado = op.na_hora[def.chave] ~= false;
			m78, ligado = imgui.checkbox("   " .. def.nome, ligado);
			if m78 then op.na_hora[def.chave] = ligado; mudou_78 = true; end
		end
		imgui.text("Sem dados ainda: Hammer, Hunting Horn, Lance, Gunlance, Insect Glaive (Long Sword usa FS / SS+ISS)");
		if mudou_78 then salvar_opcoes(); end
		imgui.tree_pop();
	end

	pcall(imgui.set_next_item_open, true, 4); -- (0.77) aberta na primeira vez (se o REFramework tiver)
	if imgui.tree_node("Configurar Barra de previsao") then
		estado.barra_exemplo_ate = os.clock() + 0.3;
		local mudou_barra, m_b = false, false;
		m_b, op.barra_desligada = imgui.checkbox("Desligar a barra (nunca mostra a barra de previsao)", op.barra_desligada == true);
		mudou_barra = mudou_barra or m_b;
		if not op.barra_desligada then
			imgui.text("Enquanto esta aba estiver aberta aparece uma barra de exemplo na tela.");
		end
		m_b, op.barra_sempre_visivel = imgui.checkbox("Sempre visivel (desligado = automatico: so aparece com golpe vindo)", op.barra_sempre_visivel == true);
		mudou_barra = mudou_barra or m_b;
		m_b, op.barra_tamanho = imgui.slider_float("Tamanho", op.barra_tamanho or 1, 0.5, 2.0, "%.2f");
		mudou_barra = mudou_barra or m_b;
		m_b, op.barra_opacidade = imgui.slider_float("Opacidade", op.barra_opacidade or 1, 0.1, 1.0, "%.2f");
		mudou_barra = mudou_barra or m_b;
		m_b, op.altura_tela = imgui.slider_float("Posicao vertical (0 = topo, 1 = embaixo)", op.altura_tela or 0.7, 0.05, 0.95, "%.2f");
		mudou_barra = mudou_barra or m_b;
		m_b, op.barra_horizontal = imgui.slider_float("Posicao horizontal (0 = esquerda, 1 = direita)", op.barra_horizontal or 0.5, 0.05, 0.95, "%.2f");
		mudou_barra = mudou_barra or m_b;
		if imgui.button("Voltar ao padrao") then
			op.barra_tamanho, op.barra_opacidade, op.altura_tela, op.barra_horizontal = 1.0, 1.0, 0.70, 0.5;
			mudou_barra = true;
		end
		if mudou_barra then salvar_opcoes(); end
		imgui.tree_pop();
	end

	if estado.perfil == PERFIS.espada_longa then
		local mudou_somente;
		mudou_somente, op.somente_ss_iss = imgui.checkbox("Somente SS+ISS (sem FS e sem esquiva)", op.somente_ss_iss);
		if mudou_somente then
			if op.somente_ss_iss then op.usar_ss_iss = true; end
			salvar_opcoes();
		end
		local _;
		_, estado.leitura_ss_iss = imgui.checkbox("Leitura do SS+ISS (o mod NAO defende, so le os seus SS+ISS)", estado.leitura_ss_iss == true);
		if estado.leitura_ss_iss then
			imgui.text(string.format("  %s - %d leituras salvas (pasta Prints)", leitura.atual and "LENDO AGORA" or "esperando M5 + Espaco",
				leitura.salvas));
			if leitura.ultima then imgui.text("  Ultima: " .. leitura.ultima); end
		end
	end

	-- status em uma linha
	local perfil_status = estado.perfil;
	if not op.guarda_automatica then
		imgui.text("Status: desligada");
	elseif estado.motivo_parado == "" and perfil_status ~= nil then
		imgui.text("Status: defendendo (" .. perfil_status.nome .. ")");
	else
		imgui.text("Status: parado - " .. (estado.motivo_parado ~= "" and estado.motivo_parado or "aguardando"));
	end

	-- resumo da sessao (0.46: vale para qualquer arma)
	local certas, total_def = 0, 0;
	for _, d in ipairs(estado.defesas_sessao or {}) do
		local r = tostring(d.resultado);
		if string.sub(r, 1, 2) == "OK" then certas = certas + 1; total_def = total_def + 1;
		elseif string.find(r, "LEVOU DANO", 1, true) then total_def = total_def + 1; end
	end
	local extras = {};
	if estado.defesas.perfeita > 0 then extras[#extras + 1] = estado.defesas.perfeita .. " guardas perfeitas"; end
	if estado.defesas.power > 0 then extras[#extras + 1] = estado.defesas.power .. " Power Guards"; end
	if (estado.defesas.esquiva_perfeita or 0) > 0 then extras[#extras + 1] = estado.defesas.esquiva_perfeita .. " esquivas perfeitas"; end
	imgui.text(string.format("Nesta sessao: %d de %d defesas sem dano%s", certas, total_def,
		#extras > 0 and (" - " .. table.concat(extras, ", ")) or ""));

	--[[
		"Ajustes da arma" mostra so as opcoes da arma que esta na sua mao; "Diagnostico"
		(Prints e teste de botoes) so precisa ser aberto se eu pedir.
	]]
	local perfil_menu = estado.perfil;

	if perfil_menu ~= nil and imgui.tree_node("Ajustes da arma (" .. perfil_menu.nome .. ")") then
		local mudou_arma, alterado = false, false;

		-- lanca: o que fazer nos golpes guardaveis
		if posicao_no_perfil(perfil_menu, "contra_ataque") ~= nil then
			local acoes = { "contra_ataque", "guarda" };
			local nomes_acoes = { "Contra-ataque", "So a guarda" };
			local atual_acao = (op.acao_guardavel == "guarda") and 2 or 1;
			local alterou_acao, nova_acao = imgui.combo("Nos golpes de frente", atual_acao, nomes_acoes);
			if alterou_acao then op.acao_guardavel = acoes[nova_acao] or "contra_ataque"; mudou_arma = true; end
		end

		-- liga/desliga das defesas que podem ser desligadas (Power Guard, esquiva)
		for _, acao in ipairs(perfil_menu.niveis) do
			local opcao = perfil_menu.desligavel[acao];
			if opcao ~= nil then
				alterado, op[opcao] = imgui.checkbox("Usar " .. NOME_ACAO[acao], op[opcao]);
				mudou_arma = mudou_arma or alterado;
			end
		end

		if perfil_menu == PERFIS.espada_longa then
			alterado, op.usar_ss_iss = imgui.checkbox("Usar SS+ISS (barra abaixo do vermelho: prioridade 1)", op.usar_ss_iss);
			mudou_arma = mudou_arma or alterado;
			alterado, op.ls_sem_fs_abaixo_vermelho = imgui.checkbox("Abaixo do vermelho: esquiva no lugar do FS (o FS zera o carregamento da barra)", op.ls_sem_fs_abaixo_vermelho);
			mudou_arma = mudou_arma or alterado;
			local qtd_fs_nao = 0;
			for _, n in pairs(fs_falhas) do if n >= FS_FALHAS_PARA_SS then qtd_fs_nao = qtd_fs_nao + 1; end end
			imgui.text(string.format("Golpes que o FS nao defende (usam SS+ISS com a barra vermelha): %d", qtd_fs_nao));
			alterado, op.iss_ajuste_auto = imgui.checkbox("Tempo do ISS se ajusta sozinho", op.iss_ajuste_auto);
			mudou_arma = mudou_arma or alterado;
			mudou_arma = mudou_arma or alterado;
			if imgui.button("Esquecer os golpes que o FS nao defende") then
				fs_falhas = {};
				json.dump_file("aviso_lanca_defesas.json", { golpes = defesas_aprendidas, bloqueios = bloqueios_ls, fs_falhas = fs_falhas, ss_animacoes = ss_animacoes, ss_sem_golpe = ss_sem_golpe, janela_combo = janela_combo_dados, anim_fs = ANIM_FS, anim_iss = ANIM_ISS, duracao_golpes = duracao_golpes });
			end
		end

		-- tempo de cada defesa da arma (quanto antes do golpe ela comeca)
		for _, acao in ipairs(perfil_menu.niveis) do
			local opcao = perfil_menu.antecedencia[acao];
			if opcao ~= nil then
				local maximo = (acao == "power_guard") and 1000 or ((acao == "contra_ataque") and 800 or 500);
				local rotulo = (perfil_menu.rotulo_tempo and perfil_menu.rotulo_tempo[acao]) or ("Tempo: " .. NOME_ACAO[acao] .. " (ms antes do golpe)");
				alterado, op[opcao] = imgui.slider_int(rotulo, op[opcao] or 150, 0, maximo);
				mudou_arma = mudou_arma or alterado;
			end
		end

		-- tempos que fazem parte de uma defesa (ex.: o Iai depois do Special Sheathe)
		for _, extra in ipairs(perfil_menu.tempos_extras or {}) do
			alterado, op[extra.opcao] = imgui.slider_int(extra.nome, op[extra.opcao] or 150, 0, extra.maximo or 500);
			mudou_arma = mudou_arma or alterado;
		end

		if mudou_arma then salvar_opcoes(); end
		imgui.tree_pop();
	end

	if imgui.tree_node("Diagnostico (so se eu pedir)") then
		pcall(desenhar_aba_prints);

		-- testar os botoes (ex.: guarda da Espada e Escudo)
		if imgui.tree_node("Testar / reaprender botoes") then
			local alvos = { "guarda", "contra_ataque", "power_guard", "esquiva", "foresight", "toque_m5", "toque_m2", "toque_m4" };
			local nomes = { "Guarda (M5)", "Contra-ataque (M5 e depois M2)", "Power Guard (M5, M2 e Espaco)", "Esquiva (Espaco)",
				"Foresight Slash (Long Sword)", "Gravar toque do M5 (Foresight)", "Gravar toque do M2 (Foresight)", "Gravar toque do M4 (guardar a arma e correr)" };
			local e_combo = entrada.alvo == "foresight";
			local atual = 1;
			for i, a in ipairs(alvos) do if a == entrada.alvo then atual = i; end end

			local alterou_alvo, novo = imgui.combo("Botao", atual, nomes);
			if alterou_alvo then entrada.alvo = alvos[novo] or "guarda"; entrada.achados = {}; end

			if e_combo then
				imgui.text("O teste comeca 8 segundos depois do clique: feche o menu e, na espada longa, de um golpe antes.");
			end
			if imgui.button("Testar: o mod aperta " .. NOME_DO_ALVO[entrada.alvo] .. " (comeca em 8 segundos)") then
				entrada.forcar_de = agora() + 8;
				entrada.teste_estado = {};
				entrada.forcar_ate = entrada.forcar_de + 5;
			end

			-- se o teste nao funcionar com alguma arma, da para reaprender o botao
			if not e_combo then
			imgui.text("Se o teste nao funcionar, com a arma SACADA e sem monstro perto:");
			if imgui.button("Passo 1: captura PARADO (sem apertar nada)") then comecar_captura(1); end
			local texto_passo2 = (entrada.alvo == "esquiva") and "Passo 2: captura APERTANDO E SOLTANDO O ESPACO UMA VEZ" or ("Passo 2: captura SEGURANDO " .. NOME_DO_ALVO[entrada.alvo]);
			if ALVO_TOQUE[entrada.alvo] then texto_passo2 = "Passo 2: captura APERTANDO E SOLTANDO O " .. string.upper(ALVO_TOQUE[entrada.alvo]) .. " UMA VEZ"; end
			if imgui.button(texto_passo2) then comecar_captura(2); end

			if #entrada.achados > 0 then
				imgui.text(string.format("Aprendido: %d campos", #entrada.achados));
			elseif entrada.capturou_2 and entrada.fase == "parado" then
				imgui.text("Nao achei diferenca entre as capturas. Repita o passo 2 segurando o botao o tempo todo.");
			end
			end -- not e_combo

			imgui.tree_pop();
		end

		imgui.tree_pop();
	end

	imgui.tree_pop();
end);


-- =====================================================================================
-- INICIO
-- =====================================================================================

pcall(carregar_opcoes);

pcall(ligar_pontos_de_escrita);
pcall(carregar_conhecimento);

pcall(function()
	if op.limpeza_golpes_065 == true then return; end
	for anim_g in pairs(duracao_golpes) do
		if not e_golpe_seu(anim_g) then duracao_golpes[anim_g] = nil; end
	end
	for _, g in pairs(duracao_golpes) do
		for seguinte in pairs(g.prox or {}) do
			if not e_golpe_seu(seguinte) then g.prox[seguinte] = nil; end
		end
	end
	estado.bloqueio_mudou = true;
	op.limpeza_golpes_065 = true;
	salvar_opcoes();
end);

pcall(function()
	if op.reset_postura_062 == true then return; end
	op.postura_medida_ms = 0;
	op.reset_postura_062 = true;
	salvar_opcoes();
end);

pcall(function()
	if op.reset_iss_059 == true then return; end
	op.ls_iss_ms = 150;
	op.reset_iss_059 = true;
	salvar_opcoes();
end);

--[[
	(0.53) LIMPEZA UNICA E COMPLETA (como voce pediu): apaga TUDO que foi aprendido do Arkveld e
	dos monstros enfrentados no SOS em 13/11 - os tempos dos golpes e as defesas aprendidas de
	cada golpe. Eles comecam do zero:
	  Arkveld (27), Lala Barina (21), Tempered Mizutsune (13:t), Tempered Nu Udra (25:t),
	  Rey Dau (23), Xu Wu (31), Tempered Xu Wu (31:t), Tempered Blangonga (7:t),
	  Congalala (6), Rathian (0), Rathalos (1).
	Ficam: Chatacabra, Ajarakan, Quematrice, Tempered Congalala e Doshaguma.
]]
pcall(function()
	if op.limpeza_sos_053 == true then return; end
	local apagar = {};
	for _, chave_monstro in ipairs({ "27", "21", "13:t", "25:t", "23", "31", "31:t", "7:t", "6", "0", "1" }) do
		apagar[chave_monstro] = true;
		conhecimento[chave_monstro] = nil;
	end
	grupos_cache = {};
	salvar_conhecimento();

	-- defesas aprendidas: chave "arma:monstro:banco:animacao" (o monstro pode ter ":t" ou ":at")
	for chave in pairs(defesas_aprendidas) do
		local resto = string.match(chave, "^[^:]+:(.+)$");
		local monstro = resto and string.match(resto, "^(.+):%d+:%d+$");
		if monstro ~= nil and apagar[monstro] then defesas_aprendidas[chave] = nil; end
	end
	json.dump_file("aviso_lanca_defesas.json", { golpes = defesas_aprendidas, bloqueios = bloqueios_ls, fs_falhas = fs_falhas, ss_animacoes = ss_animacoes, ss_sem_golpe = ss_sem_golpe, janela_combo = janela_combo_dados, anim_fs = ANIM_FS, anim_iss = ANIM_ISS, duracao_golpes = duracao_golpes });

	op.limpeza_sos_053 = true;
	salvar_opcoes();
end);

--[[
	(0.54) LIMPEZA UNICA: no Tempered Rathalos e no Doshaguma havia medicoes de golpes em outros
	alvos que podem ter sido bots. Como nao da para saber se foram no Palico ou num bot, saem
	(as medicoes dos golpes em VOCE ficam).
]]
pcall(function()
	if op.limpeza_bots_054 == true then return; end
	for _, chave_monstro in ipairs({ "1:t", "16" }) do
		local golpes = conhecimento[chave_monstro];
		if golpes ~= nil then
			for animacao, lista in pairs(golpes) do
				local nova = {};
				for _, medicao in ipairs(lista) do
					if (medicao[3] or 0) > 0 then nova[#nova + 1] = medicao; end
				end
				if #nova > 0 then golpes[animacao] = nova; else golpes[animacao] = nil; end
			end
			if next(golpes) == nil then conhecimento[chave_monstro] = nil; end
		end
	end
	grupos_cache = {};
	salvar_conhecimento();
	op.limpeza_bots_054 = true;
	salvar_opcoes();
end);
