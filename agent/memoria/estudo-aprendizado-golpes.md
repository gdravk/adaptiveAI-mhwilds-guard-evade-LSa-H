---
name: estudo-aprendizado-golpes
description: "Study of other mods (HitboxViewer, AutoDodge...) for precise monster-attack learning; notes in C:/Users/<usuario>/Desktop/IA-INFOaprendizadoGolpes/ESTUDO_CLAUDE.txt"
metadata:
  node_type: memory
  type: project
  originSessionId: 81a0a51e-3866-4ec1-ad32-dcb23497a1eb
  modified: 2026-11-17T15:13:53.621Z
---

On 2026-11-15 the user gave a folder `IA-INFOaprendizadoGolpes` (their own research from other AIs + downloaded mods, full permission to read/reverse). My study is saved in `C:/Users/<usuario>/Desktop/IA-INFOaprendizadoGolpes/ESTUDO_CLAUDE.txt` (moved out of the project on 2026-11-17 to keep third-party files off GitHub) — read it before implementing hitbox-based learning.

Key finds: `app.ColliderSwitcher.activateAttack` (attack hitbox turns on, even on misses; AttackParamEm gives GuardType/_IsKillable), `app.HunterCharacter.evHit_Damage` (retval 0 hit / 1425417188 evaded), `beginDodgeNoHit` + `getDodgeNoHitTime` (iframes), `changeActionRequest` (direct actions).

**Why:** user wants precise learning for hitkill monsters (Arch-tempered etc.) without taking hits; learning from other players/bots was dropped (v0.52-0.54) as imprecise.
**How to apply:** user excluded REasy and Nexus mod 738; do phase 1 (observe only) before changing defense. Related: [[atualizar-lista-monstros]].
