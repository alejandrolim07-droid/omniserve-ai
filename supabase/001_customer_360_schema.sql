create extension if not exists pgcrypto;

create table if not exists public.customers (
  id uuid primary key default gen_random_uuid(),
  full_name text not null,
  email text not null unique,
  phone text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.cases (
  id uuid primary key default gen_random_uuid(),
  case_number text not null unique,
  customer_id uuid not null references public.customers(id),
  department text not null check (
    department in ('SALES', 'CUSTOMER_SUPPORT', 'BILLING')
  ),
  priority text not null default 'NORMAL' check (
    priority in ('LOW', 'NORMAL', 'HIGH', 'CRITICAL')
  ),
  status text not null default 'NEW' check (
    status in ('NEW', 'IN_PROGRESS', 'WAITING', 'ESCALATED', 'RESOLVED', 'CLOSED')
  ),
  description text not null,
  channel text not null default 'WEBHOOK',
  requires_human_review boolean not null default false,
  received_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create table if not exists public.case_events (
  id bigint generated always as identity primary key,
  case_id uuid not null references public.cases(id) on delete cascade,
  event_type text not null,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.customers enable row level security;
alter table public.cases enable row level security;
alter table public.case_events enable row level security;

create index if not exists cases_customer_id_idx
  on public.cases(customer_id);

create index if not exists cases_department_status_idx
  on public.cases(department, status);

create index if not exists case_events_case_id_idx
  on public.case_events(case_id);
