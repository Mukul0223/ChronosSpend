-- 002_rls_and_grants.sql
-- Enables Row Level Security on every user table and grants the minimum
-- privileges each Supabase role needs. Apply to dev first, test, then prod.

alter table public.profiles enable row level security;
alter table public.presets enable row level security;
alter table public.recurrence_rules enable row level security;
alter table public.expenses enable row level security;
alter table public.daily_notes enable row level security;

-- profiles: same shape as every other table (select/insert/update/delete,
-- each restricted to the caller's own row). In practice the app only ever
-- selects and updates: the on_auth_user_created trigger creates the row as
-- a security-definer function (RLS does not apply to it), and the row is
-- removed only by the auth.users cascade, never by a direct delete call.
create policy "profiles_select_own" on public.profiles
  for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "profiles_insert_own" on public.profiles
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "profiles_update_own" on public.profiles
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "profiles_delete_own" on public.profiles
  for delete to authenticated
  using ((select auth.uid()) = user_id);

-- presets
create policy "presets_select_own" on public.presets
  for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "presets_insert_own" on public.presets
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "presets_update_own" on public.presets
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "presets_delete_own" on public.presets
  for delete to authenticated
  using ((select auth.uid()) = user_id);

-- recurrence_rules
create policy "recurrence_rules_select_own" on public.recurrence_rules
  for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "recurrence_rules_insert_own" on public.recurrence_rules
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "recurrence_rules_update_own" on public.recurrence_rules
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "recurrence_rules_delete_own" on public.recurrence_rules
  for delete to authenticated
  using ((select auth.uid()) = user_id);

-- expenses
create policy "expenses_select_own" on public.expenses
  for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "expenses_insert_own" on public.expenses
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "expenses_update_own" on public.expenses
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "expenses_delete_own" on public.expenses
  for delete to authenticated
  using ((select auth.uid()) = user_id);

-- daily_notes
create policy "daily_notes_select_own" on public.daily_notes
  for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "daily_notes_insert_own" on public.daily_notes
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "daily_notes_update_own" on public.daily_notes
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "daily_notes_delete_own" on public.daily_notes
  for delete to authenticated
  using ((select auth.uid()) = user_id);

-- anon (signed-out) gets no table access at all, as a second layer behind RLS
revoke all on public.profiles, public.presets, public.recurrence_rules, public.expenses, public.daily_notes
  from anon;

-- authenticated gets ordinary row access; RLS still filters every row
grant select, insert, update, delete on public.profiles to authenticated;
grant select, insert, update, delete on public.presets to authenticated;
grant select, insert, update, delete on public.recurrence_rules to authenticated;
grant select, insert, update, delete on public.expenses to authenticated;
grant select, insert, update, delete on public.daily_notes to authenticated;
