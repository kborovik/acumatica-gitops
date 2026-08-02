# Overlay: `default-24.200.001`

Surgical rewrites for hosts whose Default contract half is **24.200.001**
(lab 25r1 ERP pin uses this half — highest published Default on that host).

| Path | Rewrite |
|------|---------|
| `scenario/30-build.yaml` | KitAssembly `Type: Assembly` (trunk uses `Production`) |

## Compose

With `target.yaml` `default_api: "24.200.001"`, bare commands auto-compose:

```sh
acu apply
acu run    # replaces trunk 30-build.yaml with this overlay
acu diff
```

Trunk half (`25.200.001+`, e.g. 25r2 / 26r1 lab) has no matching overlay dir
— bare commands stay trunk-only.

Explicit path args still work when you need a custom compose (no auto).