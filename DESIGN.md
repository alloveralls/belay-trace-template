# DESIGN.md

## Overview

This document is a reusable design template for internal AI agent projects. It is intentionally generic: it provides a practical structure, sensible defaults, and clear placeholders so a project team can turn it into a living design reference without rewriting the whole file.

Use this document to capture both product intent and UI system decisions. Replace placeholders, tighten any examples that do not fit the project, and remove sections that are genuinely irrelevant.

## Product Context

### Project Summary

- Product or system name: `[PROJECT_NAME]`
- Primary audience: `[PRIMARY_AUDIENCE]`
- Main use cases:
  - `[USE_CASE_1]`
  - `[USE_CASE_2]`
  - `[USE_CASE_3]`

### Problem Statement

Describe the user problem, operator problem, or business need the product exists to solve.

### Success Criteria

- `[SUCCESS_METRIC_1]`
- `[SUCCESS_METRIC_2]`
- `[SUCCESS_METRIC_3]`

## Design Principles

Use 3 to 6 principles. Keep them concrete enough to guide implementation tradeoffs.

1. **Clarity over ornament**
   - Interfaces should make the primary action and current state easy to understand at a glance.
2. **Consistency with room for emphasis**
   - Reuse patterns by default, then spend visual emphasis only where the product needs stronger guidance.
3. **Fast to scan, safe to act**
   - Users should be able to understand structure quickly without being pushed into mistakes.
4. **Accessible by default**
   - Color, type, focus states, and interaction targets must remain usable without relying on perfect vision, precision input, or motion tolerance.

## Visual Foundations

This section defines the overall visual direction. Replace example values when the project settles on a real brand or interface language.

### Visual Direction

- Tone: `[calm | technical | editorial | playful | operational]`
- Density: `[compact | balanced | spacious]`
- Surface style: `[flat | layered | card-based | dashboard | document-first]`
- Motion style: `[minimal | functional | expressive]`

### Example Art Direction Notes

- Prefer a restrained interface with one clear primary accent.
- Use whitespace and typography hierarchy before adding decorative chrome.
- Reserve strong contrast for state changes, destructive actions, and key calls to action.

## Typography

These defaults are examples, not brand-derived rules. Replace them when the project has a chosen type system.

### Font Strategy

- Display stack: `system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif`
- Body stack: `system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif`
- Monospace stack: `ui-monospace, SFMono-Regular, Menlo, Consolas, monospace`

### Suggested Type Scale

| Token | Size | Weight | Line Height | Use |
|---|---|---|---|---|
| `{type.display}` | 48px | 700 | 1.1 | Major page or hero headings |
| `{type.h1}` | 36px | 700 | 1.15 | Primary section headings |
| `{type.h2}` | 28px | 650 | 1.2 | Secondary section headings |
| `{type.h3}` | 22px | 650 | 1.25 | Tertiary section headings |
| `{type.body}` | 16px | 400 | 1.5 | Standard paragraph copy |
| `{type.body-strong}` | 16px | 600 | 1.5 | Inline emphasis |
| `{type.caption}` | 14px | 400 | 1.4 | Supporting labels and metadata |
| `{type.micro}` | 12px | 400 | 1.35 | Fine print and helper copy |

### Typography Guidance

- Use one display behavior and one body behavior consistently.
- Keep paragraph text readable before making it visually distinctive.
- Do not rely on very light font weights for important UI or dense information.

## Color

Define project-owned tokens here. The values below are safe examples only.

### Core Tokens

| Token | Example Value | Use |
|---|---|---|
| `{color.bg}` | `#ffffff` | Main page background |
| `{color.surface}` | `#f6f7f9` | Secondary surfaces |
| `{color.text}` | `#1f2430` | Primary text |
| `{color.text-muted}` | `#5b6472` | Secondary text |
| `{color.border}` | `#d9dee7` | Borders and dividers |
| `{color.primary}` | `#0b57d0` | Primary action |
| `{color.primary-strong}` | `#0842a0` | Active/pressed state |
| `{color.success}` | `#177245` | Success state |
| `{color.warning}` | `#9a6700` | Warning state |
| `{color.danger}` | `#b42318` | Error/destructive state |
| `{color.focus}` | `#2563eb` | Focus ring |

### Color Rules

- Primary actions, links, and focus states must remain distinguishable without ambiguity.
- Status colors must not be the only signal; pair them with text, iconography, or structure.
- Keep contrast high enough for normal text, controls, and disabled-state interpretation.

## Spacing and Layout

### Suggested Spacing Scale

| Token | Value | Use |
|---|---|---|
| `{space.1}` | 4px | Tight internal spacing |
| `{space.2}` | 8px | Compact gaps |
| `{space.3}` | 12px | Small stack spacing |
| `{space.4}` | 16px | Default spacing |
| `{space.5}` | 24px | Card padding / section spacing |
| `{space.6}` | 32px | Larger groups |
| `{space.7}` | 48px | Major section gaps |
| `{space.8}` | 64px | Page-level spacing |

### Layout Guidance

- Default content width: `[e.g. 960px to 1280px depending on product shape]`
- Grid pattern: `[single-column | two-column | dashboard grid | document with sidebar]`
- Preferred outer padding: `[e.g. 16px mobile / 24px tablet / 32px desktop]`
- Use layout shifts intentionally; do not introduce new containers without a clear structural reason.

## Components

List the core building blocks the project expects to use. Keep each entry short and behavioral.

### Navigation

- `top-nav`
  - Defines global movement between major areas.
  - Should always surface current location and the highest-priority cross-page actions.
- `section-nav`
  - Optional local navigation for pages with deep structure.
  - Hide or collapse only when the content can still be understood without it.

### Actions

- `button-primary`
  - Used for the main action on a screen or step.
- `button-secondary`
  - Used for legitimate alternatives, not low-value clutter.
- `button-destructive`
  - Reserved for irreversible or high-risk actions.

### Information Containers

- `card`
  - Use for grouped information that benefits from shared boundaries or actions.
- `panel`
  - Use for denser operational or editor-style layouts.
- `empty-state`
  - Explain the state, why it is empty, and what action the user can take next.

### Forms and Input

- `text-input`
- `select`
- `checkbox`
- `radio-group`
- `textarea`
- `inline-validation`

For each real project, document validation behavior, error placement, helper text style, and disabled/read-only treatment.

## Responsive Behavior

### Suggested Breakpoints

| Name | Width | Typical Use |
|---|---|---|
| Small | `<= 639px` | Mobile phones |
| Medium | `640px - 1023px` | Tablets / small laptops |
| Large | `>= 1024px` | Desktop layouts |

### Responsive Rules

- Prioritize content order over preserving desktop layout geometry.
- Collapse optional chrome before collapsing core content.
- Keep primary actions reachable without excessive scrolling or precision input.
- Re-test empty states, forms, tables, and navigation separately on small screens.

## Accessibility

Accessibility requirements are part of the baseline spec, not a later hardening phase.

### Minimum Expectations

- Visible keyboard focus on all interactive elements.
- Text and controls must meet the project’s contrast requirements.
- Touch targets should be comfortably tappable on mobile devices.
- Motion should be reducible or removable for users who prefer less animation.
- Form errors should be programmatically and visually associated with fields.
- Semantic structure should support screen-reader navigation.

### Questions To Resolve

- Are there locale, language, or right-to-left requirements?
- Are there internal accessibility standards beyond public WCAG-style guidance?
- Do charts or diagrams need text alternatives?

## Content and Voice

- Voice: `[direct | calm | technical | supportive | operational]`
- Reading level: `[broad audience | technical audience | expert operators]`
- Preferred button style: verbs first, short labels, avoid vague actions like `Submit` when a more precise action exists.
- Empty states, alerts, and destructive confirmations should explain consequence and next action.

## Implementation Notes

Use this section to bridge design decisions into engineering without over-specifying code.

- Canonical tokens should eventually live in code, not only in prose.
- When a component has multiple states, document default, focus, disabled, loading, success, and error states as needed.
- If the product uses a design system package or component library, note where this document defers to it.
- Keep screenshots, moodboards, or external references in separate project assets if they become large or frequently updated.

## Open Questions

Use this section to track unresolved design decisions.

- [ ] `[QUESTION_1]`
- [ ] `[QUESTION_2]`
- [ ] `[QUESTION_3]`

## Revision Notes

- This file is a template baseline for internal projects.
- Replace example values and placeholders as the project becomes concrete.
