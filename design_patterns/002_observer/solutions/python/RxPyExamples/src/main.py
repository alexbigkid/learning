
"""RxPy v2 and v3"""
import sys
import rx

argv = rx.from_(sys.argv[1:])

argv.subscribe(
    on_next=lambda s: print(f"on_next: {s}"),
    on_error=lambda e: print(f"on_error: {e}"),
    on_completed=lambda: print("on_completed"),
)
print("done!")
