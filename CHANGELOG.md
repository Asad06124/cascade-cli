## 0.1.0

- Initial public CLI (`cascade_cli` on pub.dev; binary `cascade`): `login`, `init`, `doctor`.
- Thin client only; sealed workflow is fetched from the Cascade control plane.
- `cascade login` auto-detects a local control plane; project YAML is `project_key` only.
- Init writes secrets template + `gh` guide; doctor verifies GitHub secrets.
