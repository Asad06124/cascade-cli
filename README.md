# cascade_cli

Official CLI for [Cascade](https://cascadeci.com) — sealed Flutter CI without putting store credentials in GitHub Actions YAML.

Package: [`cascade_cli`](https://pub.dev/packages/cascade_cli) · Command: `cascade` · Site: [cascadeci.com](https://cascadeci.com)

```bash
dart pub global activate cascade_cli
cascade login
cascade init
cascade doctor
```

---

## What it does

1. **Login** — device approval against cascadeci.com (token stored locally).
2. **Init** — links your Flutter app, writes an opaque project seal, a sealed GitHub Actions workflow, and an opaque secrets guide.
3. **Doctor** — checks login, project files, and basic readiness.

Lanes (Play tracks, TestFlight, release modes) are toggled in the [dashboard](https://cascadeci.com). Closed lanes stay closed at plan time.

---

## Requirements

| Need | Why |
|------|-----|
| Dart SDK ≥ 3.5 (or Flutter SDK) | Run the CLI |
| Account on [cascadeci.com](https://cascadeci.com) | Login + app linking |
| Flutter app root | Where you run `cascade init` |
| GitHub repo + Actions | Hosts the sealed workflow |
| [`gh`](https://cli.github.com/) CLI | Push opaque secret slots |

---

## Install

```bash
dart pub global activate cascade_cli
```

Ensure the pub global bin directory is on your `PATH` (Dart prints the path after activate). Then:

```bash
cascade --help
```

Upgrade later with the same activate command.

---

## Usage

### 1. Create an account

Sign up at [cascadeci.com](https://cascadeci.com) with a real email and complete OTP login in the browser. You do **not** need to create an app in the dashboard first — `cascade init` creates or links it.

### 2. Login

```bash
cascade login
```

Opens (or prints) a device-approval URL. After you approve in the browser, the CLI stores a token at:

```text
~/.cascade/config.json
```

Never commit that file. Re-run `cascade login` if the token expires or you switch machines.

### 3. Init (Flutter app root)

```bash
cd /path/to/your_flutter_app
cascade init
```

Typical first run:

- Detects `pubspec.yaml` / package name
- Creates or reuses a matching Cascade app for your account
- Writes project + workflow + secrets scaffolding

**Flags**

| Flag | Meaning |
|------|---------|
| `--new` | Force a brand-new Cascade app (skip reuse by package) |
| `--pick` | Interactively pick an existing app when several match |
| `--name MyApp` | Display name for a newly created app |

Examples:

```bash
cascade init
cascade init --name Roomround
cascade init --pick
cascade init --new --name ExperimentalBuild
```

### 4. Secrets (opaque slots)

Init writes a local env draft and a markdown guide with **opaque slot names** (not plain GitHub secret key names in docs meant for reverse-engineering).

1. Fill `cascade.secrets.env` (gitignored) with your real values.
2. Follow `cascade.secrets.md` to push slots with `gh`.

```bash
gh auth login
# then follow the commands listed in cascade.secrets.md
```

Do not invent secret names — use only the slots from the guide for your project.

### 5. Commit what should be public

```bash
git add cascade.project.yaml \
  .github/workflows/cascade.yml \
  cascade.secrets.env.example \
  cascade.secrets.md
git commit -m "Add Cascade CI"
git push
```

| File | Commit? |
|------|---------|
| `cascade.project.yaml` | Yes |
| `.github/workflows/cascade.yml` | Yes (sealed — do not hand-edit) |
| `cascade.secrets.env.example` | Yes |
| `cascade.secrets.md` | Yes |
| `cascade.secrets.env` | **No** |
| `~/.cascade/config.json` | **No** |

### 6. Doctor

```bash
cascade doctor
```

Use this after login/init, or when CI misbehaves, to verify local config and project files.

### 7. Trigger builds with git tags

Push a tag (optionally with an intent suffix). Exact tag rules live in your dashboard / secrets guide; common intents:

| Tag intent | Typical outcome |
|------------|-----------------|
| *(plain version tag)* | APK + email delivery |
| `[test-android-internal]` | Play internal testing |
| `[test-android-closed]` | Play closed testing |
| `[test-android-open]` | Play open testing |
| `[test-ios]` | TestFlight |
| `[build-apk]` | APK only |
| `[build-ios]` | IPA only |
| `[release-android-partial]` | Production partial rollout |
| `[release-android-full]` | Production full rollout |
| `[release-ios]` | App Store |

Enable the matching lanes in the dashboard before you expect those paths to run.

---

## Commands (quick reference)

```text
cascade login          Authenticate with cascadeci.com
cascade init [flags]   Seal project + write workflow / secrets guide
cascade doctor         Local health check
cascade --help         Show help
```

---

## Tips

- Prefer production (`https://cascadeci.com`). If an old config pointed at a dead localhost API, delete `~/.cascade/config.json` and run `cascade login` again — recent CLI versions ignore dead localhost and fall back to production.
- Do not edit the sealed workflow by hand; re-run init or use the dashboard when features change.
- Keep `gh` authenticated on the machine where you push secret slots.
- For product docs and onboarding, see [cascadeci.com/guide](https://cascadeci.com/guide) and [cascadeci.com/docs](https://cascadeci.com/docs).

---

## Support us

Cascade and this CLI are maintained independently. Hosting the control plane, artifact delivery, email, and ongoing package upkeep have real costs — even when the CLI on pub.dev looks “just a small Dart package.”

If Cascade helps you ship, and you want it to stay maintained, you can support the project:

- **Contact / donate:** [cascadeci.com/contact](https://cascadeci.com/contact) — mention **“Support Cascade”** or **donate** in the message
- **Email:** [cascadeciofficial@gmail.com](mailto:cascadeciofficial@gmail.com?subject=Support%20Cascade)

Any amount helps keep the package and service running for Flutter teams who rely on it. Thank you.

---

## Links

- Site: [cascadeci.com](https://cascadeci.com)
- pub.dev: [cascade_cli](https://pub.dev/packages/cascade_cli)
- Issues: [GitHub issues](https://github.com/Asad06124/cascade-cli/issues)
- Contact: [cascadeci.com/contact](https://cascadeci.com/contact)

## License

MIT
