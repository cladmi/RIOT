MODULE = cpu

DIRS = periph $(RIOTCPU)/arm7_common

ifneq (,$(filter mci,$(USEMODULE)))
  DIRS += mci
endif
ifneq (,$(filter i2c,$(USEMODULE)))
  DIRS += i2c
endif

include $(RIOTBASE)/Makefile.base
