---
name: cf-gate
description: >-
  Put a website behind a Cloudflare Access (Zero Trust) login gate, or remove
  one, entirely from the CLI — no dashboard GUI. Use when the user wants to
  password/email-protect a hostname, gate a Cloudflare Pages or Workers site,
  restrict a site to specific emails, set up Zero Trust Access, or asks about
  "cf-gate". Manages Access applications and allow-email policies via the
  Cloudflare API using a token in the skill's .env. Note: wrangler does NOT
  manage Access — this uses the Cloudflare REST API directly.
---

# cf-gate

Headlessly create/remove Cloudflare **Access** (Zero Trust) gates that require
an email login before a site renders. Wraps the Cloudflare API in
`scripts/cf-gate.sh`; credentials come from a `.env` next to it.

## Setup (once)

1. Copy `.env.example` → `.env` in this skill's base directory, `chmod 600 .env`,
   and fill `CF_API_TOKEN` + `CF_ACCOUNT_ID`. The `.env.example` lists the exact
   token scopes. Minting that token in the dashboard is the **only** GUI step.
2. Verify: run the `whoami` command below. It must print `credentials valid`.

`.env` is gitignored — never commit it.

## Usage

Resolve the script from the injected **"Base directory for this skill"** value:

```bash
SKILL="<base directory for this skill>"
bash "$SKILL/scripts/cf-gate.sh" <command> [args]
```

| Command | Effect |
|---------|--------|
| `whoami` | Verify the token works against the account. |
| `gate <host> [email\|@domain ...]` | Create/update an allow-email gate on `<host>`. Idempotent. Emails default to `CF_GATE_EMAILS`. |
| `ungate <host>` | Remove the gate on `<host>`. |
| `list` | List every Access app (id, domain, name). |
| `status <host>` | Show the gate's policies (decision + allowed emails). |
| `pages-domain <project> <host>` | Attach a custom domain to a Pages project (so the gated host resolves). |

`@example.com` allows any address on that domain; a bare address allows just
that person. Re-running `gate` on an existing host updates it in place (no
duplicate apps).

## Typical end-to-end flow (e.g. gating a Pages site on a custom domain)

```bash
SKILL="<base directory for this skill>"
G() { bash "$SKILL/scripts/cf-gate.sh" "$@"; }

G whoami                                                     # sanity check
G pages-domain polish-prompt-reports reports.hsiehting.com   # custom domain → Pages
G gate reports.hsiehting.com                                 # gate it to CF_GATE_EMAILS
G status reports.hsiehting.com                               # confirm the policy
```

After gating, visiting the host shows a Cloudflare login; an allowed email
receives a one-time PIN (or uses the configured IdP), then reaches the site.

## Notes & gotchas

- **The host must be a Cloudflare-proxied zone or a `*.pages.dev` domain.** For
  a custom domain like `reports.hsiehting.com`, `pages-domain` both registers it
  with the Pages project and creates the proxied CNAME → `<project>.pages.dev`.
  The CNAME step needs the token to have **Zone → DNS → Edit** on that zone; if
  it doesn't, the command degrades gracefully and tells you to add the scope.
- **One Access app per hostname.** For a catch-all, gate `*.hsiehting.com` as
  its own host string (the wildcard hostname must be routable).
- **Removing the gate ≠ taking the site down.** `ungate` only drops the Access
  policy; the site itself stays served by Pages/Workers/DNS.
- Errors print the Cloudflare error `[code] message`; an auth error usually
  means the token is missing the `Access: Apps and Policies: Edit` scope.
