# Defesa Automática - Monster Hunter Wilds

Mod em Lua para o [REFramework](https://github.com/praydog/REFramework). Enquanto você luta, ele aprende os golpes dos monstros grandes. Quando vê chegando um golpe que já conhece, mostra uma barra de previsão na tela (o marcador encosta na linha na hora do impacto) e faz a defesa da sua arma no tempo certo: guarda, Power Guard, Foresight Slash, Special Sheathe + Iai Spirit Slash, esquiva e as outras.

Funciona com as 14 armas, jogando sozinho ou no SOS.

O "IA" do nome é aprendizado por medição: o mod mede o tempo e o alcance de cada golpe e guarda o que funcionou. Não há rede neural.

## O que o mod não faz

O mod não anula golpe do monstro e não dá invencibilidade. A defesa é a mesma ação que você faria: ele pede a ação ao jogo ou aperta os botões. Nenhum valor do jogo muda (dano, vida, duração da invencibilidade). Com a arma guardada, ele não faz nada.

## Requisitos

- Monster Hunter Wilds no PC (Steam). O REFramework só existe no PC, então o mod não roda no PlayStation nem no Xbox. Dá para jogar com controle no PC normalmente.
- [REFramework](https://github.com/praydog/REFramework)

## Instalação

1. Instale o REFramework na pasta do jogo.
2. Copie a versão mais nova (`aviso_lanca_vX.YY.lua`) para `MonsterHunterWilds/reframework/autorun/` e deixe só uma versão do mod nessa pasta.
3. Abra o jogo. O menu do mod fica no REFramework (tecla Insert), em "Defesa Automatica".

## Botões

O README usa os botões padrão do jogo:

| Ação | Controle PlayStation | Controle Xbox | Teclado e mouse |
|---|---|---|---|
| Ataque especial / guarda | R2 | RT | botão direito |
| Ataque normal | △ | Y | botão esquerdo |
| Segundo ataque | ○ | B | veja Opções > Controles |
| Esquiva | X | A | Espaço |
| Guardar a arma | □ | X | Shift ou E |

Na maior parte das defesas o mod pede a ação direto ao jogo, e aí os seus botões não importam. Algumas defesas usam toques gravados. Se você mudou os botões do jogo, grave esses toques de novo em Avancado > Testar / reaprender botoes.

## Menu

- **Defesa automatica**: liga e desliga. **Mostrar aviso na tela**: liga e desliga o aviso.
- **Configurar Barra de previsao**: tamanho, opacidade e posição da barra. Ela pode ficar sempre visível ou desligada.
- **Ajustes da arma**: mostra só as opções da arma que está na mão, como usar Power Guard, usar SS+ISS ou Somente SS+ISS.
- **Avancado**: relatório, tempo de cada defesa, teste e gravação dos botões.

## Arquivos que o mod cria (em `reframework/data/`)

| Arquivo | O que guarda |
|---|---|
| `aviso_lanca_aprendizado.json` | golpes aprendidos de cada monstro. Normal, Tempered, Arch-tempered e Guardian ficam separados. |
| `aviso_lanca_ativacoes.json` | áreas de ataque vistas, com tempo e alcance de cada golpe |
| `aviso_lanca_defesas.json` | qual defesa funciona em cada golpe |
| `aviso_lanca_opcoes.json` | opções do menu |
| `aviso_lanca_prints/` | relatório de cada sessão, com defesas, danos e o quanto o mod conhece de cada monstro |

## Como ele aprende

Todo golpe de monstro é uma sequência de animações. O mod mede quanto tempo passa entre o começo da animação e o impacto. Essa medida vem de golpes que acertam você, de golpes que você defende ou esquiva, da área de ataque que o monstro liga (mesmo quando ela não pega ninguém) e da área de ataque chegando perto do seu corpo.

Depois de ver o mesmo golpe 2 vezes, o mod já avisa e defende. No SOS, golpes em outros jogadores não ensinam nada, porque chegam ao seu jogo atrasados pela rede.

## Prioridades

| Arma | Ordem das defesas |
|---|---|
| Lance | guarda (perfeita ou normal), depois Power Guard, depois esquiva |
| Long Sword | barra de espírito abaixo do vermelho: SS+ISS, depois Foresight Slash, depois esquiva. Barra vermelha: Foresight Slash e esquiva, e o SS+ISS só nos golpes em que o FS falha. |
| Gunlance, Sword and Shield, Great Sword, Charge Blade (forma espada) | guarda, depois esquiva |
| Switch Axe | Counter Rising Slash (forma espada), depois esquiva |
| Hammer | Charged Step, depois esquiva |
| Heavy Bowgun | Perfect Block, depois esquiva |
| Outras armas | esquiva |

Em todas as armas, guardar a arma e correr vem antes de tudo: o mod nunca interrompe esse comando. Ele precisa estar gravado no menu Avancado.

## Pastas do repositório

| Pasta | O que tem |
|---|---|
| raiz | todas as versões do mod (`aviso_lanca_v*.lua`), a lista de monstros com a porcentagem de conhecimento e o script que atualiza essa lista |
| `core/` | a versão que estava no jogo e a configuração do menu |
| `brain/` | o que o mod aprendeu: golpes, áreas de ataque e defesas |
| `models/` | os toques de botão gravados |
| `cognition/` | relatórios das lutas, leituras do SS+ISS e rascunhos de análise |
| `agent/` | ferramentas de verificação, scripts que montaram cada versão e as regras do projeto |
| `imagens/` | as imagens deste README |

---

# Histórico de versões

## 1.4x - Lance

- **1.40** A Lance fica sem contra-ataque: guarda, Power Guard e esquiva.

## 1.3x - Lance, limpeza e SOS

- **1.39** Lance: quando você leva o golpe, a defesa conta como falha mesmo que o jogo tenha avisado guarda. Golpe previsto pela geometria não muda o aprendizado. A defesa de um golpe só sobe de nível depois de 2 falhas seguidas.
- **1.38** Lance: ordem nova (guarda, Power Guard, contra-ataque, esquiva). A defesa é pedida de novo a cada 0,12s até sair, por cima de qualquer animação, inclusive durante a corrida da Lance. O contra-ataque passa a ser pedido direto ao jogo.
- **1.37** Omega Planetes e Savage zerados, uma vez só. Defesa que começou tarde não muda o aprendizado. Power Guard e esquiva em cima da hora corrigidos.
- **1.36** O Savage Omega Planetes aparece com o nome certo (antes saía "Tempered").
- **1.35** Lance: o mod conferia a defesa por um efeito que o jogo repete a cada quadro e achava que tinha defendido quando você apanhava. Guarda e Power Guard são pedidos de novo se o jogo não aceitar. O botão de ataque do contra-ataque só é apertado com a guarda na tela.
- **1.34** Revisão da 1.28 à 1.33: a defesa pela geometria passa a valer no SOS. Limpeza do código e do menu.
- **1.33** Volta a regra de SS+ISS da 1.29 com a barra vermelha. Sai a medição quadro a quadro da invencibilidade, porque o valor que o jogo informa já inclui o Evade Window.
- **1.32** Teste com mais SS+ISS na barra vermelha (desfeito na 1.33).
- **1.31** Revisão da medição de invencibilidade: usa a mediana e a esquiva sai no máximo 200 ms mais cedo.
- **1.30** "FS já em andamento" só espera se esse FS ainda cobre o golpe.

## 1.2x - Skills, dano e alcance

- **1.29** O alcance do golpe também vem da área de ataque. Corrige golpes que chegavam mais longe do que já tinham acertado.
- **1.28** Acertos do FS feitos com mais invencibilidade (Evade Window) não enganam o aprendizado quando você joga sem a skill.
- **1.27** A invencibilidade é lida do jogo a cada momento (Evade Window, Bubbly Dance, mantos). Esquiva e FS saem mais cedo quando ela é maior.
- **1.26** "Levou o golpe" vem do próprio jogo, não da vida. Isso vale com Divine Blessing, escudo do Gogmazios, Rocksteady, veneno e fogo. Fogo amigo não conta.
- **1.25** Perda de vida sem golpe (veneno, efeitos) é ignorada para qualquer monstro.
- **1.24** Revisão da regra dos 3 FS.
- **1.23** No máximo 3 FS seguidos; o 4º vira esquiva.
- **1.22** Limpeza de ajustes do ISS causados por dano de efeito.
- **1.21** O dano pequeno de efeito (o tique do Gore Magala) não conta como golpe.
- **1.20** Aprende pela área de ataque sozinha, mesmo quando o golpe não acerta ninguém.

## 1.0x e 1.1x - Long Sword

- **1.19** Preparação para o SOS: só contam os avisos da sua arma.
- **1.18** O ISS não tem invencibilidade, só o contra de 0,3s. Os golpes seguintes ficam com o FS.
- **1.17** Dano na postura só conta contra o golpe certo.
- **1.16** Fim do teste do FS sem barra: FS sem barra não protege.
- **1.15** Correção do relatório. O SS+ISS é aprendido por golpe.
- **1.14** O teste do FS sem barra fica sempre automático.
- **1.13** Teste automático do FS sem barra.
- **1.12** O ISS só fica protegido de interrupções enquanto protege você.
- **1.11** Medição do FS corrigida.
- **1.10** Correção: golpes sem dano (rugido, vento) davam erro.
- **1.09** Correção urgente da 1.08, que dava erro a cada quadro.
- **1.08** Medição da barra de espírito em cada FS.
- **1.07** FS sem barra de espírito nunca é usado.
- **1.06** O relatório lista todos os danos levados.
- **1.05** O SS não corta o começo do FS. O tempo do ISS é aprendido por golpe.
- **1.04** Primeira versão estável da Long Sword: SS+ISS primeiro, depois FS, depois esquiva. O FS só sai dentro do combo.
- **1.03** Nada interrompe o SS+ISS até o fim da animação.
- **1.02** FS e esquiva forçados por cima de qualquer animação.
- **1.01** O SS não é pedido durante esquiva ou dano.
- **1.00** SS+ISS que dá certo sobe um nível. O FS sai quando não dá tempo de SS+ISS.

## 0.9x - As 14 armas e ações forçadas

- **0.99** Luta com as 14 armas. Guarda, contra-ataque e Power Guard forçados.
- **0.98** Charge Blade: a esquiva da forma machado não desfaz a forma.

  Luta contra o Chatacabra com as 14 armas, uma de cada vez (resultado na 0.99).

  ![Luta contra o Chatacabra com as 14 armas, uma de cada vez (resultado na 0.99).](imagens/v0.98-chat-1.png)

- **0.97** Charge Blade: forma espada usa guarda, forma machado usa esquiva.
- **0.96** Ações das 14 armas medidas em testes (Charged Step, Counter da Switch Axe e outras).
- **0.95** Switch Axe: Counter Rising Slash.
- **0.94** O relatório lista as ações do jogo de cada arma.
- **0.93** Hammer: o Charged Step respeita a carga.
- **0.92** Heavy Bowgun: Perfect Block.
- **0.91** Perfil para as 14 armas. Guard Up passa a ser sempre considerado.
- **0.90** Limpeza do menu e do código.

## 0.8x - Aprendizado novo e ações forçadas

- **0.89** FS, SS, ISS e esquiva pedidos direto ao jogo na hora da defesa.
- **0.88** Correção do travamento no "Saving..." e da trava de botões que vazava.
- **0.87** FS e ISS pedidos direto ao jogo, mas só quando o jogo aceitaria.
- **0.86** Os seus ataques ficam travados antes do SS+ISS.
- **0.85** A trava dos seus golpes fica mais segura.
- **0.84** O relatório mostra a causa de cada falha.
- **0.83** Long Sword parada: o mod aperta uma estocada (○ / B) para abrir o combo e soltar o SS+ISS.
- **0.82** Projéteis, alcance e geometria das áreas de ataque.
- **0.81** Com a arma guardada, o mod não faz nada. Valores de mods já testados têm preferência.
- **0.80** O mod só lê o jogo e aperta botões reais.
- **0.79** Ajustes no aprendizado novo.
- **0.78** Aprende pelo contato do golpe e pela área de ataque.

## 0.7x - Barra de previsão e golpes múltiplos

- **0.77** Opção "Desligar a barra".
- **0.76** Opção "Sempre visível".

  A barra configurável ainda não aparecia na tela; a opção "Desligar a barra" entrou na 0.77.

  ![A barra configurável ainda não aparecia na tela; a opção "Desligar a barra" entrou na 0.77.](imagens/v0.76-chat-1.png)

- **0.75** Aba "Configurar Barra de previsão" (tamanho, opacidade, posição).
- **0.74** Barra fixa de 4s.
- **0.73** Ajustes da barra de previsão.
- **0.72** A trava também mede o FS e o ISS.
- **0.71** A trava descobre botões de ataque que escapavam.
- **0.70** Golpes múltiplos, em sequência rápida.

## 0.6x - Trava dos seus golpes (Long Sword)

- **0.69** Golpes em sequência usam SS+ISS na barra vermelha.
- **0.68** Correção de travamento no fim da luta, quando o monstro já tinha sumido.
- **0.67** Escrita mais segura nos botões do jogo.
- **0.66** Botões travados também somem da memória de apertos do jogo.

  O jogo travou no fim da luta contra o Chatacabra (corrigido na 0.67 e na 0.68).

  ![O jogo travou no fim da luta contra o Chatacabra (corrigido na 0.67 e na 0.68).](imagens/v0.66-chat-1.png)

- **0.65** Trava corrigida: FS, SS e ISS não contam como golpe seu.
- **0.64** A trava usa o tempo que cada golpe seu prende o personagem.
- **0.63** Ataques travados antes do SS.
- **0.62** Correção da duração máxima da postura do SS+ISS.
- **0.61** A postura do SS fica travada quando vem golpe.
- **0.60** O mod aprende até quando o combo deixa sair FS e SS.

## 0.5x - SS+ISS e online

- **0.59** SS+ISS: os seus botões ficam livres até o SS sair.
- **0.58** Aprende também quando o FS ou o ISS defendem.

  Botões novos no menu, antes de uma luta contra o Chatacabra.

  ![Botões novos no menu, antes de uma luta contra o Chatacabra.](imagens/v0.58-chat-1.png)

- **0.57** A prioridade segue a barra de espírito.
- **0.56** SS+ISS automático.
- **0.55** Leitura dos SS+ISS que você faz na mão.

  Relatório do mod e o esquema de como usar o SS+ISS: o SS (vermelho) sai antes, e o ISS (azul) sai na hora do golpe.

  ![Relatório do mod e o esquema de como usar o SS+ISS: o SS (vermelho) sai antes, e o ISS (azul) sai na hora do golpe.](imagens/v0.55-chat-1.png)

  ![Relatório do mod e o esquema de como usar o SS+ISS: o SS (vermelho) sai antes, e o ISS (azul) sai na hora do golpe.](imagens/v0.55-chat-2.png)

- **0.54** Além dos golpes em você, só aprende com golpes no Palico.
- **0.53** Limpeza dos monstros aprendidos no SOS.
- **0.52** Online: não aprende com golpes em outros jogadores.
- **0.51** A trava dos botões é aprendida por animação.
- **0.50** Revisão da 0.45 à 0.49.

## 0.4x - Foresight, relatório e variantes

- **0.49** Cada variante de monstro tem o seu aprendizado. Guardar a arma e correr vira a prioridade máxima.
- **0.48** O Foresight tem prioridade sobre todos os seus botões.

  Print usado para separar o aprendizado por variante (normal, Tempered e Arch-tempered), feito na 0.49.

  ![Print usado para separar o aprendizado por variante (normal, Tempered e Arch-tempered), feito na 0.49.](imagens/v0.48-chat-1.png)

- **0.47** O nome de cada monstro fica salvo (lista com porcentagem).
- **0.46** O combo conta os botões de ataque. Menu mais simples.
- **0.45** Aprende com golpes no Palico. Mostra quanto conhece de cada monstro.
- **0.44** Relatório automático.
- **0.43** Limpeza do código.

  Testes com Dual Blades e Hunting Horn, os dois com ótimo resultado, e com a Light Bowgun.

  ![Testes com Dual Blades e Hunting Horn, os dois com ótimo resultado, e com a Light Bowgun.](imagens/v0.43-chat-1.png)

  ![Testes com Dual Blades e Hunting Horn, os dois com ótimo resultado, e com a Light Bowgun.](imagens/v0.43-chat-2.png)

  ![Testes com Dual Blades e Hunting Horn, os dois com ótimo resultado, e com a Light Bowgun.](imagens/v0.43-chat-3.png)

- **0.42** Foresight e esquiva usam a memória de apertos do jogo (versão estável).

  O FS saiu em quase todos os golpes do Chatacabra. O primeiro print é de depois que ele morreu.

  ![O FS saiu em quase todos os golpes do Chatacabra. O primeiro print é de depois que ele morreu.](imagens/v0.42-chat-1.png)

  ![O FS saiu em quase todos os golpes do Chatacabra. O primeiro print é de depois que ele morreu.](imagens/v0.42-chat-2.png)

- **0.41** Long Sword só com Foresight e esquiva.

  Luta em que o mod não fez nenhuma esquiva nem FS; alguns FS foram feitos na mão.

  ![Luta em que o mod não fez nenhuma esquiva nem FS; alguns FS foram feitos na mão.](imagens/v0.41-chat-1.png)

- **0.40** Ataque automático da Long Sword (removido na 0.41).

  Toques gravados e relatório. O ataque automático saiu na versão seguinte.

  ![Toques gravados e relatório. O ataque automático saiu na versão seguinte.](imagens/v0.40-chat-1.png)


## 0.3x - Long Sword e Hammer

- **0.39** Iai: o mod segura o botão especial (R2 / RT) até o Iai sair.

  O Iai ainda não saía. Na luta, só saíram alguns Special Sheathe.

  ![O Iai ainda não saía. Na luta, só saíram alguns Special Sheathe.](imagens/v0.39-chat-1.png)

  ![O Iai ainda não saía. Na luta, só saíram alguns Special Sheathe.](imagens/v0.39-chat-2.png)

- **0.38** Foresight e Iai no mesmo tempo da guarda.
- **0.37** Apertos de 1 quadro.
- **0.36** Iai usa a memória de apertos do jogo. O Foresight é repetido até sair.

  Esquiva, FS e Iai ainda sem funcionar.

  ![Esquiva, FS e Iai ainda sem funcionar.](imagens/v0.36-chat-1.png)

  ![Esquiva, FS e Iai ainda sem funcionar.](imagens/v0.36-chat-2.png)

- **0.35** Hammer removido. Histórico das defesas.

  O Iai não saía depois do Special Sheathe. Na luta contra o Chatacabra, esquiva, FS e Iai não saíam.

  ![O Iai não saía depois do Special Sheathe. Na luta contra o Chatacabra, esquiva, FS e Iai não saíam.](imagens/v0.35-chat-1.png)

  ![O Iai não saía depois do Special Sheathe. Na luta contra o Chatacabra, esquiva, FS e Iai não saíam.](imagens/v0.35-chat-2.png)

- **0.34** Toque gravado do botão especial (R2 / RT). Dano medido pela vida.

  Teste do toque gravado do botão especial (R2 / RT), que funcionou.

  ![Teste do toque gravado do botão especial (R2 / RT), que funcionou.](imagens/v0.34-chat-1.png)

- **0.33** O combo da Long Sword dura 2,5s.

  O FS saiu bem no teste; o Iai ficava parado com a arma na bainha.

  ![O FS saiu bem no teste; o Iai ficava parado com a arma na bainha.](imagens/v0.33-chat-1.png)

- **0.32** A guarda fica segurada em golpes seguidos.

  Relatório depois de matar 2 Chatacabra com a Lance, teste da Sword and Shield (guarda e esquiva funcionando) e o primeiro teste do FS da Long Sword.

  ![Relatório depois de matar 2 Chatacabra com a Lance, teste da Sword and Shield (guarda e esquiva funcionando) e o primeiro teste do FS da Long Sword.](imagens/v0.32-chat-1.png)

  ![Relatório depois de matar 2 Chatacabra com a Lance, teste da Sword and Shield (guarda e esquiva funcionando) e o primeiro teste do FS da Long Sword.](imagens/v0.32-chat-2.png)

  ![Relatório depois de matar 2 Chatacabra com a Lance, teste da Sword and Shield (guarda e esquiva funcionando) e o primeiro teste do FS da Long Sword.](imagens/v0.32-chat-3.png)

  ![Relatório depois de matar 2 Chatacabra com a Lance, teste da Sword and Shield (guarda e esquiva funcionando) e o primeiro teste do FS da Long Sword.](imagens/v0.32-chat-4.png)

- **0.31** Guard Up: golpes "impossíveis de guardar" passam a ser guardados.
- **0.30** Revisão da Long Sword e do Hammer.

## 0.2x - Prioridade, direção e 7 armas

- **0.29** Long Sword (Foresight, SS + Iai) e Hammer (Charged Step). Os comandos da Long Sword foram estudados a partir da lista de ações do jogo, parado e depois de um golpe:

  ![Comandos da Long Sword parado e depois de um golpe](imagens/v0.29-comandos-long-sword.png)

- **0.28** Menu simples.

  Prioridades do Hammer (Charged Step, depois esquiva) e da Sword and Shield.

  ![Prioridades do Hammer (Charged Step, depois esquiva) e da Sword and Shield.](imagens/v0.28-chat-1.png)

  ![Prioridades do Hammer (Charged Step, depois esquiva) e da Sword and Shield.](imagens/v0.28-chat-2.png)

- **0.27** 7 armas.
- **0.26** Exportação por arma.

  O botão "Começar gravação" e a exportação da estrutura de cada arma e dos controles do jogo.

  ![O botão "Começar gravação" e a exportação da estrutura de cada arma e dos controles do jogo.](imagens/v0.26-chat-1.png)

  ![O botão "Começar gravação" e a exportação da estrutura de cada arma e dos controles do jogo.](imagens/v0.26-chat-2.png)

- **0.25** Menu simples e multiplayer.
- **0.24** Perfis de arma.
- **0.23** Todos os monstros grandes.
- **0.22** Power Guard nas sequências de golpes.
- **0.21** Power Guard com os três botões segurados.

  O Power Guard funcionando no teste, e o relatório da luta contra o Arkveld: 18 guardas perfeitas e 7 Power Guards.

  ![O Power Guard funcionando no teste, e o relatório da luta contra o Arkveld: 18 guardas perfeitas e 7 Power Guards.](imagens/v0.21-chat-1.png)

  ![O Power Guard funcionando no teste, e o relatório da luta contra o Arkveld: 18 guardas perfeitas e 7 Power Guards.](imagens/v0.21-chat-2.png)

- **0.20** Power Guard na ordem certa.

## 0.1x - Defesa automática

- **0.19** Defesa com prioridade e direção do golpe.

  O Power Guard saía na ordem errada: 2 esquivas e 1 guarda.

  ![O Power Guard saía na ordem errada: 2 esquivas e 1 guarda.](imagens/v0.19-chat-1.png)

- **0.18** Botão de esquiva em modo seguro.

  Teste do Power Guard (saía só um contra-ataque longo, faltava a parte da esquiva) e da esquiva, que deu certo.

  ![Teste do Power Guard (saía só um contra-ataque longo, faltava a parte da esquiva) e da esquiva, que deu certo.](imagens/v0.18-chat-1.png)

- **0.17** Toque gravado da esquiva.
- **0.16** Escrita nos botões depois da leitura do mouse.

  A guarda funcionando; o contra-ataque saiu certo uma vez e depois ficou guardando e soltando.

  ![A guarda funcionando; o contra-ataque saiu certo uma vez e depois ficou guardando e soltando.](imagens/v0.16-chat-1.png)

- **0.15** Escrita segura.

  O jogo parou de travar, mas os testes de guarda e contra-ataque não faziam nenhuma ação.

  ![O jogo parou de travar, mas os testes de guarda e contra-ataque não faziam nenhuma ação.](imagens/v0.15-chat-1.png)

- **0.14** Aba "Prints".
- **0.13** Contra-ataque.
- **0.11 e 0.12** Guarda, Power Guard e esquiva.

  A guarda funcionando no teste; a esquiva ainda não, e o contra-ataque só guardava e soltava.

  ![A guarda funcionando no teste; a esquiva ainda não, e o contra-ataque só guardava e soltava.](imagens/v0.11-chat-1.png)

  ![A guarda funcionando no teste; a esquiva ainda não, e o contra-ataque só guardava e soltava.](imagens/v0.11-chat-2.png)

- **0.9 e 0.10** Primeira defesa automática: guarda, contra-ataque e esquiva.

## 0.3 a 0.8 - Primeiras versões

- **0.8** Guarda automática.

  Primeiros testes da guarda e da esquiva automáticas.

  ![Primeiros testes da guarda e da esquiva automáticas.](imagens/v0.8-chat-1.png)

  ![Primeiros testes da guarda e da esquiva automáticas.](imagens/v0.8-chat-2.png)

- **0.6 e 0.7** Teste da guarda automática.
- **0.4 e 0.5** Pesquisa dos controles. O menu dessa época tinha botões para exportar a estrutura da arma e os controles do jogo e para gravar os apertos:

  ![Menu da pesquisa dos controles (0.4 e 0.5)](imagens/v0.4-pesquisa-dos-controles.png)

- **0.3** Primeiro aviso e aprendizado dos golpes.
