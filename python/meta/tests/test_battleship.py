from meta.battleship import getHitProbability


def test_all_zeros():
    G = [[0, 0], [0, 0]]
    assert getHitProbability(2, 2, G) == 0.0


def test_all_ones():
    G = [[1, 1], [1, 1]]
    assert getHitProbability(2, 2, G) == 1.0


def test_mixed_values():
    G = [[0, 1], [1, 0]]
    assert getHitProbability(2, 2, G) == 0.5


def test_single_cell_hit():
    G = [[1]]
    assert getHitProbability(1, 1, G) == 1.0


def test_single_cell_miss():
    G = [[0]]
    assert getHitProbability(1, 1, G) == 0.0


def test_non_square_grid():
    G = [[1, 0, 1], [0, 1, 0]]
    assert getHitProbability(2, 3, G) == 0.5


def test_large_grid():
    G = [[1] * 100 for _ in range(100)]  # 100x100 grid of 1s
    assert getHitProbability(100, 100, G) == 1.0
