"""RxPy v4"""
from reactivex import of

source = of("Alpha", "Beta", "Gamma", "Delta", "Epsilon")

source.subscribe(
    on_next=lambda v: print(f"Received: {v}"),
    on_error=lambda e: print(f"Error: {e}"),
    on_completed=lambda: print("Done!"),
)
