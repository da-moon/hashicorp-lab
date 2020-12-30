include vars.mk
include ../../contrib/make/pkg/base/base.mk
include ../../contrib/make/pkg/string/string.mk
include ../../contrib/make/pkg/color/color.mk
include ../../contrib/make/pkg/functions/functions.mk
include ../../contrib/make/targets/buildenv/buildenv.mk
include ../../contrib/make/targets/git/git.mk

NOMAD_SERVER_TARGETS:=$(PROJECT_NAME)-server
NOMAD_CLIENT_TARGETS:=$(PROJECT_NAME)-client
ifneq ($(CONTAINER_COUNT),)
CONTAINER_SEQ:=$(shell seq $(CONTAINER_COUNT))
NOMAD_SERVER_TARGETS = $(CONTAINER_SEQ:%=$(PROJECT_NAME)-server-%)
NOMAD_CLIENT_TARGETS = $(CONTAINER_SEQ:%=$(PROJECT_NAME)-client-%)
endif

NOMAD_SERVER_CONTAINERS=$(NOMAD_SERVER_TARGETS:%=lxd-%)
NOMAD_CLIENT_CONTAINERS=$(NOMAD_CLIENT_TARGETS:%=lxd-%)
LXD_TARGETS = $(NOMAD_SERVER_CONTAINERS) $(NOMAD_CLIENT_CONTAINERS)
LXD_START_TARGETS = $(NOMAD_SERVER_TARGETS:%=lxd-start-%) $(NOMAD_CLIENT_TARGETS:%=lxd-start-%)
LXD_STOP_TARGETS = $(NOMAD_SERVER_TARGETS:%=lxd-stop-%) $(NOMAD_CLIENT_TARGETS:%=lxd-stop-%)
LXD_CLEAN_TARGETS = $(NOMAD_SERVER_TARGETS:%=lxd-clean-%) $(NOMAD_CLIENT_TARGETS:%=lxd-clean-%)

include ../../contrib/make/targets/lxd/lxd.mk

THIS_FILE := $(firstword $(MAKEFILE_LIST))
SELF_DIR := $(dir $(THIS_FILE))
.PHONY: $(PROJECT_NAME)
.SILENT: $(PROJECT_NAME)
$(PROJECT_NAME): $(PROJECT_NAME)-containers
	- $(call print_running_target)
	- $(eval command=ansible-playbook -i inventories/staging site.yml --limit staging-servers)
ifneq ($(VAULT_PASSWORD_FILE),)
	- $(eval command=$(command) --vault-password-file $(VAULT_PASSWORD_FILE))
endif
	- $(eval command=$(command) && ansible-playbook -i inventories/staging site.yml --limit staging-clients)
ifneq ($(VAULT_PASSWORD_FILE),)
	- $(eval command=$(command) --vault-password-file $(VAULT_PASSWORD_FILE))
endif
	- @$(MAKE) --no-print-directory \
	 -f $(THIS_FILE) shell cmd="${command}"
ifneq ($(DELAY),)
	- sleep $(DELAY)
endif
	- $(call print_completed_target)
.PHONY: $(PROJECT_NAME)-containers
.SILENT: $(PROJECT_NAME)-containers
$(PROJECT_NAME)-containers:
	- $(call print_running_target)
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) $(LXD_TARGETS)
	- $(call print_completed_target)
.PHONY: $(PROJECT_NAME)-clean
.SILENT: $(PROJECT_NAME)-clean
$(PROJECT_NAME)-clean:
	- $(call print_running_target)
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) $(LXD_CLEAN_TARGETS)
	- $(call print_completed_target)