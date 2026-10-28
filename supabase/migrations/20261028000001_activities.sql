-- Activities: tummy time, bath, play, outdoors, reading, massage, or
-- anything else with the family's own label (todos.txt: feature gap vs
-- Huckleberry, Baby Daybook, ParentLove).
--
-- A timer that is still running has no ended_at. An entry without a
-- duration (e.g. "bath at 7 pm") has ended_at = started_at.

create table public.activities (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null,
  baby_id uuid not null,
  kind text not null check (kind in ('tummy_time', 'bath', 'play', 'outdoors', 'reading', 'massage', 'other')),
  -- The family's own name for an "other" activity, e.g. "Swimming".
  label text check (length(label) <= 60),
  started_at timestamptz not null,
  ended_at timestamptz,
  notes text check (length(notes) <= 500),
  created_by uuid default auth.uid() references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  check (ended_at is null or ended_at >= started_at),
  foreign key (baby_id, family_id) references public.babies (id, family_id) on delete cascade
);

create index activities_baby_idx on public.activities (baby_id, started_at desc);
create index activities_family_updated_idx on public.activities (family_id, updated_at);

create trigger set_updated_at before update on public.activities
  for each row execute function private.set_updated_at();

alter table public.activities enable row level security;

create policy "family members can do everything" on public.activities
  for all to authenticated
  using ((select private.is_family_member(family_id)))
  with check ((select private.is_family_member(family_id)));

grant select, insert, update, delete on public.activities to authenticated, service_role;

-- Offline sync (powersync/sync-config.yaml lists it too).
alter publication powersync add table public.activities;
