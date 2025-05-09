"""Unit tests for testDisply.py"""

# Standard library imports
import os
import logging
import unittest
from unittest.mock import ANY, MagicMock, call, patch

# Third party imports
from parameterized import parameterized

# Own modules imports



logging.basicConfig(format='[%(funcName)s]:[%(levelname)s]: %(message)s')
tst_logger = logging.getLogger(__name__)
log_level = os.environ.get('LOG_LEVEL', 'WARNING').upper()
tst_logger.setLevel(logging.getLevelName(log_level))


# -----------------------------------------------------------------------------
# class for testing testDisply main functionality
# -----------------------------------------------------------------------------
class TesttestDisply(unittest.TestCase):
    """Test for testDisply"""

    @classmethod
    def setUpClass(cls):
        logging.disable(logging.CRITICAL) # disables logging
        # logging.disable(logging.NOTSET) # enables logging

    @classmethod
    def tearDownClass(cls):
        logging.disable(logging.NOTSET)


    def setUp(self) -> None:
        self.maxDiff = None
        return super().setUp()


    # -------------------------------------------------------------------------
    # Tests simple case
    # -------------------------------------------------------------------------
    def test_simple_case(self) -> None:
        """Validates simple behavior"""
        # Arrange
        # ---------------------------------------------------------------------
        expected = 89
        

        # Act
        # ---------------------------------------------------------------------
        actual = 10 * 8 + 9

        # Assert
        # ---------------------------------------------------------------------
        self.assertEqual(actual, expected, f'Unexpected result: {actual}')


    # -------------------------------------------------------------------------
    # Tests composite case
    # -------------------------------------------------------------------------
    @parameterized.expand([
        # str1,  str2,   expected
        ['tst1', 'tst2', 'tst1_tst2'],
        ['tst3', 'tst4', 'tst3_tst4'],
    ])
    def test_composite_case(self, str1:str, str2:str, expected:str) -> None:
        """Validates all cases"""
        # Arrange
        # ---------------------------------------------------------------------

        # Act
        # ---------------------------------------------------------------------
        actual = f'{str1}_{str2}'

        # Assert
        # ---------------------------------------------------------------------
        self.assertEqual(actual, expected, f'Unexpected result: {actual}')


    def test_does_something__given_condition(self) -> None:
        """Validates simple behavior"""
        # Arrange
        # -------------------------------------------------------------------------
        expected = 89

    
        # Act
        # -------------------------------------------------------------------------
        actual = 10 * 8 + 9
    
        # Assert
        # -------------------------------------------------------------------------
        self.assertEqual(actual, expected, f'Unexpected result: {actual}')
    
    @parameterized.expand([
        # str1,  str2,   expected
        ['tst1', 'tst2', 'tst1_tst2'],
        ['tst3', 'tst4', 'tst3_tst4'],
    ])
    def test_does_something__given_condition(self, str1:str, str2:str, expected:str) -> None:
        """Validates all cases"""
        # Arrange
        # -------------------------------------------------------------------------
        
    
        # Act
        # -------------------------------------------------------------------------
        actual = f'{str1}_{str2}'
    
        # Assert
        # -------------------------------------------------------------------------
        self.assertEqual(actual, expected, f'Unexpected result: {actual}')
    
    

if __name__ == '__main__':
    unittest.main()
