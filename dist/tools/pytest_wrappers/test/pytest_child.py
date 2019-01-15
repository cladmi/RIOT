"""
pytest integration helper for 'testrunner'.

Logging on the console while running tests can be disabled by setting
environment variable TEST_LOG_CONSOLE=0 (default: 1)

The test timeout is extracted if possible from the 'testrunner.run' timeout
argument (text extracted)
"""
import os
import sys
import re

import pexpect
import pytest

from testrunner.spawn import setup_child, teardown_child


TEST_LOG_CONSOLE = bool(int(os.environ.get('TEST_LOG_CONSOLE', '1')))


class CustomSpawn(pexpect.spawn):
    """Convenient subclass to better catch pexpect timeout and eof errors.

    Catch the pexpect exceptions and replace the value wih the called pattern.
    At the same time, remove all traceback and context as we do not care about
    where in the original pexpect library.
    """

    def __init__(self, *args, **kwargs):
        kwargs.setdefault('encoding', 'utf-8')
        super().__init__(*args, **kwargs)

    def expect(self, pattern, *args, **kwargs):
        # pylint:disable=arguments-differ
        try:
            return super().expect(pattern, *args, **kwargs)
        except (pexpect.TIMEOUT, pexpect.EOF) as exc:
            exc.orig_value = exc.value
            exc.value = pattern
            raise exc.with_traceback(None) from None

    def expect_exact(self, pattern, *args, **kwargs):
        # pylint:disable=arguments-differ
        try:
            return super().expect_exact(pattern, *args, **kwargs)
        except (pexpect.TIMEOUT, pexpect.EOF) as exc:
            exc.orig_value = exc.value
            exc.value = pattern
            raise exc.with_traceback(None) from None


@pytest.fixture(scope="module")
def child(request, timeout=None, logconsole=TEST_LOG_CONSOLE):
    """Implement the 'child' fixture."""
    timeout_kwargs = {}
    timeout = _test_timeout(request, timeout)
    if timeout is not None:
        timeout_kwargs['timeout'] = timeout

    logfile = ConsoleAndCapture() if logconsole else sys.stdout

    _child = setup_child(spawnclass=CustomSpawn,
                         logfile=logfile, **timeout_kwargs)

    yield _child

    print("")
    teardown_child(_child)


def _test_timeout(request, timeout=None):
    """Try to extract the timeout from the calling 'request' context.

    Returns 'timeout' if not None otherwise, check the text of the script
    to find `run` 'timeout=' argument
    """
    if timeout is None:
        timeout = _read_run_timeout(request.module.__file__)
    return timeout


def _read_run_timeout(testfile):
    """Return the 'timeout' value from the test file.

    This is a hack to extract timeout from the test file.
    """
    run_args_re = re.compile(r'^    sys.exit\(run\([^,]+(.*)\)\)$')
    timeout_re = re.compile(r'timeout=(\d+)')

    with open(testfile) as testfd:
        for line in testfd:
            args_match = run_args_re.match(line)
            if not args_match:
                continue
            run_args = args_match.group(1)

            # Found the 'run' function and arguments

            timeout_match = timeout_re.search(run_args)
            if not timeout_match:
                return None
            timeout = timeout_match.group(1)

            return int(timeout)

    raise ValueError("Could not extract 'timeout'")


class ConsoleAndCapture():
    """Write both to Console (__stdout__) and Capture (stdout)."""
    @staticmethod
    def write(data):
        """Write data to outputs."""
        sys.stdout.write(data)
        sys.__stdout__.write(data)

    @staticmethod
    def flush():
        """Flush outputs."""
        sys.stdout.flush()
        sys.__stdout__.flush()
