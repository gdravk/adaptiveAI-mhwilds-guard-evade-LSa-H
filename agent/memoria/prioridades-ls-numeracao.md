---
name: prioridades-ls-numeracao
description: "How to number Long Sword priorities when talking to the user (SS+ISS 1, FS 2, dodge 3; 0 = M4)"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 81a0a51e-3866-4ec1-ad32-dcb23497a1eb
  modified: 2026-11-16T15:03:34.824Z
---

When talking about Long Sword priorities, use: SS+ISS = prioridade 1, FS = prioridade 2, esquiva normal = prioridade 3. Prioridade 0 is reserved for other things such as the M4 (sheathe and run). Also use this numbering in report labels in the mod.

Rules behind it: SS+ISS is never interrupted until its animation ends. FS (only after one of the user's own attacks, i.e. in combo) and dodge are forced over any other action, but never over SS+ISS. Right after SS+ISS ends, all three are free immediately.

Survival comes first. The user authorized changing these priorities whenever the data shows another choice avoids damage better: "o importante e nao tomar o dano e nao morrer". Example from v1.18: the ISS has no i-frames, only a 0.3s counter, so attacks with a second hit within 0.9s use FS (750 ms i-frames) instead of SS+ISS.

**Why:** the user corrected the numbering after I called SS+ISS "prioridade 0", and later put not taking damage above the priority order.
**How to apply:** use this numbering in every message and report text about the LS. See [[so-comandos-reais]].
