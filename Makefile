.ONESHELL:
.SILENT:

SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c
MAKEFLAGS += --no-builtin-rules --no-builtin-variables

CHECK_TENANT ?= GITOPS
# Optional: make check HOST=25r1  (empty = all matrix.yaml cells)
HOST ?=
# Walk script for make record (globals --script/-f before subcommand; acu-walk ≥0.7).
# Only demo/walk.yaml is active (major-release multi-cell film; beat cell: switches hosts).
# Other demo/*-walk.yaml files are archive — do not point record at them.
WALK := demo/walk.yaml
# Optional take-default matrix cell (omit = first cell when sticky BASE_URL cleared).
# Beat-level cell: still switches mid-take for multi-host films (acu-walk V25).
CELL ?=

default: help

.PHONY: help check record

check: ## Full E2E matrix lifecycle (acu check; recreate tenant each cell)
	# Sticky ACU_BASE_URL would override every cell base_url — clear for multi-cell.
	# ACU_SSH defaults to Administrator@<cell host> when unset.
	unset ACU_BASE_URL ACU_SSH || true
	if [[ -n "$(HOST)" ]]; then
		$(call header,check cell=$(HOST) tenant=$(CHECK_TENANT))
		acu --cell "$(HOST)" check --yes --tenant $(CHECK_TENANT)
	else
		$(call header,check --all tenant=$(CHECK_TENANT))
		acu check --all --yes --tenant $(CHECK_TENANT)
	fi

record: ## Record walk film (demo/walk.yaml; CELL=… optional; unsets sticky ACU_BASE_URL)
	# Sticky ACU_BASE_URL masks matrix/--cell for the take default host.
	# Beat cell: (V25) still uses matrix base_url; clearing sticky keeps take
	# boot + config show aligned with matrix first cell or CELL=.
	unset ACU_BASE_URL || true
	args=(-f "$(WALK)")
	if [[ -n "$(CELL)" ]]; then
		args+=(--cell "$(CELL)")
	fi
	$(call header,record script=$(WALK)$(if $(CELL), cell=$(CELL),))
	acu-walk "$${args[@]}" config validate
	acu-walk "$${args[@]}" record --yes

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
