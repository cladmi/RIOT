include ../Makefile.tests_common

BOARD_INSUFFICIENT_MEMORY := \
	arduino-duemilanove \
	arduino-nano \
	arduino-uno \
	nucleo-f031k6 \
	hifive1 \
	hifive1b \
	i-nucleo-lrwan1 \
	stm32l0538-disco \
	#

# The test reboots on 'arduino-mega2560' because it mallocs too much memory.
# So I disabled all the other avr boards. Re-enable after success test.
BOARD_INSUFFICIENT_MEMORY += \
	arduino-leonardo \
	arduino-mega2560 \
	jiminy-mega256rfr2 \
	mega-xplained \
	waspmote-pro \
	#

USEMODULE += posix_headers
USEMODULE += pthread

include $(RIOTBASE)/Makefile.include
