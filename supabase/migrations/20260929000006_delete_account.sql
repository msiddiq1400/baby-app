-- "Delete my account" (required by Google Play and the App Store).
--
-- delete_my_account() removes the caller completely:
--   * families where they are the only member are deleted, with every baby
--     and entry in them (the foreign keys cascade);
--   * in families shared with others, the entries stay for the others, and
--     if the caller was the only owner, the longest-standing member becomes
--     owner;
--   * their unused invite codes are deleted;
--   * finally their login is deleted, which also removes their profile and
--     memberships (on delete cascade).

-- Entries a deleted person made stay in a shared family, without an author:
-- every "who made this" reference to auth.users becomes nullable and is
-- cleared when that user is deleted. (profiles and family_members already
-- cascade and are left alone.)
do $$
declare
  fk record;
begin
  for fk in
    select c.conname, c.conrelid::regclass as tbl, a.attname as col
    from pg_constraint c
    join pg_attribute a on a.attrelid = c.conrelid and a.attnum = c.conkey[1]
    where c.contype = 'f'
      and c.confrelid = 'auth.users'::regclass
      and c.connamespace = 'public'::regnamespace
      and c.confdeltype = 'a'          -- no action
      and array_length(c.conkey, 1) = 1
  loop
    execute format('alter table %s alter column %I drop not null', fk.tbl, fk.col);
    execute format('alter table %s drop constraint %I', fk.tbl, fk.conname);
    execute format(
      'alter table %s add constraint %I foreign key (%I) references auth.users (id) on delete set null',
      fk.tbl, fk.conname, fk.col
    );
  end loop;
end;
$$;

create or replace function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  me constant uuid := auth.uid();
begin
  if me is null then
    raise exception 'not_signed_in' using errcode = '42501';
  end if;

  -- Families nobody else belongs to: delete with all their data.
  delete from public.families f
  where exists (select 1 from public.family_members m where m.family_id = f.id and m.user_id = me)
    and not exists (select 1 from public.family_members m where m.family_id = f.id and m.user_id <> me);

  -- Shared families where the caller is the only owner: the member who
  -- joined first takes over.
  update public.family_members m
  set role = 'owner'
  from (
    select distinct on (o.family_id) o.family_id, o.user_id
    from public.family_members o
    where o.user_id <> me
      and o.family_id in (select family_id from public.family_members where user_id = me and role = 'owner')
      and not exists (
        select 1 from public.family_members x
        where x.family_id = o.family_id and x.user_id <> me and x.role = 'owner'
      )
    order by o.family_id, o.created_at, o.user_id
  ) heir
  where m.family_id = heir.family_id and m.user_id = heir.user_id;

  delete from public.family_invites where created_by = me and accepted_at is null;

  delete from auth.users where id = me;
end;
$$;

revoke execute on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;
