import { createClient, SupabaseClient } from "@supabase/supabase-js";

type SupabaseOptions = {
  url?: string;
  anonKey?: string;
};

// Development fallbacks to help boot without local .env
const DEV_FALLBACK_URL = "https://yulkqnavkkpyzvvalopi.supabase.co";
const DEV_FALLBACK_ANON =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl1bGtxbmF2a2tweXp2dmFsb3BpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY1NTI1NjEsImV4cCI6MjA3MjEyODU2MX0.scE7J9ZunBfWAh6GsuTX7abTceD-lxZXhlMTY1FOuV4";

export function getEnvUrl() {
  if (typeof process !== "undefined") {
    return (
      process.env.NEXT_PUBLIC_SUPABASE_URL ||
      process.env.SUPABASE_URL ||
      DEV_FALLBACK_URL
    );
  }
  return DEV_FALLBACK_URL;
}

export function getEnvAnonKey() {
  if (typeof process !== "undefined") {
    return (
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ||
      process.env.SUPABASE_ANON_KEY ||
      DEV_FALLBACK_ANON
    );
  }
  return DEV_FALLBACK_ANON;
}

export function getEnvServiceKey(): string | undefined {
  if (typeof process !== "undefined") {
    return process.env.SUPABASE_SERVICE_ROLE_KEY;
  }
  return undefined;
}

export function createSupabaseBrowserClient(opts: SupabaseOptions = {}): SupabaseClient {
  const url = opts.url ?? getEnvUrl();
  const anonKey = opts.anonKey ?? getEnvAnonKey();
  return createClient(url, anonKey, {
    auth: {
      persistSession: true,
      autoRefreshToken: true,
    },
  });
}

export function createSupabaseServerClient(opts: SupabaseOptions = {}): SupabaseClient {
  // For now, same as browser; Next.js route handlers can pass cookies later.
  return createSupabaseBrowserClient(opts);
}

export function createSupabaseServiceClient(): SupabaseClient {
  const url = getEnvUrl();
  const serviceKey = getEnvServiceKey();
  const key = serviceKey || getEnvAnonKey();
  return createClient(url, key);
}
