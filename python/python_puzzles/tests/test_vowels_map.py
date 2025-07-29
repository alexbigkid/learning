import unittest
from abk_apple.vowels_map import solution

class SolutionTests(unittest.TestCase):

    def test1(self):
        self.assertEqual(solution("hello"), [1, 4])

    def test2(self):
        self.assertEqual(solution("HEY"), [1])

    def test3(self):
        self.assertEqual(solution("hEllOworLd"), [1, 4, 6])

    def test4(self):
        self.assertEqual(solution("xyzxyz"), [])

    def test5(self):
        self.assertEqual(solution("aeiou"), [0, 1, 2, 3, 4])

    def test6(self):
        self.assertEqual(solution("AEIOUAEIOUaeiouaeiou"), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19])

    def test7(self):
        self.assertEqual(solution("a" * 500), list(range(500)))

    def test8(self):
        self.assertEqual(solution("b" * 500), [])

    def test9(self):
        self.assertEqual(solution("C" * 250 + "aeiou" * 50), list(range(250, 500)))

    def test10(self):
        self.assertEqual(solution("a" * 250 + "b" * 250), list(range(250)))

if __name__ == '__main__':
    unittest.main()
