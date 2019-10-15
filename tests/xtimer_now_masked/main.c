/*
 * Copyright (C) 2019 Freie Universität Berlin
 *
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License v2.1. See the file LICENSE in the top level
 * directory for more details.
 */

/**
 * @ingroup     tests
 * @{
 *
 * @file
 * @brief       xtimer_usleep test application
 *
 * @author      Gaëtan Harter <gaetan.harter@fu-berlin.de>
 * @}
 */

#include <stdio.h>
#include "xtimer.h"

int main(void)
{
    xtimer_ticks32_t before, after;
    int irqstate;
#ifdef MODULE_PERIPH_TIMER_OVERFLOW
    int flag;
#endif

    while (true) {
        before = xtimer_now();

        irqstate = irq_disable();
        xtimer_spin((xtimer_ticks32_t){.ticks32=XTIMER_ISR_BACKOFF-1});
        after = xtimer_now();
#ifdef MODULE_PERIPH_TIMER_OVERFLOW
        flag = timer_get_overflow_flag(XTIMER_DEV);
#endif
        irq_restore(irqstate);

#ifdef MODULE_PERIPH_TIMER_OVERFLOW
        if (flag) {
            printf("Overflow flag: %u\n", flag);
        }
#endif
        if (before.ticks32 >= after.ticks32) {
            printf("%u: %lx < %lx\n", before.ticks32 < after.ticks32, before.ticks32, after.ticks32);
        }
    }
}
