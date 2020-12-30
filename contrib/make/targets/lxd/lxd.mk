
PROJECT_TARGETS:=$(PROJECT_NAME)
ifneq ($(CONTAINER_COUNT),)
CONTAINER_SEQ:=$(shell seq $(CONTAINER_COUNT))
PROJECT_TARGETS = $(CONTAINER_SEQ:%=$(PROJECT_NAME)-%)
endif

PROJECT_CONTAINERS=$(PROJECT_TARGETS:%=lxd-%)
LXD_TARGETS = $(PROJECT_CONTAINERS)
LXD_LAUNCH_TARGETS = $(PROJECT_TARGETS:%=lxd-launch-%)
LXD_START_TARGETS = $(PROJECT_TARGETS:%=lxd-start-%)
LXD_STOP_TARGETS = $(PROJECT_TARGETS:%=lxd-stop-%)
LXD_CLEAN_TARGETS = $(PROJECT_TARGETS:%=lxd-clean-%)

.PHONY: $(LXD_TARGETS)
.SILENT: $(LXD_TARGETS)
$(LXD_TARGETS):
	- $(call print_running_target)
	- $(eval name=$(@:lxd-%=%))
	- $(eval command=lxd-debian)
	- $(eval command=$(command) --name '$(name)')
	- $(eval command=$(command) --ssh-config)
	- $(eval command=$(command) --python)
	- $(eval command=$(command) --starship)
	- $(eval command=$(command) --rg)
	- $(eval command=$(command) --spacevim)
	- @$(MAKE) --no-print-directory \
	 -f $(THIS_FILE) shell cmd="${command}"
ifneq ($(DELAY),)
	- sleep $(DELAY)
endif
	- $(call print_completed_target)
.PHONY: $(LXD_LAUNCH_TARGETS)
.SILENT: $(LXD_LAUNCH_TARGETS)
$(LXD_LAUNCH_TARGETS): 
	- $(call print_running_target)
	- $(eval name=$(@:lxd-launch-%=%))
	- $(call print_running_target, launching a new LXD container with name of $(name) and base image of $(LXC_IMAGE))
	- $(eval command=lxc launch $(LXC_IMAGE) "$(name)")
	- $(eval command=$(command) || lxc start "$(name)")
	- @$(MAKE) --no-print-directory \
	 -f $(THIS_FILE) shell cmd="${command}"
ifneq ($(DELAY),)
	- sleep $(DELAY)
endif
	- $(call print_completed_target)

.PHONY: lxd-stop
.SILENT: lxd-stop
lxd-stop:
	- $(call print_running_target)
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) $(LXD_STOP_TARGETS)
	- $(call print_completed_target)
.PHONY: $(LXD_STOP_TARGETS)
.SILENT: $(LXD_STOP_TARGETS)
$(LXD_STOP_TARGETS): 
	- $(call print_running_target)
	- $(eval name=$(@:lxd-stop-%=%))
	- $(call print_running_target, stopping $(name) LXD container forcefully)
	- $(eval command=lxc stop $(name) --force || true)
	- @$(MAKE) --no-print-directory \
	 -f $(THIS_FILE) shell cmd="${command}"
	- $(call print_completed_target)
.PHONY: lxd-clean
.SILENT: lxd-clean
lxd-clean:
	- $(call print_running_target)
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) $(LXD_CLEAN_TARGETS)
	- $(call print_completed_target)
.PHONY: $(LXD_CLEAN_TARGETS)
.SILENT: $(LXD_CLEAN_TARGETS)
$(LXD_CLEAN_TARGETS):  lxd-clean-%:lxd-stop-%
	- $(call print_running_target)
	- $(eval name=$(@:lxd-clean-%=%))
	- $(call print_running_target, removing $(name) LXD container)
	- $(eval command=lxc delete $(name))
	- @$(MAKE) --no-print-directory \
	 -f $(THIS_FILE) shell cmd="${command}"
	- $(call print_completed_target)
.PHONY: lxd
.SILENT: lxd
lxd: 
	- $(call print_running_target)
	- $(info CONTAINER_NAME >> $(CONTAINER_NAME) )
	- $(info $(LXD_TARGETS))
	- $(info $(LXD_LAUNCH_TARGETS))
	- $(info $(LXD_START_TARGETS))
	- $(call print_completed_target)

