# Default when RIOTBASE is not set and is executed from the RIOT directory
RIOTBOARD ?= $(or $(RIOTBASE),$(CURDIR))/boards

# List all boards.
# By default, all directories in RIOTBOARD except 'common'
#   use 'wildcard */.' to only list directories
ALLBOARDS ?= $(sort $(filter-out common,$(patsubst $(RIOTBOARD)/%/.,%,$(wildcard $(RIOTBOARD)/*/.))))

# Set the default value from `BOARDS`
BOARDS ?= $(ALLBOARDS)

# Enabled boards, whitelisted and not blacklisted
# It only has a sensible value from inside an application
BOARDS_ENABLED ?= $(filter-out $(BOARD_BLACKLIST),$(filter $(or $(BOARD_WHITELIST),%),$(BOARDS)))

.PHONY: info-boards info-boards-enabled
info-boards:
	@echo $(BOARDS)

info-boards-enabled:
	@echo $(BOARDS_ENABLED)
