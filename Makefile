include contrib/make/pkg/base/base.mk
include contrib/make/pkg/string/string.mk
include contrib/make/pkg/color/color.mk
include contrib/make/pkg/functions/functions.mk
include contrib/make/targets/buildenv/buildenv.mk
include contrib/make/targets/git/git.mk

THIS_FILE := $(firstword $(MAKEFILE_LIST))
SELF_DIR := $(dir $(THIS_FILE))

PLAYBOOKS_TARGETS=$(notdir $(patsubst %/,%,$(dir $(wildcard ./playbooks/*/Makefile))))
.PHONY: playbooks
.SILENT: playbooks
playbooks:
	- $(call print_running_target)
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) $(PLAYBOOKS_TARGETS)
	- $(call print_completed_target)

.PHONY: $(PLAYBOOKS_TARGETS)
.SILENT: $(PLAYBOOKS_TARGETS)
$(PLAYBOOKS_TARGETS):
	- $(call print_running_target)
	- @$(MAKE) --no-print-directory -C playbooks/$(@)/ $(@)
	- $(call print_completed_target)

.PHONY: playbooks-info
.SILENT: playbooks-info
playbooks-info:
	- $(info $(PLAYBOOKS_TARGETS))

CONTAINER_TARGETS=$(PLAYBOOKS_TARGETS:%=%-containers)
.PHONY: containers
.SILENT: containers
containers:
	- $(call print_running_target)
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) $(CONTAINER_TARGETS)
	- $(call print_completed_target)
.PHONY: $(CONTAINER_TARGETS)
.SILENT: $(CONTAINER_TARGETS)
$(CONTAINER_TARGETS):
	- $(eval name=$(@:%-containers=%))
	- @$(MAKE) --no-print-directory -C playbooks/$(name)/ $(name)-containers

.PHONY: containers-info
.SILENT: containers-info
containers-info:
	- $(info $(CONTAINER_TARGETS))

CLEAN_TARGETS=$(PLAYBOOKS_TARGETS:%=%-clean)
.PHONY: clean
.SILENT: clean
clean:
	- $(call print_running_target)
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) $(CLEAN_TARGETS)
	- $(call print_completed_target)
.PHONY: $(CLEAN_TARGETS)
.SILENT: $(CLEAN_TARGETS)
$(CLEAN_TARGETS):
	- $(eval name=$(@:%-clean=%))
	- @$(MAKE) --no-print-directory -C playbooks/$(name)/ $(name)-clean

.PHONY: clean-info
.SILENT: clean-info
clean-info:
	- $(info $(CLEAN_TARGETS))

