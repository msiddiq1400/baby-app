-- Permanently removes entries 30 days after they were deleted in the app.
-- Run once in Supabase > SQL Editor (todos.txt item 27a). Safe to run again:
-- it replaces the function and the schedule.
--
-- Why 30 days: deleting in the app only marks a row (deleted_at) so the
-- deletion reaches the other family members' phones, including phones that
-- were offline. After 30 days every phone has long since caught up, so the
-- row can go for good. Deleting a baby removes all its entries with it
-- (the foreign keys cascade).
--
-- Every table with a deleted_at column is included, so new tables are
-- covered automatically.

create extension if not exists pg_cron;

create or replace function private.purge_deleted_entries()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  t text;
begin
  -- Children before parents, so the row counts in the log are meaningful
  -- (babies last: their entries would cascade anyway).
  for t in
    select c.table_name
    from information_schema.columns c
    join information_schema.tables tb
      on tb.table_schema = c.table_schema and tb.table_name = c.table_name and tb.table_type = 'BASE TABLE'
    where c.table_schema = 'public' and c.column_name = 'deleted_at'
    order by (c.table_name = 'babies'), (c.table_name = 'medications'), c.table_name
  loop
    execute format('delete from public.%I where deleted_at < now() - interval ''30 days''', t);
  end loop;
end;
$$;

revoke all on function private.purge_deleted_entries() from public, anon, authenticated;

-- Every night at 03:00 Pakistan time (22:00 UTC).
select cron.schedule('purge-deleted-entries', '0 22 * * *', 'select private.purge_deleted_entries()');

-- To check it ran:  select * from cron.job_run_details order by start_time desc limit 5;
-- To stop it:       select cron.unschedule('purge-deleted-entries');
