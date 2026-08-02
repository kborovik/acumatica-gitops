# LAB5 Electronics Inc. — Acumatica demo tenant seed

Git-versioned Acumatica configuration for **LAB5 Electronics Inc.**, an electronics manufacturer demo company used for the [lab5.ca](https://lab5.ca) **Demo Tenant Factory** sales pitch.

Rebuild from empty to company, masters, and linked transaction history
(seed capital, buy components, assemble products, sell, invoice, collect).
Not a production ERP.

Requires the [`acu` CLI](https://github.com/kborovik/acumatica-cli) (PyPI: `acumatica-cli`)
**≥ 0.23.1**.

## Layout

| Path | Role |
|------|------|
| `config/bootstrap/` | Company, features, credit terms (Bootstrap REST package is CLI SoT 1.4.0+) |
| `config/baseline/` | GL foundation (COA, ledger, subaccounts, UOMs) |
| `config/setup/` | Financial year, master calendar, open periods |
| `config/master/` | Inventory, warehouse, items, vendors, customers, module prefs, roles, users |
| `config/views/` | Observation defs for `acu state` (trial balance); not seed |
| `scenario/10-seed-capital.yaml` | Once-class owner capital JE (CLI skip-if-present when present) |
| `scenario/20-buy.yaml` | Additive component PO to receipt to bill to AP pay (four vendors) |
| `scenario/30-build.yaml` | Additive kit assembly (parts to GW-EDGE / CELL / RAIL) |
| `scenario/40-sell.yaml` | Additive SO to ship to invoice (three customers; no AR pay) |
| `scenario/45-collect.yaml` | Additive mixed AR collect: ACMEMFG full, NORTHGRID partial, AGRISENSE open |
| `state/` | Committed derived observations (`acu state` from `config/views/`) |
| `overlays/` | Optional Default-half rewrites (compose after trunk via path args) |
| `reports/` | Multi-host matrix evidence templates and run notes |
| `demo/` | Everything for the sales video: shooting script, screen↔seed map, scripted GUI walk |
| `SPEC.md` | Spec-driven design (goal, invariants, tasks) |
| `target.yaml` | Verified ERP build + Default API pin (`erp`, `default_api`) |
| `.env` | Credentials (local only — never commit) |

## Quick rebuild

**Start from a brand-new empty tenant.**
Do not apply onto a half-configured company.

```sh
# 1. Credentials (local .env)
# ACU_BASE_URL, ACU_TENANT, ACU_USER, ACU_PASSWORD
# ACU_SSH optional (defaults to Administrator@<host> when unset;
# set blank ACU_SSH= for hosted / no-SSH)
# Default API pin = target.yaml default_api (not an env key)

acu config check

# 2. Empty tenant + bootstrap (SSH control plane)
# create also publishes AcuBootstrap — ready for apply
acu tenant create --login TENANT
# Hosted / tenant already exists: acu bootstrap
# Offline UI fallback: acu bootstrap --export AcuBootstrap.zip

# 3. Seed configuration (config/ umbrella; order = bootstrap → baseline → setup → master)
acu apply config/
# bare `acu apply` also prefers config/ when those trees exist

# 4. Linked history for the pitch (once capital, then buy/build/sell/collect)
acu run scenario/
# bare `acu run` defaults to scenario/

# 5. Prove no drift on seeded config
acu diff config/
# bare `acu diff` also prefers config/

# 6. Capture derived state (trial balance → state/)
acu state
```

### Once vs additive scenarios

| File | Class | Warm re-run |
|------|-------|-------------|
| `10-seed-capital.yaml` | **once** | CLI skips when capital JE already present; Owner Capital stays 50k (not stacked) |
| `20-buy.yaml` | additive | New component PO/receipt/bill/pay each run; part and cash deltas hold |
| `30-build.yaml` | additive | New kit assemblies each run; parts to kits deltas hold |
| `40-sell.yaml` | additive | New SO/ship/invoice pack each run; AR +4138, cash 0; deltas hold |
| `45-collect.yaml` | additive | Mixed AR: ACMEMFG full 1196, NORTHGRID partial 1000, AGRISENSE open; cash +2196 |

Primary compose: `acu apply config/` then `acu run scenario/`.

Warm capital-only gate (state must not move):

```sh
acu run scenario/10-seed-capital.yaml && acu state --assert-unchanged
```

### Other useful commands

| Command | Role |
|---------|------|
| `acu tenant list` | List tenants on the instance (SSH) |
| `acu tenant delete --login TENANT --yes` | Delete tenant + recycle app pool |
| `acu tenant recycle --yes` | Restart site app pool (free API slots / reload tenant map) |
| `acu extract` | Inverse of apply: live tenant to `config/**` seed YAML |
| `acu schema` | Dump endpoint OpenAPI into `schemas/` |
| `acu inventory ARTIFACT` | Offline: SM203520 Settings XML ZIP / `ac.exe export xml` into `inventory/` |
| `acu reconcile` | Offline: `inventory/` vs optional `config/` into `findings/` |
| `make check` | E2E matrix on all 3 lab Windows hosts (25r1 / 25r2 / 26r1): ephemeral tenant; bare `acu apply`/`run`/`diff` pin auto-compose overlays; delete per host |
| `make check HOST=25r1` | Same E2E for one matrix cell only |

### CLI floor (acumatica-cli ≥ 0.23.1)

| Capability | Why it matters here |
|------------|---------------------|
| Apply multi-error + continue | One failed PUT does not stop the tree; exit 1 with full summary (never silent partial) |
| 422 field errors | Actionable field-level REST errors on bad seed rows |
| Bootstrap package SoT **1.4.0+** | `acu bootstrap` / tenant create publish package from CLI; data-repo does **not** carry `project.xml` as seed |

Sibling CLI matrix notes: [acu-cli multi-host matrix](https://github.com/kborovik/acu-cli#multi-host-matrix-v44)
and [acu-cli#29](https://github.com/kborovik/acu-cli/issues/29).

## Pitch path

See [demo/walk.yaml](demo/walk.yaml) — the promo video's script, shot plan and
narration, and the beat-by-beat source for this path.
Short version:

1. Company **LAB5 Electronics Inc.**
2. Bank funded (Owner Capital to Checking 10100)
3. Components at **WH01** after the buy; four vendor bills paid by WIRE
4. Kit assembly (parts to finished gateways)
5. Sales order, shipment, invoice (three customers; invoices left Open)
6. Mixed AR collect: ACMEMFG COD full, NORTHGRID partial, AGRISENSE open
7. Cold ending: cash **48159**, AR **1942** (not fully collected)

The walk itself is scripted — see [demo/](demo/README.md).
One command captures the
full product: `make demo` ensures CLI replay logs, drives every beat, and writes
stills plus `demo/out/video/walk.webm`.
Cold reshoot: `make demo-clean && make demo`.

## Demo users (identity seed only)

`config/master/90-roles.yaml` seeds custom role **SO Admin**.
`config/master/91-users.yaml` seeds demo users `soadmin`, `apadmin`, `aradmin`
(passwords are demo-only and may be committed per §C).

**Role membership is not durable on Bootstrap cold PUT** (live GET returns
empty `Roles: []` after apply — §B.3). Treat User/Role YAML as **identity
seed only**: create the logins; assign SO/AP/AR Admin membership in the UI
(or a later durable path) when the pitch needs those screens.

## Non-goals

- Production cutover / opening balances from a legacy system
- Multi-industry catalog (this seed is IoT gateway manufacturing / kit assembly)
- Secrets or host credentials in Git (`V8`) — demo user passwords are the
  documented exception for local pitch logins

## Target matrix (trunk + pins + overlays)

Multi-version support is **one trunk seed** plus per-host pins and optional
overlays — **not** long-running release branches as product lines
(`acu-25r1` / `acu-25r2` / `acu-26r1` are not parallel product trees).

**Trunk branch:** `acu-26r1` is the default trunk today (origin/HEAD).
Rename to `main` is deferred until after overlay path is green on lab hosts;
until then, open work lands on `acu-26r1`.

**Retire** long-running `acu-25r1` / `acu-25r2` after trunk+overlay is green
on lab — plan and commands: [reports/retire-release-branches.md](reports/retire-release-branches.md).
Do not treat those branches as product lines.

| Piece | Role |
|-------|------|
| Trunk seed | Canonical `config/` + `scenario/` (newest supported matrix) |
| `target.yaml` | Host pin: `erp` + `default_api` from live `acu config check` |
| `overlays/<default-half>/` | Surgical rewrites keyed by Default API half (e.g. `default-24.200.001`) |
| `reports/` | Matrix evidence: seed SHA × host × pin × overlay × outcomes |

### Pins

See `target.yaml` on this host (`erp` build + `default_api`).
`acu` resolves the contract API version from `--api-version`, else `default_api`,
else the CLI code default — not from `.env`.
Pins must be **host-true** from live check (invalid Default halves forbidden).

### Overlay compose

Overlays live under `overlays/default-<default_api>/`. With host-true
`target.yaml`, **bare** commands auto-compose the pin overlay (acu-cli ≥
next release / editable with V44 pin auto). Explicit path args disable auto.

```sh
# Pin default_api: 24.200.001 → overlays/default-24.200.001/
acu apply
acu run
acu diff

# Explicit (no auto) — later path wins same keys
acu apply config/ overlays/default-24.200.001/
```
