# Retire long-running release branches (V12)

## Goal

Stop using `acu-25r1` / `acu-25r2` / (later) rename-away `acu-26r1` as
**product lines**. Multi-version = trunk seed + `target.yaml` + overlays.

## Preconditions (gate before delete)

1. Trunk (`acu-26r1` today) documents matrix model (T34–T35).
2. PaymentMethod BILL dropped so cold `acu apply config/` completes (T36).
3. Overlay `default-24.200.001` KitAssembly Assembly path documented (T37).
4. Host-true pins documented — no `25.100.001` Default examples (T38).
5. Matrix report template in use for at least one green 25r1-overlay and
   25r2/26r1-trunk cold pass (T39 + lab re-run).

## Retirement steps (operator)

When preconditions hold:

```sh
# 1. Tag freezes if any historical pin must stay reachable
git tag archive/acu-25r1 origin/acu-25r1
git tag archive/acu-25r2 origin/acu-25r2
git push origin archive/acu-25r1 archive/acu-25r2

# 2. Delete remote long-running product branches
git push origin --delete acu-25r1
git push origin --delete acu-25r2

# 3. Optional local cleanup
git branch -D acu-25r1 acu-25r2 2>/dev/null || true
```

## After rename to `main`

When trunk renames `acu-26r1` → `main`, update origin/HEAD and docs; keep
`acu-26r1` only as a temporary alias if needed, then delete.

## Status

| Branch | Status |
|--------|--------|
| `acu-26r1` | **Trunk** (keep until rename to `main`) |
| `acu-25r1` | **Pending delete** — archive tag then delete after green overlay lab pass |
| `acu-25r2` | **Pending delete** — archive tag then delete after green trunk lab pass |

This file is the plan note; it does not delete remotes by itself.
