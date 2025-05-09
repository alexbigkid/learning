"""Custom Operator"""
import reactivex
from reactivex import operators as ops

def length_more_than_5():
    # In v4 rx.pipe has been renamed to `compose`
    return reactivex.compose(
        ops.map(lambda s: len(s)),
        ops.filter(lambda i: i >= 5),
    )

reactivex.of("Alpha", "Beta", "Gamma", "Delta", "Epsilon").pipe(
    length_more_than_5()
).subscribe(lambda value: print(f"Received: {value}"))
