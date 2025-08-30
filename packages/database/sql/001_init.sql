-- Supabase schema for NexusCore
-- Extensions
create extension if not exists "uuid-ossp";
create extension if not exists pgcrypto;
create extension if not exists vector;

-- Auth-linked profiles
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Organizations (workspaces)
create table if not exists public.organizations (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  owner_id uuid not null references public.profiles(id) on delete restrict,
  created_at timestamptz not null default now()
);

-- Memberships with role
create type public.org_role as enum ('owner','admin','member','viewer');

create table if not exists public.memberships (
  org_id uuid not null references public.organizations(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role public.org_role not null default 'member',
  created_at timestamptz not null default now(),
  primary key (org_id, user_id)
);

-- Invitations
create table if not exists public.invitations (
  id uuid primary key default uuid_generate_v4(),
  org_id uuid not null references public.organizations(id) on delete cascade,
  email text not null,
  role public.org_role not null default 'member',
  invited_by uuid not null references public.profiles(id) on delete set null,
  token text not null unique,
  accepted_at timestamptz,
  created_at timestamptz not null default now()
);

-- API Keys per org
create table if not exists public.api_keys (
  id uuid primary key default uuid_generate_v4(),
  org_id uuid not null references public.organizations(id) on delete cascade,
  name text not null,
  hashed_key text not null,
  created_by uuid not null references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  last_used_at timestamptz
);

-- Usage records (metered billing)
create table if not exists public.usage_records (
  id uuid primary key default uuid_generate_v4(),
  org_id uuid not null references public.organizations(id) on delete cascade,
  tokens integer,
  requests integer,
  provider text,
  model text,
  at timestamptz not null default now()
);

-- Stripe customer linkage
create table if not exists public.billing_customers (
  org_id uuid primary key references public.organizations(id) on delete cascade,
  stripe_customer_id text unique not null,
  plan text not null default 'free',
  status text not null default 'active',
  current_period_end timestamptz
);

-- Enable RLS
alter table public.profiles enable row level security;
alter table public.organizations enable row level security;
alter table public.memberships enable row level security;
alter table public.invitations enable row level security;
alter table public.api_keys enable row level security;
alter table public.usage_records enable row level security;
alter table public.billing_customers enable row level security;

-- Helpers: get current auth uid
create or replace function public.auth_uid() returns uuid language sql stable as $$
  select auth.uid();
$$;

-- Profiles RLS: user can see own profile
create policy profiles_select_self on public.profiles
for select using (id = public.auth_uid());
create policy profiles_insert_self on public.profiles
for insert with check (id = public.auth_uid());
create policy profiles_update_self on public.profiles
for update using (id = public.auth_uid());

-- Org visibility: members only
create policy orgs_members_only_select on public.organizations
for select using (exists (
  select 1 from public.memberships m
  where m.org_id = id and m.user_id = public.auth_uid()
));

create policy orgs_owner_insert on public.organizations
for insert with check (owner_id = public.auth_uid());

-- Memberships: user can see memberships they belong to
create policy memberships_member_select on public.memberships
for select using (
  user_id = public.auth_uid() or exists (
    select 1 from public.memberships m
    where m.org_id = memberships.org_id and m.user_id = public.auth_uid()
  )
);

-- Invitations: visible to org members
create policy invitations_member_select on public.invitations
for select using (exists (
  select 1 from public.memberships m
  where m.org_id = invitations.org_id and m.user_id = public.auth_uid()
));

-- API Keys: visible to org members
create policy api_keys_member_select on public.api_keys
for select using (exists (
  select 1 from public.memberships m
  where m.org_id = api_keys.org_id and m.user_id = public.auth_uid()
));

-- Usage records: visible to org members
create policy usage_member_select on public.usage_records
for select using (exists (
  select 1 from public.memberships m
  where m.org_id = usage_records.org_id and m.user_id = public.auth_uid()
));

-- Billing: visible to org members
create policy billing_member_select on public.billing_customers
for select using (exists (
  select 1 from public.memberships m
  where m.org_id = billing_customers.org_id and m.user_id = public.auth_uid()
));
