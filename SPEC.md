# LAB5 Distribution — Acumatica demo tenant seed

## §G GOAL

Rebuildable Acumatica distribution demo tenant LAB5 Distribution for lab5.ca sales-video pitch (Demo Tenant Factory): empty → company + masters + linked txn history; clean `acu diff` after apply.

## §C CONSTRAINTS

- Industry flavor: distribution (stock inventory, SO → ship → invoice → payment).
- Company display name: LAB5 Distribution (Acumatica org); pitch surface lab5.ca Demo Tenant Factory.
- Seed lives in Git as acu YAML (`bootstrap/`, `baseline/`, `setup/`, `master/`, `scenario/`); no secrets in YAML — creds stay `.env`.
- Target matrix: `target.yaml` (erp 26.101.0225, default_api 25.200.001); tenant id from env (`ACU_TENANT=LAB5`).
- Demo data only; not production cutover / not multi-industry catalog this pass.
- Distribution masters + linked buy-sell history live under `master/` + `scenario/`; not rename-only scaffold.

## §I INTERFACES

- cmd: `acu apply <path>` → PUT/actions from YAML seed dirs
- cmd: `acu diff <path>` → drift report vs live tenant
- yaml: `bootstrap/*.yaml` → company, features, credit terms (bootstrap endpoint)
- yaml: `baseline/*.yaml` → GL/subaccount/UOM foundation (Default + bootstrap endpoints)
- yaml: `setup/*.yaml` → fin year, master calendar, open periods (actions)
- yaml: `master/*.yaml` → inventory, warehouse, customers, vendors, items, module prefs
- yaml: `scenario/` → linked PO/receipt/SO/shipment/invoice/payment history
- env: `ACU_BASE_URL`, `ACU_TENANT`, `ACU_API_VERSION`, `ACU_USER`, `ACU_PASSWORD` ! set for live apply
- entity: Company (AcctCD/AcctName), Account, Ledger, Subaccount, UnitsOfMeasure, InventoryItem, Customer, Vendor, SalesOrder, …

## §V INVARIANTS

V1: demo-tenant-seed — artifact is Git-versioned Acumatica seed for rebuildable LAB5 Distribution demo (lab5.ca pitch); not production ERP
V2: company-identity — org display name always `LAB5 Distribution`; org CD consistent across company, ledger-company, open-periods
V3: linked-history — every demo doc chains: customer/vendor → order → shipment/receipt → invoice/bill → payment; orphan demo docs forbidden
V4: feature-closure — `bootstrap/features.yaml` enables every feature baseline/master/scenario YAML requires
V5: apply-order — numbered YAML prefixes encode alphabetical apply order; record referencing entity sorts after file creating it
V6: pitch-surface — seed populates distribution pitch path: stock item, available qty, SO, shipment, invoice, payment, AR open balance on standard screens
V7: deterministic-rebuild — empty/reset tenant + full seed apply → clean `acu diff` on seeded paths
V8: no-secrets-in-seed — seed YAML + committed docs never contain passwords, API keys, host credentials

## §T TASKS

id|status|task|cites
T1|x|set company AcctName LAB5 Distribution; align AcctCD + ledger-company + open-periods refs|V2
T2|x|expand distribution COA (inventory asset, COGS, sales, freight, AP/AR depth as pitch needs)|V6
T3|x|enable inventory prefs + warehouse + location seed under master/|V4,V5
T4|x|seed stock items + UOMs (PIECE/each + distribution units) w/ costs|V6
T5|x|seed customers + vendors + credit terms used by scenarios|V3
T6|x|seed PO → receipt path so on-hand qty exists pre-sales demo|V3,V6
T7|x|seed SO → shipment → invoice → payment chain (linked)|V3,V6
T8|x|document pitch walkthrough (screen path + which seed rows drive each beat)|V1,V6
T9|x|`acu apply` full seed + `acu diff` green on target tenant|V7
T10|x|README: rebuild steps, pitch path, non-goals|V1,V8

## §B BUGS

id|date|cause|fix
