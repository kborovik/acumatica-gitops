# Overlays (Default API half)

Surgical rewrites for hosts whose **Default contract half** differs from
trunk. Keyed by `target.yaml` `default_api`, not ERP marketing year.

Same layout and bare pin auto-compose as `acu config init` scaffolds —
see acu-cli `overlays/README.md` (package template).

```
overlays/default-<default_api>/
  config/…      # optional: SEED_DIRS under config/ (or root of overlay)
  scenario/…    # optional: same basenames as trunk scenario/*.yaml
```

## Bare compose

With host-true `target.yaml`, omit path args:

```sh
acu apply   # trunk config/ + overlay config when present
acu run     # trunk scenario/ with overlay basenames replacing
acu diff
```

## Lab matrix

| ERP line | `default_api` | Overlay | Notes |
|----------|---------------|---------|--------|
| 25r1 | `24.200.001` | `default-24.200.001/` | KitAssembly Type Assembly |
| 25r2 | `25.200.001` | *(none)* | trunk Production |
| 26r1 | `25.200.001` | *(none)* | trunk Production |

Future half: add `overlays/default-<half>/` with the minimal rewrite only.
