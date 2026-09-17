create or replace function public.match_customer_identity(
  p_email text default null,
  p_phone text default null
)
returns table (
  customer_id uuid,
  full_name text,
  email text,
  phone text,
  match_type text
)
language sql
security definer
set search_path = public
as $$
  select
    c.id,
    c.full_name,
    c.email,
    c.phone,
    case
      when p_email is not null and c.email = lower(trim(p_email)) then 'EMAIL'
      when p_phone is not null and c.phone = trim(p_phone) then 'PHONE'
      else 'NONE'
    end
  from public.customers c
  where
    (p_email is not null and c.email = lower(trim(p_email)))
    or
    (p_phone is not null and c.phone = trim(p_phone))
  order by
    case when p_email is not null and c.email = lower(trim(p_email)) then 0 else 1 end
  limit 5;
$$;

create or replace function public.upsert_customer_profile(
  p_full_name text,
  p_email text,
  p_phone text default null
)
returns table (
  customer_id uuid,
  full_name text,
  email text,
  phone text,
  updated_at timestamptz
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_customer public.customers;
begin
  if nullif(trim(p_full_name), '') is null then
    raise exception 'full name is required';
  end if;

  if nullif(trim(p_email), '') is null then
    raise exception 'email is required';
  end if;

  insert into public.customers (full_name, email, phone)
  values (
    trim(p_full_name),
    lower(trim(p_email)),
    nullif(trim(p_phone), '')
  )
  on conflict (email)
  do update set
    full_name = excluded.full_name,
    phone = coalesce(excluded.phone, public.customers.phone),
    updated_at = now()
  returning * into v_customer;

  return query
  select
    v_customer.id,
    v_customer.full_name,
    v_customer.email,
    v_customer.phone,
    v_customer.updated_at;
end;
$$;

revoke all on function public.match_customer_identity(text, text)
  from public, anon, authenticated;
revoke all on function public.upsert_customer_profile(text, text, text)
  from public, anon, authenticated;

grant execute on function public.match_customer_identity(text, text)
  to service_role;
grant execute on function public.upsert_customer_profile(text, text, text)
  to service_role;
