# Claude Code Skills

## Release Skills

A GitHub release is **automatically created** whenever files under `claude.symlink/skills/` are pushed to `main`.

The workflow auto-generates a timestamped tag (e.g. `skill-20260329-143000`), zips every skill folder that contains a `SKILL.md`, and attaches them to the release.

You can also trigger manually from the **Actions** tab via `workflow_dispatch`.
