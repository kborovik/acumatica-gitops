.ONESHELL:
.SILENT:

SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c
MAKEFLAGS += --no-builtin-rules --no-builtin-variables

# Ephemeral tenant for `make check` (override: make check CHECK_TENANT_ID=90 CHECK_TENANT=SMOKE)
CHECK_TENANT_ID ?= 99
CHECK_TENANT    ?= CHECK

default: help

.PHONY: help install tenants apply diff run pipeline check encrypt decrypt \
        release major minor patch

install: ## Install the acu CLI on PATH (from PyPI)
	uv tool install acumatica-cli --upgrade

tenants: ## List tenants on the instance
	acu tenant list

apply: ## Apply tenant configuration
	acu apply

diff: ## Drift check: live vs. applied configuration
	acu diff

run: ## Run the transaction scenario
	acu run scenario/10-seed-capital.yaml

check: ## Brand-new deployment: create tenant → apply all YAML → destroy
	trap 'acu tenant delete --id $(CHECK_TENANT_ID) --yes || true' EXIT
	acu tenant create --id $(CHECK_TENANT_ID) --login $(CHECK_TENANT)
	acu --tenant $(CHECK_TENANT) apply
	acu --tenant $(CHECK_TENANT) run scenario/10-seed-capital.yaml

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
