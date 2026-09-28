-- Medicine schedules as times of day ("8:00 and 20:00") instead of
-- "every N hours", which had no start time to schedule reminders from.
-- "Every 8 hours" is entered as three times.
--
-- The medicine cabinet had no screens before this, so no rows exist to migrate.

alter table public.medications
  drop column every_hours,
  add column dose_times time[] not null default '{}',
  add column as_needed boolean not null default false,
  add constraint medications_schedule_check
    check (as_needed or cardinality(dose_times) between 1 and 12);

-- Which scheduled dose a record belongs to (null for "as needed" doses),
-- so the app can show each of today's doses as given, skipped or missed.
alter table public.medication_doses
  add column scheduled_for timestamptz;

create index medication_doses_medication_idx
  on public.medication_doses (medication_id, given_at desc);
