#include <stdio.h>
#include "test_utils/interactive_sync.h"

/* This function will be called automatically before `main`.*/
#ifdef MODULE_TEST_UTILS_INTERACTIVE_SYNC_AUTOCALL
void core_pre_main_function(void)
{
    test_utils_interactive_sync();
}
#endif

void test_utils_interactive_sync(void)
{
    char c = '\0'; /* Print help on first loop */
    do {
        if (c == 'r') {
            /* This one should have a different case than the help message
             * otherwise we match it when using 'expect' */
            puts("READY");
        }
        else if (c != '\n' && c != '\r') {
            puts("Help: Press s to start test, r to print it is ready");
        }
        c = getchar();
    } while (c != 's');

    puts("START");
}
