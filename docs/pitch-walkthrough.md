# LAB5 Electronics Inc. — sales-video pitch walkthrough

Maps each demo beat to seed rows for the [lab5.ca Demo Tenant Factory](https://lab5.ca/services/demo-tenant-factory) pitch.

Company: **LAB5 Electronics Inc.** (`AcctCD: LAB5`). Rebuild: see root `README.md`
(`acu apply config/` then `acu run scenario/`).

## Pitch path (screens)

| Beat | Screen (ID) | What the camera shows | Seed / scenario driver |
|------|-------------|----------------------|-------------------------|
| 1. Clean company | Company (CS101500) | Org name LAB5 Electronics Inc. | `config/bootstrap/company.yaml` |
| 2. Bank funded | Account Summary / Journal (GL301000) | Checking 10100 + Owner Capital 30000 | `scenario/10-seed-capital.yaml` (once-class) |
| 3. Parts on hand | Inventory Summary (IN401000) | Component qty after the buy | `scenario/20-buy.yaml` PO legs; parts in `config/master/80-stock-items-parts.yaml` |
| 4. Vendors paid | Bills (AP301000) + Checks (AP302000) | SHENZHEN / ENCLOTEC / WAVELINK / MEMSTOR closed; WIRE from 10100 | `20-buy` bill + pay steps |
| 5. Assemble kits | Kit Assembly (IN307000) | Parts → GW-EDGE / CELL / RAIL | `scenario/30-build.yaml`; specs `config/master/85-kit-specifications.yaml` |
| 6. Kits on hand | Inventory Summary (IN401000) | Finished gateways after build | `30-build` qty deltas; kits `config/master/82-stock-items-kits.yaml` |
| 7. Sales order | Sales Orders (SO301000) | ACMEMFG / NORTHGRID / AGRISENSE | `scenario/40-sell.yaml` `so-*`; customers `config/master/76-customers.yaml` |
| 8. Shipment | Shipments (SO302000) | Confirmed shipment from WH01 | `SalesOrderCreateShipment` + `ConfirmShipment` |
| 9. Invoice | Invoices (SO303000) | Invoices closed after payment | `PrepareInvoice` + `ReleaseSalesInvoice` |
| 10. Customer WIRE | Payments (AR302000) | All three customers paid in full to 10100 | `pay-acme` / `pay-northgrid` / `pay-agrisense` |
| 11. Cash position | Account Summary (GL401000) | 10100 net +51,048 this full cycle | seed − AP pay + AR collections |
| 12. Clean rebuild | CLI | Empty tenant, apply, run, clean diff | `acu apply config/`; `acu run scenario/`; `acu diff config/` (V7) |

## Linked chain (V3)

```
Seed capital (GL, once) to Checking 10100
Vendors (SHENZHEN / ENCLOTEC / WAVELINK / MEMSTOR) to PO to Purchase Receipt to Bill to AP WIRE Payment
Kit assembly (parts to GW-EDGE / CELL / RAIL) at WH01 MAIN
Customer (ACMEMFG / NORTHGRID / AGRISENSE) to SO to Shipment to Invoice to AR WIRE Payment
```

No orphan demo docs: every scenario document references a prior captured number (`${po_*}`, `${rcpt_*}`, `${bill_*}`, `${asm_*}`, `${ship_*}`, `${inv_*}`).

## Once vs additive

| Scenario | Class | Role in the pitch |
|----------|-------|-------------------|
| `10-seed-capital` | once | Funds Checking; skipped on warm re-run so Owner Capital does not stack |
| `20-buy` | additive | Restocks components at WH01 and pays the four vendors each run |
| `30-build` | additive | Assembles kits from parts (exact BOM) each run |
| `40-sell` | additive | Full collect cycle for the three demo customers each run |

## Master data the pitch depends on

| Area | Files under `config/master/` |
|------|------------------------------|
| Warehouse WH01 + MAIN bin | `50-warehouse.yaml`, `51-warehouse-locations.yaml` |
| IN/SO/PO prefs | `20-in-preferences.yaml`, `56-so-preferences.yaml`, `57-po-preferences.yaml` |
| Stock (parts + kits) | `80-stock-items-parts.yaml`, `82-stock-items-kits.yaml`, `85-kit-specifications.yaml` |
| Vendors / customers | `75-vendors.yaml`, `76-customers.yaml` |
| Cash / WIRE | `63-cash-account.yaml`, `64-payment-methods.yaml` |
| Owner capital COA | `config/baseline/20-accounts.yaml` (10100, 30000) |

## Non-goals (this seed)

- Not production cutover data / legacy trial-balance import
- Not multi-branch / multicurrency
- Not tax configuration beyond EXEMPT category
