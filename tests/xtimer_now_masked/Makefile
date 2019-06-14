include ../Makefile.tests_common

USEMODULE += xtimer

# This test randomly fails on `native` so disable it from CI
# Test on a board with only a 16 bit width and 1Mhz
# On 'samr21-xpro' it would take ~1h12m
TEST_ON_CI_WHITELIST += frdm-kw41z

include $(RIOTBASE)/Makefile.include
