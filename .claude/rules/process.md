# rules/process.md — Non-Negotiable Process Rules

These rules are not guidance. They are hard constraints that apply on every project, at every stage, without exception. Re-read this file after any `/compact` and before marking any milestone done.

---

## MCP gates — hard stops

A missing MCP is not a warning. It is a blocker.

**Distinguish three states — treat them differently:**

| State | Meaning | Action |
|---|---|---|
| ✅ Connected | Tool found, call succeeded | Proceed |
| ⚠️ Transient error | Tool found, call returned 502/timeout | Note it, retry later, proceed cautiously |
| ❌ Not configured | Tool not found after searching deferred tools | **Hard stop. Do not proceed.** |

**When an MCP is ❌ not configured:**
1. Stop. Do not attempt to work around it with training knowledge.
2. Tell George exactly which MCP is missing and why it's needed.
3. Provide the exact setup path: Claude Code → Settings → MCP Servers, or the `claude mcp add` command if known.
4. Wait for confirmation that it's been added and re-check before continuing.

Proceeding without a required MCP means falling back to potentially stale training knowledge instead of the authoritative source. This produces guesswork dressed as confidence.

---

## Required MCPs by stack item

When a project includes any of the following, the corresponding MCP is required — not optional:

| Stack item | Required MCP | Publisher |
|---|---|---|
| Any project | Linear | Anthropic / Linear |
| Any project | Notion | Anthropic / Notion |
| Any project | GitHub | Anthropic / GitHub |
| Netlify deployment | Netlify | Anthropic / Netlify |
| Supabase | Supabase MCP | Supabase (official) |
| Strapi | — (no official MCP yet — note this) | — |

Check this table during Phase 1. If a required MCP is missing, hard stop and flag it before any design or code work begins.

---

## Required skills by stack item

Skills must be **invoked** before working in their domain — not just noted as available. Knowing a skill exists and not using it is equivalent to not having it.

| Domain / tool | Skill to invoke | When |
|---|---|---|
| Any shadcn component work | `shadcn` | Before building or modifying any component |
| Any Next.js file conventions / patterns | `next-best-practices` | Before Phase 1b stack verification |
| Any Supabase schema or query work | `supabase-postgres-best-practices` | Before writing the first table or query |
| Any marketing copy / landing page | `copywriting` | Before writing any conversion copy |
| Any frontend UI design work | `frontend-design` | Before high-fidelity UI work |
| Any Claude API / Anthropic SDK integration | `claude-api` | Before writing any AI integration code |
| SVG animations (draw-on, morphing, path) | `svg-animations` | Before animating any SVG asset |
| GSAP animations (timelines, ScrollTrigger) | `gsap-core` + `gsap-react` + `gsap-scrolltrigger` | Before any GSAP implementation |
| Framer Motion (React animations, gestures, layout) | `framer-motion-react` + relevant sub-skill | Before any Framer Motion implementation |
| UI polish / micro-interactions / motion review | `impeccable` | When adding animations to existing UI or polishing a feature |

**Animation tool decision guide:**
- **SVG path animations** (draw-on, morphing, icons) → `svg-animations` skill, plain CSS or SMIL
- **React component animations** (enter/exit, layout shifts, gestures) → Framer Motion + `framer-motion-react`
- **Complex timelines or scroll-driven animations** → GSAP + `gsap-scrolltrigger`
- **UI polish pass on an existing feature** → `impeccable` (reviews and enhances motion holistically)

**The rule:** Before starting work in any of these domains, invoke the relevant skill. Do not use training knowledge as a substitute for an available skill. If the skill isn't yet installed, use `find-skills` to locate and install it first.

---

## New service added mid-project — mandatory check

Any time a new package is installed (`npm install [something]`) or a new third-party service is introduced during the project (not just at setup), pause and run this check before writing any implementation:

**Step 1 — Skill check:**
- Does a skill exist for this service/library? Search available skills.
- If yes: invoke it before writing any code.
- If no: use `find-skills` to search for one. If installable, install it first.

**Step 2 — MCP check:**
- Does an official MCP exist for this service?
- Search `registry.modelcontextprotocol.io` for the service name.
- **Prioritise by source tier:**
  1. **Official vendor MCP** — published by the company that makes the service (e.g. Stripe's own MCP). Always prefer this.
  2. **Anthropic-curated** — listed in the Anthropic subregistry or Claude Code docs MCP table.
  3. **Community** — listed in the registry but not from the official vendor. Use with caution; note provenance to George.
- If an official or curated MCP is found: surface the name, publisher tier, and install instructions. Stop and wait for George to add it before continuing.
- If no MCP is found: note it explicitly ("No official MCP found for [service] — proceeding with skill/training knowledge") and continue.

**Never silently proceed** with a new service without completing both checks. The cost of checking is seconds. The cost of using stale training knowledge for an API is bugs that are hard to diagnose.

---

## Issue lifecycle

- **Binary acceptance criterion on every issue.** "Done when: `[mechanical check]`." Not "it works" or "it feels complete." A check that a computer or human can run in seconds with pass/fail.
- **Update the Linear issue status as work progresses.** Not just at the end — in progress when started, done when the criterion passes.
- **Log material decisions as Linear comments** — not just in conversation. Decisions that aren't logged are decisions that will be re-litigated.
- **When a solution is found or a decision is made mid-implementation, post a comment to the active Linear issue before moving on.** Do not wait until the end of the session. The comment should state what was decided and why — one sentence minimum.
- **After a git push, update the active Linear issue.** At minimum: confirm the issue is still the right status. If the push completed a task, mark it done and add a comment linking what was shipped. If Notion scope changed as a result, update the master plan first.

---

## Milestone completion — never declare done early

Before marking any milestone complete:
1. Open the user-facing surface in a fresh browser tab and walk through it manually.
2. Ask: is there any seam between old and new behaviour?
3. Ask: does the binary acceptance criterion on every issue in this milestone pass?
4. Ask: does the codebase still contain two vocabularies, two data models, or two UI surfaces where the milestone promised one?

If any answer is yes — the milestone is not done. "The engine works" is not "every consumer uses the engine."

---

## Lessons — write in the moment

Write a lesson entry the same session something notable happens. Not at the end of the project — now.

Write a lesson when:
- Something broke in a non-obvious way and the fix revealed a generalisation
- A decision was made whose reasoning matters for future work
- A milestone closed faster or slower than expected due to something predictable
- A process discipline worked or failed in an instructive way

**One lesson = one Notion child page.** Never append lessons to the parent page as inline text. The parent page is an index only.

---

## After `/compact` — mandatory re-orientation

If the conversation has been compacted (context window was compressed), do the following before continuing any work:

1. **Re-read `CLAUDE.md`** — re-establish the project stack, principles, and routing.
2. **Re-read `.claude/rules/code.md`** — re-load non-negotiable code constraints.
3. **Re-read `.claude/rules/design.md`** — re-load non-negotiable design constraints including the honesty and self-evaluation rules.
4. **Re-read this file (`.claude/rules/process.md`)** — re-load process rules and MCP/skill tables.
5. **Re-read the Discovery Summary in Notion** — fetch the project's master plan page and re-read the Discovery Summary section. Every design and build decision must be informed by the validated problem statement, target user, differentiation thesis, and open questions. Do not design or build anything without this context.
6. **Check the current Linear issue** — confirm which issue is in progress and re-read its acceptance criterion.
7. **Check the Lessons & Insights page** — if anything from the compacted session warrants a lesson that wasn't written, write it now.

Do not assume that rules from the previous session context survived compaction intact. Re-read the files. This takes 2 minutes and prevents hours of drift.

---

## Before every design or build decision — research check

Before designing any user-facing surface or making a significant implementation decision:

1. **Is the Discovery Summary loaded?** If not, fetch it from Notion now.
2. **Does this decision align with the validated problem statement and target user?** If not, name the tension before proceeding.
3. **Does this decision conflict with what competitive research revealed?** If you're doing something a competitor already does well, there should be a reason.
4. **Does this decision reflect the differentiation thesis?** If the product's edge is X, every design decision should either support X or at minimum not contradict it.

This check takes 30 seconds. Skipping it is how products drift away from their core proposition one small decision at a time.
