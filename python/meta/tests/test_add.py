from meta.add import getSum


def test_positive_numbers():
    assert getSum(1, 2, 3) == 6


def test_zero_values():
    assert getSum(0, 0, 0) == 0


def test_negative_numbers():
    assert getSum(-1, -2, -3) == -6


def test_mixed_signs():
    assert getSum(-5, 10, -3) == 2


def test_large_numbers():
    assert getSum(1000000, 2000000, 3000000) == 6000000
