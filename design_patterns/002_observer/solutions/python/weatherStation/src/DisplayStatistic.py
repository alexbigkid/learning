from IDisplay import IDisplay
from IObserver import IObserver
from IPublisher import IPublisher
from WeatherData import WeatherInfo


class DisplayStatistic(IObserver, IDisplay):
    _weather_data:IPublisher
    _max_temp:float = 0.0
    _min_temp:float = 200.0
    _temp_sum:float = 0.0
    _num_readings:int = 0


    def __init__(self, weather_data:IPublisher) -> None:
        self._weather_data = weather_data
        self._weather_data.subscribe(self)


    def update(self, updated_data: dict) -> None:
        if current_temp := updated_data.get(WeatherInfo.TEMPERATURE):
            self._temp_sum += current_temp
            self._num_readings += 1
            if current_temp > self._max_temp:
                self._max_temp = current_temp
            if current_temp < self._min_temp:
                self._min_temp = current_temp
            self.display()


    def display(self) -> None:
        print(f'Avg/Max/Min temperature = {self._temp_sum/self._num_readings}/{self._max_temp}/{self._min_temp}')


if __name__ == '__main__':
    raise Exception(f'This module should not be executed directly. Only for imports')
