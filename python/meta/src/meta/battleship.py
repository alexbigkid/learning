"""Battleship."""


def getHitProbability(R: int, C: int, G: list[list[int]]) -> float:
    # Write your code here
    sum: int = 0
    for row in G:
        for cell in row:
            sum = sum + cell
    return sum / (R * C)
