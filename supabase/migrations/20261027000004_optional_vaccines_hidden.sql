-- Optional RSV and flu reminders (todos.txt Q5) are shown next to the
-- routine schedule where a country offers them to all babies. Any family
-- member can hide them for a baby; it syncs to the whole family.
alter table public.babies
  add column hide_optional_vaccines boolean not null default false;
