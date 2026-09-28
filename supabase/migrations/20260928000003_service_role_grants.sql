-- The hosted project has "automatically expose new tables" turned off, so no
-- role gets table access by default. The app's role (authenticated) is
-- granted in earlier migrations; this gives the server-side role
-- (service_role, used by scheduled jobs such as reminders) the same
-- explicit access. service_role bypasses RLS, so it is never used in the app.
--
-- New tables in later migrations need their own grants.

grant usage on schema public to service_role;
grant select, insert, update, delete on all tables in schema public to service_role;
grant usage, select on all sequences in schema public to service_role;
grant execute on all functions in schema public to service_role;
