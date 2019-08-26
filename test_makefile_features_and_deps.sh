#! /bin/bash

cd $(dirname $0)

#
# Check in features files to try detecting non authorized lines patterns
#
# This allows detecting emergent way of doing things in Makefile.features files.
# They should either be fixed in the board/cpu definition, or add support in the
# build system if it is justified.
#
# Less is better!
#
# Allow having for boards and cpu:
# * Comments and empty lines
# * FEATURES_PROVIDED +=
# * FEATURES_CONFLICT +=  FEATURES_CONFLICT_MSG +=
# * endif/else (no conditions for the allowed 'if' yet)
#
# For boards only
# * CPU CPU_MODEL
# * including $(RIOTBOARD)/.*/Makefile.features
#
# For CPU only
# * including $(RIOTCPU)/.*/Makefile.features



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# It is not ok to add random lines to make your cpu/board pass this test. #
# It should be fixed or prove it is something that should be supported.   #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


EMPTY_LINES_ARRAY=(-e '^[[:space:]]*#' -e '^$')

FEATURES_LINES_ARRAY=()
FEATURES_LINES_ARRAY+=(-e '^[[:space:]]*FEATURES_PROVIDED +=')
FEATURES_LINES_ARRAY+=(-e '^FEATURES_CONFLICT +=' -e 'FEATURES_CONFLICT_MSG +=')
FEATURES_LINES_ARRAY+=(-e '^endif' -e '^else')

BOARD_LINES_ARRAY=()
BOARD_LINES_ARRAY+=("${EMPTY_LINES_ARRAY[@]}")
BOARD_LINES_ARRAY+=("${FEATURES_LINES_ARRAY[@]}")
BOARD_LINES_ARRAY+=(-e '^CPU =' -e '^CPU_MODEL =')
BOARD_LINES_ARRAY+=(-e '^include $(RIOTBOARD)/.*/Makefile.features')

CPU_LINES_ARRAY=()
CPU_LINES_ARRAY+=("${EMPTY_LINES_ARRAY[@]}")
CPU_LINES_ARRAY+=("${FEATURES_LINES_ARRAY[@]}")
CPU_LINES_ARRAY+=(-e '^[-]*include $(RIOTCPU)/.*/Makefile.features')



BOARD_FEATURES_FILES_ARRAY=(boards/*/Makefile.features boards/common/*/Makefile.features)
CPU_FEATURES_FILES_ARRAY=(cpu/*/Makefile.features)

DEP_LINES_ARRAY=()
DEP_LINES_ARRAY+=("${EMPTY_LINES_ARRAY[@]}")
DEP_LINES_ARRAY+=(-e 'include .*/Makefile.dep')
DEP_LINES_ARRAY+=(-e 'ifneq (,$(filter .*,$(USEMODULE)))')
DEP_LINES_ARRAY+=(-e 'ifneq (,$(filter .*,$(USEPKG)))')
DEP_LINES_ARRAY+=(-e 'ifneq (,$(filter .*,$(FEATURES_USED)))')
DEP_LINES_ARRAY+=(-e '^USEMODULE +=' -e '  USEMODULE +=')
DEP_LINES_ARRAY+=(-e '^USEPKG +=' -e '  USEPKG +=')
DEP_LINES_ARRAY+=(-e '^FEATURES_REQUIRED +=' -e '  FEATURES_REQUIRED +=')
DEP_LINES_ARRAY+=(-e '^FEATURES_OPTIONAL +=' -e '  FEATURES_OPTIONAL +=')
DEP_LINES_ARRAY+=(-e '^endif')

# Not that I want these in that way but they are currently there
# Default handling
DEP_LINES_ARRAY+=(-e '^  ifeq (,$(filter .*,$(USEMODULE)))')
DEP_LINES_ARRAY+=(-e '^  endif')

DEP_LINES_ARRAY+=(-e '^OLD_USEMODULE := $(sort $(USEMODULE))')
DEP_LINES_ARRAY+=(-e '^OLD_USEPKG := $(sort $(USEPKG))')
DEP_LINES_ARRAY+=(-e '^USEMODULE := $(sort $(USEMODULE))')
DEP_LINES_ARRAY+=(-e '^USEPKG := $(sort $(USEPKG))')
DEP_LINES_ARRAY+=(-e '^ifneq ($(OLD_USEMODULE) $(OLD_USEPKG),$(USEMODULE) $(USEPKG))')


check_board_features() {
    grep -n -v "${BOARD_LINES_ARRAY[@]}" $@

    # 0 is an error as there are lines
    (($? != 0))
    return $?
}

check_cpu_features() {
    grep -n -v "${CPU_LINES_ARRAY[@]}" $@

    # 0 is an error as there are lines
    (($? != 0))
    return $?
}

check_dep() {
    git --no-pager grep -n -v "${DEP_LINES_ARRAY[@]}" '**/Makefile.dep' 'Makefile.dep'
    # 0 is an error as there are lines
    (($? != 0))
    return $?
}


check_cpu_and_board_features() {
    local error=0

    dist/tools/buildsystem_sanity_check/check.sh
    error=$(($? || ${error}))

    check_board_features "${BOARD_FEATURES_FILES_ARRAY[@]}"
    error=$(($? || ${error}))

    check_cpu_features "${CPU_FEATURES_FILES_ARRAY[@]}"
    error=$(($? || ${error}))

    check_dep
    error=$(($? || ${error}))
    return ${error}
}


check_cpu_and_board_features
exit $?
