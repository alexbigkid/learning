def solution(s):
    # TODO: implement find_vowels_positions
    def toggle_char_case(char: str) -> str:
        if 'a' <= char <= 'z':
            return chr(ord(char) - 32)
        if 'A' <= char <= 'Z':
            return chr(ord(char) + 32)
        return char

    return ''.join(toggle_char_case(c) for c in s)
