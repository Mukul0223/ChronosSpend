-- 001_core_tables.sql
-- Core tables for ChronosSpend: profiles, presets, recurrence_rules, expenses, daily_notes.
-- Apply to chronosspend-dev first, test, then to chronosspend-prod.

-- profiles: one row per user, created automatically by a trigger on auth.users
create table public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  currency_code text not null default 'USD'
    check (currency_code ~ '^[A-Z]{3}$'),
  week_starts_on smallint not null default 0
    check (week_starts_on in (0, 1)),
  created_at timestamptz not null default now()
);

create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (user_id)
  values (new.id);
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- presets: the reusable quick-log menu
create table public.presets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null
    check (char_length(btrim(name)) between 1 and 60),
  amount_cents integer not null
    check (amount_cents > 0 and amount_cents <= 100000000),
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index presets_user_sort_idx on public.presets (user_id, sort_order);

-- recurrence_rules: repeating items
create table public.recurrence_rules (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  preset_id uuid references public.presets(id) on delete set null,
  name text not null
    check (char_length(name) between 1 and 60),
  amount_cents integer not null
    check (amount_cents > 0 and amount_cents <= 100000000),
  frequency text not null
    check (frequency in ('daily', 'weekly', 'monthly')),
  start_date date not null
    check (start_date between date '2000-01-01' and date '2100-12-31'),
  end_date date
    check (end_date is null or end_date >= start_date),
  skip_dates date[] not null default '{}'
    check (array_length(skip_dates, 1) is null or array_length(skip_dates, 1) <= 1000),
  materialized_through date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index recurrence_rules_user_created_idx on public.recurrence_rules (user_id, created_at);

-- expenses: the ledger
create table public.expenses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  occurred_on date not null
    check (occurred_on between date '2000-01-01' and date '2100-12-31'),
  name text not null
    check (char_length(name) between 1 and 60),
  amount_cents integer not null
    check (amount_cents > 0 and amount_cents <= 100000000),
  preset_id uuid references public.presets(id) on delete set null,
  rule_id uuid references public.recurrence_rules(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index expenses_rule_day_key
  on public.expenses (rule_id, occurred_on)
  where rule_id is not null;

create index expenses_user_date_idx on public.expenses (user_id, occurred_on);

-- daily_notes
create table public.daily_notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  note_date date not null,
  body text not null
    check (char_length(body) between 1 and 2000),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, note_date)
);
