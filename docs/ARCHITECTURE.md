# NexusCore Architecture

```mermaid
flowchart LR
  UI[Next.js Web (apps/web)] -->|HTTP| API[Next.js API (apps/api)]
  API -->|HTTP| LLM[LLM Gateway (FastAPI)]
  API -->|Supabase JS| DB[(Supabase Postgres + Auth + RLS + pgvector)]
  LLM -->|Providers| OpenAI[(OpenAI)]
  LLM --> Anthropic[(Anthropic)]
  LLM --> Together[(Together.ai)]
  API -->|Stripe SDK + Webhooks| Stripe[(Stripe)]
  subgraph Observability
    OTel[OpenTelemetry SDK] --> Tempo[Tempo/Jaeger]
  end
  UI -.traces .-> OTel
  API -.traces .-> OTel
  LLM -.traces .-> OTel
```

- apps/web: Next.js 14 App Router, Tailwind, shadcn/ui.
- apps/api: Next.js API routes (Node runtime), Stripe webhooks, org/services.
- apps/llm-gateway: FastAPI service normalizing LLM providers with retries/fallbacks and RAG plugins.
- packages/ui: Shared UI components.
- packages/validators: Zod schemas shared across FE/BE.
- packages/database: SQL migrations and types.
- terraform/: Supabase project provisioning.
