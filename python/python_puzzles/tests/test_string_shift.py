import unittest
from abk_apple.string_shift import solution

class SolutionTests(unittest.TestCase):
    def test1(self):
        self.assertEqual(solution("abc123XYz!"), "bcd123YZa!")

    def test2(self):
        self.assertEqual(solution("Hello, World!"), "Ifmmp, Xpsme!")

    def test3(self):
        self.assertEqual(solution("9876543210"), "9876543210")

    def test4(self):
        self.assertEqual(solution("nhpq$%EPV45JZ"), "oiqr$%FQW45KA")

    def test5(self):
        self.assertEqual(solution("Pythoniscool"), "Qzuipojtdppm")

    def test6(self):
        self.assertEqual(solution("Zebra"), "Afcsb")

    def test7(self):
        self.assertEqual(solution("InterviewPreparation"), "JoufswjfxQsfqbsbujpo")

    def test8(self):
        self.assertEqual(solution("YWXyz"), "ZXYza")

    def test9(self):
        self.assertEqual(solution("shift123"), "tijgu123")

    def test10(self):
        self.assertEqual(solution("adZ$56Y"), "beA$56Z")


if __name__ == '__main__':
    unittest.main()
