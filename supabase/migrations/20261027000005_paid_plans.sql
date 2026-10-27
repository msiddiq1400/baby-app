-- Paid plans (todos.txt 38b): Free and Pro.
--
-- Pro is bought in the app (Apple / Google billing through RevenueCat) by
-- one person, and the whole family gets it: everyone who shares the baby.
-- What Pro unlocks: more than one baby, up to 10 photos per baby per month
-- (Free: 1), 30-day reports and the PDF summary, colour themes and the
-- widget's "today" line. Only the first two need the server; the rest is
-- checked in the app.
--
--   subscriptions   one row per person who bought Pro: until when. Written
--                   only by the revenuecat Edge Function (service role),
--                   from RevenueCat's own records.
--   pro_emails      Pro for free (e.g. the App Store / Play reviewer's demo
--                   account). Server only; edit in the SQL editor.
--   families.pro_until  the family's Pro end date (null: Free; 'infinity':
--                   no end), kept up to date by triggers here, and synced to
--                   the phones with the family row.

create table public.subscriptions (
  user_id uuid primary key references auth.users (id) on delete cascade,
  -- null: never bought or refunded; in the past: expired; 'infinity': lifetime.
  pro_until timestamptz,
  product_id text,
  store text,
  updated_at timestamptz not null default now()
);

alter table public.subscriptions enable row level security;
create policy "read own subscription" on public.subscriptions
  for select to authenticated using (user_id = (select auth.uid()));
revoke all on public.subscriptions from anon, authenticated;
grant select on public.subscriptions to authenticated;
grant all on public.subscriptions to service_role;

create table public.pro_emails (
  email text primary key check (email = lower(email)),
  note text,
  created_at timestamptz not null default now()
);

alter table public.pro_emails enable row level security;
revoke all on public.pro_emails from anon, authenticated;
grant all on public.pro_emails to service_role;

insert into public.pro_emails (email, note)
values ('review@palnacare.com', 'App Store and Google Play reviewer demo account');

alter table public.families add column pro_until timestamptz;

-- ── Keeping families.pro_until up to date ────────────────────────────────────

create or replace function private.refresh_family_plan(fid uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  best timestamptz;
begin
  select max(greatest(
           s.pro_until,
           case when pe.email is not null then 'infinity'::timestamptz end
         ))
  into best
  from public.family_members m
  left join public.subscriptions s on s.user_id = m.user_id
  left join auth.users u on u.id = m.user_id
  left join public.pro_emails pe on pe.email = lower(u.email)
  where m.family_id = fid;

  -- Lets the guard below tell this update from a phone's.
  perform set_config('palna.plan_refresh', 'on', true);
  update public.families set pro_until = best
  where id = fid and pro_until is distinct from best;
  perform set_config('palna.plan_refresh', 'off', true);
end;
$$;

-- Phones can't set pro_until (owners may edit the family's name): a change
-- that doesn't come from refresh_family_plan is ignored.
create or replace function private.guard_family_plan()
returns trigger
language plpgsql
as $$
begin
  if new.pro_until is distinct from old.pro_until
     and coalesce(current_setting('palna.plan_refresh', true), 'off') <> 'on'
     and auth.uid() is not null then
    new.pro_until := old.pro_until;
  end if;
  return new;
end;
$$;

create trigger guard_family_plan
  before update on public.families
  for each row execute function private.guard_family_plan();

create or replace function private.on_subscription_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  fid uuid;
begin
  for fid in
    select family_id from public.family_members
    where user_id in (coalesce(new.user_id, old.user_id), coalesce(old.user_id, new.user_id))
  loop
    perform private.refresh_family_plan(fid);
  end loop;
  return null;
end;
$$;

create trigger on_subscription_change
  after insert or update or delete on public.subscriptions
  for each row execute function private.on_subscription_change();

-- Someone joins or leaves: the family may gain or lose Pro.
create or replace function private.on_member_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform private.refresh_family_plan(coalesce(new.family_id, old.family_id));
  return null;
end;
$$;

create trigger on_member_change
  after insert or delete on public.family_members
  for each row execute function private.on_member_change();

create or replace function private.on_pro_email_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  fid uuid;
begin
  for fid in
    select m.family_id from public.family_members m
    join auth.users u on u.id = m.user_id
    where lower(u.email) in (coalesce(new.email, old.email), coalesce(old.email, new.email))
  loop
    perform private.refresh_family_plan(fid);
  end loop;
  return null;
end;
$$;

create trigger on_pro_email_change
  after insert or delete on public.pro_emails
  for each row execute function private.on_pro_email_change();

create or replace function private.family_is_pro(fid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce((select pro_until > now() from public.families where id = fid), false);
$$;

-- ── Limits ──────────────────────────────────────────────────────────────────
-- The app checks these first and offers Pro; these stop old or modified
-- apps. Families that already have more (from before plans) keep them.

-- Free: one baby per family.
create or replace function private.check_baby_limit()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null or private.family_is_pro(new.family_id) then
    return new;
  end if;
  if exists (
    select 1 from public.babies
    where family_id = new.family_id and deleted_at is null and id <> new.id
  ) then
    raise exception 'plan_limit: the free plan has one baby per family' using errcode = '42501';
  end if;
  return new;
end;
$$;

create trigger check_baby_limit
  before insert on public.babies
  for each row execute function private.check_baby_limit();

-- Photos: Free 1, Pro 10 per baby per month of age (replaces the unique
-- index from 20261001000002_photos.sql).
drop index public.photos_one_per_month;
create index photos_baby_month_idx on public.photos (baby_id, age_month) where deleted_at is null;

create or replace function private.check_photo_limit()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  allowed integer;
begin
  if new.deleted_at is not null then
    return new;
  end if;
  if tg_op = 'UPDATE' and old.deleted_at is null and old.age_month = new.age_month then
    return new;
  end if;
  allowed := case when private.family_is_pro(new.family_id) then 10 else 1 end;
  if (select count(*) from public.photos
      where baby_id = new.baby_id and age_month = new.age_month and deleted_at is null and id <> new.id
     ) >= allowed then
    raise exception 'plan_limit: % photo(s) per month on this plan', allowed using errcode = '42501';
  end if;
  return new;
end;
$$;

create trigger check_photo_limit
  before insert or update of age_month, deleted_at on public.photos
  for each row execute function private.check_photo_limit();
