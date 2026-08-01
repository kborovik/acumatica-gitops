.ONESHELL:
.SILENT:

SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c
MAKEFLAGS += --no-builtin-rules --no-builtin-variables

CHECK_TENANT ?= LAB5

default: help

.PHONY: help

check: ## Full end-to-end test (always recreate tenant from clean)
	trap 'acu tenant delete --login $(CHECK_TENANT) --yes || true' EXIT
	acu tenant delete --login $(CHECK_TENANT) --yes || true
	acu tenant create --login $(CHECK_TENANT)
	acu --tenant $(CHECK_TENANT) apply config/
	acu --tenant $(CHECK_TENANT) run scenario/
	acu --tenant $(CHECK_TENANT) diff config/

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
