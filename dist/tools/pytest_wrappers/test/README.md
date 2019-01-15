`pytest_child`
==============


Adds a `pytest` command to RIOT that executes tests and generates an JUnitXML
output.


Usage
-----

    RIOT_MAKEFILES_GLOBAL_POST='$(RIOTTOOLS)/pytest_wrappers/test/pytest.mk.post' make -C tests/bloom_bytes/ flash pytest


Configuration/Integration
-------------------------

The documentation is kept at the beginning of the `pytest_child.py` to not
duplicate information.
