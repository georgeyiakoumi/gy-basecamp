# gy-basecamp

A personal project starter for George Yiakoumi — combining a production-ready Next.js scaffold with a Claude Code assistant trained for UX/product design work.

This isn't just a boilerplate. It's an opinionated system that enforces good process, prevents known failure modes, and makes every project start from the same high baseline — so time is spent building, not configuring.

---

## What this does

Running `create-project.sh` scaffolds a new project and opens it in VS Code. From that point, Claude Code takes over:

1. **Checks every required MCP** — Linear, Notion, GitHub, Netlify, Supabase (if included). Missing MCPs are a hard stop, not a warning. Claude won't proceed without the tools it needs.
2. **Scans for relevant skills** — identifies and invokes the right skills for the project stack before any work begins. No falling back to stale training knowledge.
3. **Asks for prior context** — if you have brainstorm notes, a handover doc, or a rough spec from a previous session, Claude asks for it before scaffolding anything. That context informs the Notion plan from the start.
4. **Reads lessons before acting** — before responding to any design, code, or process prompt, Claude fetches the project's Lessons & Insights from Notion and reads them. Lessons are a feedback loop, not a diary.
5. **Scopes the project** — asks the right questions to establish what's being built, who it's for, and what success looks like.
6. **Creates a Notion master plan** — goals, users, scope, constraints, milestones, decisions log, open questions. The single source of truth.
7. **Creates a Linear project + issues** — one issue per discrete task, with binary acceptance criteria. "It works" is not a criterion.
8. **Follows the UX process** — research and strategy first, brand identity before any UI, shadcn components last. The process is enforced, not optional.
9. **Enforces git discipline throughout** — every piece of work lives on a branch derived from a Linear ticket. Claude never commits or pushes without your explicit approval. PRs must pass typecheck and build before being raised.
10. **Enforces non-negotiable rules throughout** — a dedicated rules system (`rules/code.md`, `rules/design.md`, `rules/process.md`) that Claude re-reads after every `/compact` and before every milestone sign-off.

---

## Why it's useful

**Process discipline without friction.** The setup routine runs automatically on first open. Notion plans, Linear issues, and acceptance criteria are created before a single line of code is written. This isn't bureaucracy — it's the thing that makes milestones ship on time and retrospectives say "scoping worked."

**Rules that survive context compression.** Deep in a project, Claude's context window fills up. `/compact` compresses it. Rules stated once at session start can get lost. This template solves that with a three-file rules system that Claude is explicitly instructed to re-read after compaction, at session resume, and before any milestone is declared done.

**Informed tool use, not guesswork.** Every tool and library in the stack has a corresponding skill that must be invoked before implementation begins. New services added mid-project trigger an automatic skill and MCP check — including a search of the official MCP registry for an authoritative integration, prioritised by vendor tier.

**A feedback loop that compounds.** Every project writes its lessons to a structured Notion page. Each lesson is its own child page (preventing pages that are too large to read). Lessons are written in the moment, not reconstructed at the end. Over time, these lessons feed back into the template itself.

**Built from real projects.** The rules, standards, and processes in this template are derived from lessons learned across multiple shipped products — not generic best practices. The specific failure modes it guards against are ones that have actually happened.

---

## Stack

| Layer | Tool |
|---|---|
| Framework | Next.js (App Router) |
| Styling | Tailwind CSS v4 |
| Components | shadcn/ui (new-york style) |
| Icons | Lucide React |
| Forms | React Hook Form + Zod |
| Testing | Vitest + Playwright |
| CI | GitHub Actions |
| Deployment | Netlify |

**Add-ons** (selected at project creation):

| Add-on | What it adds |
|---|---|
| Supabase | Auth + database (client + server clients, RLS-ready) |
| Dark mode | `next-themes` wired into root layout |
| Sidebar | shadcn Sidebar component + CSS variables |
| Charts | Recharts + shadcn chart wrappers + `--chart-*` tokens |
| Shiki | Syntax highlighting for code display |
| Storybook | Component documentation and visual testing |
| Cloudinary | `next-cloudinary` + `lib/cloudinary.ts` helper + env vars |
| Cloudflare + ISR | Webhook revalidation route (`/api/revalidate`) + env vars |

---

## The Claude assistant

Claude Code reads `CLAUDE.md` automatically on every session open. The assistant is configured across several files:

| File | Purpose |
|---|---|
| `CLAUDE.md` | Master routing, stack, post-compact re-orientation trigger |
| `.claude/rules/code.md` | Non-negotiable code rules — stack, Tailwind, TypeScript, security |
| `.claude/rules/design.md` | Non-negotiable design rules — colour, typography, dark mode, accessibility |
| `.claude/rules/process.md` | Non-negotiable process rules — MCP gates, git workflow, skill tables, milestone discipline |
| `.claude/project-setup.md` | Full startup routine — MCP checks → prior context intake → discovery → Notion → Linear |
| `.claude/discovery.md` | Pre-build discovery process — problem framing, assumptions, competitive research |
| `.claude/ui-standards.md` | shadcn · Tailwind · Lucide standards, dark mode setup, forms, loading states |
| `.claude/ux-process.md` | Research, strategy, personas, brand identity, user flows, onboarding |
| `.claude/design-psychology.md` | Hick's Law, Gestalt, Fitts's Law, Jakob's Law, Cognitive Load, Colour Psychology |
| `.claude/memory/lessons.md` | Local backup of Notion Lessons & Insights — read before every session |

**The rules files** are the key addition. They're short by design — fast to re-read after `/compact`. They contain only hard constraints: things that, if violated, cause real problems. The detailed reference files (`ui-standards.md`, `ux-process.md`, etc.) are consulted during work. The rules files are enforced throughout.

---

## Prerequisites

Install these once. They're needed every time you create a new project.

| Tool | Install |
|---|---|
| GitHub CLI | `brew install gh` then `gh auth login` |
| Node.js 18+ | [nodejs.org](https://nodejs.org) or `brew install node` |
| VS Code | [code.visualstudio.com](https://code.visualstudio.com) |
| VS Code CLI | Open VS Code → Cmd+Shift+P → `Shell Command: Install 'code' command in PATH` |
| Claude Code | Install the Claude Code extension in VS Code |
| Supabase CLI (optional) | `brew install supabase/tap/supabase` — only needed for local DB dev |

MCP connections (Linear, Notion, Netlify, GitHub, Supabase) are configured at the VS Code level, not per-project. Set them up once in Claude Code's MCP settings — they're available in all projects automatically.

---

## Creating a new project

Download both scripts and store them somewhere permanent. You only need to do this once.

```bash
# 1. Download the scripts
curl -o ~/Scripts/create-project.sh https://raw.githubusercontent.com/georgeyiakoumi/gy-basecamp/main/create-project.sh
curl -o ~/Scripts/sync-template.sh https://raw.githubusercontent.com/georgeyiakoumi/gy-basecamp/main/sync-template.sh

# 2. Make them executable
chmod +x ~/Scripts/create-project.sh ~/Scripts/sync-template.sh

# 3. Add aliases to your shell profile (~/.zshrc or ~/.bashrc)
echo 'alias new-project="~/Scripts/create-project.sh"' >> ~/.zshrc
echo 'alias sync-template="bash ~/Scripts/sync-template.sh"' >> ~/.zshrc
source ~/.zshrc
```

**Then to create a project:**

```bash
new-project
```

The script will ask for:
- Project name and type (web app / marketing site / content site / UI component / prototype)
- Add-ons: Supabase, dark mode, sidebar, charts, Shiki

Then it creates the GitHub repo, clones it, configures the scaffold, runs `npm install`, and opens VS Code. From there, Claude Code handles everything else.

## Syncing an existing project

When the template is updated (new rules, improved standards, bug fixes), pull the changes into any existing project:

```bash
cd /path/to/your-project
sync-template
```

This updates only the shared Claude assistant files — `.claude/rules/`, `.claude/project-setup.md`, `.claude/ui-standards.md`, `e2e/smoke.spec.ts`, etc. It never touches `CLAUDE.md`, `README.md`, `.env.local`, or any project code.

```bash
# Preview what would change without writing anything
sync-template --dry-run
```

---

## Environment variables

After the script runs, open `.env.local`. If you included Supabase:

```bash
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

Find these in Supabase under **Settings → API**. Without Supabase, only `NEXT_PUBLIC_APP_URL` is needed.

```bash
npm run dev
```

---

## Deployment

This template is configured for Netlify via `netlify.toml`. To connect:

1. Push to GitHub (the script does this automatically)
2. Netlify → Add new site → Import from GitHub → select the repo
3. Build settings are pre-configured
4. Add environment variables in **Site → Environment variables**
5. Deploy

> **Note on Netlify's free tier:** 300 build credits/month (~30 deploys). Disable auto-publishing during active development — **Site settings → Build & deploy → Stop auto publishing** — and deploy manually when ready to ship.

---

## Applying your brand

Use **[ui.shadcn.com/create](https://ui.shadcn.com/create)** to configure your theme visually. Once finalised:

- **`app/globals.css`** — replace the `:root` and `.dark` blocks with the generated CSS
- **`components.json`** — update `baseColor` and `iconLibrary`
- **`app/layout.tsx`** — add the Google Font variable to `<html>` if a custom font was chosen

Do this once, at the end of the Brand Identity phase, before any components are built. Claude will prompt this as part of the UX process.

---

## Repo structure

```
├── CLAUDE.md                    ← Read on every session open — routing + stack + rules
├── .claude/
│   ├── rules/
│   │   ├── code.md              ← Non-negotiable code rules (re-read after /compact)
│   │   ├── design.md            ← Non-negotiable design rules (re-read after /compact)
│   │   └── process.md           ← Non-negotiable process rules + MCP/skill/git tables
│   ├── memory/
│   │   └── lessons.md           ← Local backup of Notion Lessons & Insights
│   ├── project-setup.md         ← Startup routine: MCP checks → context intake → Notion → Linear
│   ├── discovery.md             ← Pre-build discovery: problem framing, assumptions, research
│   ├── design-psychology.md     ← Hick's Law, Gestalt, Fitts's, Jakob's, Cognitive Load
│   ├── ui-standards.md          ← shadcn · Tailwind · Lucide standards
│   └── ux-process.md            ← Research, personas, brand identity, flows, testing
├── app/
│   ├── globals.css              ← shadcn CSS variables (edit here to apply brand)
│   ├── layout.tsx
│   └── page.tsx
├── components/
│   └── ui/                      ← shadcn components (via npx shadcn add)
├── lib/
│   └── utils.ts                 ← cn() helper
├── e2e/                         ← Playwright E2E tests (set up in Phase 1b)
│   └── smoke.spec.ts
├── public/
├── .env.example
├── components.json              ← shadcn CLI config
├── netlify.toml                 ← Build + headers config
├── playwright.config.ts         ← E2E test config
├── postcss.config.js            ← Tailwind v4 via @tailwindcss/postcss
└── package.json
```

---

## Updating the template

Improve `.claude/` docs or the scaffold directly in this repo. Existing projects won't be affected — they took a snapshot at clone time. That's intentional.
