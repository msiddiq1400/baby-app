-- Stored breast milk: one row per bag or bottle, from pumping until it is
-- used or thrown away. Expiry is calculated in the app from where the milk
-- is kept (CDC guidance), so rules can change without migrating data.

create table public.milk_stash (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null,
  baby_id uuid not null,
  pumping_session_id uuid references public.pumping_sessions (id) on delete set null,
  pumped_at timestamptz not null,
  amount_ml integer not null check (amount_ml between 1 and 1000),
  location text not null check (location in ('room', 'cooler', 'fridge', 'freezer', 'thawed')),
  frozen_at timestamptz,
  thawed_at timestamptz,
  finished_at timestamptz,
  finished_reason text check (finished_reason in ('used', 'discarded')),
  notes text,
  created_by uuid not null default auth.uid() references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  foreign key (baby_id, family_id) references public.babies (id, family_id) on delete cascade,
  check ((finished_at is null) = (finished_reason is null)),
  check (location <> 'freezer' or frozen_at is not null),
  check (location <> 'thawed' or thawed_at is not null)
);

create index milk_stash_baby_active_idx on public.milk_stash (baby_id, pumped_at) where finished_at is null;
create index milk_stash_family_updated_idx on public.milk_stash (family_id, updated_at);

create trigger set_updated_at before update on public.milk_stash
  for each row execute function private.set_updated_at();

alter table public.milk_stash enable row level security;
create policy "family members can do everything" on public.milk_stash
  for all to authenticated
  using ((select private.is_family_member(family_id)))
  with check ((select private.is_family_member(family_id)));

grant select, insert, update, delete on public.milk_stash to authenticated, service_role;
