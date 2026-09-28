# Baby App

Flutter app (iOS + Android) with a Supabase backend. Feature ideas: [plan-1.txt](plan-1.txt).

```
app/        Flutter app
supabase/   Database migrations and local Supabase config
```

## Local development

Requires Flutter, Node and Docker Desktop.

```sh
# Start local Supabase (first run downloads ~2-3 GB of images)
npx supabase start
npx supabase status          # URLs and keys; Studio runs at http://127.0.0.1:54323

# App config: copy the example and paste the local publishable key
cp app/env/example.json app/env/dev.json

# Android phone over USB: let the phone reach Supabase on this PC
adb reverse tcp:54321 tcp:54321

cd app
flutter run --dart-define-from-file=env/dev.json
```

Database changes always go in a new file in `supabase/migrations/` (`npx supabase migration new <name>`),
never by editing tables in the dashboard. `npx supabase db reset` rebuilds the local database from them.

## Hosting: Supabase Cloud now, own server later

Production starts on Supabase Cloud. The setup is kept portable so it can move to a self-hosted
Supabase (Docker) server if Cloud costs grow:

- The schema is plain Postgres in migrations, so the same files run on both.
- The app reads the server URL and key from `env/*.json`, so switching needs no code change.
- Avoid Cloud-only features. Edge Functions, Storage and Auth are all part of self-hosted Supabase.

To move later: set up self-hosted Supabase on the new server, apply the migrations, copy the data
(`pg_dump` / `pg_restore`, plus Storage files and the JWT secret so existing logins keep working),
then ship an app update pointing at the new URL.

> The current toolbox VPS (2 vCPU / 4 GB RAM) is too small for self-hosted Supabase. A separate
> server with about 4 vCPU / 8 GB RAM is needed.
