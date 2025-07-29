from meta.invert import getWrongAnswers


def test_all_A():
    assert getWrongAnswers(5, "AAAAA") == "BBBBB"


def test_all_B():
    assert getWrongAnswers(4, "BBBB") == "AAAA"


def test_alternating():
    assert getWrongAnswers(6, "ABABAB") == "BABABA"


def test_mixed():
    assert getWrongAnswers(3, "BAA") == "ABB"


def test_empty_string():
    assert getWrongAnswers(0, "") == ""


def test_long_input():
    input_str = "AB" * 50000  # length = 100000
    expected_output = "BA" * 50000
    assert getWrongAnswers(100000, input_str) == expected_output
