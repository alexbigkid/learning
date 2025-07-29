"""Cafeteria."""


def getMaxAdditionalDinersCount(N: int, K: int, M: int, S: list[int]) -> int:
    # Write your code here
    S.sort()
    additional_diners = 0
    pos = 1  # Start checking from seat 1

    for seat in S:
        # Blocked range by this diner
        left = max(1, seat - K)
        right = min(N, seat + K)

        # Place diners greedily in the gap before this block
        while pos < left:
            additional_diners += 1
            pos += K + 1

        # Move past the blocked zone
        pos = right + 1

    # Place diners in the tail of the row
    while pos <= N:
        additional_diners += 1
        pos += K + 1

    return additional_diners
