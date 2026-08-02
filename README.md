# LAB5 Electronics Inc. — Acumatica demo tenant seed

Git-versioned Acumatica configuration for **LAB5 Electronics Inc.**, an electronics manufacturer demo company used for the [lab5.ca](https://lab5.ca) **Demo Tenant Factory** sales pitch.

Rebuild from empty to company, masters, and linked transaction history
(seed capital, buy components, assemble products, sell, invoice, collect).
Not a production ERP.

Requires the [`acu` CLI](https://github.com/kborovik/acumatica-cli) (PyPI: `acumatica-cli`)
**≥ 0.24.0**.

## Layout

| Path | Role |
|------|------|
| `matrix.yaml` | Multi-host pin+where: cells `id`+`erp`+`default_api`+`base_url` (V27); `--cell` selects |
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
| `overlays/` | Optional Default-half rewrites (`default-<default_api>/`); bare apply/run/diff auto-compose |
| `reports/` | Multi-host matrix evidence templates and run notes |
| `demo/` | Everything for the sales video: shooting script, screen↔seed map, scripted GUI walk |
| `SPEC.md` | Spec-driven design (goal, invariants, tasks) |
| `.env` | Secrets only (local — never commit); pin+where live in `matrix.yaml` |

## Quick rebuild

**Start from a brand-new empty tenant.**
Do not apply onto a half-configured company.

```sh
# 1. Credentials (local .env): ACU_TENANT, ACU_USER, ACU_PASSWORD
#    Default API pin + REST where = matrix.yaml cell (default_api + base_url)
#    Optional ACU_BASE_URL overrides active cell where (ad-hoc probes)
#    ACU_SSH optional (defaults to Administrator@<host> when unset;
#    set blank ACU_SSH= for hosted / no-SSH)
#    First cell is default; --cell id selects another

acu config check
# acu --cell 25r1 config check

# 2. Empty tenant + bootstrap (SSH control plane)
# create also publishes AcuBootstrap — ready for apply
acu tenant create --login TENANT
# Hosted / tenant already exists: acu bootstrap
# Offline UI fallback: acu bootstrap --export AcuBootstrap.zip

# 3. Seed configuration (config/ umbrella; order = bootstrap → baseline → setup → master)
# bare apply/run/diff auto-compose overlays/default-<default_api>/ when present
acu apply

# 4. Linked history for the pitch (once capital, then buy/build/sell/collect)
acu run

# 5. Prove no drift on seeded config
acu diff

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
| `acu check --all --yes` | Cold lifecycle every `matrix.yaml` cell (delete→create→apply→run→diff→delete) |
| `make check` | Same as `acu check --all` for lab matrix (tenant `GITOPS` by default) |
| `make check HOST=25r1` | Same E2E for one matrix cell only (`acu --cell 25r1 check`) |

### CLI floor (acumatica-cli ≥ 0.24.0)

| Capability | Why it matters here |
|------------|---------------------|
| `matrix.yaml` pin+where | Multi-host cells (`id`+`erp`+`default_api`+`base_url`); retires `target.yaml` |
| Bare pin auto-compose | `acu apply`/`run`/`diff` append/replace from `overlays/default-<api>/` |
| `acu check` lifecycle | Cold matrix E2E per cell (`--all` / `--cell`) |
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

Multi-version support is **one trunk seed** plus committed `matrix.yaml` cells
and optional overlays — **not** long-running release branches as product lines
(`acu-25r1` / `acu-25r2` / `acu-26r1` are not parallel product trees).

**Trunk branch:** `main` (lab cells in `matrix.yaml`; default cell `26r1`).

**Retire** long-running `acu-25r1` / `acu-25r2` after trunk+overlay is green
on lab — plan and commands: [reports/retire-release-branches.md](reports/retire-release-branches.md).
Do not treat those branches as product lines.

| Piece | Role |
|-------|------|
| Trunk seed | Canonical `config/` + `scenario/` (newest supported matrix) |
| `matrix.yaml` | Multi-host pin+where: each cell `id`+`erp`+`default_api`+`base_url` |
| `overlays/default-<half>/` | Surgical rewrites keyed by Default API half (e.g. `default-24.200.001`) |
| `reports/` | Matrix evidence: seed SHA × host × pin × overlay × outcomes |

### Pins

Committed `matrix.yaml` is the sole pin+where registry. Each lab host is a cell:

| Cell id | ERP (`erp`) | Default (`default_api`) | Overlay |
|---------|-------------|-------------------------|---------|
| `26r1` (default) | `26.101.0225` | `25.200.001` | *(none)* |
| `25r1` | `25.101.0153` | `24.200.001` | `overlays/default-24.200.001/` |
| `25r2` | `25.201.0213` | `25.200.001` | *(none)* |

`acu` resolves contract API from `--api-version`, else active cell `default_api`,
else the CLI code default — never `ACU_API_VERSION` in `.env`.
REST where: `--url` → optional `ACU_BASE_URL` → cell `base_url`.
Pins must be **host-true** from live check (invalid Default halves forbidden).
Canonical table: [reports/matrix-pins.md](reports/matrix-pins.md).

### Overlay compose

Overlays live under `overlays/default-<default_api>/`. With host-true matrix
cells, **bare** commands auto-compose the pin overlay (acu-cli ≥ 0.24.0).
Explicit path args disable auto.

```sh
# Cell 25r1 default_api: 24.200.001 → overlays/default-24.200.001/
acu --cell 25r1 apply
acu --cell 25r1 run
acu --cell 25r1 diff

# Explicit (no auto) — later path wins same keys
acu apply config/ overlays/default-24.200.001/

# Cold lifecycle every cell (SSH + tenant required)
acu check --all --yes --tenant LAB5
```
