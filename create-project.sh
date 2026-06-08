#!/bin/bash

# ─────────────────────────────────────────────────────────────
# create-project.sh
# Creates a new project repo from George's design template.
# Branches scaffold, config, and CLAUDE.md based on project type.
#
# Prerequisites:
#   - GitHub CLI installed and authenticated (gh auth login)
#   - Node.js 18+ installed
#   - VS Code CLI installed (code command available)
#   - T7 Editing external drive mounted (preferred)
# ─────────────────────────────────────────────────────────────

set -e

TEMPLATE_REPO="georgeyiakoumi/gy-basecamp"
DRIVE_NAME="T7 Editing"
DRIVE_PATH="/Volumes/$DRIVE_NAME"
PROJECTS_DIR="$DRIVE_PATH/Projects"
FALLBACK_DIR="$HOME/Projects"

# ── Colours ──────────────────────────────────────────────────
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo ""
echo -e "${BOLD}╔══════════════════════════════════╗${RESET}"
echo -e "${BOLD}║     New Project Setup            ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════╝${RESET}"
echo ""

# ── Check prerequisites ───────────────────────────────────────
echo -e "${BLUE}Checking prerequisites...${RESET}"

if ! command -v gh &> /dev/null; then
  echo -e "${RED}✗ GitHub CLI (gh) not found. Install: https://cli.github.com${RESET}"
  exit 1
fi

if ! command -v node &> /dev/null; then
  echo -e "${RED}✗ Node.js not found. Install: https://nodejs.org${RESET}"
  exit 1
fi

if ! command -v code &> /dev/null; then
  echo -e "${YELLOW}⚠ VS Code CLI (code) not found — open the project manually after.${RESET}"
  VSCODE_AVAILABLE=false
else
  VSCODE_AVAILABLE=true
fi

echo -e "${GREEN}✓ Prerequisites met${RESET}"
echo ""

# ── Check T7 Editing drive ────────────────────────────────────
if [ -d "$DRIVE_PATH" ]; then
  echo -e "${GREEN}✓ $DRIVE_NAME is connected${RESET}"
  mkdir -p "$PROJECTS_DIR"
  ACTIVE_DIR="$PROJECTS_DIR"
else
  echo -e "${YELLOW}⚠ $DRIVE_NAME is not connected.${RESET}"
  echo -e "  Projects will be saved to ${YELLOW}$FALLBACK_DIR${RESET} instead."
  echo ""
  read -p "Continue with fallback location? (y/n): " USE_FALLBACK
  if [[ "$USE_FALLBACK" != "y" && "$USE_FALLBACK" != "Y" ]]; then
    echo -e "${RED}Aborted. Connect $DRIVE_NAME and try again.${RESET}"
    exit 0
  fi
  mkdir -p "$FALLBACK_DIR"
  ACTIVE_DIR="$FALLBACK_DIR"
fi

echo ""

# ── Project name ──────────────────────────────────────────────
while true; do
  read -p "$(echo -e ${BOLD})Project name (kebab-case, e.g. client-dashboard): $(echo -e ${RESET})" PROJECT_NAME

  if [[ -z "$PROJECT_NAME" ]]; then
    echo -e "${RED}✗ Project name cannot be empty.${RESET}"
    echo ""
    continue
  fi

  if [[ ! "$PROJECT_NAME" =~ ^[a-z0-9-]+$ ]]; then
    echo -e "${RED}✗ Use lowercase letters, numbers, and hyphens only.${RESET}"
    echo ""
    continue
  fi

  if gh repo view "georgeyiakoumi/$PROJECT_NAME" &> /dev/null; then
    echo -e "${RED}✗ A repo named '$PROJECT_NAME' already exists on your GitHub account.${RESET}"
    echo ""
    continue
  fi

  if [ -d "$ACTIVE_DIR/$PROJECT_NAME" ]; then
    echo -e "${YELLOW}⚠ A folder named '$PROJECT_NAME' already exists at $ACTIVE_DIR${RESET}"
    read -p "Delete it and continue? (y/n): " DELETE_FOLDER
    if [[ "$DELETE_FOLDER" == "y" || "$DELETE_FOLDER" == "Y" ]]; then
      rm -rf "$ACTIVE_DIR/$PROJECT_NAME"
      echo -e "${GREEN}✓ Deleted $ACTIVE_DIR/$PROJECT_NAME${RESET}"
    else
      echo ""
      continue
    fi
  fi

  break
done

# ── Project type ──────────────────────────────────────────────
echo ""
echo -e "${BOLD}What are you building?${RESET}"
echo -e "  ${CYAN}1)${RESET} Web app        — Next.js + shadcn + Tailwind + Netlify"
echo -e "  ${CYAN}2)${RESET} Marketing site — Next.js + shadcn + Tailwind + Netlify"
echo -e "  ${CYAN}3)${RESET} Content site   — Next.js + shadcn + Tailwind + Strapi + Render + Netlify"
echo -e "  ${CYAN}4)${RESET} UI component   — Next.js + shadcn + Tailwind only"
echo -e "  ${CYAN}5)${RESET} Prototype      — Next.js + shadcn + Tailwind only"
echo ""
read -p "$(echo -e ${BOLD})Choose (1-5): $(echo -e ${RESET})" PROJECT_TYPE

case $PROJECT_TYPE in
  1)
    PROJECT_TYPE_LABEL="Web app"
    USE_NETLIFY=true
    USE_STRAPI=false
    MCP_BLOCK="| **Linear** | Creating/updating issues, logging decisions, tracking progress |
| **Notion** | Creating/updating the master plan document |
| **Netlify** | Checking deployment status and environment config |
| **GitHub** | Repo access, branch/PR status |"
    ;;
  2)
    PROJECT_TYPE_LABEL="Marketing site"
    STACK_SUMMARY="Next.js · shadcn/ui · Tailwind CSS · Netlify"
    USE_SUPABASE=false
    USE_NETLIFY=true
    USE_STRAPI=false
    STACK_BLOCK="| Framework | Next.js (App Router) |
| Styling | Tailwind CSS |
| Components | shadcn/ui |
| Icons | Lucide React |
| Deployment | Netlify |"
    MCP_BLOCK="| **Linear** | Creating/updating issues, logging decisions, tracking progress |
| **Notion** | Creating/updating the master plan document |
| **Netlify** | Checking deployment status and environment config |
| **GitHub** | Repo access, branch/PR status |
| **Excalidraw** | Generating IA diagrams and user flows |"
    ;;
  3)
    PROJECT_TYPE_LABEL="Content site"
    STACK_SUMMARY="Next.js · shadcn/ui · Tailwind CSS · Strapi · Render · Netlify"
    USE_SUPABASE=true
    USE_NETLIFY=true
    USE_STRAPI=true
    STACK_BLOCK="| Framework | Next.js (App Router) |
| Styling | Tailwind CSS |
| Components | shadcn/ui |
| Icons | Lucide React |
| CMS | Strapi (subfolder → deployed to Render) |
| Database | Supabase (used by Strapi) |
| Deployment | Netlify (frontend) · Render (Strapi) |"
    MCP_BLOCK="| **Linear** | Creating/updating issues, logging decisions, tracking progress |
| **Notion** | Creating/updating the master plan document |
| **Netlify** | Checking frontend deployment status |
| **GitHub** | Repo access, branch/PR status |
| **Excalidraw** | Generating IA diagrams and user flows |"
    ;;
  4)
    PROJECT_TYPE_LABEL="UI component"
    STACK_SUMMARY="Next.js · shadcn/ui · Tailwind CSS"
    USE_SUPABASE=false
    USE_NETLIFY=false
    USE_STRAPI=false
    STACK_BLOCK="| Framework | Next.js (App Router) |
| Styling | Tailwind CSS |
| Components | shadcn/ui |
| Icons | Lucide React |"
    MCP_BLOCK="| **Linear** | Creating/updating issues, logging decisions, tracking progress |
| **Notion** | Creating/updating the master plan document |
| **GitHub** | Repo access, branch/PR status |
| **Excalidraw** | Generating IA diagrams and user flows |"
    ;;
  5)
    PROJECT_TYPE_LABEL="Prototype"
    STACK_SUMMARY="Next.js · shadcn/ui · Tailwind CSS"
    USE_SUPABASE=false
    USE_NETLIFY=false
    USE_STRAPI=false
    STACK_BLOCK="| Framework | Next.js (App Router) |
| Styling | Tailwind CSS |
| Components | shadcn/ui |
| Icons | Lucide React |"
    MCP_BLOCK="| **Linear** | Creating/updating issues, logging decisions, tracking progress |
| **Notion** | Creating/updating the master plan document |
| **GitHub** | Repo access, branch/PR status |
| **Excalidraw** | Generating IA diagrams and user flows |"
    ;;
  *)
    echo -e "${RED}✗ Invalid choice. Run the script again and enter 1–5.${RESET}"
    exit 1
    ;;
esac

# ── Supabase (skip for content site — already included; skip for UI/prototype) ──
if [ "$USE_STRAPI" = false ] && [ "$USE_NETLIFY" = true ]; then
  echo ""
  read -p "$(echo -e ${BOLD})Will this project need Supabase (auth / database)? (y/n): $(echo -e ${RESET})" USE_SUPABASE_INPUT
  if [[ "$USE_SUPABASE_INPUT" == "y" || "$USE_SUPABASE_INPUT" == "Y" ]]; then
    USE_SUPABASE=true
  else
    USE_SUPABASE=false
  fi
elif [ "$USE_STRAPI" = true ]; then
  USE_SUPABASE=true  # Content site always needs Supabase for Strapi
fi

# ── Build stack summary + block dynamically ───────────────────
if [ "$PROJECT_TYPE_LABEL" = "Web app" ] || [ "$PROJECT_TYPE_LABEL" = "Marketing site" ]; then
  if [ "$USE_SUPABASE" = true ]; then
    STACK_SUMMARY="Next.js · shadcn/ui · Tailwind CSS · Supabase · Netlify"
    STACK_BLOCK="| Framework | Next.js (App Router) |
| Styling | Tailwind CSS |
| Components | shadcn/ui |
| Icons | Lucide React |
| Database | Supabase |
| Deployment | Netlify |"
  else
    STACK_SUMMARY="Next.js · shadcn/ui · Tailwind CSS · Netlify"
    STACK_BLOCK="| Framework | Next.js (App Router) |
| Styling | Tailwind CSS |
| Components | shadcn/ui |
| Icons | Lucide React |
| Deployment | Netlify |"
  fi
fi

# ── Charts ────────────────────────────────────────────────────
echo ""
read -p "$(echo -e ${BOLD})Will this project need charts or data visualisation? (y/n): $(echo -e ${RESET})" USE_CHARTS
if [[ "$USE_CHARTS" == "y" || "$USE_CHARTS" == "Y" ]]; then
  USE_CHARTS=true
else
  USE_CHARTS=false
fi

# ── Shiki ────────────────────────────────────────────────────
echo ""
read -p "$(echo -e ${BOLD})Will this project display code on the frontend? (y/n): $(echo -e ${RESET})" USE_SHIKI
if [[ "$USE_SHIKI" == "y" || "$USE_SHIKI" == "Y" ]]; then
  USE_SHIKI=true
else
  USE_SHIKI=false
fi

# ── Sidebar ───────────────────────────────────────────────────
echo ""
read -p "$(echo -e ${BOLD})Will this project use a sidebar layout? (y/n): $(echo -e ${RESET})" USE_SIDEBAR
if [[ "$USE_SIDEBAR" == "y" || "$USE_SIDEBAR" == "Y" ]]; then
  USE_SIDEBAR=true
else
  USE_SIDEBAR=false
fi

# ── Storybook ─────────────────────────────────────────────────
echo ""
read -p "$(echo -e ${BOLD})Will this project need a component library / Storybook? (y/n): $(echo -e ${RESET})" USE_STORYBOOK
if [[ "$USE_STORYBOOK" == "y" || "$USE_STORYBOOK" == "Y" ]]; then
  USE_STORYBOOK=true
else
  USE_STORYBOOK=false
fi

# ── Cloudinary ────────────────────────────────────────────────
echo ""
read -p "$(echo -e ${BOLD})Will this project need managed media / image uploads (Cloudinary)? (y/n): $(echo -e ${RESET})" USE_CLOUDINARY
if [[ "$USE_CLOUDINARY" == "y" || "$USE_CLOUDINARY" == "Y" ]]; then
  USE_CLOUDINARY=true
else
  USE_CLOUDINARY=false
fi

# ── Cloudflare + ISR webhooks ─────────────────────────────────
echo ""
read -p "$(echo -e ${BOLD})Will this project use Cloudflare + ISR webhook revalidation? (y/n): $(echo -e ${RESET})" USE_CLOUDFLARE
if [[ "$USE_CLOUDFLARE" == "y" || "$USE_CLOUDFLARE" == "Y" ]]; then
  USE_CLOUDFLARE=true
else
  USE_CLOUDFLARE=false
fi

# ── Dark mode ─────────────────────────────────────────────────
echo ""
echo -e "${BOLD}Theme toggling (dark mode) is included by default.${RESET}"
read -p "$(echo -e ${BOLD})Include dark mode? [Y/n]: $(echo -e ${RESET})" USE_DARK_MODE_INPUT
if [[ "$USE_DARK_MODE_INPUT" == "n" || "$USE_DARK_MODE_INPUT" == "N" ]]; then
  USE_DARK_MODE=false
else
  USE_DARK_MODE=true
fi

# ── Visibility ────────────────────────────────────────────────
echo ""
echo -e "${BOLD}Repo visibility:${RESET}"
select VISIBILITY in "private" "public"; do
  case $VISIBILITY in
    private|public) break;;
  esac
done

# ── Confirm ───────────────────────────────────────────────────
echo ""
echo -e "${BOLD}Summary:${RESET}"
echo -e "  Name:       ${GREEN}$PROJECT_NAME${RESET}"
echo -e "  Type:       ${CYAN}$PROJECT_TYPE_LABEL${RESET}"
echo -e "  Stack:      $STACK_SUMMARY"
if [ "$USE_SUPABASE" = true ] && [ "$USE_STRAPI" = false ]; then
  echo -e "  Supabase:   auth + database scaffolding included"
fi
if [ "$USE_CHARTS" = true ]; then
  echo -e "  Charts:     Recharts + shadcn Chart"
fi
if [ "$USE_SHIKI" = true ]; then
  echo -e "  Shiki:      syntax highlighting"
fi
if [ "$USE_SIDEBAR" = true ]; then
  echo -e "  Sidebar:    shadcn Sidebar + CSS variables"
fi
if [ "$USE_STORYBOOK" = true ]; then
  echo -e "  Storybook:  component documentation"
fi
if [ "$USE_CLOUDINARY" = true ]; then
  echo -e "  Cloudinary: media + image management"
fi
if [ "$USE_CLOUDFLARE" = true ]; then
  echo -e "  Cloudflare: ISR webhook revalidation"
fi
if [ "$USE_DARK_MODE" = true ]; then
  echo -e "  Dark mode:  next-themes ThemeProvider"
else
  echo -e "  Dark mode:  ${YELLOW}skipped${RESET}"
fi
echo -e "  Visibility: $VISIBILITY"
echo -e "  Location:   ${BLUE}$ACTIVE_DIR/$PROJECT_NAME${RESET}"
echo ""
read -p "Continue? (y/n): " CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "Aborted."
  exit 0
fi

cd "$ACTIVE_DIR"

echo ""
echo -e "${BLUE}Creating GitHub repo from template...${RESET}"

if [ "$VISIBILITY" = "private" ]; then
  gh repo create "$PROJECT_NAME" \
    --template "$TEMPLATE_REPO" \
    --private \
    --clone
else
  gh repo create "$PROJECT_NAME" \
    --template "$TEMPLATE_REPO" \
    --public \
    --clone
fi

echo -e "${GREEN}✓ Repo created and cloned${RESET}"
cd "$PROJECT_NAME"

# ── Tailor scaffold based on project type ─────────────────────
echo ""
echo -e "${BLUE}Configuring scaffold for: $PROJECT_TYPE_LABEL...${RESET}"

if [ "$USE_SUPABASE" = false ]; then
  rm -rf supabase
  rm -f lib/supabase/client.ts lib/supabase/server.ts
  rmdir lib/supabase 2>/dev/null || true
  echo -e "  ${YELLOW}↳ Removed Supabase config${RESET}"
fi

if [ "$USE_NETLIFY" = false ]; then
  rm -f netlify.toml
  echo -e "  ${YELLOW}↳ Removed Netlify config${RESET}"
fi

# Rebuild .env.example to match the stack
if [ "$USE_SUPABASE" = false ]; then
  cat > .env.example << 'EOF'
# ── App ───────────────────────────────────────────────────────
NEXT_PUBLIC_APP_URL=http://localhost:3000
EOF
fi

if [ "$USE_STRAPI" = true ]; then
  cat >> .env.example << 'EOF'

# ── Strapi ────────────────────────────────────────────────────
# Set once Strapi is deployed to Render
NEXT_PUBLIC_STRAPI_URL=http://localhost:1337
STRAPI_API_TOKEN=your-strapi-api-token
EOF

  mkdir -p strapi
  cat > strapi/README.md << 'EOF'
# Strapi CMS

This subfolder contains the Strapi CMS instance for this project.

## Local setup

```bash
cd strapi
npx create-strapi-app@latest . --quickstart
```

## Deploying to Render

1. Push this repo to GitHub
2. Go to render.com → New Web Service → connect this repo
3. Set root directory to `strapi`
4. Build command: `npm run build`
5. Start command: `npm run start`

Set these environment variables in Render:
- `DATABASE_URL` — Supabase connection string (Settings → Database → URI)
- `ADMIN_JWT_SECRET` — run: openssl rand -base64 32
- `API_TOKEN_SALT`   — run: openssl rand -base64 32
- `APP_KEYS`         — run: openssl rand -base64 32
- `JWT_SECRET`       — run: openssl rand -base64 32

Once deployed, copy the Render URL to NEXT_PUBLIC_STRAPI_URL in Netlify env vars.
EOF
  echo -e "  ${YELLOW}↳ Added Strapi subfolder — see strapi/README.md to init${RESET}"
fi

# Add Recharts + chart tokens if charts enabled
if [ "$USE_CHARTS" = true ]; then
  # Add recharts to package.json dependencies
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's/"lucide-react": "[^"]*"/"lucide-react": "^0.460.0",\n    "recharts": "^2.15.0"/' package.json
  else
    sed -i 's/"lucide-react": "[^"]*"/"lucide-react": "^0.460.0",\n    "recharts": "^2.15.0"/' package.json
  fi

  # Inject chart tokens into globals.css using Python (v4 oklch format)
  python3 - << 'PYEOF'
import re

with open('app/globals.css', 'r') as f:
    css = f.read()

CHART_LIGHT = """
  /* ── Chart colours ─────────────────────────────────────────
     Used by shadcn Chart component. Edit to match your brand.
  ───────────────────────────────────────────────────────── */
  --chart-1: oklch(0.646 0.222 41.116);
  --chart-2: oklch(0.6 0.118 184.704);
  --chart-3: oklch(0.398 0.07 227.392);
  --chart-4: oklch(0.828 0.189 84.429);
  --chart-5: oklch(0.769 0.188 70.08);"""

CHART_DARK = """
  --chart-1: oklch(0.488 0.243 264.376);
  --chart-2: oklch(0.696 0.17 162.48);
  --chart-3: oklch(0.769 0.188 70.08);
  --chart-4: oklch(0.627 0.265 303.9);
  --chart-5: oklch(0.645 0.246 16.439);"""

# Insert after --radius line in :root
css = re.sub(r'(  --radius: [^;]+;)', r'\1' + CHART_LIGHT, css, count=1)
# Insert before closing brace of .dark block
css = re.sub(r'(\.dark \{[^}]*?)(})', lambda m: m.group(1) + CHART_DARK + '\n}', css, count=1, flags=re.DOTALL)

with open('app/globals.css', 'w') as f:
    f.write(css)
PYEOF

  echo -e "  ${YELLOW}↳ Added Recharts + chart colour tokens${RESET}"
fi

# Add sidebar CSS variables if sidebar enabled
if [ "$USE_SIDEBAR" = true ]; then
  python3 - << 'PYEOF'
import re

with open('app/globals.css', 'r') as f:
    css = f.read()

SIDEBAR_LIGHT = """
  /* ── Sidebar ───────────────────────────────────────────────
     Used by shadcn Sidebar component.
  ───────────────────────────────────────────────────────── */
  --sidebar: oklch(0.985 0 0);
  --sidebar-foreground: oklch(0.145 0 0);
  --sidebar-primary: oklch(0.205 0 0);
  --sidebar-primary-foreground: oklch(0.985 0 0);
  --sidebar-accent: oklch(0.97 0 0);
  --sidebar-accent-foreground: oklch(0.205 0 0);
  --sidebar-border: oklch(0.922 0 0);
  --sidebar-ring: oklch(0.708 0 0);"""

SIDEBAR_DARK = """
  --sidebar: oklch(0.205 0 0);
  --sidebar-foreground: oklch(0.985 0 0);
  --sidebar-primary: oklch(0.488 0.243 264.376);
  --sidebar-primary-foreground: oklch(0.985 0 0);
  --sidebar-accent: oklch(0.269 0 0);
  --sidebar-accent-foreground: oklch(0.985 0 0);
  --sidebar-border: oklch(1 0 0 / 10%);
  --sidebar-ring: oklch(0.556 0 0);"""

# Insert after --radius line in :root
css = re.sub(r'(  --radius: [^;]+;)', r'\1' + SIDEBAR_LIGHT, css, count=1)
# Insert before closing brace of .dark block
css = re.sub(r'(\.dark \{[^}]*?)(})', lambda m: m.group(1) + SIDEBAR_DARK + '\n}', css, count=1, flags=re.DOTALL)

with open('app/globals.css', 'w') as f:
    f.write(css)
PYEOF
  echo -e "  ${YELLOW}↳ Added sidebar CSS variables (light + dark)${RESET}"
fi

# Set up dark mode with next-themes
if [ "$USE_DARK_MODE" = true ]; then
  # Add next-themes to package.json dependencies
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's/"lucide-react": "[^"]*"/"lucide-react": "^0.460.0",\n    "next-themes": "^0.4.4"/' package.json
  else
    sed -i 's/"lucide-react": "[^"]*"/"lucide-react": "^0.460.0",\n    "next-themes": "^0.4.4"/' package.json
  fi

  # Wrap layout.tsx with ThemeProvider
  cat > app/layout.tsx << 'LAYOUTEOF'
import type { Metadata } from 'next'
import { ThemeProvider } from 'next-themes'
import './globals.css'

export const metadata: Metadata = {
  title: 'Project',
  description: 'Built with Next.js, shadcn/ui, and Tailwind CSS.',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className="min-h-screen bg-background font-sans antialiased">
        <ThemeProvider
          attribute="class"
          defaultTheme="system"
          enableSystem
          disableTransitionOnChange
        >
          {children}
        </ThemeProvider>
      </body>
    </html>
  )
}
LAYOUTEOF

  echo -e "  ${YELLOW}↳ Added next-themes ThemeProvider to layout.tsx${RESET}"
else
  echo -e "  ${YELLOW}↳ Dark mode skipped — .dark CSS vars retained for future use${RESET}"
fi

echo -e "${GREEN}✓ Scaffold configured${RESET}"

# ── Inject project identity into CLAUDE.md ────────────────────
echo ""
echo -e "${BLUE}Updating CLAUDE.md...${RESET}"

ORIGINAL_CLAUDE=$(cat CLAUDE.md)

DARK_MODE_FLAG="true"
if [ "$USE_DARK_MODE" = false ]; then DARK_MODE_FLAG="false"; fi
SIDEBAR_FLAG="false"
if [ "$USE_SIDEBAR" = true ]; then SIDEBAR_FLAG="true"; fi
SHIKI_FLAG="false"
if [ "$USE_SHIKI" = true ]; then SHIKI_FLAG="true"; fi

cat > CLAUDE.md << EOF
# Project: $PROJECT_NAME
**Type:** $PROJECT_TYPE_LABEL
**Created:** $(date +%Y-%m-%d)
**Dark mode:** $DARK_MODE_FLAG
**Sidebar:** $SIDEBAR_FLAG
**Shiki:** $SHIKI_FLAG

## Stack

| Layer | Tool |
|---|---|
$STACK_BLOCK

## Active MCPs

| MCP | When to use |
|---|---|
$MCP_BLOCK

**Standing rules:**
- Log decisions and trade-offs as comments on the relevant Linear issue — not just in conversation
- If scope changes, update Notion first, then adjust Linear to match
- Never create Linear issues without a corresponding Notion plan entry

---

$ORIGINAL_CLAUDE
EOF

echo -e "${GREEN}✓ CLAUDE.md updated${RESET}"

# ── Rewrite README.md for this project type ───────────────────
echo -e "${BLUE}Updating README.md...${RESET}"

# Build env vars section
if [ "$USE_SUPABASE" = true ] && [ "$USE_STRAPI" = true ]; then
  ENV_SECTION='After the script runs, open `.env.local` and fill in your credentials:

```bash
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_STRAPI_URL=http://localhost:1337
STRAPI_API_TOKEN=your-strapi-api-token
```

Find Supabase keys under **Settings → API** in your Supabase project. Strapi keys are set once Strapi is deployed to Render.'
elif [ "$USE_SUPABASE" = true ]; then
  ENV_SECTION='After the script runs, open `.env.local` and fill in your Supabase credentials:

```bash
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

Find these in your Supabase project under **Settings → API**.'
else
  ENV_SECTION='After the script runs, `.env.local` is ready to go:

```bash
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

No external services to configure.'
fi

# Build deployment section
if [ "$USE_NETLIFY" = true ] && [ "$USE_STRAPI" = true ]; then
  DEPLOY_SECTION='## Deployment

### Frontend (Netlify)

Configured via `netlify.toml`. To connect:

1. Push the repo to GitHub
2. Go to [netlify.com](https://netlify.com) → Add new site → Import from GitHub
3. Select the repo — build settings are pre-configured
4. Add environment variables: `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `NEXT_PUBLIC_APP_URL`, `NEXT_PUBLIC_STRAPI_URL`, `STRAPI_API_TOKEN`
5. Deploy

### Strapi CMS (Render)

See `strapi/README.md` for full setup instructions.'
elif [ "$USE_NETLIFY" = true ]; then
  DEPLOY_SECTION="## Deployment

Configured for Netlify via \`netlify.toml\`. To connect:

1. Push the repo to GitHub
2. Go to [netlify.com](https://netlify.com) → Add new site → Import from GitHub
3. Select the repo — build settings are pre-configured
4. Add environment variables in **Site → Environment variables**
5. Deploy"
else
  DEPLOY_SECTION='## Running locally

```bash
npm run dev
```

No deployment target is configured. Add one when you are ready to ship.'
fi

# Build repo structure section
if [ "$USE_SUPABASE" = true ] && [ "$USE_STRAPI" = true ]; then
  STRUCTURE_SECTION='```
├── CLAUDE.md
├── .claude/
│   ├── project-setup.md
│   ├── design-psychology.md
│   ├── ui-standards.md
│   └── ux-process.md
├── app/
│   ├── globals.css
│   ├── layout.tsx
│   └── page.tsx
├── components/ui/
├── lib/
│   ├── utils.ts
│   └── supabase/
│       ├── client.ts
│       └── server.ts
├── strapi/
│   └── README.md
├── supabase/
│   └── config.toml
├── public/
├── .env.example
├── netlify.toml
├── package.json
├── tailwind.config.ts
└── tsconfig.json
```'
elif [ "$USE_SUPABASE" = true ]; then
  STRUCTURE_SECTION='```
├── CLAUDE.md
├── .claude/
│   ├── project-setup.md
│   ├── design-psychology.md
│   ├── ui-standards.md
│   └── ux-process.md
├── app/
│   ├── globals.css
│   ├── layout.tsx
│   └── page.tsx
├── components/ui/
├── lib/
│   ├── utils.ts
│   └── supabase/
│       ├── client.ts
│       └── server.ts
├── supabase/
│   └── config.toml
├── public/
├── .env.example
├── netlify.toml
├── package.json
├── tailwind.config.ts
└── tsconfig.json
```'
elif [ "$USE_NETLIFY" = true ]; then
  STRUCTURE_SECTION='```
├── CLAUDE.md
├── .claude/
│   ├── project-setup.md
│   ├── design-psychology.md
│   ├── ui-standards.md
│   └── ux-process.md
├── app/
│   ├── globals.css
│   ├── layout.tsx
│   └── page.tsx
├── components/ui/
├── lib/
│   └── utils.ts
├── public/
├── .env.example
├── netlify.toml
├── package.json
├── tailwind.config.ts
└── tsconfig.json
```'
else
  STRUCTURE_SECTION='```
├── CLAUDE.md
├── .claude/
│   ├── project-setup.md
│   ├── design-psychology.md
│   ├── ui-standards.md
│   └── ux-process.md
├── app/
│   ├── globals.css
│   ├── layout.tsx
│   └── page.tsx
├── components/ui/
├── lib/
│   └── utils.ts
├── public/
├── .env.example
├── package.json
├── tailwind.config.ts
└── tsconfig.json
```'
fi

cat > README.md << EOF
# $PROJECT_NAME

**Type:** $PROJECT_TYPE_LABEL
**Stack:** $STACK_SUMMARY

---

## Getting started

\`\`\`bash
npm run dev
\`\`\`

Open [http://localhost:3000](http://localhost:3000).

---

## Environment variables

$ENV_SECTION

---

$DEPLOY_SECTION

---

## Repo structure

$STRUCTURE_SECTION

---

## Adding shadcn components

\`\`\`bash
npx shadcn add button
npx shadcn add card dialog select table tabs
\`\`\`

Components land in \`components/ui/\` and inherit your brand tokens automatically.

---

## Applying your brand

**\`app/globals.css\`** — update the HSL values for \`--primary\`, \`--accent\`, \`--radius\`, and any other shadcn tokens.

**\`tailwind.config.ts\`** — update \`fontFamily.sans\` to your chosen typeface. Add the font import to \`layout.tsx\` using \`next/font\`.

Both light (\`:root\`) and dark (\`.dark\`) variants are pre-wired. Update both when changing colours.
EOF

echo -e "${GREEN}✓ README.md updated${RESET}"

# ── Install dependencies ──────────────────────────────────────
echo ""
echo -e "${BLUE}Installing dependencies...${RESET}"
npm install
echo -e "${GREEN}✓ Dependencies installed${RESET}"

# ── Add shadcn chart component if charts enabled ──────────────
if [ "$USE_CHARTS" = true ]; then
  echo -e "${BLUE}Adding shadcn Chart component...${RESET}"
  npx shadcn@latest add chart -y
  echo -e "${GREEN}✓ Chart component added${RESET}"
fi

# ── Install Shiki if code display enabled ─────────────────────
if [ "$USE_SHIKI" = true ]; then
  echo -e "${BLUE}Installing Shiki...${RESET}"
  npm install shiki
  echo -e "${GREEN}✓ Shiki installed${RESET}"
fi

# ── Set up Storybook if enabled ───────────────────────────────
if [ "$USE_STORYBOOK" = true ]; then
  echo -e "${BLUE}Setting up Storybook...${RESET}"
  npx storybook@latest init --yes
  echo -e "${GREEN}✓ Storybook initialised${RESET}"
fi

# ── Set up Cloudinary if enabled ──────────────────────────────
if [ "$USE_CLOUDINARY" = true ]; then
  echo -e "${BLUE}Installing Cloudinary...${RESET}"
  npm install next-cloudinary

  # Scaffold a minimal helper
  mkdir -p lib
  cat > lib/cloudinary.ts << 'EOF'
import { v2 as cloudinary } from 'cloudinary'

cloudinary.config({
  cloud_name: process.env.NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
})

export default cloudinary
EOF

  cat >> .env.example << 'EOF'

# ── Cloudinary ────────────────────────────────────────────────
NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret
EOF

  echo -e "  ${YELLOW}↳ Add Cloudinary keys to .env.local (Settings → API Keys in Cloudinary dashboard)${RESET}"
  echo -e "${GREEN}✓ Cloudinary scaffolded${RESET}"
fi

# ── Set up Cloudflare + ISR webhook if enabled ────────────────
if [ "$USE_CLOUDFLARE" = true ]; then
  echo -e "${BLUE}Scaffolding Cloudflare ISR webhook revalidation...${RESET}"

  mkdir -p app/api/revalidate
  cat > app/api/revalidate/route.ts << 'EOF'
import { revalidatePath, revalidateTag } from 'next/cache'
import { NextRequest, NextResponse } from 'next/server'

export async function POST(request: NextRequest) {
  const secret = request.nextUrl.searchParams.get('secret')

  if (secret !== process.env.REVALIDATION_SECRET) {
    return NextResponse.json({ message: 'Invalid secret' }, { status: 401 })
  }

  const body = await request.json().catch(() => ({}))
  const tag = body?.tag as string | undefined
  const path = body?.path as string | undefined

  if (tag) {
    revalidateTag(tag)
    return NextResponse.json({ revalidated: true, tag })
  }

  if (path) {
    revalidatePath(path)
    return NextResponse.json({ revalidated: true, path })
  }

  return NextResponse.json(
    { message: 'Provide a tag or path in the request body' },
    { status: 400 }
  )
}
EOF

  cat >> .env.example << 'EOF'

# ── Cloudflare / ISR revalidation ─────────────────────────────
# Generate with: openssl rand -base64 32
REVALIDATION_SECRET=your-revalidation-secret
EOF

  echo -e "  ${YELLOW}↳ Webhook endpoint: POST /api/revalidate?secret=\$REVALIDATION_SECRET${RESET}"
  echo -e "  ${YELLOW}↳ Body: { \"tag\": \"posts\" } or { \"path\": \"/blog\" }${RESET}"
  echo -e "  ${YELLOW}↳ Set up Cloudflare Worker or webhook in your CMS to call this on content publish${RESET}"
  echo -e "${GREEN}✓ ISR revalidation route scaffolded${RESET}"
fi

# ── Set up .env.local ─────────────────────────────────────────
if [ -f ".env.example" ]; then
  cp .env.example .env.local
  echo -e "${GREEN}✓ .env.local created from .env.example${RESET}"
  if [ "$USE_SUPABASE" = true ]; then
    echo -e "${YELLOW}  ↳ Fill in Supabase keys in .env.local before starting the dev server${RESET}"
  fi
  if [ "$USE_STRAPI" = true ]; then
    echo -e "${YELLOW}  ↳ Fill in STRAPI_API_TOKEN once Strapi is deployed to Render${RESET}"
  fi
fi

# ── Open in VS Code ───────────────────────────────────────────
echo ""
if [ "$VSCODE_AVAILABLE" = true ]; then
  echo -e "${BLUE}Opening in VS Code...${RESET}"
  code .
  echo -e "${GREEN}✓ VS Code opened${RESET}"
  echo ""
  echo -e "${BOLD}Claude Code will load CLAUDE.md automatically.${RESET}"
  echo -e "It will run the project setup routine and check MCP connections."
else
  echo -e "${YELLOW}Open VS Code manually:${RESET}"
  echo -e "  cd \"$(pwd)\" && code ."
fi

# ── Done ──────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════╗${RESET}"
echo -e "${GREEN}${BOLD}║     Project ready!               ║${RESET}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════╝${RESET}"
echo ""
echo -e "  ${BOLD}Name:${RESET}      $PROJECT_NAME"
echo -e "  ${BOLD}Type:${RESET}      $PROJECT_TYPE_LABEL"
echo -e "  ${BOLD}Stack:${RESET}     $STACK_SUMMARY"
if [ "$USE_DARK_MODE" = true ]; then
  echo -e "  ${BOLD}Dark mode:${RESET} enabled (next-themes)"
fi
if [ "$USE_SIDEBAR" = true ]; then
  echo -e "  ${BOLD}Sidebar:${RESET}   CSS variables injected"
fi
if [ "$USE_SHIKI" = true ]; then
  echo -e "  ${BOLD}Shiki:${RESET}     syntax highlighting installed"
fi
if [ "$USE_SUPABASE" = true ] && [ "$USE_STRAPI" = false ]; then
  echo -e "  ${BOLD}Supabase:${RESET}  scaffolding included"
fi
if [ "$USE_STORYBOOK" = true ]; then
  echo -e "  ${BOLD}Storybook:${RESET} component docs ready"
fi
if [ "$USE_CLOUDINARY" = true ]; then
  echo -e "  ${BOLD}Cloudinary:${RESET} lib/cloudinary.ts scaffolded"
fi
if [ "$USE_CLOUDFLARE" = true ]; then
  echo -e "  ${BOLD}Cloudflare:${RESET} ISR route at /api/revalidate"
fi
echo -e "  ${BOLD}GitHub:${RESET}    https://github.com/georgeyiakoumi/$PROJECT_NAME"
echo -e "  ${BOLD}Local:${RESET}     $ACTIVE_DIR/$PROJECT_NAME"
echo ""
if [ "$USE_SUPABASE" = true ]; then
  echo -e "  ${YELLOW}→ Fill in .env.local with your Supabase keys${RESET}"
fi
if [ "$USE_STRAPI" = true ]; then
  echo -e "  ${YELLOW}→ cd strapi && npx create-strapi-app@latest . --quickstart${RESET}"
fi
if [ "$USE_CLOUDINARY" = true ]; then
  echo -e "  ${YELLOW}→ Fill in Cloudinary keys in .env.local${RESET}"
fi
if [ "$USE_CLOUDFLARE" = true ]; then
  echo -e "  ${YELLOW}→ Set REVALIDATION_SECRET in .env.local and Netlify env vars${RESET}"
  echo -e "  ${YELLOW}→ Wire your CMS webhook to POST /api/revalidate?secret=...${RESET}"
fi
echo ""
echo -e "${YELLOW}  One manual step — protect the main branch:${RESET}"
echo -e "  https://github.com/georgeyiakoumi/$PROJECT_NAME/settings/rules/new"
echo -e "  ${YELLOW}↳ Add target → Include by pattern → ${BOLD}main${RESET}"
echo -e "  ${YELLOW}↳ Enable: Restrict deletions${RESET}"
echo -e "  ${YELLOW}↳ Enable: Require a pull request before merging (0 approvals)${RESET}"
echo -e "  ${YELLOW}↳ Enable: Block force pushes${RESET}"
echo -e "  ${YELLOW}↳ Save ruleset${RESET}"
echo ""
echo -e "${CYAN}  Tip: run ${BOLD}sync-template${RESET}${CYAN} from inside this project at any time"
echo -e "  to pull the latest rules and standards from the template.${RESET}"
echo ""
echo -e "${YELLOW}${BOLD}  Before starting work — verify MCPs are connected:${RESET}"
echo -e "${YELLOW}  Claude Code → Settings → MCP Servers${RESET}"
echo ""
echo -e "  ${BOLD}☐ Linear${RESET}   — required for all projects"
echo -e "  ${BOLD}☐ Notion${RESET}   — required for all projects"
echo -e "  ${BOLD}☐ GitHub${RESET}   — required for all projects"
if [ "$USE_NETLIFY" = true ]; then
  echo -e "  ${BOLD}☐ Netlify${RESET}  — required (Netlify deployment selected)"
fi
if [ "$USE_SUPABASE" = true ]; then
  echo -e "  ${BOLD}☐ Supabase${RESET} — required (Supabase selected)"
fi
echo ""
echo -e "  ${CYAN}Then run Phase 1 in project-setup.md to confirm connectivity${RESET}"
echo -e "  ${CYAN}before any design or code work begins.${RESET}"
echo ""
