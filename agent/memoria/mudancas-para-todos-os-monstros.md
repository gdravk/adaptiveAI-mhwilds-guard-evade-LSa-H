---
name: mudancas-para-todos-os-monstros
description: "Every change must be designed to work for ALL monsters, not tuned to the monster of the last fight"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 7270b846-9712-4034-a60d-fe9cd26b79f1
  modified: 2026-11-16T18:38:43.721Z
---

Every change to the mod has to be thought through carefully for all monsters in the game (and future ones). The user will not test each monster and adapt the mod after every fight. A fight report shows a problem; the fix must solve the general case, not just that monster.

**Why:** the user said (2026-11-16): "as mudancas que forem implementadas precisam ser pensadas cuidadosamente para TODOS os monstros. Pois nao ficaremos fazendo teste em todos os monstros do jogo".
**How to apply:** prefer general signals from the game (contact hook, attack areas, i-frames, game state) over fixed numbers that fit one fight. Before finishing a change, list how it behaves with multi-hit monsters, beams and long hitboxes, projectiles, flying monsters, big and small monsters, damage over time, and SOS. Avoid hardcoding monster IDs or attack keys; when one-time data cleanups do need a key, keep them one-time and say so. Related: [[so-comandos-reais]], [[prioridades-ls-numeracao]].
