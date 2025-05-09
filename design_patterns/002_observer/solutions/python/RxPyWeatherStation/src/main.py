"""RxPy Weather station implementation"""
import sys

import reactivex

from DisplayCurrentConditions import DisplayCurrentConditions
from DisplayForecast import DisplayForecast
from DisplayStatistic import DisplayStatistic
from WeatherObservable import SensorData

def main():
    """main function"""
    exit_code = 0
    current_conditions = DisplayCurrentConditions()
    statistics = DisplayStatistic()
    forecast = DisplayForecast()

    try:
        sensor_observable = reactivex.create(SensorData.emit)
        sensor_observable.subscribe(current_conditions)
        sensor_observable.subscribe(statistics)
        sensor_observable.subscribe(forecast)
    except Exception as exception:
        print('ERROR: executing chapter 2 exercise')
        print(f'EXCEPTION: {exception}')
        exit_code = 1
    finally:
        sys.exit(exit_code)

if __name__ == '__main__':
    main()
