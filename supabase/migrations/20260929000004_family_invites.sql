-- Inviting caregivers: an owner creates a short code (valid 7 days, single
-- use) and shares it; the other person enters it to join the family.
-- Codes are only created and accepted through the functions below, which
-- check permissions, so the table itself is read-only for owners.

create table public.family_invites (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families (id) on delete cascade,
  code text not null unique,
  created_by uuid not null default auth.uid() references auth.users (id),
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default now() + interval '7 days',
  accepted_by uuid references auth.users (id),
  accepted_at timestamptz
);

alter table public.family_invites enable row level security;
create policy "owners see their family's invites" on public.family_invites
  for select to authenticated using ((select private.is_family_owner(family_id)));
grant select on public.family_invites to authenticated;
grant select, insert, update, delete on public.family_invites to service_role;

-- Creates an invite for a family the caller owns; returns the code.
create or replace function public.create_family_invite(target_family uuid)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  -- No 0/O or 1/I, so codes are easy to read out over the phone.
  alphabet constant text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  new_code text;
begin
  if not private.is_family_owner(target_family) then
    raise exception 'not_family_owner' using errcode = '42501';
  end if;
  loop
    new_code := '';
    for i in 1..6 loop
      new_code := new_code || substr(alphabet, 1 + floor(random() * length(alphabet))::int, 1);
    end loop;
    exit when not exists (select 1 from public.family_invites where code = new_code);
  end loop;
  insert into public.family_invites (family_id, code, created_by) values (target_family, new_code, auth.uid());
  return new_code;
end;
$$;

-- Joins the caller to the invite's family as a caregiver; returns the family id.
create or replace function public.accept_family_invite(invite_code text)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  invite public.family_invites;
begin
  if auth.uid() is null then
    raise exception 'not_signed_in' using errcode = '42501';
  end if;
  select * into invite from public.family_invites
  where code = upper(trim(invite_code)) and accepted_at is null and expires_at > now()
  for update;
  if not found then
    raise exception 'invalid_invite' using errcode = 'P0002';
  end if;
  insert into public.family_members (family_id, user_id, role)
  values (invite.family_id, auth.uid(), 'caregiver')
  on conflict do nothing;
  update public.family_invites set accepted_by = auth.uid(), accepted_at = now() where id = invite.id;
  return invite.family_id;
end;
$$;

-- Members of a family the caller belongs to, with a name to show.
create or replace function public.family_member_list(target_family uuid)
returns table (user_id uuid, display_name text, role public.family_role, is_me boolean)
language sql
stable
security definer
set search_path = ''
as $$
  select m.user_id, coalesce(nullif(p.display_name, ''), u.email::text), m.role, m.user_id = auth.uid()
  from public.family_members m
  join auth.users u on u.id = m.user_id
  left join public.profiles p on p.id = m.user_id
  where m.family_id = target_family and private.is_family_member(target_family)
  order by m.created_at;
$$;

-- Functions are executable by everyone by default; only signed-in users here.
revoke execute on function public.create_family_invite(uuid) from public, anon;
revoke execute on function public.accept_family_invite(text) from public, anon;
revoke execute on function public.family_member_list(uuid) from public, anon;
grant execute on function public.create_family_invite(uuid) to authenticated;
grant execute on function public.accept_family_invite(text) to authenticated;
grant execute on function public.family_member_list(uuid) to authenticated;

-- (family_members is already in the powersync publication, so PowerSync
-- sees people joining or leaving a family.)
