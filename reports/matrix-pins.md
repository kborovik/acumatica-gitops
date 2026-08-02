# Host-true matrix pins (V13)

`target.yaml` on each host must match live `acu config check`.
Invalid Default halves are forbidden (example: **`25.100.001` is not a
published Default** on the 25r1 lab host — highest Default there is
**`24.200.001`**).

## Lab cells (2026-08-02 probe)

| Cell | ERP (`erp`) | Default (`default_api`) | Overlay | Notes |
|------|-------------|-------------------------|---------|-------|
| 25r1 lab | `25.101.0153` | **`24.200.001`** | `overlays/default-24.200.001/` | KitAssembly Type Assembly |
| 25r2 lab | `25.201.0213` | `25.200.001` | (none) | Trunk KitAssembly Type Production |
| 26r1 lab (trunk) | `26.101.0225` | `25.200.001` | (none) | Current `target.yaml` on this branch |

## Anti-pattern (do not re-commit)

```yaml
# WRONG on 25r1 lab — 25.100.001 is not host-true Default
erp: "25.101.0153"
default_api: "25.100.001"
```

```yaml
# RIGHT on 25r1 lab
erp: "25.101.0153"
default_api: "24.200.001"
```

Per-host pins live in that host's checkout `target.yaml` (or CI inject);
this file is documentation only, not applied by `acu`.
