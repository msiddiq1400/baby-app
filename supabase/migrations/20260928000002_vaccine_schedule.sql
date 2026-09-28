-- Reference data: national vaccine schedules.
-- Read-only for the app; edited only through migrations.
--
-- !! The Pakistan rows below were entered from general knowledge of the EPI
-- !! schedule and MUST be checked against the current Federal EPI schedule
-- !! (and reviewed by a pediatrician) before release. Keep verified = false
-- !! until then; the app should show an "unverified" warning for those rows.

create table public.vaccine_schedule (
  country_code text not null,
  code text not null,
  name text not null,
  dose_label text,
  due_age_value integer not null check (due_age_value >= 0),
  due_age_unit text not null check (due_age_unit in ('day', 'week', 'month')),
  sort_order integer not null,
  verified boolean not null default false,
  source text,
  primary key (country_code, code)
);

alter table public.vaccine_schedule enable row level security;
create policy "anyone signed in can read" on public.vaccine_schedule
  for select to authenticated using (true);
grant select on public.vaccine_schedule to authenticated;

insert into public.vaccine_schedule
  (country_code, code, name, dose_label, due_age_value, due_age_unit, sort_order, source)
values
  ('PK', 'BCG',     'BCG',                      null,     0,  'day',   10, 'Pakistan EPI (unverified)'),
  ('PK', 'OPV-0',   'Oral Polio Vaccine',       'Dose 0', 0,  'day',   11, 'Pakistan EPI (unverified)'),
  ('PK', 'HEPB-0',  'Hepatitis B',              'Birth',  0,  'day',   12, 'Pakistan EPI (unverified)'),
  ('PK', 'OPV-1',   'Oral Polio Vaccine',       'Dose 1', 6,  'week',  20, 'Pakistan EPI (unverified)'),
  ('PK', 'PENTA-1', 'Pentavalent (DTP-HepB-Hib)','Dose 1', 6,  'week',  21, 'Pakistan EPI (unverified)'),
  ('PK', 'PCV-1',   'Pneumococcal (PCV)',       'Dose 1', 6,  'week',  22, 'Pakistan EPI (unverified)'),
  ('PK', 'ROTA-1',  'Rotavirus',                'Dose 1', 6,  'week',  23, 'Pakistan EPI (unverified)'),
  ('PK', 'OPV-2',   'Oral Polio Vaccine',       'Dose 2', 10, 'week',  30, 'Pakistan EPI (unverified)'),
  ('PK', 'PENTA-2', 'Pentavalent (DTP-HepB-Hib)','Dose 2', 10, 'week',  31, 'Pakistan EPI (unverified)'),
  ('PK', 'PCV-2',   'Pneumococcal (PCV)',       'Dose 2', 10, 'week',  32, 'Pakistan EPI (unverified)'),
  ('PK', 'ROTA-2',  'Rotavirus',                'Dose 2', 10, 'week',  33, 'Pakistan EPI (unverified)'),
  ('PK', 'OPV-3',   'Oral Polio Vaccine',       'Dose 3', 14, 'week',  40, 'Pakistan EPI (unverified)'),
  ('PK', 'PENTA-3', 'Pentavalent (DTP-HepB-Hib)','Dose 3', 14, 'week',  41, 'Pakistan EPI (unverified)'),
  ('PK', 'PCV-3',   'Pneumococcal (PCV)',       'Dose 3', 14, 'week',  42, 'Pakistan EPI (unverified)'),
  ('PK', 'IPV-1',   'Inactivated Polio Vaccine','Dose 1', 14, 'week',  43, 'Pakistan EPI (unverified)'),
  ('PK', 'MR-1',    'Measles-Rubella',          'Dose 1', 9,  'month', 50, 'Pakistan EPI (unverified)'),
  ('PK', 'TCV',     'Typhoid Conjugate',        null,     9,  'month', 51, 'Pakistan EPI (unverified)'),
  ('PK', 'IPV-2',   'Inactivated Polio Vaccine','Dose 2', 9,  'month', 52, 'Pakistan EPI (unverified)'),
  ('PK', 'MR-2',    'Measles-Rubella',          'Dose 2', 15, 'month', 60, 'Pakistan EPI (unverified)');
