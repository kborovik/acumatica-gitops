# LAB5 Electronics Inc. — Acumatica demo tenant seed

## §G GOAL

Rebuildable Acumatica manufacturer demo tenant LAB5 Electronics Inc. for lab5.ca sales-video pitch (Demo Tenant Factory): empty → config + linked txn history; clean `acu diff config/` after apply+run.

## §C CONSTRAINTS

- Industry flavor: electronics manufacturing (stock inventory, seed capital, PO → bill → pay, kit assembly, SO → ship → invoice → payment).
- Company display name: LAB5 Electronics Inc. (Acumatica org); pitch surface lab5.ca Demo Tenant Factory.
- Seed lives in Git as acu YAML (`config/{bootstrap,baseline,setup,master}/`, `scenario/`); no secrets in YAML — creds stay `.env`.
- Target matrix: `target.yaml` (erp 26.101.0225, default_api 25.200.001); tenant id from env (`ACU_TENANT=LAB5`).
- Demo data only; not production cutover / not multi-industry catalog this pass.
- Apply trees under `config/`; linked history under `scenario/` lifecycle files (once seed + additive buy/build/sell); not rename-only scaffold.
- Demo SO login: user `soadmin` w/ role `SO Admin` (descr Full access to SO functions and settings); password ! in Git.
- Demo AP login: user `apadmin` w/ built-in role `AP Admin`; password ! in Git.
- Demo AR login: user `aradmin` w/ built-in role `AR Admin`; password ! in Git.

## §I INTERFACES

- cmd: `acu config check` → read-only preflight (.env, target.yaml, REST, ?SSH)
- cmd: `acu tenant create --login NAME` → create + bootstrap (SSH); re-run republishes; --id optional (omit = next free)
- cmd: `acu tenant delete --login NAME [--yes]` → delete + recycle app pool (SSH); --id alt
- cmd: `acu tenant list|recycle` → list tenants / app-pool recycle (SSH)
- cmd: `acu bootstrap` → publish AcuBootstrap (REST); `--export PATH` offline zip
- cmd: `acu apply [config/]` → PUT/actions config umbrella bootstrap/baseline/setup/master; bare prefers config/
- cmd: `acu run [scenario/]` → ordered scenario YAMLs; once-class skip-if-present; bare defaults scenario/
- cmd: `acu diff [config/]` → drift vs live on apply trees; exit 2 on drift; bare prefers config/
- cmd: `acu state` → capture config/views/ → state/; `--assert-unchanged` exit 2 when moved
- cmd: `acu extract` → live tenant → config/{bootstrap,baseline,setup,master}/ (inverse apply)
- cmd: `acu inventory ARTIFACT` → offline SM203520 XML or ac.exe export xml → inventory/
- cmd: `acu reconcile` → offline inventory/ vs ?config/ → findings/
- cmd: `acu schema` → dump OpenAPI → schemas/
- yaml: `config/bootstrap/*.yaml` → company, features, credit terms (bootstrap endpoint)
- yaml: `config/bootstrap/project.xml` → Bootstrap/1.3.0 contract (Role/User/NumberingSequence + *Preferences depth; acu config init source)
- yaml: `config/baseline/*.yaml` → GL/subaccount/UOM foundation (Default + bootstrap endpoints)
- yaml: `config/setup/*.yaml` → fin year, master calendar, open periods (actions)
- yaml: `config/master/*.yaml` → inventory, warehouse, customers, vendors, items, module prefs, roles, users, numbering sequences
- yaml: `config/views/*.yaml` → state observation defs (not seed; acu state input)
- yaml: `scenario/10-seed-capital.yaml` → once-class owner capital JE (Dr 10100 / Cr 30000)
- yaml: `scenario/20-buy.yaml` → additive component PO → receipt → bill → AP pay (four vendors)
- yaml: `scenario/30-build.yaml` → additive kit assembly (parts → GW kits)
- yaml: `scenario/40-sell.yaml` → additive SO → ship → invoice → AR pay (three-customer pack)
- yaml: `state/*.yaml` → committed derived observations (acu state output)
- yaml: `target.yaml` → erp + default_api pin (API version when --api-version absent)
- env: `ACU_BASE_URL`, `ACU_TENANT`, `ACU_USER`, `ACU_PASSWORD` ! set for live apply; `ACU_SSH` ? (default Administrator@host; blank = hosted); no ACU_API_VERSION
- entity: Company (AcctCD/AcctName), Account, Ledger, Subaccount, UnitsOfMeasure, InventoryItem, Customer, Vendor, SalesOrder, Role, User, NumberingSequence, …

## §V INVARIANTS

V1: demo-tenant-seed — artifact is Git-versioned Acumatica seed for rebuildable LAB5 Electronics Inc. manufacturer demo (lab5.ca pitch); not production ERP
V2: company-identity — org display name always `LAB5 Electronics Inc.`; org CD consistent across company, ledger-company, open-periods
V3: linked-history — every demo doc chains: customer/vendor → order → shipment/receipt → invoice/bill → payment; orphan demo docs forbidden
V4: feature-closure — `config/bootstrap/features.yaml` enables every feature config/master/scenario YAML requires
V5: apply-order — numbered YAML prefixes under `config/` encode alphabetical apply order; record referencing entity sorts after file creating it
V6: pitch-surface — seed populates manufacturer pitch path: seed capital, component buy+pay, kit assembly, kit qty, SO, shipment, invoice, customer payment (all closed) on standard screens
V7: deterministic-rebuild — empty/reset tenant + `acu apply config/` + `acu run scenario/` → clean `acu diff config/`
V8: no-secrets-in-seed — seed YAML + committed docs never contain passwords, API keys, host credentials
V9: once-capital — seed-capital scenario is once-class; CLI skips when txn already present; Owner Capital not stacked by re-run (closes §B.1)
V10: seed-layout — apply trees under `config/{bootstrap,baseline,setup,master}/`; `scenario/` = `10-seed-capital` + `20-buy` + `30-build` + `40-sell` only; monoscenario `buy-sell` forbidden; per-leg delta expects; primary compose `acu apply config/` then `acu run scenario/`

## §T TASKS

id|status|task|cites
T1|x|set company AcctName LAB5 Electronics Inc.; align AcctCD + ledger-company + open-periods refs|V2
T2|x|expand manufacturer COA (inventory asset, COGS, sales, freight, AP/AR depth as pitch needs)|V6
T3|x|enable inventory prefs + warehouse + location seed under master/|V4,V5
T4|x|seed stock items + UOMs (PIECE/each + manufacturing units) w/ costs|V6
T5|x|seed customers + vendors + credit terms used by scenarios|V3
T6|x|seed PO → receipt path so on-hand qty exists pre-sales demo|V3,V6
T7|x|seed SO → shipment → invoice → payment chain (linked)|V3,V6
T8|x|document pitch walkthrough (screen path + which seed rows drive each beat)|V1,V6
T9|x|`acu apply` full seed + `acu diff` green on target tenant|V7
T10|x|README: rebuild steps, pitch path, non-goals|V1,V8
T11|x|seed capital GL batch (Dr 10100 / Cr 30000) in scenario; cash funded for AP|V3,V6
T12|x|PO receipt → AP bill → AP WIRE Check; clear PO accrual + AP|V3,V6
T13|x|AR WIRE for all three scenario customers; cash + AP/AR expects green|V3,V6
T14|x|pitch walkthrough + README + V6 reflect full cash cycle (no open-AR beat)|V1,V6
T15|x|move bootstrap/ baseline/ setup/ master/ under config/|V5,V10
T16|x|split scenario into 10-seed-capital (once) 20-buy-gateways 30-sell; drop buy-sell.yaml; per-leg expects|V3,V9,V10
T17|x|README + pitch-walkthrough: acu apply config/; acu run scenario/; once vs additive|V6,V7,V10
T18|x|open GitHub issue kborovik/acumatica-cli: once-guard skip-if-present + template config/ + split scenario|V9,V10
T19|x|after CLI once ships: warm second acu run scenario/ keeps capital 50000|V7,V9
T20|x|split buy-build-sell: 20-buy parts (4 vendors) 30-build kit assembly 40-sell; drop finished-goods buy|V3,V6,V10
T21|x|live probe KitAssembly Type/Status; green acu run scenario/ on buy+build+sell|V3,V6,V7
T22|.|seed Role SO Admin + User soadmin + membership config/master/ (role before user); password ! committed|V5,V8,I.yaml,T25
T23|.|seed User apadmin + membership built-in AP Admin; password ! committed|V5,V8,I.yaml,T25
T24|.|seed User aradmin + membership built-in AR Admin; password ! committed|V5,V8,I.yaml,T25
T25|x|sync config/bootstrap/project.xml ← acu-cli Bootstrap/1.3.0 (config init source; Role/User/NumberingSequence + prefs depth)|V4,V7,I.yaml
T26|x|seed config/master/05-numbering-sequences.yaml NumberingSequence bootstrap; before prefs that cite *NumberingID|V5,T25
T27|x|deepen master *Preferences YAML to 1.3.0 field depth (acu-cli template parity)|V4,T25,T26

## §B BUGS

id|date|cause|fix
B1|2026-07-24|monoscenario buy-sell re-posts seed capital each run; Owner Capital stacks N times 50k|V9
