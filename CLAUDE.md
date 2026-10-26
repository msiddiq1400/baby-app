# baby-app

Palna: Flutter app (`app/`), Supabase backend (`supabase/`), PowerSync, and the palnacare.com site (`website/`, Cloudflare).

## Working rules (owner's preferences — follow these)

### Branches and releases
- `dev` is the source of truth. `main` is what's live: a push to `main` is a
  release and deploys.
- Each batch of work the owner asks for goes on ONE branch made from an
  up-to-date `dev`: `feat/<repo>-<feature>-v1` (or `fix/...`, `chore/...`).
  Don't split a batch over several branches (even when helpers work in
  parallel: they commit to that one branch). Build the whole batch there and
  push it. Pushing a branch triggers no CI and no deploy.
- The owner tests it locally first (debug build on the phone, or a local
  run). Only when they say it's OK: open a pull request into `dev`. CI runs
  the full test suite on it. Merge into `dev` after CI passes and the owner
  approves.
- Release: when the owner says "release" (end of day, or twice a day), open
  ONE pull request `dev` -> `main` for the repo, wait for CI, and merge it on
  the owner's OK with a merge commit (not squash). That merge is the one
  deploy (see Deploys).
- Never commit feature work straight to `dev` or `main`.
- Once a feature branch is merged into `dev`, delete it — on GitHub and
  locally. Never delete `dev` or `main`.
- Commit messages: no "Co-Authored-By" or other AI attribution lines.
- Ask before every merge into `dev`, before every release into `main`, and
  before any deploy.

### Tests while working
- Don't run the full test suite after every change — it wastes time. Run the
  analyzer/linter plus only the tests for the code you touched (commands
  below). The full suite runs in CI on the pull request (or run it once
  before merging if the owner asks).

### CI and deploys
- Tests run on pull requests into `dev` and into `main`. Deploys run only on
  a push to `main` (a merged release). Never deploy from `dev` or a feature
  branch.

### Tests (run only what you touched)
- App: in `app/`, `flutter analyze` then only the matching test files, e.g.
  `flutter test test/<file>_test.dart`.
- Full app suite (`flutter test`): runs in GitHub CI on pull requests into
  `dev` and `main`; locally only when the owner asks.

### Deploys (merging the release into `main`)
- The owner approves the release; everything below then happens by itself.
- GitHub "Tests and deploy" (`.github/workflows/tests.yml`): on pull
  requests into `dev` and `main` it runs the app and server tests. On a push
  to `main` (the release, already tested on its pull request) it applies new
  Supabase migrations and deploys the `notify-family` function. The nightly
  database backup runs on its own schedule (leave it).
- Website (`website/`, Cloudflare `wrangler.jsonc`): Cloudflare rebuilds
  palnacare.com on every push to `main`.
- Codemagic (free plan: Mac machines only, 500 minutes a month shared with
  OathLock and API Toolbox): iPhone to TestFlight and Android to Google Play
  (internal, draft) start on every push to `main` that changes `app/` (or
  `codemagic.yaml`).
- `[skip ci]` in the merge commit message skips the GitHub and Codemagic
  runs (use it for docs-only merges; Cloudflare still rebuilds the site).
