import unittest
from abk_apple.palindrome import solution


class TestPalindromeCheck(unittest.TestCase):
    def test_case_1(self):
        self.assertEqual(solution("racecar"), True)

    def test_case_2(self):
        self.assertEqual(solution("hello"), False)

    def test_case_3(self):
        self.assertEqual(solution("A man, a plan, a canal: Panama"), True)

    def test_case_4(self):
        self.assertEqual(solution("aha"), True)

    def test_case_5(self):
        self.assertEqual(solution("1234321"), True)

    def test_case_6(self):
        self.assertEqual(solution("Python"), False)

    def test_case_7(self):
        self.assertEqual(solution("Was it a car or a cat I saw?"), True)

    def test_case_8(self):
        self.assertEqual(solution("Able, was I saw Elba"), True)

    def test_case_9(self):
        self.assertEqual(solution("A1B2c3c2b1a"), True)

    def test_case_10(self):
        self.assertEqual(solution("!@#$%^&*()"), True)


if __name__ == '__main__':
    unittest.main()
