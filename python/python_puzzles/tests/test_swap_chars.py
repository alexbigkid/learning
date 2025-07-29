import unittest
from abk_apple.swap_chars import solution

class SolutionTests(unittest.TestCase):
    def test1(self):
        self.assertEqual(solution("abcdef"), "badcfe")

    def test2(self):
        self.assertEqual(solution("hello"), "ehllo")

    def test3(self):
        self.assertEqual(solution("H"), "H")

    def test4(self):
        self.assertEqual(solution(""), "")

    def test5(self):
        self.assertEqual(solution("123456"), "214365")

    def test6(self):
        self.assertEqual(solution("!@#$%^&"), "@!$#^%&")

    def test7(self):
        self.assertEqual(solution("abcde"*20), "badcaecbed"*10)

    def test8(self):
        self.assertEqual(solution("!!!!!"), "!!!!!")

    def test9(self):
        self.assertEqual(solution("a"*99 + "b"), ("a"*98) + "ba")

if __name__ == '__main__':
    unittest.main()
