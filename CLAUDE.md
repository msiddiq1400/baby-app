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
- Once a branch is merged, delete it — on GitHub and locally. Don't keep old
  branches around.
- Commit messages: no "Co-Authored-By" or other AI attribution lines.
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

### Deploys (merging into `main` is the release)
- The owner approves the merge; everything below then happens by itself.
  Never deploy from a feature branch.
- GitHub "Tests and deploy" (`.github/workflows/tests.yml`): on pull
  requests into `main` it runs the app and server tests. On a push to
  `main`, once both pass, it applies new Supabase migrations and deploys the
  `notify-family` function. The nightly database backup runs on its own
  schedule (leave it).
- Website (`website/`, Cloudflare `wrangler.jsonc`): Cloudflare rebuilds
  palnacare.com on every push to `main`.
- Codemagic: iPhone to TestFlight and Android to Google Play (internal,
  draft) start on every push to `main` that changes `app/` (or
  `codemagic.yaml`).
- `[skip ci]` in the merge commit message skips the GitHub and Codemagic
  runs (use it for docs-only merges; Cloudflare still rebuilds the site).
