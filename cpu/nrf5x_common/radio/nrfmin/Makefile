MODULE = nrfmin

SRC = nrfmin.c

# TODO This is somehow an 'implement' by 'nrfmin_gnrc' pseudomodule
ifneq (,$(filter gnrc_netdev_default,$(USEMODULE)))
  SRC += nrfmin_gnrc.c
endif

include $(RIOTBASE)/Makefile.base
