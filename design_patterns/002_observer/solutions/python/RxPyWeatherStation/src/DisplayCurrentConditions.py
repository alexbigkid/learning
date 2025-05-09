"""Display Current Conditions"""
from WeatherObservable import SensorInfo
from IDisplay import IDisplay
from reactivex import Observer


class DisplayCurrentConditions(Observer, IDisplay):
    """Display Current Conditions"""
    _temperature:float = 0
    _humidity:float = 0

    def on_next(self, value: SensorInfo) -> None:
        if value.temperature:
            self._temperature = value.temperature
        if value.humidity:
            self._humidity = value.humidity
        self.display()

    def on_error(self, error: str) -> None:
        print(f'DisplayCurrentConditions Error: {error}')

    def on_completed(self) -> None:
        print('DisplayCurrentConditions completed!\n')

    def display(self) -> None:
        """Display function"""
        print('Current Conditions:')
        print('-------------------')
        print(f'Temperature:    {self._temperature}°C')
        print(f'Humidity:       {self._humidity}%')
        print('')

if __name__ == '__main__':
    raise RuntimeError('This module should not be executed directly. Only for imports')
