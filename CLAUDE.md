# baby-app

Palna: Flutter app (`app/`), Supabase backend (`supabase/`), PowerSync, and the palnacare.com site (`website/`, Cloudflare).

## Working rules (owner's preferences — follow these)

### Branches and releases
- Every change goes on its own branch, made from an up-to-date `main`:
  `feat/<repo>-<feature>-v1` (or `fix/...`, `chore/...`).
- Build the whole feature on that branch and push it there. Pushing a branch
  triggers no CI and no deploy.
- The owner tests it locally first (debug build on the phone, or a local
  run). Only when they say it's OK: open a pull request into `main`. CI runs
  the full test suite on the pull request.
- Merge into `main` only after CI passes and the owner approves. Never commit
  feature work straight to `main` — a push to `main` is a release.
- Ask before every commit that goes to `main`, before merging, and before
  any deploy.

### Tests while working
- Don't run the full test suite after every change — it wastes time. Run the
  analyzer/linter plus only the tests for the code you touched (commands
  below). The full suite runs in CI on the pull request (or run it once
  before merging if the owner asks).

### CI and deploys
- Checks and deploys run only for `main` (pushes to `main` and pull requests
  into `main`). Never deploy from a feature branch.

### Tests (run only what you touched)
- App: in `app/`, `flutter analyze` then only the matching test files, e.g.
  `flutter test test/<file>_test.dart`.
- Full app suite (`flutter test`): runs in GitHub CI on pull requests into
  `main` and on `main`; locally only when the owner asks.

### Deploys
- Codemagic (iPhone to TestFlight, Android to Google Play): no triggers, run
  only when started by hand, from `main`.
- GitHub "tests" workflow: pushes to `main` and pull requests into `main`
  only. The nightly database backup runs on its own schedule (leave it).
- Website (`website/`, Cloudflare `wrangler.jsonc`): deploy only from `main`.
- Supabase migrations: apply only from `main`, after the owner approves.
