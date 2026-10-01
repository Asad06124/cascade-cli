# Cascade CLI

Official command-line tool for [Cascade](https://cascade.dev) — connect a Flutter
app to your Cascade account, write the project key, and install the sealed CI workflow.

```bash
dart pub global activate cascade_cli
cascade login
cascade init
cascade doctor
```

> **Note:** On pub.dev the package id is **`cascade_cli`** (the name `cascade` is reserved).
> After activate, the command you run is still **`cascade`**.

---

## Requirements

| Need | Why |
|------|-----|
| [Flutter / Dart SDK](https://docs.flutter.dev/get-started/install) (Dart ≥ 3.5) | Install and run the CLI |
| A Cascade account at [cascade.dev](https://cascade.dev) | Login + app linking |
| A Flutter app with `pubspec.yaml` | `cascade init` must run in the app root |
| A GitHub repo for that app | Hosts code + Actions |
| [GitHub CLI](https://cli.github.com/) (`gh`) | Push secrets; `cascade doctor` checks them |
| GitHub Actions enabled on the repo | Runs `.github/workflows/cascade.yml` |

Optional (only for lanes you enable):

- Android keystore + `key.properties` (signing / Play)
- Play Console service-account JSON (Play uploads)
- App Store Connect API key + Match secrets (TestFlight / App Store)

---

## Install

```bash
dart pub global activate cascade_cli
```

Confirm the Dart/Flutter global bin is on your `PATH`. Then:

```bash
cascade --help
```

---

## Full usage flow

### 1. Create a Cascade account (website)

1. Open [https://cascade.dev](https://cascade.dev) (or your hosted panel).
2. Sign up with a **real email** (temporary/disposable addresses are blocked).
3. Enter the OTP from your email.
4. You can browse the dashboard later — you do **not** need to create an app in the UI first.

### 2. Log in from the terminal

In any directory:

```bash
cascade login
```

What happens:

1. The CLI opens your browser to Cascade.
2. Sign in on the website (if you are not already).
3. Click **Allow** / authorize the CLI.
4. The terminal prints `✅ Logged in as you@…`.

Credentials are stored in `~/.cascade/config.json` (never commit this).

**Developers only — local panel:** if a control plane is running at `http://127.0.0.1:43127`, `cascade login` auto-detects it. Override with:

```bash
cascade login --api http://127.0.0.1:43127
# or
export CASCADE_API_URL=http://127.0.0.1:43127
```

### 3. Init inside your Flutter app

```bash
cd /path/to/your_flutter_app   # folder that contains pubspec.yaml
cascade init
```

This will:

1. Create (or re-link) the app in your Cascade account from `pubspec.yaml`
2. Write `cascade.project.yaml` — **project key** for CI (commit this)
3. Write `.github/workflows/cascade.yml` — **sealed** thin workflow (commit this; do not edit)
4. Create `cascade.secrets.env` (gitignored), plus `.example` and `cascade.secrets.md`
5. Ensure `cascade.secrets.env` is in `.gitignore`

Useful flags:

```bash
cascade init --new          # force a brand-new Cascade app for this folder
cascade init --pick         # choose an existing Cascade app
cascade init --name MyApp   # override the display name
```

### 4. Fill secrets and push them to GitHub

You do **not** need every secret — only what your enabled lanes use.

1. Open `cascade.secrets.env` (Android signing may already be auto-filled).
2. Set at least `CASCADE_NOTIFY_EMAILS` if you want result emails.
3. Follow `cascade.secrets.md`, or push with `gh`:

```bash
gh auth login   # once

gh secret set CASCADE_NOTIFY_EMAILS --body "you@example.com"

# Bulk (skips empty values if you only filled what you need):
set -a && source cascade.secrets.env && set +a
gh secret set CASCADE_NOTIFY_EMAILS --body "$CASCADE_NOTIFY_EMAILS"
# …plus Android / Play / Apple secrets you actually use
```

Secrets live in **GitHub Actions secrets**, not in the Cascade dashboard.

### 5. Enable lanes in the Cascade dashboard

1. Open [cascade.dev](https://cascade.dev) → your app.
2. Turn **on** only the deliveries you want (e.g. TestFlight, Play internal, APK build).
3. Closed lanes stay closed even if someone tags a commit for them.

### 6. Commit Cascade files and push

```bash
git add cascade.project.yaml .github/workflows/cascade.yml \
  cascade.secrets.env.example cascade.secrets.md
git commit -m "Add Cascade CI"
git push
```

Do **not** commit `cascade.secrets.env`.

### 7. Health check

```bash
cascade doctor
```

Checks: CLI login, `pubspec.yaml`, project key, sealed workflow, and whether required GitHub secrets exist for your enabled lanes.

### 8. Ship with a tagged commit

Cascade reads the **start** of the commit message:

```bash
git commit -m "[test-android-internal] polish onboarding"
git push
```

Common tags:

| Tag | Intent |
|-----|--------|
| `[test-android-internal]` | Play internal testing |
| `[test-android-closed]` | Play closed testing |
| `[test-android-open]` | Play open testing |
| `[test-ios]` | TestFlight |
| `[build-apk]` | Build APK (no store) |
| `[build-ios]` | Build IPA (no store) |
| `[release-android-partial]` | Production partial rollout (Pro) |
| `[release-android-full]` | Production full rollout (Pro) |
| `[release-ios]` | App Store release (Pro) |

Then GitHub Actions runs `.github/workflows/cascade.yml` on **your** repo. That sealed workflow asks Cascade what is allowed, then the runner executes the plan (build / store upload / email).

---

## Commands reference

| Command | What it does |
|---------|----------------|
| `cascade login` | Browser login to Cascade; saves token locally |
| `cascade init` | Create/link app + write project key + sealed workflow + secrets templates |
| `cascade doctor` | Validate local files + GitHub secrets for enabled lanes |
| `cascade --help` | Show help |

---

## Files Cascade creates

| File | Commit? | Purpose |
|------|---------|---------|
| `cascade.project.yaml` | Yes | Project key for CI |
| `.github/workflows/cascade.yml` | Yes | Sealed thin Actions workflow (do not edit) |
| `cascade.secrets.env` | **No** | Local fillable secrets (gitignored) |
| `cascade.secrets.env.example` | Yes | Empty template |
| `cascade.secrets.md` | Yes | How to push secrets with `gh` |

---

## What this package is / is not

**Is:** a thin public client that talks to the Cascade HTTP API.

**Is not:** the Cascade website, control-plane server, or private fat CI pipelines.

The sealed workflow is downloaded from your Cascade account during `cascade init` — it is not editable source in this package. Editing it breaks integrity checks (`WORKFLOW_TAMPERED`).

---

## Privacy note for maintainers

Publish **only** this package directory from a **public CLI-only** repository.
Never publish or mirror the private Cascade control-plane monorepo to pub.dev.
See `PUBLISH.md` in the source tree (omitted from the pub.dev tarball).
