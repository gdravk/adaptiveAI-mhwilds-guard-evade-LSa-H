---
name: so-comandos-reais
description: Rule history - mod reads the game and sends commands; since 2026-11-16 the user allows FORCING defense actions (changeActionRequest anytime); still never cancel hits / give invincibility / edit values
metadata:
  type: feedback
---

The mod READS game values and sends commands. Allowed: real button presses / input buffer; direct action requests (changeActionRequest). On 2026-11-16 the user decided to FORCE defenses (FS, SS, ISS, dodge, weapon-specific moves like Hammer Charged Step) even mid-animation, always ON, also in multiplayer, with no off switch. Still NOT allowed (never asked for): startNoHitTimer / invincibility, SKIP_ORIGINAL or cancelling hits, editing HitInfo / animation speed / timers / gauges, inventing mechanics (e.g. hammer block).

**Why:** user first wanted "legit" (buttons only), then approved a window-gated middle ground, then explicitly asked to force actions because stuck-in-attack caused most damage.
**How to apply:** action IDs: LS FS (2,16), ISS (2,25+aura); others learned from the game (action class names). Related: [[estudo-aprendizado-golpes]], [[regras-arma-guardada-e-mods-testados]].
