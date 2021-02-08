import unittest


class UnitTestSample(unittest.TestCase):
    """
    The Python / pytest Github Action requires at least one python test to enforce all python tasks in the repo pass.
    """

    def test_sample(self):
        assert True
