-- Starting solids (foods tried, likes, reactions) and development
-- milestones reached. The food and milestone lists themselves ship inside
-- the app (assets); these tables only hold what the family records.

create table public.food_tries (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null,
  baby_id uuid not null,
  food_id text not null,
  tried_on date not null,
  opinion text check (opinion in ('liked', 'neutral', 'disliked')),
  reaction text not null default 'none' check (reaction in ('none', 'mild', 'severe')),
  notes text,
  created_by uuid not null default auth.uid() references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  foreign key (baby_id, family_id) references public.babies (id, family_id) on delete cascade
);

create table public.milestone_checks (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null,
  baby_id uuid not null,
  milestone_id text not null,
  achieved_on date not null,
  notes text,
  created_by uuid not null default auth.uid() references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  foreign key (baby_id, family_id) references public.babies (id, family_id) on delete cascade
);

create index food_tries_baby_idx on public.food_tries (baby_id, tried_on desc);
create index food_tries_family_updated_idx on public.food_tries (family_id, updated_at);
create index milestone_checks_baby_idx on public.milestone_checks (baby_id, milestone_id);
create index milestone_checks_family_updated_idx on public.milestone_checks (family_id, updated_at);

do $$
declare
  t text;
begin
  foreach t in array array['food_tries', 'milestone_checks'] loop
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
alter publication powersync add table public.food_tries, public.milestone_checks;
