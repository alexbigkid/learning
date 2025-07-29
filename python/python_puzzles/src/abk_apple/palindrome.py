def solution(input_string):
    input_lower_cased: str = ""

    def lower_case_and_filter(char: str) -> str:
        if 'A' <= char <= 'Z':
            return chr(ord(char) + 32)
        if 'a' <= char <= 'z':
            return char
        return ''

    def reverse_string(s: str) -> str:
        result: str = ""
        for c in s:
            result = c + result
        return result

    for c in input_string:
        input_lower_cased += lower_case_and_filter(c)

    reversed_string = reverse_string(input_lower_cased)
    # reversed_string = input_lower_cased[::-1]

    return reversed_string == input_lower_cased
