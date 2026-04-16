# project-setup.md — Project Startup Routine

Run this routine at the start of every new project, or when picking up a project for the first time in a session.
Work through each phase in order. Do not skip ahead to design or code until phases 1 and 2 are complete.

---

## Phase 1 — MCP connectivity check

Before anything else, verify that the required MCPs are reachable. Report the status of each clearly.

**Required connections:**

| MCP | Purpose | Required? | When needed |
|---|---|---|---|
| Linear | Project tracking, issues, milestones | Yes | Phase 4 onwards |
| GitHub | Repo access, branch status, PR state | Yes | Phase 4 onwards |
| Notion | Master plan documentation | Yes | Phase 3 onwards |

| Netlify | Deployment status and environment config | If project uses Netlify | Deployment stage |

**How to check (important — follow this order):**

1. **First, search for available tools** using the tool search / deferred tools mechanism. Cloud MCPs (Linear, Notion, Netlify, GitHub) are loaded as deferred tools and may not appear until you explicitly search for them. Search for each by name before concluding it's missing.

2. **Then attempt a lightweight call** to each found MCP (e.g. list teams in Linear, search in Notion, list commits in GitHub). A successful response confirms the connection is live.

3. **Distinguish between three states:**
   - ✅ **Connected** — tool found and call succeeded
   - ⚠️ **Temporarily unavailable** — tool found but call returned an error (502, timeout, etc.). This is usually a transient proxy issue — note it and retry later. Do not block on this.
   - ❌ **Not configured** — tool not found even after searching. Flag to George.

4. **Do not block project scoping on transient errors.** If an MCP returns a 502 or timeout, note it and proceed. These are cloud-hosted MCPs that may have momentary outages. Only stop if the MCP is genuinely not configured (no tools found at all).

5. Also list any additional MCPs that are connected beyond the required set, in case they're relevant.

**Expected output:**
```
MCP Status
──────────
✅ Linear     — connected (workspace: [name])
✅ GitHub     — connected (repo: [name])
✅ Notion     — connected

✅ Netlify    — connected
⚠️ [Other]   — connected but verify it's needed
```

**If an MCP is not configured (❌):**
- Flag it to George with the specific MCP name
- George can add it via the MCP servers panel in VS Code (Claude Code extension settings)
- All required MCPs are cloud MCPs managed through the Claude AI integration — they are added via the VS Code extension, not config files
- Once added, it will be available in all projects automatically

---

## Phase 1b — Stack verification

After MCPs are confirmed, verify the codebase is correctly configured before any design or code work begins. Run these checks and fix anything that fails:

**Tailwind CSS pipeline (v4):**
1. `postcss.config.js` exists at the project root with `@tailwindcss/postcss` as the only plugin — there is no `tailwind.config.ts` in v4
2. `app/globals.css` starts with `@import "tailwindcss";` and `@import "tw-animate-css";` — not the old `@tailwind base/components/utilities` directives
3. `@tailwindcss/postcss` is in devDependencies (run `npm ls @tailwindcss/postcss` — if missing, `npm install -D @tailwindcss/postcss`)
4. There is no `tailwind.config.ts` — all theme configuration lives inside `globals.css` in the `@theme inline` block

**Quick smoke test:**
- Run `npx next build` — it should compile without errors
- If the build passes but styles don't render in the browser, clear the `.next` cache (`rm -rf .next`) and restart the dev server

**If any of these are missing, fix them before proceeding.** A broken CSS pipeline will waste hours downstream.

**Typecheck:**
- Run `npm run typecheck` — it should pass with zero errors
- Fix any type errors before proceeding. A codebase that starts with type errors compounds them quickly.

**Testing setup — Playwright (do this in Phase 1b, before any features are built):**

Install Playwright:
```bash
npm install -D @playwright/test
npx playwright install
```

Create `playwright.config.ts` at the project root:
```ts
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
})
```

Add to `package.json` scripts:
```json
"test:e2e": "playwright test",
"test:e2e:ui": "playwright test --ui"
```

Create `e2e/` directory and write the first smoke test immediately — even before any features exist. A passing baseline of 1 test is more valuable than a planned suite of 20:
```ts
// e2e/smoke.spec.ts
import { test, expect } from '@playwright/test'

test('homepage loads', async ({ page }) => {
  await page.goto('/')
  await expect(page).toHaveTitle(/[A-Za-z]/)
})
```

> **Why set up testing on day one?** A test suite established early creates a passing baseline. That baseline is the only thing that proves future changes — upgrades, refactors, migrations — haven't regressed anything. A test suite added late has to be written against already-complex code with no baseline to compare against. See Standing engineering disciplines → Test suite hygiene.

> **Why run the build now?** `npm run dev` masks many production errors (missing Suspense boundaries, SSR/CSR mismatches, static prerendering failures). A build that passes locally on day one establishes a clean baseline. A build broken for weeks is much harder to diagnose than one broken since yesterday. Run `next build` on every PR via CI — or at minimum, run it manually before declaring any milestone done.

---

## Phase 1c — Skills and MCP scan

Once the stack is confirmed (from CLAUDE.md header), scan for relevant skills and MCPs and surface anything useful before work begins. This is a proactive check — not a gate.

**Skill scan:**

Search available skills and flag any that are relevant to this project's stack:

| Condition | Skill to invoke |
|---|---|
| Any project | `shadcn` — for all component work |
| Any project | `next-best-practices` — for Next.js file conventions and patterns |
| Supabase included | `supabase-postgres-best-practices` — invoke when designing schema or writing queries |
| Marketing site or copywriting needed | `copywriting` — for landing pages, CTAs, headlines |
| Frontend design work | `frontend-design` — for distinctive, high-quality UI |
| Building with Claude API | `claude-api` — for any AI integration work |

Surface which skills are available and note which ones apply to this project. Do not invoke them now — just flag them so George knows they exist and when to use them.

**MCP scan:**

Beyond the required MCPs already checked in Phase 1, scan for any additional MCPs that might be relevant:

- If Supabase is included — is a Supabase MCP available?
- If the project uses a third-party service — is there an MCP for it?
- Any other connected MCPs that weren't in the required list but could be useful?

Report what's available. If a relevant MCP is missing, note it — but do not block on it.

**Expected output:**
```
Skills available for this project
──────────────────────────────────
✅ shadcn             — use for all component work
✅ next-best-practices — use for Next.js patterns
✅ supabase-postgres-best-practices — use when writing schema/queries
[others if relevant]

Additional MCPs
───────────────
[Any beyond Linear / Notion / Netlify / GitHub]
```

---

## Phase 2 — Project scoping

Before creating anything in Linear or Notion, establish the project scope through conversation. Ask George for any details that aren't already clear:

**Scoping questions (ask only what isn't already known):**
- What is the project? One-sentence description.
- Who is it for? Primary user type(s).
- What does success look like? Key outcomes, not features.
- What's the rough timeline or deadline?
- Are there any known constraints — technical, design, or otherwise?
- Which design reference files apply? (Check against `CLAUDE.md` routing table)

Do not over-question. If context from the conversation already answers these, skip them.

---

## Phase 3 — Master plan (Notion)

Once scope is clear, create the master plan document in Notion. This is the single source of truth for what the project is and why — Linear tracks the how and when.

**Notion document structure:**
```
# [Project Name]

## Overview
One paragraph: what this is, who it's for, what success looks like.

## Goals
- Primary goal
- Secondary goals (max 3)

## Users
- [Persona name] — [one-line description of their need]

## Scope
### In scope
- [Feature / capability]

### Out of scope
- [Explicit exclusions — prevents scope creep]

## Constraints
- Technical, timeline, design, or resource constraints

## Design principles
- 2–4 product-specific principles that govern decisions on this project
- These sit alongside the global principles in CLAUDE.md

## Milestones
| Milestone | Description | Target |
|---|---|---|
| M1 | [Name] | [Date or sprint] |
| M2 | [Name] | [Date or sprint] |

## Decisions log
Capture every significant directional decision here on the day it's made — before any code is written.
Each entry must include the *why*, not just the *what*. The why is what you'll need when constraints change and you have to revisit.

| Date | Decision | Why | Alternatives rejected |
|---|---|---|---|
| YYYY-MM-DD | [What was decided] | [The reasoning] | [What else was considered and why it was ruled out] |

> A decisions log pays for itself many times over. The cost is ten minutes of writing per decision; the value is never re-litigating the same question three weeks later when you're tired and the answer feels arbitrary.

## Open questions
- Questions that need answers before specific tasks can be completed
```

After creating the document, share the Notion URL with George for review before proceeding to Linear.

---

## Phase 4 — Linear project + issues

Once George has confirmed the Notion plan, create the corresponding structure in Linear.

**What to create:**

1. **A new Linear project** named `[Project Name]`
   - Add a description (pull from the Notion Overview section)
   - Link to the Notion document in the project description

2. **One issue per discrete task**, grouped by milestone where milestones exist

**Issue format:**
```
Title:       [Short, action-oriented — "Build report export flow" not "Export"]
Description: [What needs to be done and why — 2–4 sentences]
             [Link to relevant Notion section if applicable]
Labels:      [design / frontend / backend / research / content]
Priority:    [Urgent / High / Medium / Low]
Milestone:   [M1 / M2 / etc. if defined]
Done when:   [Binary, mechanical acceptance criterion — a check a computer or human can run in seconds
              that returns pass/fail with no judgement required. Examples:
              - "`npm run build` exits 0 with no new warnings"
              - "User can complete [task] in a fresh browser session without console errors"
              - "`git grep 'deprecated-module'` returns zero matches"
              NOT: "the feature works" or "it feels complete"]
```

> **Why binary criteria matter.** "Feels done" is unreliable. A binary, mechanical check eliminates subjective decision points, makes the work decomposable into measurable steps, and absorbs setbacks without scope-reduction temptation — because scope reduction is visibly cheating when the criterion still fails.

**Issue granularity guide:**
- One issue = one reviewable unit of work (something that can be PR'd, tested, or signed off independently)
- If an issue would take more than 2–3 days, split it
- If an issue would take less than 30 minutes, consider combining it with a related one

**After creating all issues:**
- Confirm the total issue count and project structure with George
- Flag any dependencies between issues (i.e. issue B cannot start until issue A is complete)
- Identify any open questions from Notion that are blocking specific issues

**Scoping question to ask for every issue before creating it:**
> "What does this assume already exists?"

If the answer reveals a missing foundation — something multiple other issues also depend on — stop. Create the foundation work as its own issue first and reclassify the original as a follow-up. A half-day ticket that cascades into a multi-week foundation reset is a sign the precondition wasn't examined at scoping time.

---

## Phase 5 — Begin work

With MCPs verified, plan documented in Notion, and issues created in Linear, begin the first task following the order below. Do not skip ahead — each stage feeds the next.

### Stage 1 — UX process (always first)
Load [`ux-process.md`](./ux-process.md). Before any interface is designed, the following must be established:

1. **Research** — what do we know about the users? What assumptions need validating? → Document findings in **Notion** (one page per research round)
2. **Strategy** — does the feature align to a clear user goal and business outcome? → Record in the **Notion** master plan under Goals and Design principles
3. **Personas** — which persona(s) does this task serve? Reference them in every design decision → One **Notion** page per persona, linked from the master plan
4. **Brand identity** — establish tone of voice, colour direction, typography system, and icon style as a cohesive set → Document on a **Notion** page titled `[Project Name] — Brand Identity`, linked from the master plan. Then configure: colours and font variables in `globals.css` (`@theme inline` block), font imports in `layout.tsx`, icon library swap if needed via `npm run swap-icons`. When writing or reviewing any marketing or UI copy (headings, CTAs, landing pages, onboarding), invoke the `copywriting` skill.
5. **User stories** — write stories for all in-scope functionality before opening Figma or writing code → Draft in **Notion** first, then mirror each story as a **Linear** issue
6. **Information architecture** — define the structure and navigation before laying out screens → Document as a structured **Notion** page with the site map hierarchy, linked from the master plan
7. **User flows** — map the full flow (happy path + errors + edge cases) before designing individual screens → Document as **Notion** pages (one page per flow) using the flow notation format; link from the master plan and the relevant Linear issue

Do not proceed to Stage 2 until flows are mapped and reviewed.

### Stage 2 — Design psychology (runs throughout, starts here)
Load [`design-psychology.md`](./design-psychology.md). Before producing any UI, apply the relevant principles to the flows and structure established in Stage 1:

- Run each screen or flow through the checklist: Hick's Law, Gestalt grouping, Fitts's Law, Jakob's Law, Cognitive Load, Colour Psychology
- Flag any points in the flow where a principle is being violated — resolve at the flow level before moving to UI
- Document which principles are driving key decisions — these become the rationale when reviewing with stakeholders

Design psychology continues to apply through Stage 3. It is not a one-time gate.

### Stage 3 — UI standards (last)
Load [`ui-standards.md`](./ui-standards.md). Only once structure and psychology have been validated, apply the visual layer using the brand identity decisions from Stage 1:

1. **Layout** — translate flows into screen layouts using Tailwind grid/flex
2. **Components** — reach for shadcn primitives first; compose or extend as needed. When adding, composing, debugging, or styling shadcn components, invoke the `shadcn` skill — it has component docs, usage examples, and registry knowledge built in.
3. **Colour** — apply the brand palette via shadcn tokens in `globals.css`; verify dark mode and WCAG AA contrast
4. **Typography** — apply the brand's font system; confirm hierarchy reads clearly across the type scale
5. **Iconography** — use the project's chosen icon library; confirm sizing (`size-*`), labels, and accessibility attributes
6. **Spacing** — apply Tailwind spacing scale; confirm groupings read correctly

### Testing strategy (runs throughout)

Testing is not a phase that happens after features are built — it is a discipline applied continuously. Follow this approach:

**What to test with Playwright (E2E):**
- Every user-facing flow defined in the UX process — happy path first, then error states
- Any flow that involves auth, data mutation, or navigation across multiple pages
- Critical paths: sign up, log in, core feature task, export/save

**What NOT to test with Playwright:**
- Visual appearance (use manual dark mode / breakpoint checks instead)
- Internal implementation details — test what the user sees, not how the code works
- Every possible edge case — focus on the flows users will actually hit

**When to write tests:**
- Write the E2E test for a flow **in the same issue** as building the flow — not as a follow-up ticket
- After any refactor that touches a user-facing flow, run the full suite before marking done
- After any dependency upgrade (React, Next.js, Tailwind), run the full suite to confirm the baseline holds

**Maintaining the suite:**
- Update test selectors in the **same PR** that changes the UI — never let them drift
- If the pass count drops dramatically between runs, check the environment before reading the code — a stale dev server on port 3000 is a common false positive (see Standing engineering disciplines → Test suite hygiene)
- Keep `reuseExistingServer: !process.env.CI` in `playwright.config.ts` but be aware: if a background dev server is running from a previous session, Playwright will reuse it. Kill stray servers before running the suite locally if results look wrong (`lsof -i :3000`)

**The baseline number matters:**
After each milestone, note the passing test count in a Linear comment. This number is a load-bearing fact — it's what you compare against when something unexpected changes.

### Database work (Supabase)
When any work involves writing queries, designing schema, or optimising database performance, invoke the `supabase-postgres-best-practices` skill. This applies from the first time a table is created — schema decisions made early are expensive to undo later.

### README — rewrite it for this project

The `README.md` created by `create-project.sh` is a scaffold placeholder. Before any code is committed, replace it with a README that reflects the actual project.

A good project README covers:
- **What it is** — one paragraph, plain English, no jargon
- **Who it's for** — the primary user type(s) from the personas
- **Stack** — the actual stack for this project (from CLAUDE.md header)
- **Getting started** — `npm run dev`, env vars to fill in
- **Deployment** — how to deploy, where it lives
- **Repo structure** — the actual structure, not a generic template

Write this once scoping is complete (after Phase 2) and keep it up to date as the project evolves. A README that accurately describes the project is useful to future-you, collaborators, and anyone reading the case study.

### Throughout all stages
- Update the relevant Linear issue status as work progresses
- Log decisions and trade-offs as comments on the Linear issue — not just in conversation
- If scope changes materially, update the Notion document first, then adjust Linear issues to match

---

---

## Phase 6 — Project close

Run this phase when the final milestone is shipped and the product is in a stable deployed state.

**1. Linear**
- Mark all remaining issues as Done or Cancelled (with a note explaining why)
- Mark the project itself as Completed

**2. Notion**
- Update the master plan's milestone table to reflect completion dates
- Add a "Status: Shipped" note to the Overview section
- Confirm the Decisions Log is up to date

**3. Deployment**
- Confirm the production build is green (`next build` passes)
- Verify the live URL is accessible and environment variables are set correctly
- Check Netlify deploy log for any warnings

**4. Retrospective — Lessons & Insights**
Create a child page under the master plan titled `📚 Lessons & Insights`. This is a permanent record of what this project taught us — written for someone who has no project context, as case study material.

See the **Lessons & Insights** rules below for how to write and structure this page.

---

## Lessons & Insights — standing rules

These rules apply throughout the project, not just at close. Lessons should be captured in the moment — while the story is fresh — not reconstructed at the end.

### When to write a lesson
Write a lesson entry whenever any of the following happen:
- A non-obvious decision was made and the reasoning matters for future work
- Something broke in a way that wasn't anticipated — and the fix revealed a generalisation
- A process discipline was applied (binary acceptance criterion, regression checklist, etc.) and it worked or failed in an instructive way
- A milestone closes faster or slower than expected due to something that could have been predicted
- A refactor, migration, or architecture change produced a surprise — good or bad

Do not wait for the project to end. Write the lesson the same session it happened.

### Format for each entry
```
Date: YYYY-MM-DD
Headline: One sentence — what happened and why it matters

The story: What actually happened — specific, concrete, names the files/tickets/decisions involved.

The generalisation: The rule that applies beyond this project. Written for an external reader with no project context.

Linear reference: [ticket ID(s) if applicable]
```

### Page structure — one lesson per Notion page
**Do not write all lessons on a single page.** Each lesson is its own child page under `📚 Lessons & Insights`. The parent page contains only:
- A one-paragraph intro explaining the format
- A numbered index linking to each child page (title = lesson headline)

This keeps every individual lesson readable by the Notion MCP in a single fetch, and prevents the parent page from growing too large to read.

**To add a new lesson:**
1. Create a new child page under `📚 Lessons & Insights` titled `[N]. [Date] — [Headline]`
2. Write the full entry using the format above
3. Add a link to it in the index on the parent page

### Tone
Write for an external audience — someone reading this for a case study should not need project context to understand the point. The story is project-specific; the generalisation is universal.

---

## Standing engineering disciplines

These rules apply on every project, at every stage. They are derived from hard-won experience and exist to prevent specific, recurring failure modes.

### Declaring a milestone done

Before marking any milestone complete, open the user-facing surface in a fresh browser tab and click through it manually. Ask:
- Can I find any seam between old behaviour and new behaviour?
- Does the codebase still contain two vocabularies, two UI surfaces, or two data models where the milestone promised one?
- Does the binary acceptance criterion on every issue in this milestone pass?

If any answer is yes, the milestone is not done. "The engine works" is a developer story. "Every user-facing surface uses the engine" is the milestone.

### Before any refactor touching user-facing flows

Write a **regression checklist** *before* starting — not after. Walk through the working flows manually, enumerate every user-facing capability the refactor must preserve, and put the checklist in the PR description. Run it before declaring done.

Format:
```
## Regression checklist
- [ ] [User can do X — specific UI steps, not abstract feature name]
- [ ] [User can do Y — include any edge cases specific to this flow]
```

Automated tests are necessary but not sufficient. The checklist catches what tests don't cover. Skipping it leads to silent feature loss that only surfaces when a user manually tests.

### Removing a feature

Removing a feature is two jobs:
1. Remove the user-facing surface (UI, routes, buttons)
2. Remove the full implementation (data shapes, props, functions, types, state)

Doing only (1) is **worse than doing neither** — dead implementation creates a phantom mental model that misleads anyone who reads the code later. Either delete every trace in the same commit, or open a cleanup issue immediately and make the residue visible. "I'll come back to it" doesn't happen.

### Test suite hygiene

Update test selectors and assertions in the **same PR** that changes the UI — not as a follow-up. A test suite allowed to drift loses its value as a regression signal. When test results drop dramatically (e.g. 40 passing → 11 passing), check the test environment before reading the code — a stale dev server, build cache, or polluted port is often the culprit.
