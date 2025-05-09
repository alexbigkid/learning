"""Display Statistics"""
from WeatherObservable import SensorInfo
from IDisplay import IDisplay
from reactivex import Observer


class DisplayStatistic(Observer, IDisplay):
    """Display Weather Statistics class"""
    _max_temp:float = 0.0
    _min_temp:float = 200.0
    _temp_sum:float = 0.0
    _num_readings:int = 0

    def on_next(self, value: SensorInfo) -> None:
        self._num_readings += 1
        if value.temperature:
            self._temp_sum += value.temperature
            self._max_temp = max(value.temperature, self._max_temp)
            self._min_temp = min(value.temperature, self._min_temp)
        self.display()

    def on_error(self, error: str) -> None:
        print(f'DisplayStatistic Error: {error}')

    def on_completed(self) -> None:
        print('DisplayStatistic completed!\n')

    def display(self) -> None:
        print('Current Conditions:')
        print('###################')
        print(f'Avg/Max/Min temperature = {round(self._temp_sum/self._num_readings, 2)}/{self._max_temp}/{self._min_temp}')


if __name__ == '__main__':
    raise RuntimeError('This module should not be executed directly. Only for imports')
