from IObserver import IObserver
from IDisplay import IDisplay
from IObservable import IObservable
from WeatherObservable import WeatherInfo


class DisplayStatistic(IObserver, IDisplay):
    _weather_data:IObservable
    _max_temp:float = 0.0
    _min_temp:float = 200.0
    _temp_sum:float = 0.0
    _num_readings:int = 0


    def __init__(self, weather_data:IObservable) -> None:
        self._weather_data = weather_data
        self._weather_data.substribe(self)

    def update(self, updated_data: dict) -> None:
        self._num_readings += 1
        self._temp_sum += updated_data.get(WeatherInfo.TEMPERATURE)
        
        self._max_temp = max(updated_data.get(WeatherInfo.TEMPERATURE), self._max_temp)
        self._min_temp = min(updated_data.get(WeatherInfo.TEMPERATURE), self._min_temp)
        self.display() 

    def display(self) -> None:
        print(f'Avg/Max/Min temperature = {self._temp_sum/self._num_readings}/{self._max_temp}/{self._min_temp}')


if __name__ == '__main__':
    raise Exception(f'This module should not be executed directly. Only for imports')
