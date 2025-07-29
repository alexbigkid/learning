from meta.cafeteria import getMaxAdditionalDinersCount


def test_no_existing_diners():
    assert getMaxAdditionalDinersCount(10, 1, 0, []) == 5  # Seats: 1,3,5,7,9


def test_example_case():
    assert getMaxAdditionalDinersCount(10, 1, 2, [2, 6]) == 3  # Seats: 4,8,10


def test_full_blockage():
    assert getMaxAdditionalDinersCount(5, 1, 3, [1, 3, 5]) == 0


def test_minimum_inputs():
    assert getMaxAdditionalDinersCount(1, 0, 0, []) == 1
    assert getMaxAdditionalDinersCount(1, 0, 1, [1]) == 0


def test_dense_existing_diners():
    assert getMaxAdditionalDinersCount(20, 2, 5, [3, 6, 9, 12, 15]) == 1  # Only seat 19 possible


def test_single_block_center():
    assert getMaxAdditionalDinersCount(15, 2, 1, [8]) == 4  # Seats: 1, 4, 11, 14


def test_tail_opening():
    assert getMaxAdditionalDinersCount(10, 2, 1, [1]) == 3  # Seats: 4, 7, 10


def test_large_input_sparse():
    # Only first and last seats are occupied; plenty of room in between
    test_num = getMaxAdditionalDinersCount(100, 2, 2, [1, 100])
    print(f"{test_num = }")
    assert getMaxAdditionalDinersCount(100, 2, 2, [1, 100]) == (100 - 2) // 3  # Expect around 32


def test_seat_taken_in_the_middle():
    assert getMaxAdditionalDinersCount(7, 2, 1, [4]) == 2  # seats 1, 7


def test_all_seats_taken_by_buffer():
    assert getMaxAdditionalDinersCount(7, 2, 1, [1, 4, 7]) == 0  # all seats taken


def test_k_zero():
    # Can fill every seat except occupied
    assert getMaxAdditionalDinersCount(5, 0, 1, [3]) == 4
