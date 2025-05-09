"""Some help functions"""
import logging
# import logging.config
from logging import Logger
import timeit
from colorama import Fore


def function_trace(original_function):
    """Decorator function to help to trace function call entry and exit
    Args:
        original_function (_type_): function above which the decorator is defined
    """
    def function_wrapper(*args, **kwargs):
        _logger = logging.getLogger(original_function.__name__)
        _logger.debug(f"{Fore.CYAN}-> {original_function.__name__}{Fore.RESET}")
        result = original_function(*args, **kwargs)
        _logger.debug(f"{Fore.CYAN}<- {original_function.__name__}{Fore.RESET}\n")
        return result
    return function_wrapper


class PerformanceTimer(object):
    """Calculates time spent. Should be used as context manager"""
    _start = 0
    def __init__(self, timer_name: str, logger: Logger):
        self._timer_name = timer_name
        self._logger = logger
    def __enter__(self):
        self._start = timeit.default_timer()
    def __exit__(self, exc_type, exc_value, traceback):
        time_took = (timeit.default_timer() - self._start) * 1000.0
        self._logger.info(f'Executing {self._timer_name} took {str(time_took)} ms')
