# Matrix example — 2026-08-02 lab probe

Illustrative filled report from issue #2 live findings (pre-T36 BILL fix
and pre-overlay). Re-run after trunk fixes and attach a new dated report.

## Header

| Field | Value |
|-------|-------|
| Date (UTC) | 2026-08-02 |
| Operator | lab probe (issue #2) |
| Seed SHA | pre-trunk-matrix fold (see issue) |
| Host | 25r1 / 25r2 lab cells |
| Tenant | (probe tenants) |
| Overlay id | none (overlay added later as `default-24.200.001`) |
| Mode | cold empty tenant |

## Outcomes by cell

### 25r1 lab

| Field | Value |
|-------|-------|
| ERP | 25.101.0153 |
| Default API | **24.200.001** (host-true; not 25.100.001) |
| apply | FAIL PaymentMethod BILL 500 (mid-tree abort) — fixed on trunk by T36 drop |
| scenarios after BILL skip | build FAIL: KitAssembly Type `Production` not allowed → use overlay Assembly |
| Overlay (post-T37) | `overlays/default-24.200.001/` |

### 25r2 lab

| Field | Value |
|-------|-------|
| ERP | 25.201.0213 |
| Default API | 25.200.001 |
| apply | FAIL PaymentMethod BILL 500 — fixed on trunk by T36 drop |
| scenarios after BILL skip | all four scenario legs PASS (trunk Production) |
| Overlay | none |

### 26r1 lab (trunk host)

| Field | Value |
|-------|-------|
| ERP | 26.101.0225 |
| Default API | 25.200.001 |
| Overlay | none |
| Notes | Current `target.yaml` on `acu-26r1` |

## Pin table

Canonical host-true pins: [matrix-pins.md](matrix-pins.md).
