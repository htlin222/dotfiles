# Setup

How to install these dotfiles — both interactively (a human at a terminal) and
non-interactively (CI, containers, or an agent driving the shell).

All entry points live in `start/` and share the TUI library in `start/lib/`.
They are **idempotent**: re-running is safe and only does what's missing.

## TL;DR

```sh
git clone <repo> ~/.dotfiles && cd ~/.dotfiles

# Interactive, full machine setup (prompts on conflicts):
start/bootstrap

# Just (re)link the dotfiles, no package installs:
start/link_dotfiles

# Install packages: brew bundle + every topic install.sh:
start/install
```

## Entry points

| Script             | What it does                                                              |
| ------------------ | ------------------------------------------------------------------------- |
| `bootstrap`        | Full setup: Homebrew → oh-my-zsh (`--unattended`) → symlinks → macOS deps |
| `link_dotfiles`    | Symlinks only — every `*.symlink` (maxdepth 2) → `~/.<name>`              |
| `install`          | `brew bundle` (streamed) + every topic `install.sh` (failures don't abort)|
| `setup_linux.sh`   | Pop!_OS/apt: packages, oh-my-zsh + plugins, TPM, link list, chsh          |

A typical fresh macOS install is `start/bootstrap` then `start/install`.

## Non-interactive mode (CI / agents)

The **only** interactive prompt is the per-file conflict prompt in
`link_file` (skip / overwrite / backup). Non-interactive mode replaces it with
a fixed policy and never reads from the terminal.

It turns on automatically when there's no TTY — so piping output, running in CI,
or driving the script from an agent already runs unattended (and avoids a
`read </dev/tty` failure aborting the run under `set -e`). You can also force it
explicitly:

```sh
# Force unattended; default conflict policy = backup (non-destructive):
start/bootstrap --non-interactive        # or -y
start/link_dotfiles -y

# Pick the conflict policy explicitly (each implies non-interactive):
start/link_dotfiles --backup             # move existing aside to *.backup (default)
start/link_dotfiles --overwrite          # replace existing files/links
start/link_dotfiles --skip               # keep existing, skip the link

# Same via environment (useful when you can't add flags):
DOTFILES_NONINTERACTIVE=1 start/bootstrap
DOTFILES_ON_CONFLICT=overwrite start/link_dotfiles
```

`bootstrap -y` also passes `NONINTERACTIVE=1` to the Homebrew installer so it
won't pause on "Press RETURN to continue".

### Agent-friendly one-liner

```sh
cd ~/.dotfiles && DOTFILES_NONINTERACTIVE=1 start/link_dotfiles
```

For a full unattended machine setup:

```sh
cd ~/.dotfiles && start/bootstrap --non-interactive && start/install -y
```

### Flags & env reference

| Flag                       | Effect                                              |
| -------------------------- | --------------------------------------------------- |
| `-y`, `--non-interactive`  | Never prompt; apply the default conflict policy     |
| `--backup`                 | Conflict → move existing to `*.backup` (default)    |
| `--overwrite`              | Conflict → replace existing file/link               |
| `--skip`                   | Conflict → keep existing, don't link                |
| `-h`, `--help`             | Show usage                                          |

| Env var                                  | Effect                              |
| ---------------------------------------- | ----------------------------------- |
| `DOTFILES_NONINTERACTIVE=1`              | Force non-interactive mode          |
| `DOTFILES_ON_CONFLICT=backup\|overwrite\|skip` | Default policy when unattended |
| `NONINTERACTIVE=1` (bootstrap)           | Skip the Homebrew installer's pause |
| `NO_COLOR=1`, `TERM=dumb`                | Disable colors/spinner (TUI degrades) |

> `setup_linux.sh` is always unattended (conflicts are backed up). `sudo apt`
> and the Homebrew/macOS installers may still prompt for a password — that's the
> OS, not these scripts.

## What gets linked

`install_dotfiles` (in `lib/links.sh`) finds every `*.symlink` at depth ≤ 2
under the repo and links it to `~/.<basename>`:

- `zsh/zshrc.symlink` → `~/.zshrc`
- `claude.symlink/` → `~/.claude` (whole directory)
- …and so on for each topic.

Re-running relinks only what's missing; an `-ef` guard prevents the repo from
being symlinked onto itself.

## Verifying changes to these scripts

These run on a fresh macOS under stock **Bash 3.2**, before Homebrew installs a
newer bash. Before committing changes to `start/`:

```sh
bash -n start/bootstrap start/install start/link_dotfiles start/setup_linux.sh start/lib/*.sh
shellcheck --severity=warning start/* start/lib/*.sh

# Sandbox a non-interactive link run against a throwaway $HOME:
tmp=$(mktemp -d)
HOME="$tmp" DOTFILES_NONINTERACTIVE=1 /bin/bash start/link_dotfiles
```
