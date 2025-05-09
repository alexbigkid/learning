from IDisplay import IDisplay
from IObserver import IObserver
from IPublisher import IPublisher
from WeatherData import WeatherInfo


class DisplayForecast(IObserver, IDisplay):
    _weather_data:IPublisher = None
    _current_pressure:float = 29.92
    _last_pressure:float = None

    def __init__(self, weather_data: IPublisher) -> None:
        self._weather_data = weather_data
        self._weather_data.subscribe(self)


    def update(self, updated_data: dict) -> None:
        if current_pressure := updated_data.get(WeatherInfo.PRESSURE):
            self._last_pressure = self._current_pressure
            self._current_pressure = current_pressure
            self.display()


    def display(self) -> None:
        if self._current_pressure > self._last_pressure:
            forecast = 'Improving weather on the way!'
        elif self._current_pressure == self._last_pressure:
            forecast = 'More of the same'
        else:
            forecast = 'Watch out for cooler, rainy weather'
        print(f'Forecast: {forecast}')


if __name__ == '__main__':
    raise Exception(f'This module should not be executed directly. Only for imports')
