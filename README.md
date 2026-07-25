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
| `scenario/10-seed-capital.yaml` | Once-class owner capital JE (CLI skip-if-present when present) |
| `scenario/20-buy.yaml` | Additive component PO to receipt to bill to AP pay (four vendors) |
| `scenario/30-build.yaml` | Additive kit assembly (parts to GW-EDGE / CELL / RAIL) |
| `scenario/40-sell.yaml` | Additive SO to ship to invoice to AR pay (three customers) |
| `docs/pitch-walkthrough.md` | Screen path ↔ seed map for the sales video |
| `SPEC.md` | Spec-driven design (goal, invariants, tasks) |
| `target.yaml` | Verified ERP / Default API matrix |
| `.env` | Credentials (local only — never commit) |

## Quick rebuild

**Start from a brand-new empty tenant.**
Do not apply onto a half-configured company.

```sh
# 1. Credentials (local)
# ACU_BASE_URL, ACU_TENANT, ACU_USER, ACU_PASSWORD, ACU_API_VERSION
# optional: ACU_SSH for tenant create

acu config check

# 2. Publish Bootstrap package (features + custom endpoint)
acu bootstrap

# 3. Seed configuration (config/ umbrella; order = bootstrap then baseline then setup then master)
acu apply config/

# 4. Linked history for the pitch (once capital, then buy/build/sell)
acu run scenario/

# 5. Prove no drift on seeded config
acu diff config/
```

Until the CLI defaults to the `config/` umbrella and once-guard (see open issue on [acumatica-cli](https://github.com/kborovik/acumatica-cli)), explicit trees still work:

```sh
acu apply config/bootstrap/ config/baseline/ config/setup/ config/master/
acu diff  config/bootstrap/ config/baseline/ config/setup/ config/master/
```

### Once vs additive scenarios

| File | Class | Warm re-run |
|------|-------|-------------|
| `10-seed-capital.yaml` | **once** | CLI skips when capital JE already present; Owner Capital stays 50k (not stacked) |
| `20-buy.yaml` | additive | New component PO/receipt/bill/pay each run; part and cash deltas hold |
| `30-build.yaml` | additive | New kit assemblies each run; parts to kits deltas hold |
| `40-sell.yaml` | additive | New SO/ship/invoice/pay pack each run; deltas hold |

Primary compose: `acu apply config/` then `acu run scenario/`.

## Pitch path

See [docs/pitch-walkthrough.md](docs/pitch-walkthrough.md).
Short version:

1. Company **LAB5 Electronics Inc.**
2. Bank funded (Owner Capital to Checking 10100)
3. Components at **WH01** after the buy; four vendor bills paid by WIRE
4. Kit assembly (parts to finished gateways)
5. Sales order, shipment, invoice, WIRE payment (all three customers paid)

## Non-goals

- Production cutover / opening balances from a legacy system
- Multi-industry catalog (this seed is IoT gateway manufacturing / kit assembly)
- Secrets or host credentials in Git (`V8`)

## Target matrix

See `target.yaml` (ERP build + Default API version).
Live `acu` commands fail when `ACU_API_VERSION` disagrees with `default_api`.
