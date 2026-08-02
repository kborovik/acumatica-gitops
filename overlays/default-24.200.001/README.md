# Overlay: `default-24.200.001`

Surgical rewrites for hosts whose Default contract half is **24.200.001**
(lab 25r1 ERP pin uses this half — highest published Default on that host).

| Path | Rewrite |
|------|---------|
| `scenario/30-build.yaml` | KitAssembly `Type: Assembly` (trunk uses `Production`) |

## Compose

```sh
# Pin host target.yaml: default_api must be host-true (24.200.001 on 25r1 lab)
acu apply config/
# no config-entity rewrites in this overlay yet; path still valid if empty of seed YAML
acu run scenario/10-seed-capital.yaml scenario/20-buy.yaml \
  overlays/default-24.200.001/scenario/30-build.yaml \
  scenario/40-sell.yaml scenario/45-collect.yaml
acu diff config/
```

Trunk (Default `25.200.001+`, e.g. 25r2 / 26r1 lab):

```sh
acu apply config/
acu run scenario/
```
