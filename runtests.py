import sys
import doctest
import unittest

import test_py

try:
    import test_pyx
except ImportError:
    test_pyx = None

if __name__ == '__main__':
    suite = unittest.TestSuite()
    suite.addTest(doctest.DocTestSuite(test_py))
    if test_pyx:
        suite.addTest(doctest.DocTestSuite(test_pyx))
    runner = unittest.TextTestRunner(verbosity=2)
    if not runner.run(suite).wasSuccessful():
        sys.exit(1)
