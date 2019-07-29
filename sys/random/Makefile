BASE_MODULE := prng

SUBMODULES += prng_fortuna
SUBMODULES += prng_mersenne
SUBMODULES += prng_minstd
SUBMODULES += prng_musl_lcg
SUBMODULES += prng_sha1prng
SUBMODULES += prng_tinymt32
SUBMODULES += prng_xorshift

ifneq (,$(filter prng_fortuna,$(USEMODULE)))
  DIRS += fortuna
endif

ifneq (,$(filter prng_tinymt32,$(USEMODULE)))
  DIRS += tinymt32
endif

include $(RIOTBASE)/Makefile.base
