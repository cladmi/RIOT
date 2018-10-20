#!/usr/bin/env python3

# Copyright (C) 2016 Kaspar Schleiser <kaspar@schleiser.de>
#
# This file is subject to the terms and conditions of the GNU Lesser
# General Public License v2.1. See the file LICENSE in the top level
# directory for more details.

import sys
from testrunner import run


def test1(child):
    child.expect_exact("######################### TEST1:")
    child.expect_exact("first: sem_init")
    child.expect_exact("first: thread create")
    child.expect_exact("first: sem_getvalue")
    child.expect_exact("first: sem_getvalue != 0")
    child.expect_exact("first: do yield")
    child.expect_exact("second: sem_trywait")
    child.expect_exact("second: sem_trywait done with == 0")
    child.expect_exact("second: wait for post")
    child.expect_exact("first: done yield")
    child.expect_exact("first: sem_trywait")
    child.expect_exact("first: sem_trywait FAILED")
    child.expect_exact("first: sem_trywait done")
    child.expect_exact("first: sem_post")
    child.expect_exact("second: sem was posted")
    child.expect_exact("second: end")
    child.expect_exact("first: sem_post done")
    child.expect_exact("first: sem_destroy")
    child.expect_exact("first: end")


def test2(child):
    child.expect_exact("######################### TEST2:")
    child.expect_exact("first: sem_init")
    child.expect_exact("first: thread create: 5")
    child.expect_exact("first: thread created: priority 5 (1/5)")
    child.expect_exact("first: thread create: 4")
    child.expect_exact("first: thread created: priority 4 (2/5)")
    child.expect_exact("first: thread create: 3")
    child.expect_exact("first: thread created: priority 3 (3/5)")
    child.expect_exact("first: thread create: 2")
    child.expect_exact("first: thread created: priority 2 (4/5)")
    child.expect_exact("first: thread create: 1")
    child.expect_exact("first: thread created: priority 1 (5/5)")
    child.expect_exact("------------------------------------------")
    child.expect_exact("post no. 0")
    child.expect_exact("Thread 'priority 1' woke up.")
    child.expect_exact("Back in main thread.")
    child.expect_exact("post no. 1")
    child.expect_exact("Thread 'priority 2' woke up.")
    child.expect_exact("Back in main thread.")
    child.expect_exact("post no. 2")
    child.expect_exact("Thread 'priority 3' woke up.")
    child.expect_exact("Back in main thread.")
    child.expect_exact("post no. 3")
    child.expect_exact("Thread 'priority 4' woke up.")
    child.expect_exact("Back in main thread.")
    child.expect_exact("post no. 4")
    child.expect_exact("Thread 'priority 5' woke up.")
    child.expect_exact("Back in main thread.")


def test3(child):
    child.expect_exact("######################### TEST3:")
    child.expect_exact("first: sem_init s1")
    child.expect_exact("first: sem_init s2")
    child.expect_exact("first: create thread 1")
    child.expect_exact("first: create thread 2")
    child.expect_exact("------------------------------------------")
    child.expect_exact("post s1")
    child.expect_exact("Thread 1 woke up after waiting for s1.")
    child.expect_exact("post s2")
    child.expect_exact("Thread 2 woke up after waiting for s2.")
    child.expect_exact("post s2")
    child.expect_exact("Thread 1 woke up after waiting for s2.")
    child.expect_exact("post s1")
    child.expect_exact("Thread 2 woke up after waiting for s1.")


def test4(child):
    child.expect_exact("######################### TEST4:")
    child.expect_exact("first: sem_init s1")
    child.expect_exact("first: wait 1 sec for s1")
    child.expect_exact("first: timed out")
    child.expect(r"first: waited 1\d{6} usec")


def main(child):
    test1(child)
    test2(child)
    test3(child)
    test4(child)
    child.expect("######################### DONE")


if __name__ == "__main__":
    sys.exit(run(testfunc))
