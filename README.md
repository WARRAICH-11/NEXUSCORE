# NexusCore

Production-grade AI SaaS boilerplate monorepo.

- Apps
  - `apps/web` – Next.js 14 App Router UI (Tailwind)
  - `apps/api` – Next.js API routes (Stripe webhooks)
  - `apps/llm-gateway` – FastAPI microservice (optional)
- Packages
  - `packages/ui` – Shared React UI components
  - `packages/validators` – Zod schemas shared FE/BE
  - `packages/database` – Supabase client helpers + SQL
- Infra
  - `terraform/` – Supabase project provisioning (optional)
  - `docs/` – Architecture, Setup, Runbook

## Quick start

Prereqs: Node 20+, npm 10+, Python 3.11 (for gateway), Stripe CLI, optional Docker.

1) Install deps (root):

```bash
npm install
```

2) Dev servers

- Web (http://localhost:3000)

```bash
npm run dev -w apps/web
```

- API (http://localhost:3001)

```bash
npm run dev -w apps/api
```

- LLM Gateway (optional, http://localhost:8000)

```bash
python -m venv .venv
. .venv/Scripts/Activate.ps1  # Windows PowerShell
pip install -r apps/llm-gateway/requirements.txt
uvicorn apps.llm-gateway.main:app --reload --port 8000
```

3) Stripe webhooks (local):

```bash
stripe listen --forward-to localhost:3001/api/stripe/webhook
```

## Environment

Copy `.env.example` to `.env` at repo root (consumed by Next apps). Set:

- `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`, `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY`
- Optional provider keys: `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `TOGETHER_API_KEY`
- Observability: `OTEL_EXPORTER_OTLP_ENDPOINT`, `OTEL_SERVICE_NAME`

Dev fallback values are used in `@nexuscore/database` to boot without a local .env.

## Scripts

- Root
  - `npm run dev` – Turbo dev across apps
  - `npm run build` – Turbo build
  - `npm run lint` – Lint pipeline (currently no-op for most packages)
  - `npm run format` – Prettier
- Apps
  - `apps/web`: `npm run dev -w apps/web`, `npm run build -w apps/web`
  - `apps/api`: `npm run dev -w apps/api`, `npm run build -w apps/api`

## CI

GitHub Actions workflow at `.github/workflows/ci.yml`:
- Checkout, setup Node 20
- `npm ci`
- Lint pipeline via Turborepo
- Type-check `apps/web` and `apps/api`

## Infra (optional)

`terraform/` can create a Supabase project. See `terraform.tfvars.example`. Apply schema in `packages/database/sql/001_init.sql`.

## Project structure

```
.
├─ apps/
│  ├─ api/
│  ├─ web/
│  └─ llm-gateway/
├─ packages/
│  ├─ config/
│  ├─ database/
│  ├─ ui/
│  └─ validators/
├─ docs/
├─ terraform/
├─ turbo.json
├─ package.json
└─ README.md
```

## License

MIT
