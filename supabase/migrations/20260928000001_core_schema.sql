-- Core schema: families, caregivers, babies and tracking tables.
--
-- Portability rule: plain Postgres + auth.uid() only, so the same migrations
-- run on Supabase Cloud and on a self-hosted Supabase stack.
--
-- Sync rules for tracking tables:
--   * ids are uuids the app may generate offline
--   * rows are soft-deleted (deleted_at) so deletions sync to other devices
--   * family_id is stored on every row so access checks and sync buckets are simple

create schema if not exists private;

-- ── Helpers ─────────────────────────────────────────────────────────────────

create or replace function private.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ── Profiles ────────────────────────────────────────────────────────────────

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  preferred_locale text not null default 'en' check (preferred_locale in ('en', 'ur', 'ur-Latn')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, new.raw_user_meta_data ->> 'full_name');
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function private.handle_new_user();

-- ── Families and caregivers ─────────────────────────────────────────────────

create table public.families (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_by uuid not null default auth.uid() references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create type public.family_role as enum ('owner', 'caregiver');

create table public.family_members (
  family_id uuid not null references public.families (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  role public.family_role not null default 'caregiver',
  created_at timestamptz not null default now(),
  primary key (family_id, user_id)
);

create index family_members_user_id_idx on public.family_members (user_id);

create or replace function private.is_family_member(fid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.family_members
    where family_id = fid and user_id = (select auth.uid())
  );
$$;

create or replace function private.is_family_owner(fid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.family_members
    where family_id = fid and user_id = (select auth.uid()) and role = 'owner'
  );
$$;

-- Whoever creates a family becomes its owner.
create or replace function private.add_family_owner()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.family_members (family_id, user_id, role)
  values (new.id, new.created_by, 'owner');
  return new;
end;
$$;

create trigger on_family_created
  after insert on public.families
  for each row execute function private.add_family_owner();

-- ── Babies ──────────────────────────────────────────────────────────────────

create type public.baby_sex as enum ('female', 'male');

create table public.babies (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families (id) on delete cascade,
  name text not null,
  sex public.baby_sex,
  birth_date date not null,
  birth_weight_g integer check (birth_weight_g between 300 and 7000),
  birth_length_mm integer check (birth_length_mm between 200 and 700),
  birth_head_mm integer check (birth_head_mm between 200 and 500),
  created_by uuid not null default auth.uid() references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  -- lets tracking tables check that baby_id belongs to family_id
  unique (id, family_id)
);

create index babies_family_id_idx on public.babies (family_id);

-- ── Tracking tables ─────────────────────────────────────────────────────────
-- Every tracking table has the same bookkeeping columns, and a composite
-- foreign key that keeps baby_id and family_id consistent.

create type public.feed_type as enum ('breast', 'bottle_breast_milk', 'bottle_formula', 'solids');
create type public.breast_side as enum ('left', 'right', 'both');

create table public.feeds (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null,
  baby_id uuid not null,
  type public.feed_type not null,
  side public.breast_side,
  started_at timestamptz not null,
  ended_at timestamptz,
  amount_ml integer check (amount_ml between 0 and 1000),
  notes text,
  created_by uuid not null default auth.uid() references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  foreign key (baby_id, family_id) references public.babies (id, family_id) on delete cascade,
  check (ended_at is null or ended_at >= started_at)
);

create table public.pumping_sessions (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null,
  baby_id uuid not null,
  side public.breast_side,
  started_at timestamptz not null,
  ended_at timestamptz,
  amount_ml integer check (amount_ml between 0 and 1000),
  notes text,
  created_by uuid not null default auth.uid() references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  foreign key (baby_id, family_id) references public.babies (id, family_id) on delete cascade,
  check (ended_at is null or ended_at >= started_at)
);

create table public.diapers (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null,
  baby_id uuid not null,
  occurred_at timestamptz not null,
  is_wet boolean not null default false,
  is_dirty boolean not null default false,
  stool_color text,
  notes text,
  created_by uuid not null default auth.uid() references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  foreign key (baby_id, family_id) references public.babies (id, family_id) on delete cascade,
  check (is_wet or is_dirty)
);

create type public.sleep_kind as enum ('nap', 'night');

create table public.sleeps (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null,
  baby_id uuid not null,
  kind public.sleep_kind not null,
  started_at timestamptz not null,
  ended_at timestamptz,
  notes text,
  created_by uuid not null default auth.uid() references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  foreign key (baby_id, family_id) references public.babies (id, family_id) on delete cascade,
  check (ended_at is null or ended_at >= started_at)
);

-- Stored as whole grams / millimetres to avoid floating-point rounding.
create table public.growth_measurements (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null,
  baby_id uuid not null,
  measured_on date not null,
  weight_g integer check (weight_g between 300 and 40000),
  length_mm integer check (length_mm between 200 and 1300),
  head_mm integer check (head_mm between 200 and 600),
  notes text,
  created_by uuid not null default auth.uid() references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  foreign key (baby_id, family_id) references public.babies (id, family_id) on delete cascade,
  check (weight_g is not null or length_mm is not null or head_mm is not null)
);

-- The app stores what the doctor prescribed and reminds the parent.
-- It never calculates or suggests a dose, so dose is free text.
create table public.medications (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null,
  baby_id uuid not null,
  name text not null,
  prescribed_dose text not null,
  every_hours integer check (every_hours between 1 and 168),
  start_date date not null,
  end_date date,
  prescribed_by text,
  notes text,
  created_by uuid not null default auth.uid() references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  foreign key (baby_id, family_id) references public.babies (id, family_id) on delete cascade,
  check (end_date is null or end_date >= start_date),
  unique (id, family_id)
);

create table public.medication_doses (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null,
  baby_id uuid not null,
  medication_id uuid not null,
  given_at timestamptz not null,
  skipped boolean not null default false,
  notes text,
  created_by uuid not null default auth.uid() references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  foreign key (baby_id, family_id) references public.babies (id, family_id) on delete cascade,
  foreign key (medication_id, family_id) references public.medications (id, family_id) on delete cascade
);

create table public.vaccinations (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null,
  baby_id uuid not null,
  vaccine_code text not null,
  given_on date not null,
  batch_number text,
  clinic text,
  notes text,
  created_by uuid not null default auth.uid() references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  foreign key (baby_id, family_id) references public.babies (id, family_id) on delete cascade
);

create table public.symptom_logs (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null,
  baby_id uuid not null,
  symptom text not null check (symptom in (
    'fever', 'cough', 'runny_nose', 'vomiting', 'diarrhea', 'constipation',
    'rash', 'teething', 'feeding_refusal', 'crying', 'congestion', 'other'
  )),
  occurred_at timestamptz not null,
  temperature_c numeric(3, 1) check (temperature_c between 30 and 45),
  severity smallint check (severity between 1 and 3),
  notes text,
  created_by uuid not null default auth.uid() references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  foreign key (baby_id, family_id) references public.babies (id, family_id) on delete cascade
);

-- ── Shared triggers, indexes and access rules ───────────────────────────────

do $$
declare
  t text;
  time_col text;
begin
  foreach t in array array['profiles', 'families', 'babies'] loop
    execute format(
      'create trigger set_updated_at before update on public.%I
         for each row execute function private.set_updated_at()', t);
  end loop;

  foreach t in array array[
    'feeds', 'pumping_sessions', 'diapers', 'sleeps', 'growth_measurements',
    'medications', 'medication_doses', 'vaccinations', 'symptom_logs'
  ] loop
    execute format(
      'create trigger set_updated_at before update on public.%I
         for each row execute function private.set_updated_at()', t);

    time_col := case t
      when 'diapers' then 'occurred_at'
      when 'symptom_logs' then 'occurred_at'
      when 'growth_measurements' then 'measured_on'
      when 'medications' then 'start_date'
      when 'medication_doses' then 'given_at'
      when 'vaccinations' then 'given_on'
      else 'started_at'
    end;
    execute format('create index %I on public.%I (baby_id, %I desc)', t || '_baby_time_idx', t, time_col);
    execute format('create index %I on public.%I (family_id, updated_at)', t || '_family_updated_idx', t);

    execute format('alter table public.%I enable row level security', t);
    execute format(
      'create policy "family members can do everything" on public.%I
         for all to authenticated
         using ((select private.is_family_member(family_id)))
         with check ((select private.is_family_member(family_id)))', t);
  end loop;
end;
$$;

-- profiles: each user sees and edits only their own
alter table public.profiles enable row level security;
create policy "read own profile" on public.profiles
  for select to authenticated using (id = (select auth.uid()));
create policy "update own profile" on public.profiles
  for update to authenticated using (id = (select auth.uid()));

-- families: members read, anyone signed in can create, owners edit/delete
alter table public.families enable row level security;
create policy "members read family" on public.families
  for select to authenticated
  using ((select private.is_family_member(id)) or created_by = (select auth.uid()));
create policy "create own family" on public.families
  for insert to authenticated with check (created_by = (select auth.uid()));
create policy "owners update family" on public.families
  for update to authenticated using ((select private.is_family_owner(id)));
create policy "owners delete family" on public.families
  for delete to authenticated using ((select private.is_family_owner(id)));

-- family_members: members see each other; owners remove people; anyone can leave.
-- Adding caregivers will go through an invite function (later migration).
alter table public.family_members enable row level security;
create policy "members read members" on public.family_members
  for select to authenticated using ((select private.is_family_member(family_id)));
create policy "owners or self remove member" on public.family_members
  for delete to authenticated
  using ((select private.is_family_owner(family_id)) or user_id = (select auth.uid()));

-- babies: all family members read and write
alter table public.babies enable row level security;
create policy "family members manage babies" on public.babies
  for all to authenticated
  using ((select private.is_family_member(family_id)))
  with check ((select private.is_family_member(family_id)));

-- ── Grants ──────────────────────────────────────────────────────────────────
-- Explicit so behaviour doesn't depend on platform default privileges.
-- Only signed-in users get access; the anon role gets nothing.

revoke all on all tables in schema public from anon;
grant select, insert, update, delete on all tables in schema public to authenticated;
revoke all on schema private from public, anon;
grant usage on schema private to authenticated;
grant execute on all functions in schema private to authenticated;
