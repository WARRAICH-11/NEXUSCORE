# NexusCore Runbook

## Operations Checklist
- Deploy targets
  - Web (apps/web): Vercel
  - API (apps/api): Vercel or Railway
  - LLM Gateway (apps/llm-gateway): Railway or Fly.io (Docker)
  - Tracing backend: Grafana Tempo or Jaeger
- Secrets/Env
  - Supabase: URL, anon, service role
  - Stripe: secret key, publishable key, webhook secret
  - LLM providers: OpenAI/Anthropic/Together
  - OTEL exporter endpoint and service name

## Common Procedures

### 1) Investigate a failed user request end-to-end
1. In Vercel, find the request ID or timestamp.
2. Query traces in your OTel backend (Tempo/Jaeger) filtering by `service.name=nexuscore`.
3. Follow span tree: UI -> API -> LLM Gateway -> Providers/DB.
4. Inspect errors/logs on the failing span. Correlate with API logs and Stripe usage if billing quota is involved.

### 2) Stripe webhooks not firing locally
- Ensure Stripe CLI is running and forwarding correctly:
  ```bash
  stripe listen --forward-to localhost:3001/api/stripe/webhook
  ```
- Confirm `STRIPE_WEBHOOK_SECRET` matches the secret shown by Stripe CLI.
- Check that the API app runs on port 3001.

### 3) Supabase RLS access denied
- Confirm the JWT includes the authenticated user (using Supabase client with current session).
- Verify `memberships` contains a row for the user and org.
- Re-check RLS policies in `packages/database/sql/001_init.sql`.

### 4) LLM Gateway degraded or provider down
- Switch model/provider in config, confirm fallback strategy.
- Review gateway logs for retry/backoff behavior.
- Validate provider API keys health and quotas.

### 5) Quota enforcement
- Inspect `usage_records` for the org.
- Confirm daily usage reporting job to Stripe has run (future cron/worker).
- Verify plan limits in app config and Stripe subscription status.

## Deployment

### Web/API (Vercel)
- Connect repo to Vercel.
- Set env vars for each project accordingly.
- Enable preview deployments on PRs.

### LLM Gateway (Railway/Fly)
- Build Docker image from `apps/llm-gateway/Dockerfile`.
- Set environment (provider keys, Supabase URL/keys if needed for RAG).
- Expose port 8000.

## Backup/Restore
- Use Supabase backups and point-in-time recovery.
- Export/import data with `supabase` CLI or SQL.

## On-call
- Alerts routed from OTel backend and platform (Vercel/Railway).
- SLOs: Availability of API and Gateway, P95 latency, webhook success rate.
