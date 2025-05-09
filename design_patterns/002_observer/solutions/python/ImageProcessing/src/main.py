"""RxPy Image Processing implementation"""
import os
import sys
import logging
import time
import multiprocessing
import threading
import concurrent.futures
from venv import logger

from colorama import Fore

from abk_help_functions import function_trace, PerformanceTimer



main_logger = logging.getLogger(__name__)
log_level = os.environ.get("LOG_LEVEL", "DEBUG").upper()
LOG_FORMAT = '[%(asctime)s]:[%(levelname)s]: %(message)s'
logging.basicConfig(level=log_level, format=LOG_FORMAT, stream=sys.stderr)


# @function_trace
def sleep_for(secs: int) -> None:
    """Sleep for number of seconds"""
    main_logger.info(f'Voy a dormir por {secs}s...')
    time.sleep(secs)


def return_sleep_for(secs: int) -> str:
    """Sleep for number of seconds"""
    main_logger.info(f'Voy a dormir por {secs}s...')
    time.sleep(secs)
    return f'Dormi por {secs}s'


def main():
    """main function"""
    exit_code = 0

    try:
        timer_name: str = '1st_sleep_sequential'
        with PerformanceTimer(timer_name, main_logger):
            sleep_for(1)
            # sleep_for(1)
        main_logger.info(f'{Fore.GREEN}SUCCESS: {timer_name}{Fore.RESET}\n')


        # timer_name: str = '2nd_sleep_multi_threading'
        # with PerformanceTimer(timer_name, main_logger):
        #     p1 = threading.Thread(target=sleep_for, args=(1,))
        #     p2 = threading.Thread(target=sleep_for, args=(1,))
        #     p1.start()
        #     p2.start()
        #     p1.join()
        #     p2.join()
        # main_logger.info(f'{Fore.GREEN}SUCCESS: {timer_name}{Fore.RESET}\n')


        # timer_name: str = '2nd_sleep_multi_processing'
        # with PerformanceTimer(timer_name, main_logger):
        #     p1 = multiprocessing.Process(target=sleep_for, args=(1,))
        #     p2 = multiprocessing.Process(target=sleep_for, args=(1,))
        #     p1.start()
        #     p2.start()
        #     p1.join()
        #     p2.join()
        # main_logger.info(f'{Fore.GREEN}SUCCESS: {timer_name}{Fore.RESET}\n')


        # processes = []
        # timer_name: str = '3rd_sleep_multi_threading'
        # with PerformanceTimer(timer_name, main_logger):
        #     for _ in range(10):
        #         p = threading.Thread(target=sleep_for, args=[1])
        #         p.start()
        #         processes.append(p)
        #     for process in processes:
        #         process.join()
        # main_logger.info(f'{Fore.GREEN}SUCCESS: {timer_name}{Fore.RESET}\n')


        # processes = []
        # timer_name: str = '3rd_sleep_multi_processing'
        # with PerformanceTimer(timer_name, main_logger):
        #     for _ in range(10):
        #         p = multiprocessing.Process(target=sleep_for, args=[1])
        #         p.start()
        #         processes.append(p)
        #     for process in processes:
        #         process.join()
        # main_logger.info(f'{Fore.GREEN}SUCCESS: {timer_name}{Fore.RESET}\n')


        # timer_name: str = '4th_sleep_multi_threading'
        # with PerformanceTimer(timer_name, main_logger):
        #     with concurrent.futures.ThreadPoolExecutor() as executor:
        #         results = [executor.submit(return_sleep_for, 1) for _ in range(10)]
        #         for f in concurrent.futures.as_completed(results):
        #             main_logger.info(f.result())
        # main_logger.info(f'{Fore.GREEN}SUCCESS: {timer_name}{Fore.RESET}\n')


        # timer_name: str = '4th_sleep_multi_processing'
        # with PerformanceTimer(timer_name, main_logger):
        #     with concurrent.futures.ProcessPoolExecutor() as executor:
        #         results = [executor.submit(return_sleep_for, 1) for _ in range(10)]
        #         for f in concurrent.futures.as_completed(results):
        #             main_logger.info(f.result())
        # main_logger.info(f'{Fore.GREEN}SUCCESS: {timer_name}{Fore.RESET}\n')


        # timer_name: str = '5th_sleep_multi_threading'
        # with PerformanceTimer(timer_name, main_logger):
        #     with concurrent.futures.ThreadPoolExecutor() as executor:
        #         results = [executor.submit(return_sleep_for, sec) for sec in range(10, 0, -1)]
        #         for f in concurrent.futures.as_completed(results):
        #             main_logger.info(f.result())
        # main_logger.info(f'{Fore.GREEN}SUCCESS: {timer_name}{Fore.RESET}\n')


        # timer_name: str = '5th_sleep_multi_processing'
        # with PerformanceTimer(timer_name, main_logger):
        #     with concurrent.futures.ProcessPoolExecutor() as executor:
        #         results = [executor.submit(return_sleep_for, sec) for sec in range(10, 0, -1)]
        #         for f in concurrent.futures.as_completed(results):
        #             main_logger.info(f.result())
        # main_logger.info(f'{Fore.GREEN}SUCCESS: {timer_name}{Fore.RESET}\n')


        # timer_name: str = '6th_sleep_multi_threading'
        # with PerformanceTimer(timer_name, main_logger):
        #     with concurrent.futures.ThreadPoolExecutor() as executor:
        #         results = executor.map(return_sleep_for, range(10, 0, -1))
        #         for result in results:
        #             main_logger.info(result)
        # main_logger.info(f'{Fore.GREEN}SUCCESS: {timer_name}{Fore.RESET}\n')


        # timer_name: str = '6th_sleep_multi_processing'
        # with PerformanceTimer(timer_name, main_logger):
        #     with concurrent.futures.ProcessPoolExecutor() as executor:
        #         results = executor.map(return_sleep_for, range(10, 0, -1))
        #         for result in results:
        #             main_logger.info(result)
        # main_logger.info(f'{Fore.GREEN}SUCCESS: {timer_name}{Fore.RESET}\n')



    except Exception as exception:
        main_logger.error(f'{Fore.RED}ERROR: executing MultiProcessing{Fore.RESET}')
        main_logger.error(f"EXCEPTION: {exception}")
        exit_code = 1
    finally:
        sys.exit(exit_code)

if __name__ == '__main__':
    main()
