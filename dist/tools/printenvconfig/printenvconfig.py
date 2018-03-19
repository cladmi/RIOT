#! /usr/bin/env python3

#
# Copyright (C) 2018 Gaëtan Harter <gaetan.harter@fu-berlin.de>
#
# This file is subject to the terms and conditions of the GNU Lesser
# General Public License v2.1. See the file LICENSE in the top level
# directory for more details.
#

"""
printenvconfig

Print evironment variables given as arguments.
The format is the equivalent of 'printenv' output for given variables.

Usage
-----

    usage: printenvconfig.py [-h] variable [variable ...]

    Print given environment variable to stdout.

    positional arguments:
    variable    Environment variables

    optional arguments:
    -h, --help  show this help message and exit

Example
-------

    OTHER_VAR=test ./printenvconfig.py EDITOR SHELL OTHER_VAR
    EDITOR=vim
    SHELL=/bin/bash
    OTHER_VAR=test

"""

import os
import argparse

DESCRIPTION = 'Print given environment variable to stdout.'
PARSER = argparse.ArgumentParser(description=DESCRIPTION)
PARSER.add_argument('variable', nargs='+', help='Environment variables')


def main():
    """Write stdin to given <outfile> if it would change its content."""
    opts = PARSER.parse_args()

    values = ((var, os.environ.get(var, '')) for var in opts.variable)

    # Output VAR=$(VAR)
    for var, value in values:
        print('{}={}'.format(var, value))


if __name__ == '__main__':
    main()
