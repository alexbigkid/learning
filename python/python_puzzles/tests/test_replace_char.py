import unittest
from abk_apple.replace_char import replace_character

class TestSolution(unittest.TestCase):
    def test_1(self):
        self.assertEqual(replace_character("hello, world", "o", "a"), 'hella, warld')

    def test_2(self):
        self.assertEqual(replace_character("python coding", "o", "a"), 'pythan cading')

    def test_3(self):
        self.assertEqual(replace_character("replace character", "a", "o"), 'reploce chorocter')

    def test_4(self):
        self.assertEqual(replace_character("practice makes perfect", "e", "i"), 'practici makis pirfict')

    def test_5(self):
        self.assertEqual(replace_character("we are practicing string manipulations", "i", "o"), 'we are practocong strong manopulatoons')

    def test_6(self):
        self.assertEqual(replace_character("this function replaces one character with another", "a", "e"), 'this function repleces one cherecter with enother')

    def test_7(self):
        self.assertEqual(replace_character("keep practicing, you're doing great!", "e", "a"), "kaap practicing, you'ra doing graat!")

    def test_8(self):
        self.assertEqual(replace_character("this is a string where each occurrence of c1 is being replaced by c2", "c", "d"), 'this is a string where eadh oddurrende of d1 is being repladed by d2')

    def test_9(self):
        self.assertEqual(replace_character("the quick brown fox jumps over the lazy dog", "o", "a"), 'the quick brawn fax jumps aver the lazy dag')

    def test_10(self):
        self.assertEqual(replace_character("all consonants are replaced by vowels", "a", "e"), 'ell consonents ere repleced by vowels')

if __name__ == '__main__':
    unittest.main()
