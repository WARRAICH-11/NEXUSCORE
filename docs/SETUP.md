# NexusCore Setup

## Prerequisites
- Node.js 20+
- npm 10+
- Python 3.11+ (for FastAPI gateway)
- Docker (optional, for gateway container)
- Stripe CLI (for local webhook testing)
- Supabase account and access token

## 1. Install dependencies
At repo root:

```bash
npm install
```

## 2. Environment variables
Copy `.env.example` to each runtime environment as needed. For local dev, you can place a single `.env` at repo root consumed by Next apps.

```bash
cp .env.example .env
```

Populate:
- NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY
- STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET, NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY
- OPENAI_API_KEY, ANTHROPIC_API_KEY, TOGETHER_API_KEY

## 3. Supabase via Terraform (optional first pass)
Set your Supabase access token in environment (PowerShell example):

```powershell
$env:SUPABASE_ACCESS_TOKEN = "<token>"
```

Then from `terraform/` directory:

```bash
terraform init
terraform apply -var "organization_id=<org_id>" -var "db_password=<strongpass>"
```

Apply SQL schema in `packages/database/sql/001_init.sql` to your Supabase project (via SQL editor or migration tooling).

## 4. Start dev servers
- Web (Next.js):

```bash
npm run dev -w apps/web
```

- API (Next.js):

```bash
npm run dev -w apps/api
```

- LLM Gateway (FastAPI):

```bash
python -m venv .venv
. .venv/Scripts/Activate.ps1  # Windows PowerShell
pip install -r apps/llm-gateway/requirements.txt
uvicorn apps.llm-gateway.main:app --reload --port 8000
```

## 5. Stripe webhook (local)
In another terminal:

```bash
stripe listen --forward-to localhost:3001/api/stripe/webhook
```

## 6. Run CI locally (optional)
GitHub Actions config in `.github/workflows/ci.yml` will lint and type-check on PRs.
