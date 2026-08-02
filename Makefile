.ONESHELL:
.SILENT:

SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c
MAKEFLAGS += --no-builtin-rules --no-builtin-variables

CHECK_TENANT ?= GITOPS
# Optional: make check HOST=25r1  (empty = all matrix cells)
HOST ?=

# Lab matrix cells (tab-separated). Pins: reports/matrix-pins.md
# name	url	erp	default_api	overlay_id (empty = trunk only)
define MATRIX_CELLS
25r1	http://acu-25r1-dev1.vm.internal/AcumaticaERP	25.101.0153	24.200.001
25r2	http://acu-25r2-dev1.vm.internal/AcumaticaERP	25.201.0213	25.200.001
26r1	http://acu-26r1-dev1.vm.internal/AcumaticaERP	26.101.0225	25.200.001
endef
export MATRIX_CELLS

default: help

.PHONY: help check

check: ## Full E2E matrix on all 3 lab Windows hosts (recreate tenant each)
	# Pin swap is local-only for the run; trunk target.yaml restored on exit.
	bak=$$(mktemp)
	cp target.yaml "$$bak"
	restore_target() { cp "$$bak" target.yaml; rm -f "$$bak"; }
	trap restore_target EXIT
	failed=0
	ran=0
	# Derive SSH per host (Administrator@<hostname>); do not carry a sticky ACU_SSH.
	unset ACU_SSH || true
	while IFS=$$'\t' read -r name url erp api overlay; do
		[[ -z "$${name}" || "$${name}" == \#* ]] && continue
		if [[ -n "$(HOST)" && "$(HOST)" != "$${name}" ]]; then
			continue
		fi
		ran=$$((ran + 1))
		if [[ -n "$${overlay}" ]]; then
			$(call header,check $${name} → $${url} [overlay $${overlay}])
		else
			$(call header,check $${name} → $${url} [trunk])
		fi
		printf 'erp: "%s"\ndefault_api: "%s"\n' "$${erp}" "$${api}" > target.yaml
		export ACU_BASE_URL="$${url}"
		cell_ok=0
		if (
			set -e
			trap 'acu tenant delete --login $(CHECK_TENANT) --yes || true' EXIT
			acu tenant delete --login $(CHECK_TENANT) --yes || true
			acu tenant create --login $(CHECK_TENANT)
			# Bare apply/run/diff: pin auto-compose uses overlays/default-<default_api>/
			# when present (acu-cli V44). Explicit paths not required.
			acu --tenant $(CHECK_TENANT) apply
			acu --tenant $(CHECK_TENANT) run
			acu --tenant $(CHECK_TENANT) diff
		); then
			cell_ok=1
		fi
		if [[ $$cell_ok -eq 1 ]]; then
			echo "$(green)PASS $${name}$(reset)"
		else
			echo "FAIL $${name}" >&2
			failed=1
		fi
	done <<< "$$MATRIX_CELLS"
	if [[ $$ran -eq 0 ]]; then
		echo "no matrix cells matched HOST=$(HOST)" >&2
		exit 1
	fi
	test $$failed -eq 0

record: ## Record a YouTube video
	acu tenant delete --login $(CHECK_TENANT) --yes || true
	acu-walk clean --yes
	acu-walk record --yes

###############################################################################
# Colors and Headers
###############################################################################

TERM := xterm-256color

blue := $$(tput setaf 4)
green := $$(tput setaf 2)
reset := $$(tput sgr0)

define header
echo "$(blue)==> $(1) <==$(reset)"
endef

help:
	echo "$(blue)Usage: $(green)make [recipe]$(reset)"
	echo "$(blue)Recipes:$(reset)"
	awk 'BEGIN {FS = ":.*?## "; sort_cmd = "sort"} /^[a-zA-Z0-9_-]+:.*?## / \
	{ printf "  \033[33m%-10s\033[0m %s\n", $$1, $$2 | sort_cmd; } \
	END {close(sort_cmd)}' $(MAKEFILE_LIST)

###############################################################################
# Release
###############################################################################

# `make release <part>` passes the part as an extra goal; pick it out and give
# the part words no-op recipes so make does not try to build them. There is no
# version manifest in this repo — the version lives in the git tag, and the next
# one is bumped from the latest `v*` tag.
part := $(word 1,$(filter major minor patch,$(MAKECMDGOALS)))

release: ## tag + publish a GitHub release (make release major|minor|patch)
	set -e
	test -n "$(part)" || { echo "usage: make release major|minor|patch"; exit 1; }
	git diff --quiet && git diff --cached --quiet \
		|| { echo "working tree not clean — commit or stash first"; exit 1; }
	cur=$$(git describe --tags --match 'v*' --abbrev=0 2>/dev/null || echo v0.0.0)
	cur=$${cur#v}
	maj=$${cur%%.*}; rest=$${cur#*.}; min=$${rest%%.*}; pat=$${rest##*.}
	case "$(part)" in
	  major) maj=$$((maj + 1)); min=0; pat=0 ;;
	  minor) min=$$((min + 1)); pat=0 ;;
	  patch) pat=$$((pat + 1)) ;;
	esac
	version="$$maj.$$min.$$pat"
	$(call header,Tagging v$$version)
	git tag "v$$version"
	git push && git push --tags
	$(call header,Publishing v$$version to GitHub)
	gh release create "v$$version" --title "v$$version" --generate-notes
	echo "$(green)Released v$$version$(reset)"

major minor patch:
	:
