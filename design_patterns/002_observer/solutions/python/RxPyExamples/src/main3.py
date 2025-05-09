"""Operators chaining"""
from reactivex import of, operators as op

# source = of("Alpha", "Beta", "Gamma", "Delta", "Epsilon")

# composed = source.pipe(
#     op.map(lambda v: len(v)),
#     op.filter(lambda i: i >= 5)
# )

# composed.subscribe(
#     lambda s: print(f"Received: {s}")
# )

of("Alpha", "Beta", "Gamma", "Delta", "Epsilon").pipe(
    op.map(lambda s: len(s)),
    op.filter(lambda i: i >= 5)
).subscribe(
    lambda s: print(f"Received: {s}")
)
