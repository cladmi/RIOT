/*
 * Copyright (C) 2019 Freie Universität Berlin,
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
 * @brief       testing pthreads with shell
 *
 *
 * @author      Julian Holzwarth <julian.holzwarth@fu-berlin.de>
 *
 */

#include <stdio.h>

#include "shell.h"
#include "kernel_types.h"
#include "thread.h"
#include "pthread.h"
#include "mutex.h"

static int cmd_create_pthread(int argc, char **argv);
static int cmd_kill_pthread(int argc, char **argv);

/**
 * @brief   List of command for this application.
 */
static const shell_command_t shell_commands[] = {
    { "create", "create a pthread",
      cmd_create_pthread, },
    { "kill", "kill a pthread",
      cmd_kill_pthread, },
    { NULL, NULL, NULL }
};

mutex_t exit_mutex_list[MAXTHREADS];

void exit_mutex_list_init(pthread_t th_id)
{
    mutex_init(&exit_mutex_list[th_id - 1]);
    mutex_lock(&exit_mutex_list[th_id - 1]);
}

void exit_mutex_list_unlock_delete(pthread_t th_id)
{
    mutex_unlock(&exit_mutex_list[th_id - 1]);
}

void exit_mutex_list_lock(pthread_t th_id)
{
    mutex_lock(&exit_mutex_list[th_id - 1]);
}

typedef struct {
    char *string;
    pthread_t th_id;
}pthread_arg_t;

static void *pthread_function(void *param)
{
    pthread_arg_t *pthread_arg = (pthread_arg_t *)param;

    printf("'%s'\n", pthread_arg->string);
    pthread_t my_id = pthread_self();
    exit_mutex_list_lock(my_id);
    puts("I exit.");
    return 0;
}

static int cmd_create_pthread(int argc, char **argv)
{
    pthread_arg_t pthread_arg;

    if (argc < 2) {
        pthread_arg.string = "";
    }
    else {
        pthread_arg.string = argv[1];
    }
    pthread_t th_id;
    pthread_attr_t th_attr;
    pthread_attr_init(&th_attr);

    pthread_create(&th_id, &th_attr, pthread_function, &pthread_arg);
    exit_mutex_list_init(th_id);
    printf("pthread id: %d \n", (int)th_id);
    thread_yield();
    return 0;
}

static int cmd_kill_pthread(int argc, char **argv)
{
    if (argc != 2) {
        puts("no id");
        return 0;
    }
    int id;
    /* cannot use stdlib.h */
    if (sscanf(argv[1], "%d", &id) != 1) {
        puts("wrong arguments");
        return 0;
    }
    if (id > MAXTHREADS || id < 1) {
        puts("not a valid id");
        return 0;
    }

    exit_mutex_list_unlock_delete(id);
    thread_yield();

    return 0;
}

/**
 * @brief   main function starting shell
 *
 * @return 0 on success
 */
int main(void)
{
    puts("Starting shell...");
    char line_buf[SHELL_DEFAULT_BUFSIZE];
    shell_run(shell_commands, line_buf, SHELL_DEFAULT_BUFSIZE);

    return 0;
}
