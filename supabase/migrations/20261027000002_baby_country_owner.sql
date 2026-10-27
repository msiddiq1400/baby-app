-- Only the person who added a baby sets or changes the baby's country (it
-- picks the vaccine schedule and emergency numbers). Invited family members
-- can edit everything else. If that person has left the family or deleted
-- their account (created_by is then null), a family owner can change it.
-- (todos.txt Q1)
--
-- The app hides the option from everyone else and never sends a country
-- change it isn't allowed to make, so this only stops old or modified apps.

create or replace function private.check_baby_country_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  me constant uuid := auth.uid();
begin
  if new.country_code is not distinct from old.country_code or me is null then
    return new;
  end if;
  if old.created_by = me then
    return new;
  end if;
  if (old.created_by is null or not exists (
        select 1 from public.family_members
        where family_id = old.family_id and user_id = old.created_by
      ))
     and private.is_family_owner(old.family_id) then
    return new;
  end if;
  raise exception 'only the person who added this baby can change the country'
    using errcode = '42501';
end;
$$;

create trigger check_baby_country_change
  before update of country_code on public.babies
  for each row execute function private.check_baby_country_change();

-- Nobody can add a baby in another person's name, or move one to it later.
create or replace function private.keep_baby_created_by()
returns trigger
language plpgsql
as $$
begin
  if auth.uid() is null then
    return new;
  end if;
  if tg_op = 'INSERT' and new.created_by is distinct from auth.uid() then
    raise exception 'created_by must be you' using errcode = '42501';
  end if;
  -- Deleting an account sets it to null (on delete set null): allowed.
  if tg_op = 'UPDATE' and new.created_by is distinct from old.created_by and new.created_by is not null then
    raise exception 'created_by cannot be changed' using errcode = '42501';
  end if;
  return new;
end;
$$;

create trigger keep_baby_created_by
  before insert or update of created_by on public.babies
  for each row execute function private.keep_baby_created_by();
