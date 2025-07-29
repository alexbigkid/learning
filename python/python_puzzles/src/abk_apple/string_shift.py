def solution(s):
    # TODO: Implement the solution here
    def shift_alphas(char):
        if 'a' <= char <= 'z':
            return chr((ord(char) - ord('a') + 1) % 26 + ord('a'))
        if 'A' <= char <= 'Z':
            return chr((ord(char) - ord('A') + 1) % 26 + ord('A'))
        return char

    return ''.join(shift_alphas(c) for c in s)
