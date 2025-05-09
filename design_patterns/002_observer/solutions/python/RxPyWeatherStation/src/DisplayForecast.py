"""Display Forecast"""
from IDisplay import IDisplay
from WeatherObservable import SensorInfo
from IDisplay import IDisplay
from reactivex import Observer

class DisplayForecast(Observer, IDisplay):
    """Display weather forecast"""
    _current_pressure: float = 29.92
    _last_pressure: float | None = None

    def on_next(self, value: SensorInfo) -> None:
        if value.pressure:
            self._last_pressure = self._current_pressure
            self._current_pressure = value.pressure
        self.display()

    def on_error(self, error: str) -> None:
        print(f'DisplayForecast Error: {error}')

    def on_completed(self) -> None:
        print('DisplayForecast completed!\n')

    def display(self) -> None:
        """Display function"""
        print("Weather Forecast: ")
        print('==================')
        if self._last_pressure:
            if self._current_pressure > self._last_pressure:
                print("Weather is going to be better ☀️")
            elif self._current_pressure == self._last_pressure:
                print("Weather stays the same")
            else:
                print("Weather is going to get worse ⛈️")

if __name__ == '__main__':
    raise RuntimeError('This module should not be executed directly. Only for imports')
