# Palna: Mother & Baby Care

Baby tracker for parents in Pakistan: a Flutter app (Android + iOS) in English, Urdu and Roman Urdu,
with a Supabase backend and offline sync through PowerSync. Feature ideas: [plan-1.txt](plan-1.txt).
Open tasks for the owner: [todos.txt](todos.txt).

```
app/                 Flutter app
  lib/data/          Database on the phone (PowerSync), repositories, models, bundled content
  lib/features/      Screens, one folder per area (home, milk, solids, growth, health, settings...)
  assets/            WHO growth tables, solids guide, milestone checklists (JSON)
  tool/content/      Scripts that generate the solids and milestone JSON (edit these, not the JSON)
  test/              Unit tests, content checks, and screen/form smoke tests (EN, UR, Roman Urdu)
supabase/            Database migrations (the schema), email templates, local Supabase config
powersync/           Sync rules: which rows each phone downloads
website/             palnacare.com (plain HTML, hosted on Cloudflare); screenshots come from
                     app/tool/screenshots (flutter test tool/screenshots --update-goldens)
.github/workflows/   Nightly encrypted database backup
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
- Vaccines: Pakistan EPI schedule (marked for pediatrician review).
- Solids and recipes: NHS weaning guidance and WHO infant feeding guidance.
- Typical ranges in Reports: National Sleep Foundation (sleep under 4 months), American Academy
  of Sleep Medicine (4 months+), NHS (newborn feeds, wet and dirty diapers).
- Milestones: CDC "Learn the Signs. Act Early." checklists (2022).
- Milk storage: CDC; power-cut guidance: USDA FSIS.

A pediatrician should review all health content before release.
