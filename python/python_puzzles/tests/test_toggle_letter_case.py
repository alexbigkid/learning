import unittest
from abk_apple.toggle_letter_case import solution

class SolutionTests(unittest.TestCase):
    def test_case_1(self):
        self.assertEqual(solution("CaSeChAnGe"), "cAsEcHaNgE")

    def test_case_2(self):
        self.assertEqual(solution("HELLO"), "hello")

    def test_case_3(self):
        self.assertEqual(solution("world"), "WORLD")

    def test_case_4(self):
        self.assertEqual(solution("f"), "F")

    def test_case_5(self):
        self.assertEqual(solution("D"), "d")

    def test_case_6(self):
        self.assertEqual(solution("S5Fg7shJ8HG789"), "s5fG7SHj8hg789")

    def test_case_7(self):
        self.assertEqual(solution("@#%AbC"), "@#%aBc")

    def test_case_8(self):
        self.assertEqual(solution("pYTHONpROGRAM"), "PythonProgram")

    def test_case_9(self):
        self.assertEqual(solution("P"*50 + "q"*50), "p"*50 + "Q"*50)

    def test_case_10(self):
        self.assertEqual(solution(""), "")

    def test_case_11(self):
        self.assertEqual(solution("abcdefghijklmnopqrstuvwxyz"), "ABCDEFGHIJKLMNOPQRSTUVWXYZ")

    def test_case_12(self):
        self.assertEqual(solution("ABCDEFGHIJKLMNOPQRSTUVWXYZ"), "abcdefghijklmnopqrstuvwxyz")

    def test_case_13(self):
        self.assertEqual(solution("aBcDeFgHiJkLmNoPqRsTuVwXyZ"), "AbCdEfGhIjKlMnOpQrStUvWxYz")

if __name__ == '__main__':
    unittest.main()
