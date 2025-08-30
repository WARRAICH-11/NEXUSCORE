import { z } from "zod";

export const PlanEnum = z.enum(["free", "pro", "enterprise"]);
export type Plan = z.infer<typeof PlanEnum>;

export const CreateOrgSchema = z.object({
  name: z.string().min(2).max(80),
});

export const InviteUserSchema = z.object({
  orgId: z.string().uuid(),
  email: z.string().email(),
  role: z.enum(["owner", "admin", "member", "viewer"]).default("member"),
});

export const ApiKeyCreateSchema = z.object({
  orgId: z.string().uuid(),
  name: z.string().min(1).max(100),
});

export const UsageRecordSchema = z.object({
  orgId: z.string().uuid(),
  projectId: z.string().uuid().optional(),
  // primary meter: tokens or request count
  tokens: z.number().int().nonnegative().optional(),
  requests: z.number().int().nonnegative().optional(),
  model: z.string().optional(),
  provider: z.string().optional(),
  at: z.coerce.date().default(() => new Date()),
});

export const StripeWebhookSchema = z.object({
  type: z.string(),
  data: z.unknown(),
});

export const EnvSchema = z.object({
  NEXT_PUBLIC_SUPABASE_URL: z.string().url().optional(),
  NEXT_PUBLIC_SUPABASE_ANON_KEY: z.string().optional(),
  SUPABASE_SERVICE_ROLE_KEY: z.string().optional(),
  NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY: z.string().optional(),
  STRIPE_SECRET_KEY: z.string().optional(),
  STRIPE_WEBHOOK_SECRET: z.string().optional(),
  OPENAI_API_KEY: z.string().optional(),
  ANTHROPIC_API_KEY: z.string().optional(),
  TOGETHER_API_KEY: z.string().optional(),
  OTEL_EXPORTER_OTLP_ENDPOINT: z.string().optional(),
  OTEL_SERVICE_NAME: z.string().default("nexuscore"),
});

export type CreateOrgInput = z.infer<typeof CreateOrgSchema>;
export type InviteUserInput = z.infer<typeof InviteUserSchema>;
export type ApiKeyCreateInput = z.infer<typeof ApiKeyCreateSchema>;
export type UsageRecordInput = z.infer<typeof UsageRecordSchema>;
