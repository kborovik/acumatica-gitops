# LAB5 Distribution — sales-video pitch walkthrough

Maps each demo beat to seed rows for the [lab5.ca Demo Tenant Factory](https://lab5.ca/services/demo-tenant-factory) pitch.

Company: **LAB5 Distribution** (`AcctCD: LAB5`). Rebuild: see root `README.md`.

## Pitch path (screens)

| Beat | Screen (ID) | What the camera shows | Seed / scenario driver |
|------|-------------|----------------------|-------------------------|
| 1. Clean company | Company (CS101500) | Org name LAB5 Distribution | `bootstrap/company.yaml` |
| 2. Stock on hand | Inventory Summary (IN401000) | Qty after the buy | `scenario/buy-sell.yaml` PO leg; items in `master/82-stock-items-kits.yaml` |
| 3. Sales order | Sales Orders (SO301000) | Order for ACMEMFG / NORTHGRID / AGRISENSE | scenario `so-*` steps; customers `master/76-customers.yaml` |
| 4. Shipment | Shipments (SO302000) | Confirmed shipment from WH01 | `SalesOrderCreateShipment` + `ConfirmShipment` |
| 5. Invoice | Invoices (SO303000) | Open / closed invoice | `PrepareInvoice` + `ReleaseSalesInvoice` |
| 6. Payment | Payments (AR302000) | ACMEMFG paid in full (WIRE to 10100) | `pay-acme` + `ReleasePayment` |
| 7. AR open | Customer details / AR balance | NORTHGRID + AGRISENSE invoices still open | scenario leaves those invoices Open (linked history, V3) |
| 8. Clean rebuild | CLI | Empty tenant, apply, run, clean diff | README rebuild steps (V7) |

## Linked chain (V3)

```
Vendor (SHENZHEN…) to PO to Purchase Receipt to
Customer (ACMEMFG…) to SO to Shipment to Invoice to Payment
```

No orphan demo docs: every scenario document references a prior captured number (`${po_*}`, `${ship_*}`, `${inv_*}`).

## Master data the pitch depends on

| Area | Files under `master/` |
|------|------------------------|
| Warehouse WH01 + MAIN bin | `50-warehouse.yaml`, `51-warehouse-locations.yaml` |
| IN/SO/PO prefs | `20-in-preferences.yaml`, `56-so-preferences.yaml`, `57-po-preferences.yaml` |
| Stock (parts + kits) | `80-stock-items-parts.yaml`, `82-stock-items-kits.yaml`, `85-kit-specifications.yaml` |
| Vendors / customers | `75-vendors.yaml`, `76-customers.yaml` |
| Cash / WIRE | `63-cash-account.yaml`, `64-payment-methods.yaml` |

## Non-goals (this seed)

- Not production cutover data
- Not multi-branch / multicurrency
- Not tax configuration beyond EXEMPT category
