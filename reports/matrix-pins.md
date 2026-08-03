# Host-true matrix pins (V13)

Each `matrix.yaml` cell must match live `acu config check` for that host.
Invalid Default halves are forbidden (example: **`25.100.001` is not a
published Default** on the 25r1 lab host — highest Default there is
**`24.200.001`**).

## Lab cells (2026-08-02 probe; committed in `matrix.yaml`)

| Cell id | ERP (`erp`) | Default (`default_api`) | Overlay | Notes |
|---------|-------------|-------------------------|---------|-------|
| `26r1` (default) | `26.101.0225` | `25.200.001` | (none) | Trunk default when `--cell` omitted |
| `25r1` | `25.101.0153` | **`24.200.001`** | `overlays/default-24.200.001/` | KitAssembly Type Assembly |
| `25r2` | `25.201.0213` | `25.200.001` | (none) | Trunk KitAssembly Type Production |

## Anti-pattern (do not re-commit)

```yaml
# WRONG on 25r1 lab — 25.100.001 is not host-true Default
- id: "25r1"
  erp: "25.101.0153"
  default_api: "25.100.001"
  base_url: "http://acu-25r1-dev1.vm.internal/AcumaticaERP"
```

```yaml
# RIGHT on 25r1 lab
- id: "25r1"
  erp: "25.101.0153"
  default_api: "24.200.001"
  base_url: "http://acu-25r1-dev1.vm.internal/AcumaticaERP"
```

Pins + non-secret where live in committed root `matrix.yaml` (acu-cli V27);
this file is documentation only, not applied by `acu`. Never `target.yaml`.
