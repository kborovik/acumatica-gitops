# LAB5 Distribution — Acumatica demo tenant seed

Git-versioned Acumatica configuration for **LAB5 Distribution**, a distribution demo company used for the [lab5.ca](https://lab5.ca) **Demo Tenant Factory** sales pitch.

Rebuild from empty to company, masters, and linked transaction history
(seed capital, buy + pay vendor, sell, invoice, collect).
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
| `scenario/20-buy-gateways.yaml` | Additive PO → receipt → bill → AP pay |
| `scenario/30-sell.yaml` | Additive SO → ship → invoice → AR pay (three customers) |
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

# 3. Seed configuration (config/ umbrella; order = bootstrap → baseline → setup → master)
acu apply config/

# 4. Linked history for the pitch (once capital, then additive buy/sell)
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
| `20-buy-gateways.yaml` | additive | New PO/receipt/bill/pay each run; inventory and cash deltas hold |
| `30-sell.yaml` | additive | New SO/ship/invoice/pay pack each run; deltas hold |

Primary compose: `acu apply config/` then `acu run scenario/`.

## Pitch path

See [docs/pitch-walkthrough.md](docs/pitch-walkthrough.md).
Short version:

1. Company **LAB5 Distribution**
2. Bank funded (Owner Capital → Checking 10100)
3. Stock at **WH01** after the buy; vendor bill paid by WIRE
4. Sales order, shipment, invoice, WIRE payment (all three customers paid)

## Non-goals

- Production cutover / opening balances from a legacy system
- Multi-industry catalog (this seed is IoT gateway distribution / light assembly)
- Secrets or host credentials in Git (`V8`)

## Target matrix

See `target.yaml` (ERP build + Default API version).
Live `acu` commands fail when `ACU_API_VERSION` disagrees with `default_api`.
