-- Run in the Steady Hands CRM Supabase project: glonbvrcudwuzjundrii
-- This file is not executed by GitHub Pages.
create table if not exists public.training_progress (
 user_id uuid not null references auth.users(id) on delete cascade,
 lesson_id integer not null check (lesson_id between 0 and 3),
 completed boolean not null default false,
 seconds_watched integer not null default 0 check (seconds_watched >= 0),
 duration_seconds integer not null default 0 check (duration_seconds >= 0),
 last_position_seconds integer not null default 0 check (last_position_seconds >= 0),
 updated_at timestamptz not null default now(),
 completed_at timestamptz,
 primary key (user_id,lesson_id)
);
alter table public.training_progress enable row level security;
grant select,insert,update on public.training_progress to authenticated;
drop policy if exists "training select own or admin" on public.training_progress;
create policy "training select own or admin" on public.training_progress
 for select to authenticated using (
 user_id=(select auth.uid()) or exists (
  select 1 from public.team_permissions p
  where p.user_id=(select auth.uid()) and p.active=true and upper(p.role)='ADMIN'
 ));
drop policy if exists "training insert self" on public.training_progress;
create policy "training insert self" on public.training_progress
 for insert to authenticated with check (
 user_id=(select auth.uid()) and exists (
  select 1 from public.team_permissions p
  where p.user_id=(select auth.uid()) and p.active=true
 ));
drop policy if exists "training update self" on public.training_progress;
create policy "training update self" on public.training_progress
 for update to authenticated
 using (user_id=(select auth.uid()))
 with check (user_id=(select auth.uid()));
create index if not exists training_progress_updated_idx on public.training_progress(updated_at desc);
