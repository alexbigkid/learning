"""RxPy Image Processing implementation"""
# standard
#------------------------------------------------------------------------------
import os
import sys
import logging
import concurrent.futures
from enum import Enum
import multiprocessing
from threading import current_thread

# third party
#------------------------------------------------------------------------------
from colorama import Fore
from PIL import Image, ImageFilter
# from reactivex.concurrency import ThreadPoolScheduler
import reactivex
from reactivex.scheduler import ThreadPoolScheduler
from reactivex import Observer
from reactivex import operators as ops

# local
#------------------------------------------------------------------------------
from abk_help_functions import PerformanceTimer



#==============================================================================
# Apply Observer Pattern using reactivex library in combination with Thread/Processing Pools:
# 1. Create 4 observables of image names for each of the month of 2024
# 2. Blur - Every odd number of images in Jan
# 3. Thumbnail - Every even number of image in Feb
# 4. Grayscale - Every 3rd image of images in Jan, Feb, and Mar
# 5. Sharpen - Every image from all 4 months
#==============================================================================



#------------------------------------------------------------------------------
# settings
#------------------------------------------------------------------------------
home_directory = os.path.expanduser("~")
image_dir_202401 = f'{home_directory}/Pictures/BingWallpapers/2024/01'
image_dir_202402 = f'{home_directory}/Pictures/BingWallpapers/2024/02'
image_dir_202403 = f'{home_directory}/Pictures/BingWallpapers/2024/03'
image_dir_202404 = f'{home_directory}/Pictures/BingWallpapers/2024/04'
image_dir_list = [image_dir_202401, image_dir_202402, image_dir_202403, image_dir_202404]

main_logger = logging.getLogger(__name__)
log_level = os.environ.get("LOG_LEVEL", "INFO").upper()
LOG_FORMAT = '[%(asctime)s]:[%(levelname)s]: %(message)s'
logging.basicConfig(level=log_level, format=LOG_FORMAT, stream=sys.stderr)


class ProcessedImageDir(Enum):
    """Processed image directory"""
    BLURRED = 'processed/blurred'
    THUMBNAIL = 'processed/thumbnail'
    GRAYSCALE = 'processed/grayscale'
    SHARPEN = 'processed/sharpen'


class BlurObserver(Observer):
    def on_next(self, img_name):
        with Image.open(img_name) as img:
            img_blurred = img.filter(ImageFilter.GaussianBlur(radius=10))
            dir_name = os.path.join(os.getcwd(), ProcessedImageDir.BLURRED.value)
            img_blurred.save(os.path.join(dir_name, os.path.basename(img_name)))
        main_logger.info(f'Image blurred: {os.path.basename(img_name)}')


class ThumbnailObserver(Observer):
    def on_next(self, img_name):
        with Image.open(img_name) as img:
            img_resized = img.resize((int(img.width/12), int(img.height/12)))
            dir_name = os.path.join(os.getcwd(), ProcessedImageDir.THUMBNAIL.value)
            img_resized.save(os.path.join(dir_name, os.path.basename(img_name)))
        main_logger.info(f'Image resized: {os.path.basename(img_name)}')


class GrayscaleObserver(Observer):
    def on_next(self, img_name):
        with Image.open(img_name) as img:
            img_gray = img.convert('L')
            dir_name = os.path.join(os.getcwd(), ProcessedImageDir.GRAYSCALE.value)
            img_gray.save(os.path.join(dir_name, os.path.basename(img_name)))
        main_logger.info(f'Image grayscaled: {os.path.basename(img_name)}')


class SharpenObserver(Observer):
    def on_next(self, img_name):
        with Image.open(img_name) as img:
            img_sharpen = img.filter(ImageFilter.SHARPEN)
            dir_name = os.path.join(os.getcwd(), ProcessedImageDir.SHARPEN.value)
            img_sharpen.save(os.path.join(dir_name, os.path.basename(img_name)))
        main_logger.info(f'Image sharpened: {os.path.basename(img_name)}')



#------------------------------------------------------------------------------
# local functions
#------------------------------------------------------------------------------
def create_img_dirs() -> None:
    """Creates directories for processed images"""
    for dir_name in ProcessedImageDir:
        full_path = os.path.join(os.getcwd(), dir_name.value)
        os.makedirs(full_path, exist_ok=True)


def get_images(dir_list: list[str]) -> list:
    """Returns list of images in directory"""
    img_name_list: list[str] = []
    for dir_name in dir_list:
        img_name_list.extend(os.path.join(dir_name, img) for img in os.listdir(dir_name) if img.endswith('.jpg'))
    return img_name_list


#------------------------------------------------------------------------------
# main
#------------------------------------------------------------------------------
def main():
    """main function"""
    exit_code = 0

    try:
        img_list = get_images(image_dir_list)
        if len(img_list) == 0:
            raise Exception(f'No images found in {image_dir_list}')
        main_logger.info(f'Images found: {img_list}')
        create_img_dirs()


        optimal_thread_count = multiprocessing.cpu_count()
        pool_scheduler = ThreadPoolScheduler(optimal_thread_count)

        observable = reactivex.of(*img_list)

        blur_observer = BlurObserver()
        thumbnail_observer = ThumbnailObserver()
        grayscale_observer = GrayscaleObserver()
        sharpen_observer = SharpenObserver()


        # timer_name: str = 'image_process_sequential'
        # with PerformanceTimer(timer_name, main_logger):
        #     observable.subscribe(blur_observer.on_next)
        #     observable.subscribe(thumbnail_observer.on_next)
        #     observable.subscribe(grayscale_observer.on_next)
        #     observable.subscribe(sharpen_observer.on_next)

        # timer_name: str = 'image_process_with_futures'
        # with PerformanceTimer(timer_name, main_logger):
        #     with concurrent.futures.ProcessPoolExecutor() as executor:
        #         futures = []
        #         futures.append(executor.submit(observable.subscribe, blur_observer.on_next))
        #         futures.append(executor.submit(observable.subscribe, thumbnail_observer.on_next))
        #         futures.append(executor.submit(observable.subscribe, grayscale_observer.on_next))
        #         futures.append(executor.submit(observable.subscribe, sharpen_observer.on_next))
        #     concurrent.futures.wait(futures)


        timer_name: str = 'image_process_with_reactivex_scheduler'
        with PerformanceTimer(timer_name, main_logger):
            observable.pipe(
                # ops.map(lambda img: img_list.index(img) %2 != 0),
                ops.observe_on(pool_scheduler)
            ).subscribe(blur_observer.on_next)

            observable.pipe(
                # ops.map(lambda img: img_list.index(img) %2 == 0),
                ops.observe_on(pool_scheduler)
            ).subscribe(thumbnail_observer.on_next)

            observable.pipe(
                # ops.map(lambda img: img_list.index(img) %3 == 0),
                ops.observe_on(pool_scheduler)
            ).subscribe(grayscale_observer.on_next)

            observable.pipe(
                ops.observe_on(pool_scheduler)
            ).subscribe(on_next=sharpen_observer.on_next)
        main_logger.info(f'{Fore.GREEN}SUCCESS: {timer_name}{Fore.RESET}\n')

        # timer_name: str = 'image_blur_sequential'
        # with PerformanceTimer(timer_name, main_logger):
        #     observable.subscribe(blur_observer.on_next)
        # main_logger.info(f'{Fore.GREEN}SUCCESS: {timer_name}{Fore.RESET}\n')


        # timer_name: str = 'image_resize_sequential'
        # with PerformanceTimer(timer_name, main_logger):
        #     observable.subscribe(thumbnail_observer.on_next)
        # main_logger.info(f'{Fore.GREEN}SUCCESS: {timer_name}{Fore.RESET}\n')


        # timer_name: str = 'image_grayscale_sequential'
        # with PerformanceTimer(timer_name, main_logger):
        #     observable.subscribe(grayscale_observer.on_next)
        # main_logger.info(f'{Fore.GREEN}SUCCESS: {timer_name}{Fore.RESET}\n')


        # timer_name: str = 'image_sharpen_sequential'
        # with PerformanceTimer(timer_name, main_logger):
        #     observable.subscribe(sharpen_observer.on_next)
        # main_logger.info(f'{Fore.GREEN}SUCCESS: {timer_name}{Fore.RESET}\n')


        # timer_name: str = 'image_blur_multi_processing'
        # with PerformanceTimer(timer_name, main_logger):
        #     with concurrent.futures.ProcessPoolExecutor() as executor:
        #         executor.map(image_gauss_blur, img_list)
        # main_logger.info(f'{Fore.GREEN}SUCCESS: {timer_name}{Fore.RESET}\n')


        # timer_name: str = 'image_resize_multi_processing'
        # with PerformanceTimer(timer_name, main_logger):
        #     with concurrent.futures.ProcessPoolExecutor() as executor:
        #         executor.map(image_resize, img_list)
        # main_logger.info(f'{Fore.GREEN}SUCCESS: {timer_name}{Fore.RESET}\n')


        # timer_name: str = 'image_grayscale_multi_processing'
        # with PerformanceTimer(timer_name, main_logger):
        #     with concurrent.futures.ProcessPoolExecutor() as executor:
        #         executor.map(image_grayscale, img_list)
        # main_logger.info(f'{Fore.GREEN}SUCCESS: {timer_name}{Fore.RESET}\n')


        # timer_name: str = 'image_sharpen_multi_processing'
        # with PerformanceTimer(timer_name, main_logger):
        #     with concurrent.futures.ProcessPoolExecutor() as executor:
        #         executor.map(image_sharpen, img_list)
        # main_logger.info(f'{Fore.GREEN}SUCCESS: {timer_name}{Fore.RESET}\n')


    except Exception as exception:
        main_logger.error(f'{Fore.RED}ERROR: executing MultiProcessing{Fore.RESET}')
        main_logger.error(f"EXCEPTION: {exception}")
        exit_code = 1
    finally:
        sys.exit(exit_code)

if __name__ == '__main__':
    main()
