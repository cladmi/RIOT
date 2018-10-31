#include "periph/timer.h"
#include "periph_timer_mock.h"

static struct {
    tim_t dev;
    unsigned long freq;
    timer_cb_t cb;
    void *cb_arg;
    /* Handle only one channel for now */
    int channel;
    unsigned int timeout_value;

    unsigned int current;
} mock_timer;


static void timer_cb_mock(void *arg, int channel)
{
    (void)arg;
    (void)channel;
}

int timer_init_mock(tim_t dev, unsigned long freq, timer_cb_t cb, void *arg)
{
    printf("timer_init_mock(%u): %lu, %p, %p\n", dev, freq, cb, arg);


    mock_timer.dev = dev;
    mock_timer.freq = freq;
    mock_timer.cb = cb;
    mock_timer.cb_arg = arg;

    mock_timer.current = 0;

    timer_init(dev, freq, timer_cb_mock, NULL);

    return 0;
}


unsigned int timer_read_mock(tim_t dev)
{
    printf("timer_read_mock(%u)\n", dev);
    return mock_timer.current;
}

int timer_set_absolute_mock(tim_t dev, int channel, unsigned int value)
{
    assert(channel == 0); /* Not handled more than one channel for the moment */
    printf("timer_set_absolute_mock(%u): channel %i, value %u\n", dev, channel, value);
    mock_timer.channel = channel;
    mock_timer.timeout_value = value;
    return 1;
}
