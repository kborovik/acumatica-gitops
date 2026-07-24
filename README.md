# LAB5 Distribution — Acumatica demo tenant seed

Git-versioned Acumatica configuration for **LAB5 Distribution**, a distribution demo company used for the [lab5.ca](https://lab5.ca) **Demo Tenant Factory** sales pitch.

Rebuild from empty to company, masters, and linked transaction history (buy, sell, invoice, collect).
Not a production ERP.

Requires the [`acu` CLI](https://github.com/kborovik/acumatica-cli) (PyPI: `acumatica-cli`).

## Layout

| Path | Role |
|------|------|
| `bootstrap/` | Company, features, credit terms, Bootstrap endpoint contract (`project.xml`) |
| `baseline/` | GL foundation (COA, ledger, subaccounts, UOMs) |
| `setup/` | Financial year, master calendar, open periods |
| `master/` | Inventory, warehouse, items, vendors, customers, module prefs |
| `scenario/` | Linked transactions (`buy-sell.yaml`) |
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

# 3. Seed configuration (order matters)
acu apply bootstrap/ baseline/ setup/ master/

# 4. Linked history for the pitch
acu run scenario/

# 5. Prove no drift on seeded config
acu diff bootstrap/ baseline/ setup/ master/
```

Scenario re-runs are safe on a warm tenant (document numbers change; delta expectations still hold).

## Pitch path

See [docs/pitch-walkthrough.md](docs/pitch-walkthrough.md).
Short version:

1. Company **LAB5 Distribution**
2. Stock at **WH01** after the buy
3. Sales order, shipment, invoice, payment (ACMEMFG paid; others open AR)

## Non-goals

- Production cutover / opening balances from a legacy system
- Multi-industry catalog (this seed is IoT gateway distribution / light assembly)
- Secrets or host credentials in Git (`V8`)

## Target matrix

See `target.yaml` (ERP build + Default API version).
Live `acu` commands fail when `ACU_API_VERSION` disagrees with `default_api`.
