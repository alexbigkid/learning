def solution(s):
    # TODO: implement find_vowels_positions
    result: list[str] = []
    def is_vowel(char: str) -> bool:
        return char in {'a', 'e', 'i', 'o', 'u', 'A', 'E', 'I', 'O', 'U'}

    for index, char in enumerate(s):
        if is_vowel(char):
            result.append(index)
    return result
