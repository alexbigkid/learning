def replace_character(input_string, c1, c2):
    # TODO: Replace all occurrences of character `c1` in `input_string` with `c2`
    result: str = ""
    for c in input_string:
        result += c2 if c == c1 else c
    return result
    # return ''.join(c2 if c == c1 else c for c in input_string)
