def solution(s):
    result: str = ""
    for i in range(0, len(s), 2):
        if i + 1 < len(s):
            result += s[i+1] + s[i]
        else:
            result += s[i]
    return result
