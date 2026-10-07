## 0.1.20

- Stop `cascade init` from re-escaping `PLAY_SERVICE_ACCOUNT_JSON` (that made the Play JSON look “modified” and then fail to parse).
- Recover previously over-escaped Play JSON on `cascade match`.
- Report package version `0.1.20` from `--version`.

## 0.1.19

- Accept pasted multiline `PLAY_SERVICE_ACCOUNT_JSON` in `cascade.secrets.env` and keep JSON `\n` escapes intact so automatic Android status setup can parse the service account.
- PEM and other non-JSON secret values still expand escaped newlines as before.

## 0.1.18

- Configure separate Android and iOS automatic status credentials through authenticated `cascade match` when the deployment supports it; build and signing secrets continue to upload to GitHub.
- Reuse unchanged status credentials, validate replacements before activation, and keep provider setup independent.
- Report automatic status setup in `cascade doctor` without displaying credentials or internal identifiers.
- Preserve explicit API overrides and workflow 2.2.0 compatibility. Requires the compatible control plane before publication.

## 0.1.17

- Generate both current workflow 2.2 files from the authenticated Cascade server; reject incompatible responses before writing project files.
- Repair missing workflow markers with init, preserving local secret values and backing up previous Cascade workflows.
- Fix UTF-8 string decoding, including workflow marker recognition and corrupted terminal symbols.
- Add --version and ASCII OK/WARN/ERROR doctor output, workflow version/companion checks, lane requirements and actionable errors.
- Use the production endpoint by default; local endpoints require an explicit override.
- Upload filled release secrets independently; Apple signing requires match --ios. Secret values are passed to GitHub CLI through stdin.
- Support owner-authenticated local APK email with send.
- Clarify GitHub lifecycle refresh, 20-minute status eligibility and safe failure explanations. Provider direct status and vault ingestion remain unavailable in production.

Earlier entries describe historical behavior.

## 0.1.16

- `cascade match` now pushes every filled value from `cascade.secrets.env` to GitHub Actions (no manual `gh secret set`).
- iOS match runs when Apple API keys are set; otherwise match skips signing and only pushes.
- Docs: flow is gather → env file → `cascade match`.

## 0.1.15

- Docs: secrets flow = gather (site guide) → fill `cascade.secrets.env` → `cascade match` (iOS) → push opaque slots.

## 0.1.14

- `cascade match`: hide fastlane/OpenSSL stack traces; show a short fix message when the `.p8` key is invalid (`invalid curve name`) or match fails.

## 0.1.13

- `cascade match`: build `.p8` from `APP_STORE_CONNECT_API_KEY` env contents (`\n` unescaped); stop failing openssl gate on valid PEM text.

## 0.1.12

- `cascade init` always refreshes sealed files + secrets guide; merges `cascade.secrets.env` (keeps values, adds missing keys) instead of leaving it unchanged.

## 0.1.11

- `cascade init` always sends Android package + iOS bundle (even when refreshing an existing seal) so the dashboard stays in sync after ID changes.

## 0.1.10

- `cascade match`: normalize/validate AuthKey `.p8` PEM; prefer Fastfile + key_filepath; clearer error if key is malformed (fixes `invalid curve name` from bad env content).

## 0.1.9

- Fix `cascade match` ASC auth: generate Fastfile lane + `.p8` filepath (fastlane requires api_key Hash, not p8 string env).

## 0.1.8

- Fix `cascade match`: pass App Store Connect API key via JSON `--api_key_path` (fastlane rejected p8 string as `api_key`).

## 0.1.7

- `cascade match` is non-interactive: creates private `cascade-certs-*` GitHub repo, writes Matchfile (git), generates `MATCH_PASSWORD` + `MATCH_GIT_AUTH`, runs `fastlane match appstore`.

## 0.1.6

- Add `cascade match` — load App Store Connect API keys from `cascade.secrets.env` and run fastlane match (aliases: `fastlane`, `fastline`).

## 0.1.5

- Add `cascade logout` to switch accounts (clears `~/.cascade/config.json`).
- Document iOS: Account Holder API access, `brew install fastlane`, match with API key.

## 0.1.4

- Rewrite pub.dev README: clearer product story, quick start, tables, flow diagram, troubleshooting, Support.
- Document secrets path: fill `cascade.secrets.env`, then `gh secret set` from `cascade.secrets.md`.

## 0.1.3

- Expand pub.dev README: full usage guide and Support us section.

## 0.1.2

- Ignore dead localhost in saved config; fall back to production.

## 0.1.1

- Opaque client: login, init, doctor.

## 0.1.0

- Initial release.

## Unreleased — Phase 2E

Initialization acknowledges companion-workflow support and writes the reusable read-only lifecycle workflow alongside the sealed main workflow. Commit both generated workflows. No package publication performed.

## Unreleased — Phase 2E.1

Optional GitHub App connection enables automatic lifecycle refresh dispatch. Normal CLI initialization, CI/releases and manual refresh stay compatible. See the GitHub refresh dispatch guide; no package publication performed.
