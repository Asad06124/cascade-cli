# Cascade CLI

Cascade builds, signs, uploads and submits Flutter releases through GitHub Actions. The dashboard shows separate execution and store status, safe failure explanations, release history and retained artifacts. Full build logs remain in GitHub Actions.

Package: `cascade_cli`. Executable: `cascade`. Candidate version: 0.1.17, compatible with workflow 2.2.0. The matching control plane must be deployed before the new package is published.

## Install and prerequisites

Use Dart 3.5 or later, or Flutter with a compatible Dart SDK. Create an account at [Cascade](https://cascadeci.com/register), install [GitHub CLI](https://cli.github.com/), and authenticate it with `gh auth login`. Init requires a GitHub repository where you have write access; it binds release execution to that repository's default branch. Pull requests run validation only.

```sh
dart pub global activate cascade_cli
cascade --version
cascade --help
```

Add the pub global bin directory to PATH if Dart requests it. Upgrade with the same activate command. Cascade uses https://cascadeci.com by default.

## First project

```sh
cascade login
cd /path/to/your_flutter_app
cascade init
# Fill cascade.secrets.env with values for the delivery lanes you want.
cascade match
# For Apple signing provisioning only, explicitly run:
# cascade match --ios
```

Enable the desired delivery lanes in [App settings](https://cascadeci.com/dashboard), then:

```sh
cascade doctor
git add cascade.project.yaml .github/workflows/cascade.yml .github/workflows/cascade-refresh.yml cascade.secrets.env.example cascade.secrets.md .gitignore
git commit -m "[build-apk] Configure Cascade"
git push
```

Doctor resolves required secrets from the enabled lanes, so enable those lanes before the final check. Watch the exact run in GitHub Actions and the App Release Control Center. Do not commit `cascade.secrets.env`, signing keys or `~/.cascade/config.json`.

## Commands

- `cascade login`: approve a device login in the browser. `cascade logout` clears the saved CLI session.
- `cascade init`: create or link the App, bind the repository, and obtain current setup files from the authenticated server.
- `cascade init --pick`: choose an existing App. `--new` creates a new App; `--name MyApp` sets the display name.
- `cascade match`: push filled release/signing/notification values from the local secrets file into opaque GitHub secret slots using the generated guide's mapping. Unused values may stay empty. It does not upload status credentials to Cascade.
- `cascade match --ios`: explicitly provision Apple signing with fastlane, then upload the signing configuration. Existing secret uploads are attempted before provisioning. Install fastlane on a Mac and configure the Apple API key, Match repository and team ID first.
- `cascade doctor`: check login, Flutter project, project seal, both workflows, supported contract, server-issued workflow checksum, enabled lane requirements, local values and GitHub slot presence. It prints ASCII OK/WARN/ERROR and exits nonzero when required setup cannot be verified.
- `cascade send --app APP_ID --file app-release.apk --to you@example.com`: deliver an existing APK through the enabled Email lane using your CLI session. This route does not require a GitHub workflow or store credentials.
- `cascade --version` or `cascade version`: show package and workflow versions. `cascade --help` shows usage.

## Files and upgrades

Init writes `cascade.project.yaml`, `.github/workflows/cascade.yml`, `.github/workflows/cascade-refresh.yml`, `cascade.secrets.env.example`, `cascade.secrets.md` and a gitignored `cascade.secrets.env`.

Both workflows are wholly Cascade-owned, sealed files. Init repairs missing markers and upgrades the contract by regenerating them from the server. It saves previous copies as `.pre-cascade-init.bak`; review those backups for custom changes and keep independent custom jobs in separate workflow files. Other workflow files are untouched. Init preserves existing local secret values and adds missing keys. Each init rotates the project seal and issued workflow checksum, so idempotence means safe repeat setup rather than identical bytes. Commit the new project seal and both workflows together; avoid running init during an active release.

The package does not bundle an older workflow template. The authenticated server returns version 2.2.0, a checksum and the companion lifecycle workflow; incompatible responses are rejected before files are written. The sealed bootstrap retrieves the current server-delivered runner bundle, including structured failure and release-result support. No monorepo checkout is needed by package users.

## Choose only the credentials you need

Use the generated `cascade.secrets.md` and [public secrets guide](https://cascadeci.com/docs#secrets) for the current slot contract. Do not invent or rename slots.

- APK/Android release builds require Android keystore, alias and passwords.
- Play uploads additionally require the Play service account JSON and an existing configured application. Closed testing also requires `PLAY_CLOSED_TRACK` naming an existing closed track.
- Email requires notification recipients; the Cascade operator configures the email service.
- Signed iOS builds, TestFlight and App Store submission require Apple API credentials and Match signing configuration, including `MATCH_GIT_URL` and `IOS_TEAM_ID`. `IOS_SCHEME` defaults to Runner.
- App Store submission additionally requires truthful `IOS_SUBMISSION_INFORMATION` and a complete listing. Submission uses manual release and does not fall back to TestFlight.

Plain match does not start Apple provisioning merely because some Apple values are filled. Successful uploads remain if another upload fails; correct the reported names and rerun. Credentials stay in local configuration and GitHub Actions, never the provider-status vault.

## Release intents

Use a leading intent in the commit message with the corresponding enabled lane:

```text
[build-apk]                       APK only
[build-ios]                       signed IPA artifact
[test-android-internal]           Play internal testing
[test-android-closed]             named Play closed testing
[test-android-open]               Play open testing
[test-ios]                        internal TestFlight
[release-android-partial]         production partial rollout
[release-android-full]            production full rollout
[release-ios]                     App Store review submission
```

No intent defaults to APK and notification when the appropriate lanes are enabled. Disabled lanes are denied by the server's job plan. Upload or approval alone does not establish Live status.

## Status and failure explanations

Automatic status sync uses the Cascade GitHub workflow. Commit both workflows to the bound default branch and enable automatic status sync in App settings when the operator has configured the Cascade GitHub App. Manual scoped dispatch remains available when automatic dispatch is unavailable; use the command shown by the dashboard.

Persisted status renders immediately. Android and iOS are evaluated independently. An automatic check becomes eligible 20 minutes after the last successful exact-current check, or when no successful check exists. Reloads inside that window do not start another check. Historical releases do not auto-refresh. Failures, backoff and provider/GitHub limits can delay retries; this is not constant polling or a background scan.

Build Failed, Signing Failed, Upload Failed and Submission Failed describe execution outcomes. Processing Failed, In Review, Rejected, Live and Status refresh failed describe separate lifecycle or refresh outcomes. Cascade shows safe catalog reasons when reliable structured evidence exists; an opaque failure may have no precise root cause. Open GitHub Actions for full logs.

Cascade shows reviewer/rejection details only when official structured evidence exposes them. The current Google and Apple lifecycle readers do not expose detailed reviewer feedback. Open Google Play Console or App Store Connect for that detail.

Direct Google/Apple status sync and provider-status credential uploads are unavailable in production. They are not part of this getting-started flow.

## Troubleshooting

- Missing markers, companion workflow, invalid project seal or checksum mismatch: run `cascade init`, then commit the project file and both workflows.
- Unsupported workflow version: run `dart pub global activate cascade_cli`, then `cascade init` against the matching server.
- Missing/expired login: run `cascade login`.
- Missing GitHub CLI or authentication: install gh and run `gh auth login`.
- Values filled locally but missing on GitHub: run `cascade match`.
- Missing Apple signing setup: configure the listed Apple/Match values, then run `cascade match --ios` on a Mac.
- Lane denied: enable the desired lane in App settings and rerun doctor before pushing.
- Server unavailable: check connectivity and the configured API endpoint, then retry.

## Links and license

[Guide](https://cascadeci.com/guide) · [Docs](https://cascadeci.com/docs) · [Support](https://cascadeci.com/support) · [Contact](https://cascadeci.com/contact) · [Package](https://pub.dev/packages/cascade_cli) · [Issues](https://github.com/Asad06124/cascade-cli/issues)

Cascade is free. Support helps cover control-plane maintenance, email and storage. MIT license; see LICENSE.
