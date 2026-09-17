create or replace function public.create_customer_case(
  p_case_number text,
  p_full_name text,
  p_email text,
  p_description text,
  p_department text,
  p_priority text,
  p_requires_human_review boolean,
  p_received_at timestamptz default now()
)
returns table (
  customer_id uuid,
  case_id uuid,
  case_number text
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_customer_id uuid;
  v_case_id uuid;
begin
  if nullif(trim(p_case_number), '') is null then
    raise exception 'case number is required';
  end if;

  if nullif(trim(p_full_name), '') is null then
    raise exception 'full name is required';
  end if;

  if nullif(trim(p_email), '') is null then
    raise exception 'email is required';
  end if;

  insert into public.customers (full_name, email)
  values (trim(p_full_name), lower(trim(p_email)))
  on conflict (email)
  do update set
    full_name = excluded.full_name,
    updated_at = now()
  returning id into v_customer_id;

  insert into public.cases (
    case_number,
    customer_id,
    department,
    priority,
    status,
    description,
    channel,
    requires_human_review,
    received_at
  )
  values (
    trim(p_case_number),
    v_customer_id,
    p_department,
    p_priority,
    'NEW',
    p_description,
    'WEBHOOK',
    p_requires_human_review,
    coalesce(p_received_at, now())
  )
  returning id into v_case_id;

  insert into public.case_events (case_id, event_type, details)
  values (
    v_case_id,
    'CASE_CREATED',
    jsonb_build_object(
      'department', p_department,
      'priority', p_priority,
      'source', 'N8N'
    )
  );

  return query
  select v_customer_id, v_case_id, trim(p_case_number);
end;
$$;

revoke all on function public.create_customer_case(
  text, text, text, text, text, text, boolean, timestamptz
) from public, anon, authenticated;

grant execute on function public.create_customer_case(
  text, text, text, text, text, text, boolean, timestamptz
) to service_role;
