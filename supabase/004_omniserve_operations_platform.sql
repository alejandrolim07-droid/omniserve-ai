-- OmniServe shared operating model for workflows 7-100.
-- Safe to run after migrations 001-003. All objects are idempotent.

create table if not exists public.automation_events (
  id uuid primary key default gen_random_uuid(),
  correlation_id text not null,
  workflow_key text not null,
  department text not null,
  operation text not null,
  subject_type text not null,
  subject_id text not null,
  risk_level text not null check (risk_level in ('LOW','MEDIUM','HIGH','CRITICAL')),
  confidence numeric(5,4) not null default 1 check (confidence between 0 and 1),
  requires_human_approval boolean not null default false,
  status text not null check (status in ('READY','AWAITING_APPROVAL','APPROVED','REJECTED','COMPLETED','FAILED')),
  input jsonb not null default '{}'::jsonb,
  result jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (workflow_key, correlation_id)
);

create table if not exists public.approval_requests (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null unique references public.automation_events(id) on delete cascade,
  status text not null default 'PENDING' check (status in ('PENDING','APPROVED','REJECTED','EXPIRED')),
  reason text not null,
  requested_at timestamptz not null default now(),
  decided_at timestamptz,
  decided_by text,
  decision_note text
);

create table if not exists public.audit_log (
  id bigint generated always as identity primary key,
  event_id uuid references public.automation_events(id) on delete set null,
  actor_type text not null default 'AUTOMATION',
  actor_id text,
  action text not null,
  resource_type text not null,
  resource_id text not null,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.leads (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid references public.customers(id) on delete set null,
  email text,
  company text,
  stage text not null default 'NEW',
  score integer not null default 0 check (score between 0 and 100),
  owner text,
  source text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.service_requests (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid references public.customers(id) on delete set null,
  case_id uuid references public.cases(id) on delete set null,
  service_type text not null,
  status text not null default 'NEW',
  assigned_team text,
  scheduled_for timestamptz,
  sla_due_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.invoices (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid references public.customers(id) on delete set null,
  invoice_number text not null unique,
  currency text not null default 'USD',
  amount numeric(14,2) not null check (amount >= 0),
  status text not null default 'DRAFT',
  due_at timestamptz,
  paid_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.knowledge_articles (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  body text not null,
  category text,
  status text not null default 'DRAFT',
  embedding_ref text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.customer_interactions (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid references public.customers(id) on delete cascade,
  case_id uuid references public.cases(id) on delete set null,
  channel text not null,
  direction text not null check (direction in ('INBOUND','OUTBOUND','INTERNAL')),
  content text,
  sentiment text,
  metadata jsonb not null default '{}'::jsonb,
  occurred_at timestamptz not null default now()
);

create index if not exists automation_events_subject_idx on public.automation_events(subject_type, subject_id);
create index if not exists automation_events_department_status_idx on public.automation_events(department, status);
create index if not exists approval_requests_status_idx on public.approval_requests(status, requested_at);
create index if not exists audit_log_resource_idx on public.audit_log(resource_type, resource_id, created_at desc);
create index if not exists leads_stage_score_idx on public.leads(stage, score desc);
create index if not exists service_requests_status_idx on public.service_requests(status, sla_due_at);
create index if not exists invoices_status_due_idx on public.invoices(status, due_at);
create index if not exists customer_interactions_customer_idx on public.customer_interactions(customer_id, occurred_at desc);

alter table public.automation_events enable row level security;
alter table public.approval_requests enable row level security;
alter table public.audit_log enable row level security;
alter table public.leads enable row level security;
alter table public.service_requests enable row level security;
alter table public.invoices enable row level security;
alter table public.knowledge_articles enable row level security;
alter table public.customer_interactions enable row level security;

create or replace function public.process_automation_event(
  p_correlation_id text,
  p_workflow_key text,
  p_department text,
  p_operation text,
  p_subject_type text,
  p_subject_id text,
  p_risk_level text,
  p_confidence numeric,
  p_requires_human_approval boolean,
  p_input jsonb default '{}'::jsonb,
  p_result jsonb default '{}'::jsonb
)
returns table (event_id uuid, approval_id uuid, status text)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_event_id uuid;
  v_approval_id uuid;
  v_status text;
begin
  if nullif(trim(p_correlation_id), '') is null or nullif(trim(p_workflow_key), '') is null then
    raise exception 'correlation_id and workflow_key are required';
  end if;
  if p_risk_level not in ('LOW','MEDIUM','HIGH','CRITICAL') then
    raise exception 'invalid risk level: %', p_risk_level;
  end if;

  v_status := case when p_requires_human_approval then 'AWAITING_APPROVAL' else 'READY' end;

  insert into public.automation_events (
    correlation_id, workflow_key, department, operation, subject_type, subject_id,
    risk_level, confidence, requires_human_approval, status, input, result
  ) values (
    trim(p_correlation_id), trim(p_workflow_key), trim(p_department), trim(p_operation),
    trim(p_subject_type), trim(p_subject_id), p_risk_level,
    greatest(0, least(1, coalesce(p_confidence, 1))),
    coalesce(p_requires_human_approval, false), v_status,
    coalesce(p_input, '{}'::jsonb), coalesce(p_result, '{}'::jsonb)
  )
  on conflict (workflow_key, correlation_id) do update set
    input = excluded.input,
    result = excluded.result,
    confidence = excluded.confidence,
    requires_human_approval = excluded.requires_human_approval,
    status = excluded.status,
    updated_at = now()
  returning id into v_event_id;

  if p_requires_human_approval then
    insert into public.approval_requests (event_id, reason)
    values (v_event_id, format('%s requires human approval (%s risk)', p_operation, p_risk_level))
    on conflict (event_id) do update set reason = excluded.reason
    returning id into v_approval_id;
  end if;

  insert into public.audit_log (event_id, action, resource_type, resource_id, details)
  values (v_event_id, 'WORKFLOW_ACCEPTED', p_subject_type, p_subject_id,
    jsonb_build_object('workflow_key', p_workflow_key, 'department', p_department, 'status', v_status));

  return query select v_event_id, v_approval_id, v_status;
end;
$$;

create or replace function public.decide_approval(
  p_approval_id uuid,
  p_decision text,
  p_decided_by text,
  p_decision_note text default null
)
returns table (approval_id uuid, event_id uuid, status text)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_event_id uuid;
  v_status text;
begin
  if p_decision not in ('APPROVED','REJECTED') then
    raise exception 'decision must be APPROVED or REJECTED';
  end if;

  update public.approval_requests
  set status = p_decision, decided_at = now(), decided_by = p_decided_by, decision_note = p_decision_note
  where id = p_approval_id and status = 'PENDING'
  returning approval_requests.event_id, approval_requests.status into v_event_id, v_status;

  if v_event_id is null then raise exception 'pending approval not found'; end if;

  update public.automation_events set status = v_status, updated_at = now() where id = v_event_id;
  insert into public.audit_log (event_id, actor_type, actor_id, action, resource_type, resource_id, details)
  values (v_event_id, 'HUMAN', p_decided_by, 'APPROVAL_' || v_status, 'approval_request', p_approval_id::text,
    jsonb_build_object('note', p_decision_note));

  return query select p_approval_id, v_event_id, v_status;
end;
$$;

revoke all on function public.process_automation_event(text,text,text,text,text,text,text,numeric,boolean,jsonb,jsonb) from public, anon, authenticated;
revoke all on function public.decide_approval(uuid,text,text,text) from public, anon, authenticated;
grant execute on function public.process_automation_event(text,text,text,text,text,text,text,numeric,boolean,jsonb,jsonb) to service_role;
grant execute on function public.decide_approval(uuid,text,text,text) to service_role;
