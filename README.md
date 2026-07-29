# LAB5 Electronics Inc. — Acumatica demo tenant seed

Git-versioned Acumatica configuration for **LAB5 Electronics Inc.**, an electronics manufacturer demo company used for the [lab5.ca](https://lab5.ca) **Demo Tenant Factory** sales pitch.

Rebuild from empty to company, masters, and linked transaction history
(seed capital, buy components, assemble products, sell, invoice, collect).
Not a production ERP.

Requires the [`acu` CLI](https://github.com/kborovik/acumatica-cli) (PyPI: `acumatica-cli`).

## Layout

| Path | Role |
|------|------|
| `config/bootstrap/` | Company, features, credit terms, Bootstrap endpoint contract (`project.xml`) |
| `config/baseline/` | GL foundation (COA, ledger, subaccounts, UOMs) |
| `config/setup/` | Financial year, master calendar, open periods |
| `config/master/` | Inventory, warehouse, items, vendors, customers, module prefs |
| `config/views/` | Observation defs for `acu state` (trial balance); not seed |
| `scenario/10-seed-capital.yaml` | Once-class owner capital JE (CLI skip-if-present when present) |
| `scenario/20-buy.yaml` | Additive component PO to receipt to bill to AP pay (four vendors) |
| `scenario/30-build.yaml` | Additive kit assembly (parts to GW-EDGE / CELL / RAIL) |
| `scenario/40-sell.yaml` | Additive SO to ship to invoice to AR pay (three customers) |
| `state/` | Committed derived observations (`acu state` from `config/views/`) |
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
acu tenant create --id N --login TENANT
# Hosted / tenant already exists: acu bootstrap
# Offline UI fallback: acu bootstrap --export AcuBootstrap.zip

# 3. Seed configuration (config/ umbrella; order = bootstrap → baseline → setup → master)
acu apply config/
# bare `acu apply` also prefers config/ when those trees exist

# 4. Linked history for the pitch (once capital, then buy/build/sell)
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
| `40-sell.yaml` | additive | New SO/ship/invoice/pay pack each run; deltas hold |

Primary compose: `acu apply config/` then `acu run scenario/`.

Warm capital-only gate (state must not move):

```sh
acu run scenario/10-seed-capital.yaml && acu state --assert-unchanged
```

### Other useful commands

| Command | Role |
|---------|------|
| `acu tenant list` | List tenants on the instance (SSH) |
| `acu tenant delete --id N --yes` | Delete tenant + recycle app pool |
| `acu tenant recycle --yes` | Restart site app pool (free API slots / reload tenant map) |
| `acu extract` | Inverse of apply: live tenant → `config/**` seed YAML |
| `acu schema` | Dump endpoint OpenAPI into `schemas/` |
| `acu inventory ARTIFACT` | Offline: SM203520 Settings XML ZIP / `ac.exe export xml` → `inventory/` |
| `acu reconcile` | Offline: `inventory/` vs optional `config/` → `findings/` |
| `make check` | E2E: create ephemeral tenant, apply, run, diff, delete |

## Pitch path

See [demo/walk.yaml](demo/walk.yaml) — the promo video's script, shot plan and
narration, and the beat-by-beat source for this path. Short version:

1. Company **LAB5 Electronics Inc.**
2. Bank funded (Owner Capital to Checking 10100)
3. Components at **WH01** after the buy; four vendor bills paid by WIRE
4. Kit assembly (parts to finished gateways)
5. Sales order, shipment, invoice, WIRE payment (all three customers paid)

The walk itself is scripted — see [demo/](demo/README.md). One command captures the
full product: `make demo` ensures CLI replay logs, drives every beat, and writes
stills plus `demo/out/video/walk.webm`. Cold reshoot: `make demo-clean && make demo`.

## Non-goals

- Production cutover / opening balances from a legacy system
- Multi-industry catalog (this seed is IoT gateway manufacturing / kit assembly)
- Secrets or host credentials in Git (`V8`)

## Target matrix

See `target.yaml` (`erp` build + `default_api`).
`acu` resolves the contract API version from `--api-version`, else `default_api`,
else the CLI code default — not from `.env`.
