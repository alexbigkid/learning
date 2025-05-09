from IObserver import IObserver
from IDisplay import IDisplay
from IObservable import IObservable
from WeatherObservable import WeatherInfo

class DisplayForecast(IObserver, IDisplay):
    _weather_data:IObservable = None
    _current_pressure:float = 29.92
    _last_pressure:float = None

    def __init__(self, weather_data: IObservable) -> None:
        self._weather_data = weather_data
        self._weather_data.substribe(self)

    def update(self, updated_data: dict) -> None:
        self._last_pressure = self._current_pressure
        self._current_pressure = updated_data.get(WeatherInfo.PRESSURE)
        self.display()

    def display(self) -> None:
        print("Weather Forecast: ")
        if self._current_pressure > self._last_pressure:
            print("Weather is going to be better ☀️")
        elif self._current_pressure == self._last_pressure:
            print("Weather stays the same")
        else:
            print("Weather is going to get worse ⛈️")

if __name__ == '__main__':
    raise Exception(f'This module should not be executed directly. Only for imports')
