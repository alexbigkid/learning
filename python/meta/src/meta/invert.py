"""String invert functionality."""


def getWrongAnswers(N: int, C: str) -> str:
    # Write your code here
    return "".join(["B" if s == "A" else "A" for s in C])
