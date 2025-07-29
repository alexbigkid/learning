"""echo2 example"""

import sys
import reactivex as rx
from reactivex import operators as ops


argv = rx.from_iterable(sys.argv[1:]).pipe(ops.map(lambda s: s.capitalize()))
argv.subscribe(
    on_next=lambda i: print(f"on_next: {i}"),
    on_error=lambda e: print(f"on_error: {e}"),
    on_completed=lambda: print("on_completed")
)
print("Done")
