# Matrix run report template (V16)

Copy to `reports/YYYY-MM-DD-<host>.md` (or append a row to a shared log).
Fill every field after a cold or warm validation pass.

## Header

| Field | Value |
|-------|-------|
| Date (UTC) | |
| Operator | |
| Seed SHA | `git rev-parse HEAD` |
| Host | (hostname / base URL) |
| Tenant | |
| ERP (`target.yaml` erp) | |
| Default API (`default_api`) | |
| Overlay id | `none` \| `default-24.200.001` \| … |
| CLI version | `acu --version` |
| Mode | cold empty tenant \| warm re-run |

## Outcomes

| Step | Command | Exit | Notes |
|------|---------|------|-------|
| config check | `acu config check` | | |
| bootstrap | `acu tenant create` / `acu bootstrap` | | |
| apply | `acu apply config/` [+ overlay] | | |
| run capital | `acu run scenario/10-seed-capital.yaml` | | |
| run buy | `acu run scenario/20-buy.yaml` | | |
| run build | `acu run scenario/30-build.yaml` or overlay path | | |
| run sell | `acu run scenario/40-sell.yaml` | | |
| run collect | `acu run scenario/45-collect.yaml` | | |
| diff | `acu diff config/` [+ overlay] | | exit 2 = drift |
| state | `acu state` | | optional commit trial-balance |

## Ending balances (cold mixed-AR expected)

When cold collect policy holds (V11):

| Account | Expected ending |
|---------|-----------------|
| 10100 cash | 48159 |
| 11000 AR | 1942 |
| ACMEMFG invoice | Closed |
| NORTHGRID remainder | Open 1045 |
| AGRISENSE | Open 897 |

## Example (filled)

See [matrix-example-2026-08-02.md](matrix-example-2026-08-02.md).
