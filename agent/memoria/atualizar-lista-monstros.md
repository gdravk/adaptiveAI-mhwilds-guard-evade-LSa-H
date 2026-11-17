---
name: atualizar-lista-monstros
description: "Run atualizar_lista.pl only when needed (after the user fought / learning changed), to update % per monster in \"Lista de monstros.txt\""
metadata:
  node_type: memory
  type: feedback
  originSessionId: 81a0a51e-3866-4ec1-ad32-dcb23497a1eb
  modified: 2026-11-16T01:19:46.671Z
---

Run `perl atualizar_lista.pl` in D:\Claude outros\MOD Evade Block MH Wilds ONLY WHEN NEEDED: after the user reports fights / new learning (not on every message, not on every version, and don't announce it every time). It reads the mod's learning file (read-only, game folder) and writes " - XX%" after every monster and variant in "Lista de monstros.txt" (unseen = 0%). Variants are tracked separately ("27", "27:t", "27:at"). Mention monsters that reach 95%+.

**Why:** originally asked (2026-11-13) to run every turn; on 2026-11-16 the user said it doesn't need to run every time, only when necessary.

**How to apply:** run it when a fight report arrives; skip it on pure questions/code changes. Related: [[nomear-arquivo-com-versao]].
