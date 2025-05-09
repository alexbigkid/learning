"""Custom CPU based"""
import multiprocessing
import random
import time
from threading import current_thread

import reactivex
from reactivex.scheduler import ThreadPoolScheduler
from reactivex import operators as ops


def intense_calculation(value):
    # sleep for a random short duration between 0.5 to 2.0 seconds to simulate a long-running calculation
    time.sleep(random.randint(5, 20) * 0.1)
    return value


# calculate number of CPUs, then create a ThreadPoolScheduler with that number of threads
optimal_thread_count = multiprocessing.cpu_count()
pool_scheduler = ThreadPoolScheduler(optimal_thread_count)

# Create Process 1
reactivex.of("Alpha", "Beta", "Gamma", "Delta", "Epsilon").pipe(
    ops.map(lambda s: intense_calculation(s)), ops.subscribe_on(pool_scheduler)
).subscribe(
    on_next=lambda s: print(f"PROCESS 1: {current_thread().name} {s}"),
    on_error=lambda e: print(e),
    on_completed=lambda: print("PROCESS 1 done!"),
)

# Create Process 2
reactivex.range(1, 10).pipe(
    ops.map(lambda s: intense_calculation(s)), ops.subscribe_on(pool_scheduler)
).subscribe(
    on_next=lambda i: print(f"PROCESS 2: {current_thread().name} {i}"),
    on_error=lambda e: print(e),
    on_completed=lambda: print("PROCESS 2 done!"),
)

# Create Process 3, which is infinite
reactivex.interval(1).pipe(
    ops.map(lambda i: i * 100),
    ops.observe_on(pool_scheduler),
    ops.map(lambda s: intense_calculation(s)),
).subscribe(
    on_next=lambda i: print(f"PROCESS 3: {current_thread().name} {i}"),
    on_error=lambda e: print(e),
)

input("Press Enter key to exit\n")
