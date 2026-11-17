---
name: testes-automaticos-e-limpeza
description: Measurement/test features should run automatically (no menu toggles for the user) and be removed once they lose their purpose
metadata:
  node_type: memory
  type: feedback
  originSessionId: 81a0a51e-3866-4ec1-ad32-dcb23497a1eb
  modified: 2026-11-16T16:51:02.945Z
---

Test or measurement features in the mod should be automatic by default, with no menu option for the user to tick. Example: the "FS without spirit gauge" test alternates on/off every 2 minutes on its own. Remove these test and measurement functions (and their report lines) once they have answered their question or are no longer useful.

**Why:** the user does not want to tick test options manually, and wants the code and menu kept clean.
**How to apply:** when adding a test, make it automatic and record in the version header what question it answers. After each fight report, check whether any pending test has been answered; if so, remove it in the next version and tell the user. Both earlier tests are answered and removed: the FS-without-gauge test in v1.16, the ISS protection measurement in v1.20. Nothing pending now.
