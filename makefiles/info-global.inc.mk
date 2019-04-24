.PHONY: info-buildsizes info-buildsizes-diff info-features-missing \
        info-boards-features-missing

# Features
FEATURES_DEPS_VARIABLES_COMMON += FEATURES_PROVIDED FEATURES_OPTIONAL FEATURES_REQUIRED
FEATURES_DEPS_VARIABLES_COMMON += FEATURES_CONFLICT FEATURES_CONFLICT_MSG
FEATURES_DEPS_VARIABLES_COMMON += FEATURES_MCU_GROUP
# Defined by Makefile.dep
FEATURES_DEPS_VARIABLES_COMMON += USEMODULE USEPKG DISABLE_MODULE
FEATURES_DEPS_VARIABLES_COMMON += OLD_USEMODULE OLD_USEPKG
FEATURES_DEPS_VARIABLES_COMMON += FEATURES_USED
# Defined here but should change
FEATURES_DEPS_VARIABLES_COMMON += FEATURES_MISSING
# Others
FEATURES_DEPS_VARIABLES_COMMON += BUILDTEST_MCU_GROUP

# BSP defined variables
FEATURES_DEPS_VARIABLES_COMMON += FEATURES_DEPS_VARIABLES
FEATURES_DEPS_VARIABLES = # Set to empty by default and must be set by each bsp


# TODO
#
# Maybe some variables must not be defined at all when starting to parse the
# files like 'CPU_MODEL' which is defined as `?=`.
#
# This would require some specific added handling


# Handling of saving and restoring global state variables
FEATURES_DEPS_VARIABLES_ALL = $(FEATURES_DEPS_VARIABLES_COMMON) $(FEATURES_DEPS_VARIABLES)
save-features-deps-variables = $(eval $(foreach var,$(FEATURES_DEPS_VARIABLES_ALL),$(eval __$(var)_saved := $($(var)))))
restore-features-deps-variables-immediate = $(eval $(foreach var,$(FEATURES_DEPS_VARIABLES_ALL),$(eval $(var) := $(__$(var)_saved))))


# Give information on which variable is set between 'saved' and 'added'
save-all-variables = $(eval _ALL_VARIABLES_SAVED:= $$(sort $(.VARIABLES) _ALL_VARIABLES_SAVED))
added-variables = $(strip $(foreach v,$(.VARIABLES),$(if $(findstring $(v),$(_ALL_VARIABLES_SAVED)),,$(v))))

define board_missing_features
  BOARD             := $(1)

  # Ensure only known variables are set when parsing dependencies
  # They will be restored after the parsing to their original value
  # Note: They will be re-evaluated to their immediate value
  $$(call save-features-deps-variables)

  # Save all current variables
  $$(call save-all-variables)

  include $$(RIOTBOARD)/$(1)/Makefile.features
  ifdef BUILDTEST_MCU_GROUP
    ifneq ($(BUILDTEST_MCU_GROUP), $$(FEATURES_MCU_GROUP))
      BOARDS_FEATURES_MISSING += "$(1) $(BUILDTEST_MCU_GROUP)"
    BOARDS_WITH_MISSING_FEATURES += $(1)
    endif
  endif

  include $(RIOTBASE)/Makefile.dep

  FEATURES_MISSING := $$(sort $$(filter-out $$(FEATURES_PROVIDED), $$(FEATURES_REQUIRED)))
  ifneq (, $$(FEATURES_MISSING))
    BOARDS_FEATURES_MISSING += "$(1) $$(FEATURES_MISSING)"
    ifneq (, $$(filter-out $$(FEATURES_OPTIONAL), $$(FEATURES_MISSING)))
      BOARDS_WITH_MISSING_FEATURES += $(1)
    endif
  endif

  # Check that no unknown variables were defined
  ifneq (,$$(call added-variables))
    $$(warning Board $(BOARD) added new variables when parsing dependencies)
    $$(warning Newly added variables '$$(call added-variables)')
    $$(warning These variables must be added to FEATURES_DEPS_VARIABLES in the board/cpu Makefile.features)
  endif

  $$(call restore-features-deps-variables-immediate)
endef

BOARDS ?= $(shell find $(RIOTBOARD)/* -maxdepth 0 -type d \! -name "common" -exec basename {} \;)
BOARDS := $(filter $(if $(BOARD_WHITELIST), $(BOARD_WHITELIST), %), $(BOARDS))
BOARDS := $(filter-out $(BOARD_BLACKLIST), $(BOARDS))

BOARDS_WITH_MISSING_FEATURES :=
BOARDS_FEATURES_MISSING :=
$(foreach BOARD, $(BOARDS), $(eval $(call board_missing_features,$(BOARD))))
BOARDS := $(filter-out $(BOARDS_WITH_MISSING_FEATURES), $(BOARDS))

info-buildsizes: SHELL=bash
info-buildsizes:
	@echo -e "   text\t   data\t    bss\t    dec\tboard"; \
	for board in $(BOARDS); do \
	    echo "$$(BOARD=$${board} $(MAKE) --no-print-directory info-buildsize 2>/dev/null | tail -n-1 | cut -f-4)" "$${board}"; \
	done;

info-buildsizes-diff: SHELL=bash
info-buildsizes-diff:
	@echo -e "text\tdata\tbss\tdec\tBOARD/BINDIRBASE\n"; \
	for board in $(BOARDS); do \
	  for BINDIRBASE in $${OLDBIN} $${NEWBIN}; do \
	      BINDIRBASE=$${BINDIRBASE} BOARD=$${board} $(MAKE) info-buildsize --no-print-directory 2>/dev/null | tail -n-1 | cut -f-4; \
	  done | \
	  while read -a OLD && read -a NEW; do \
	    for I in 0 1 2 3; do \
	      if [[ -n "$${NEW[I]}" && -n "$${OLD[I]}" ]]; then \
	        DIFF=$$(($${NEW[I]} - $${OLD[I]})); \
	        if [[ "$${DIFF}" -gt 0 ]]; then $(COLOR_ECHO) -n "$(COLOR_RED)"; fi; \
	        if [[ "$${DIFF}" -lt 0 ]]; then $(COLOR_ECHO) -n "$(COLOR_GREEN)"; fi; \
	      else \
	        DIFF="$(COLOR_RED)ERR"; \
	      fi; \
	      echo -ne "$${DIFF}\t$(COLOR_RESET)"; \
	    done; \
	    echo "$${board}"; \
	    for I in 0 1 2 3; do echo -ne "$${OLD[I]-$(COLOR_RED)ERR$(COLOR_RESET)}\t"; done; echo -e "$${OLDBIN}"; \
	    for I in 0 1 2 3; do echo -ne "$${NEW[I]-$(COLOR_RED)ERR$(COLOR_RESET)}\t"; done; echo -e "$${NEWBIN}\n"; \
	  done; \
	done;

info-boards-supported:
	@echo $(BOARDS)

info-boards-features-missing:
	@for f in $(BOARDS_FEATURES_MISSING); do echo $${f}; done | column -t
