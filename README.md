# Palna: Mother & Baby Care

Baby tracker for parents in Pakistan: a Flutter app (Android + iOS) in English, Urdu and Roman Urdu,
with a Supabase backend and offline sync through PowerSync. Feature ideas: [plan-1.txt](plan-1.txt).
Open tasks for the owner: [todos.txt](todos.txt).

```
app/                 Flutter app
  lib/data/          Database on the phone (PowerSync), repositories, models, bundled content
  lib/features/      Screens, one folder per area (home, feeding, milk, solids, growth, health, settings...)
  assets/            WHO growth tables, solids guide, milestone checklists (JSON)
  tool/content/      Scripts that generate the solids and milestone JSON (edit these, not the JSON)
  test/              Unit tests, content checks, and screen/form smoke tests (EN, UR, Roman Urdu)
  test/flows/        Flow tests: the real app on a real on-phone database, with a fake Supabase
supabase/            Database migrations (the schema), email templates, local Supabase config
powersync/           Sync rules: which rows each phone downloads
website/             palnacare.com (plain HTML, hosted on Cloudflare); screenshots come from
                     app/tool/screenshots (flutter test tool/screenshots --update-goldens)
.github/workflows/   Tests on main and pull requests into main (tests.yml); nightly encrypted database backup
```

## How data flows

```
Screens ─► repositories ─► database on the phone (SQLite, PowerSync)
                                   │  sync in the background when online
                                   ▼
                     PowerSync service ◄──► Supabase Postgres
```

- The app reads and writes only the database on the phone, so it works offline and screens update
  live. PowerSync downloads each family's rows (rules in `powersync/sync-config.yaml`) and uploads
  local changes through Supabase's API (`app/lib/data/supabase_connector.dart`), so Supabase's
  row-level security applies to every write.
- Deletions are soft (`deleted_at`) so they reach other caregivers' phones.
- Sign-in, family invites and the member list talk to Supabase directly and need internet.
- Reminders (vaccines, medicines, stored milk) are local notifications scheduled on the phone.
- Running timers (breastfeeding, sleep) live in the feed and sleep rows, so they survive restarts
  and show on every family phone; Android also shows an ongoing notification and a home-screen
  widget (`android/.../PalnaWidgetProvider.kt`, fed by `home_widget_sync.dart`).
- Illnesses group symptoms, doses and doctor's visits by time range (they don't own them).

## Running the app

```sh
cd app
flutter run --dart-define-from-file=env/prod.json     # against the cloud project
flutter test                                          # all tests
```

`app/env/*.json` holds the server URLs and public keys (git-ignored; see `env/example.json`).

## Tests

`flutter test` runs everything; GitHub runs the same on pull requests into main and on main (`.github/workflows/tests.yml`).

- `test/*.dart`: calculations (ages, WHO percentiles, vaccine and medicine plans, reports), the
  bundled content, and every screen and form built in English, Urdu and Roman Urdu (fails on any
  error or text overflow).
- `test/flows/`: whole flows through the real app: tap Feed > Save, then check the row in the
  database, the upload queue and the screen. `harness.dart` opens a fresh database per test and
  fakes Supabase (`env.server.on('POST', '/rest/v1/rpc/...', ...)`), so no network is used.

When you add a feature, add a flow test next to the ones for that tab; when you fix a bug, add a
test that fails without the fix. Use texts from `lookupAppLocalizations(const Locale('en'))`, not
English literals, so wording changes don't break tests.

## Changing the database

1. Add a migration in `supabase/migrations/` (`npx supabase migration new <name>`). Never edit
   tables in the dashboard.
2. Apply it: `npx supabase db push --dry-run`, then `npx supabase db push`.
3. For a new table that should sync: add it to the `powersync` publication (in the migration), to
   `powersync/sync-config.yaml` (then redeploy it in the PowerSync dashboard), and to
   `app/lib/data/local_schema.dart`.

## Hosting: Supabase Cloud now, own server later

Production starts on Supabase Cloud. The setup is kept portable so it can move to a self-hosted
Supabase and PowerSync (Docker) if costs grow:

- The schema is plain Postgres in migrations, so the same files run on both.
- The app reads server URLs from `env/*.json`, so switching needs no code change.
- PowerSync has a self-hostable open edition.

To move later: set up self-hosted Supabase and PowerSync on the new server, apply the migrations,
copy the data (`pg_dump` / `pg_restore`, plus the JWT secret so existing logins keep working), then
ship an app update pointing at the new URLs.

> The current toolbox VPS (2 vCPU / 4 GB RAM) is too small for self-hosted Supabase. A separate
> server with about 4 vCPU / 8 GB RAM is needed.

## Content sources

- Growth charts: WHO Child Growth Standards (via the CDC data files).
- Vaccines: each baby has a country (`babies.country_code`, picked when adding the baby); its
  schedule comes from `vaccine_schedule` (Pakistan EPI, UK, US, Canada, UAE, Saudi Arabia; all marked
  unverified until a clinician reviews them). New countries are just rows in that table, synced to
  phones without an app update. Any country can also record vaccines by name
  (`vaccine_code = 'OTHER'`). Emergency numbers per country: `app/lib/core/emergency.dart`.
- Monthly photos: rows in `photos` (one per baby per month of age, enforced by a unique index;
  the free limit), files in the private Storage bucket `photos` at `<family_id>/<photo_id>.jpg`.
  PowerSync's attachment queue (`app/lib/data/photo_repository.dart`, started in `main.dart`)
  keeps them on the phone, uploads offline-made photos later and downloads family members' ones.
- Solids and recipes: NHS weaning guidance and WHO infant feeding guidance.
- Typical ranges in Reports: National Sleep Foundation (sleep under 4 months), American Academy
  of Sleep Medicine (4 months+), NHS (newborn feeds, wet and dirty diapers).
- Milestones: CDC "Learn the Signs. Act Early." checklists (2022).
- Milk storage: CDC; power-cut guidance: USDA FSIS.

A pediatrician should review all health content before release.
