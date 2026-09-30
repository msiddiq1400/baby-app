-- Demo account for Apple and Google app review: review@palnacare.com.
-- Run once in Supabase > SQL Editor, after replacing the password below.
-- Creates a confirmed email/password login, a family, a 10-week-old sample
-- baby and three days of feeds, sleeps and diapers, plus growth and vaccines.
-- Stops without changing anything if the account already exists.

do $$
declare
  v_email text := 'review@palnacare.com';
  v_password text := 'CHANGE-ME-strong-password';
  v_user uuid := gen_random_uuid();
  v_family uuid;
  v_baby uuid;
  v_birth date := current_date - 72;
begin
  if v_password = 'CHANGE-ME-strong-password' then
    raise exception 'Set v_password first';
  end if;
  if exists (select 1 from auth.users where email = v_email) then
    raise exception '% already exists', v_email;
  end if;

  -- Login. The empty-string token columns are what Supabase Auth expects;
  -- nulls there break sign-in. The profile row is added by a trigger.
  insert into auth.users (
    instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
    confirmation_token, recovery_token, email_change, email_change_token_new
  ) values (
    '00000000-0000-0000-0000-000000000000', v_user, 'authenticated', 'authenticated',
    v_email, extensions.crypt(v_password, extensions.gen_salt('bf')), now(),
    '{"provider": "email", "providers": ["email"]}', '{"full_name": "Sara (Review)"}',
    now(), now(), '', '', '', ''
  );

  insert into auth.identities (id, user_id, provider_id, provider, identity_data, last_sign_in_at, created_at, updated_at)
  values (
    gen_random_uuid(), v_user, v_user::text, 'email',
    jsonb_build_object('sub', v_user::text, 'email', v_email, 'email_verified', true),
    now(), now(), now()
  );

  -- Family (a trigger makes the user its owner) and baby.
  insert into public.families (name, created_by)
  values ('Ayaan family', v_user)
  returning id into v_family;

  insert into public.babies (family_id, name, sex, birth_date, birth_weight_g, birth_length_mm, birth_head_mm, created_by)
  values (v_family, 'Ayaan', 'male', v_birth, 3200, 500, 345, v_user)
  returning id into v_baby;

  -- Feeds every 3 hours for the last 3 days, breast and formula in turn.
  insert into public.feeds (family_id, baby_id, type, side, started_at, ended_at, amount_ml, left_seconds, right_seconds, created_by)
  select v_family, v_baby,
    case when n % 2 = 0 then 'breast' else 'bottle_formula' end::public.feed_type,
    case when n % 2 = 0 then 'both' end::public.breast_side,
    t,
    t + case when n % 2 = 0 then interval '20 minutes' else interval '10 minutes' end,
    case when n % 2 = 0 then null else 90 + (n % 3) * 15 end,
    case when n % 2 = 0 then 600 end,
    case when n % 2 = 0 then 540 end,
    v_user
  from (
    select t, row_number() over (order by t) as n
    from generate_series(now() - interval '3 days', now() - interval '1 hour', interval '3 hours') as t
  ) f;

  -- A nap after most daytime feeds, and a night sleep each night.
  insert into public.sleeps (family_id, baby_id, kind, started_at, ended_at, created_by)
  select v_family, v_baby, 'nap', t + interval '30 minutes', t + interval '30 minutes' + interval '75 minutes', v_user
  from generate_series(now() - interval '3 days', now() - interval '4 hours', interval '3 hours') as t
  where extract(hour from t at time zone 'Asia/Karachi') between 9 and 18;

  insert into public.sleeps (family_id, baby_id, kind, started_at, ended_at, created_by)
  select v_family, v_baby, 'night',
    (d + time '22:00') at time zone 'Asia/Karachi',
    (d + time '22:00') at time zone 'Asia/Karachi' + interval '5 hours', v_user
  from generate_series(current_date - 3, current_date - 1, interval '1 day') as d;

  -- Diapers every 4 hours, every third one dirty as well.
  insert into public.diapers (family_id, baby_id, occurred_at, is_wet, is_dirty, created_by)
  select v_family, v_baby, t, true, n % 3 = 0, v_user
  from (
    select t, row_number() over (order by t) as n
    from generate_series(now() - interval '3 days', now() - interval '2 hours', interval '4 hours') as t
  ) d;

  insert into public.growth_measurements (family_id, baby_id, measured_on, weight_g, length_mm, head_mm, created_by)
  values
    (v_family, v_baby, v_birth + 14, 3650, 525, 355, v_user),
    (v_family, v_baby, v_birth + 42, 4900, 565, 380, v_user),
    (v_family, v_baby, v_birth + 70, 5700, 590, 395, v_user);

  -- Birth and 6-week vaccines done; the 10-week ones show as due.
  insert into public.vaccinations (family_id, baby_id, vaccine_code, given_on, clinic, created_by)
  select v_family, v_baby, code, v_birth + case when code like '%-0' or code = 'BCG' then 0 else 42 end, 'EPI centre', v_user
  from unnest(array['BCG', 'OPV-0', 'HEPB-0', 'OPV-1', 'PENTA-1', 'PCV-1', 'ROTA-1']) as code;

  raise notice 'Created % (user id %)', v_email, v_user;
end;
$$;
