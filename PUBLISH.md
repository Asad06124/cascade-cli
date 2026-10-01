# Publishing Cascade CLI (pub.dev) — keep the panel private

## Hard rules

1. **pub.dev packages are always public.** Everything you publish is world-readable.
2. **Never** set `repository:` / `homepage:` in `pubspec.yaml` to the **private**
   control-plane monorepo (the Next.js panel, `src/`, `data/`, fat workflows, etc.).
3. **Never** run `dart pub publish` from the monorepo root.
4. Publish from a **separate public GitHub repo** that contains **only** this folder’s
   contents (or a clean mirror of `packages/cascade`).

## Safe split

| Stays private (this monorepo) | May be public (CLI repo / pub.dev) |
|-------------------------------|-------------------------------------|
| `src/` Next.js panel + API | `bin/`, `lib/` CLI client |
| `data/`, `.env*`, secrets | README describing `login` / `init` / `doctor` |
| `templates/`, fat `.github/workflows/flutter-cicd.yml` | Nothing that embeds private runners |
| `android/`, `ios/` install kits used by internal scripts | — |
| DB schema, OTP, email, auth secrets | Public API paths the CLI already calls |

The sealed workflow is **served by the control plane** on `cascade init`.
Do **not** copy private templates into the public CLI repo “for convenience.”

## Recommended flow

1. Create public repo e.g. `Asad06124/cascade-cli` (CLI only).
2. Sync **only** `packages/cascade/**` into that repo (script or `git subtree` / sparse checkout).
3. Update `pubspec.yaml` `repository:` / `issue_tracker:` to that public URL.
4. From the public clone: `dart pub publish --dry-run`, then `dart pub publish`.
5. Keep this monorepo private; panel deploys from here only.

## Dry-run checklist

- [ ] No `.env`, keystores, `data/`, or panel `src/` in the publish tarball
- [ ] `dart pub publish --dry-run` file list is CLI-only
- [ ] `repository` does not point at a private URL
- [ ] Default API host is production (`https://cascade.dev`) when no local panel is running; localhost is only used via auto-detect or override
