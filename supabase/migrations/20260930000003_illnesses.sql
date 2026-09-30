-- Illness episodes ("Day 1, Day 2 ..." of a cold, fever, tummy bug) and
-- doctor's visits. An episode doesn't own its symptoms or doses: the app
-- shows everything logged between started_at and recovered_at (or now).

create table public.illnesses (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null,
  baby_id uuid not null,
  name text check (length(name) <= 80),
  started_at timestamptz not null,
  recovered_at timestamptz,
  notes text,
  created_by uuid default auth.uid() references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  check (recovered_at is null or recovered_at >= started_at),
  foreign key (baby_id, family_id) references public.babies (id, family_id) on delete cascade
);

create table public.doctor_visits (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null,
  baby_id uuid not null,
  visited_at timestamptz not null,
  doctor text check (length(doctor) <= 120),
  diagnosis text,
  advice text,
  created_by uuid default auth.uid() references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  foreign key (baby_id, family_id) references public.babies (id, family_id) on delete cascade
);

create index illnesses_baby_idx on public.illnesses (baby_id, started_at desc);
create index illnesses_family_updated_idx on public.illnesses (family_id, updated_at);
create index doctor_visits_baby_idx on public.doctor_visits (baby_id, visited_at desc);
create index doctor_visits_family_updated_idx on public.doctor_visits (family_id, updated_at);

do $$
declare
  t text;
begin
  foreach t in array array['illnesses', 'doctor_visits'] loop
    execute format(
      'create trigger set_updated_at before update on public.%I
         for each row execute function private.set_updated_at()', t);
    execute format('alter table public.%I enable row level security', t);
    execute format(
      'create policy "family members can do everything" on public.%I
         for all to authenticated
         using ((select private.is_family_member(family_id)))
         with check ((select private.is_family_member(family_id)))', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated, service_role', t);
  end loop;
end;
$$;

-- Offline sync (the sync rules in powersync/sync-config.yaml list them too).
alter publication powersync add table public.illnesses, public.doctor_visits;
