---
schema_version: 1
id: DEC-20260701T193006-001-use-risk-based-review-and-model-budgeting
type: decision
title: Use risk-based review and model budgeting
status: proposed
created_at: 2026-07-01T19:30:06+09:00
updated_at: 2026-07-01T19:30:06+09:00
revision: 1
tags: []
links: []
metadata: {}
---

Decision:\n- Do not require Codex /subagents or Claude Code /agents for every implementation-time review.\n- Require an independent review record for every implementation, with the review method selected according to change risk.\n- Prefer high-reasoning models for planning, architecture, and review; medium-reasoning models for routine implementation; low-reasoning models only for mechanical edits.\n- Reserve cross-model or subagent review for broad, security-sensitive, production-impacting, or architecturally significant changes.\n\nRationale:\n- Mandatory subagent review consumes disproportionate token budget for small and mechanical changes.\n- Risk-based review preserves traceability and review evidence while making routine work cheaper and faster.\n- Recording the review method and model budget keeps later auditability without forcing one expensive mechanism.\n\nStatus:\n- Proposed by human and implemented in AGENTS.md guidance.
