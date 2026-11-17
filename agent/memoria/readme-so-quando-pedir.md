---
name: readme-so-quando-pedir
description: Do not update README.txt with each new version; only when the user asks
metadata:
  node_type: memory
  type: feedback
  originSessionId: 7270b846-9712-4034-a60d-fe9cd26b79f1
  modified: 2026-11-17T14:18:46.807Z
---

Do not update `README.txt` (project folder) when making a new mod version. Only touch it when the user explicitly asks.

**Why:** the user said "Não precisa fazer o readme mais, só quando eu pedir" after I updated it alongside v1.40.

**How to apply:** when building a new `aviso_lanca_vX.Y.lua` ([[nomear-arquivo-com-versao]]), skip README edits; mention nothing about it unless asked.
