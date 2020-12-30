include vars.mk
include contrib/make/pkg/base/base.mk
include contrib/make/pkg/string/string.mk
include contrib/make/pkg/color/color.mk
include contrib/make/pkg/functions/functions.mk
include contrib/make/targets/buildenv/buildenv.mk
include contrib/make/targets/git/git.mk
include contrib/make/targets/lxd/lxd.mk
THIS_FILE := $(firstword $(MAKEFILE_LIST))
SELF_DIR := $(dir $(THIS_FILE))
# launches prestaging env (lxd container)
.PHONY: init
.SILENT: init
init:
	- $(call print_running_target)
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) $(LXD_TARGETS)
	- $(call print_completed_target)
