-- Push notifications between family phones ("Sana logged a feed").
-- When someone logs a feed, a sleep or a medicine dose, the other members
-- of the family get a notification on their phones (todos.txt item 36).
--
--   push_devices       one row per phone's push token (Firebase Cloud
--                      Messaging) with that phone's settings: which kinds
--                      to show, quiet hours, language and time zone.
--                      Server-only: not synced to phones.
--   register_device    called by the app after sign-in, when the token
--                      changes and when the person changes their settings
--   unregister_device  called by the app before signing out
--   notify_family      trigger on feeds, sleeps and medication_doses that
--                      decides whether a write is worth a notification and,
--                      if so, calls the notify-family Edge Function through
--                      pg_net. The shared secret lives in Vault (name
--                      'palna_hook_secret'), never in this file; without it
--                      nothing is sent (push not set up yet).
--
-- The Edge Function (supabase/functions/notify-family) picks the
-- recipients (everyone in the family except the person who did it),
-- applies each phone's settings and writes the message.

create table public.push_devices (
  token             text primary key,
  user_id           uuid not null references auth.users (id) on delete cascade,
  platform          text not null check (platform in ('android', 'ios')),
  locale            text not null default 'en' check (locale in ('en', 'ur', 'ur-Latn')),
  time_zone         text not null default 'Asia/Karachi' check (char_length(time_zone) between 1 and 64),
  notify_feeds      boolean not null default true,
  notify_sleep      boolean not null default true,
  notify_medicines  boolean not null default true,
  -- Quiet hours in minutes after local midnight; from > to crosses
  -- midnight (1320..420 = 22:00 to 07:00). Both null = no quiet hours.
  quiet_from        smallint check (quiet_from between 0 and 1439),
  quiet_to          smallint check (quiet_to between 0 and 1439),
  updated_at        timestamptz not null default now(),
  check ((quiet_from is null) = (quiet_to is null))
);
create index push_devices_user_id on public.push_devices (user_id);

-- Only the functions below and the Edge Function (service role) touch it.
alter table public.push_devices enable row level security;
revoke all on public.push_devices from public, anon, authenticated;
grant select, delete on public.push_devices to service_role;

-- A token belongs to whichever account signed in on that phone last.
create function public.register_device(
  p_token text,
  p_platform text,
  p_locale text,
  p_time_zone text,
  p_notify_feeds boolean,
  p_notify_sleep boolean,
  p_notify_medicines boolean,
  p_quiet_from smallint,
  p_quiet_to smallint
) returns void
language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then raise exception 'Not signed in.' using errcode = '42501'; end if;
  if p_token is null or length(p_token) < 20 or length(p_token) > 4096 then
    raise exception 'Invalid device token.' using errcode = '22023';
  end if;
  if p_platform is null or p_platform not in ('android', 'ios') then
    raise exception 'Invalid platform.' using errcode = '22023';
  end if;
  if p_locale is null or p_locale not in ('en', 'ur', 'ur-Latn') then
    raise exception 'Invalid language.' using errcode = '22023';
  end if;
  if p_time_zone is null or length(p_time_zone) < 1 or length(p_time_zone) > 64 then
    raise exception 'Invalid time zone.' using errcode = '22023';
  end if;
  if (p_quiet_from is null) <> (p_quiet_to is null)
     or p_quiet_from not between 0 and 1439 or p_quiet_to not between 0 and 1439 then
    raise exception 'Invalid quiet hours.' using errcode = '22023';
  end if;
  insert into public.push_devices as d (
    token, user_id, platform, locale, time_zone,
    notify_feeds, notify_sleep, notify_medicines, quiet_from, quiet_to, updated_at
  ) values (
    p_token, uid, p_platform, p_locale, p_time_zone,
    coalesce(p_notify_feeds, true), coalesce(p_notify_sleep, true), coalesce(p_notify_medicines, true),
    p_quiet_from, p_quiet_to, now()
  )
  on conflict (token) do update set
    user_id = excluded.user_id,
    platform = excluded.platform,
    locale = excluded.locale,
    time_zone = excluded.time_zone,
    notify_feeds = excluded.notify_feeds,
    notify_sleep = excluded.notify_sleep,
    notify_medicines = excluded.notify_medicines,
    quiet_from = excluded.quiet_from,
    quiet_to = excluded.quiet_to,
    updated_at = now();
end
$$;

create function public.unregister_device(p_token text) returns void
language plpgsql security definer set search_path = '' as $$
begin
  delete from public.push_devices where token = p_token and user_id = auth.uid();
end
$$;

revoke execute on function public.register_device(text, text, text, text, boolean, boolean, boolean, smallint, smallint),
  public.unregister_device(text) from public, anon;
grant execute on function public.register_device(text, text, text, text, boolean, boolean, boolean, smallint, smallint),
  public.unregister_device(text) to authenticated, service_role;

-- ---------------------------------------------------------------- trigger

create extension if not exists pg_net with schema extensions;

-- Decides here, in the database, whether a write is news for the family,
-- so most writes (edits, deletes, entries logged hours later) never call
-- the Edge Function. Rows uploaded more than 3 hours after the fact (a
-- phone that was offline) aren't news any more.
create function private.notify_family() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  event text;
  recent constant timestamptz := now() - interval '3 hours';
  secret text;
begin
  if new.deleted_at is not null then return new; end if;

  if tg_table_name = 'feeds' then
    if tg_op = 'INSERT' then
      if new.timer_side is not null and new.ended_at is null then
        if coalesce(new.timer_started_at, new.started_at) >= recent then event := 'feed_timer_started'; end if;
      elsif coalesce(new.ended_at, new.started_at) >= recent then
        event := 'feed_logged';
      end if;
    elsif old.ended_at is null and new.ended_at is not null and old.timer_side is not null
          and new.ended_at >= recent then
      event := 'feed_timer_finished';
    end if;
  elsif tg_table_name = 'sleeps' then
    if tg_op = 'INSERT' then
      if new.ended_at is null and new.started_at >= recent then event := 'sleep_started'; end if;
    elsif old.ended_at is null and new.ended_at is not null and new.ended_at >= recent then
      event := 'sleep_ended';
    end if;
  elsif tg_table_name = 'medication_doses' then
    if tg_op = 'INSERT' and not new.skipped and new.given_at >= recent then event := 'dose_given'; end if;
  end if;

  if event is null then return new; end if;

  -- A push must never stop the entry from being saved.
  begin
    select decrypted_secret into secret from vault.decrypted_secrets where name = 'palna_hook_secret';
    if secret is null then return new; end if; -- push not set up yet
    perform net.http_post(
      url := 'https://ixrlofqsstddisizofwc.supabase.co/functions/v1/notify-family',
      headers := jsonb_build_object('Content-Type', 'application/json', 'x-palna-hook', secret),
      body := jsonb_build_object('event', event, 'record', to_jsonb(new), 'actor', auth.uid())
    );
  exception when others then
    raise warning 'notify_family: %', sqlerrm;
  end;
  return new;
end
$$;

revoke execute on function private.notify_family() from public, anon, authenticated;

create trigger feeds_notify_family
  after insert or update on public.feeds
  for each row execute function private.notify_family();
create trigger sleeps_notify_family
  after insert or update on public.sleeps
  for each row execute function private.notify_family();
create trigger medication_doses_notify_family
  after insert or update on public.medication_doses
  for each row execute function private.notify_family();
