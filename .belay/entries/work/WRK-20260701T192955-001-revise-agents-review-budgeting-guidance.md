---
schema_version: 1
id: WRK-20260701T192955-001-revise-agents-review-budgeting-guidance
type: work
title: Revise AGENTS review budgeting guidance
status: in-progress
created_at: 2026-07-01T19:29:55+09:00
updated_at: 2026-07-01T19:30:11+09:00
revision: 2
tags: []
links:
- relation: references
  id: DEC-20260701T193006-001-use-risk-based-review-and-model-budgeting
metadata: {}
---

Scope:\n- Update AGENTS.md to avoid requiring /subagents for every implementation review.\n- Document model-strength budgeting for planning, implementation, and review.\n- Preserve independent review and traceability requirements while allowing focused reviews for low-risk changes.\n\nProgress:\n- Retrieved belay context.\n- Ran belay sync successfully before editing.\n\nConstraints:\n- jj status failed in this environment because jj could not create .git refs/jj/keep lock files.\n\nValidation planned:\n- Inspect AGENTS.md diff.\n- Run belay sync and belay doctor.\n- Attempt jj st and jj diff for final validation, recording any environment failure.
