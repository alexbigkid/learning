from IObserver import IObserver
from IDisplay import IDisplay
from IObservable import IObservable
from WeatherObservable import WeatherData,WeatherInfo


class DisplayCurrentConditions(IObserver, IDisplay):
    _weather_data:WeatherData = None
    _temperature:float = None
    _humidity:float = None


    def __init__(self, weather_data:WeatherData) -> None:
        self._weather_data = weather_data
        self._weather_data.substribe(self)

    def update(self, updated_data: dict) -> None:
        self._temperature = updated_data.get('temperature')
        self._humidity = updated_data.get('humidity')
        self.display()

    def display(self) -> None:
        print(f'current conditions:\nTemperature: {self._temperature}\n Humidity: {self._humidity}')

if __name__ == '__main__':
    raise Exception(f'This module should not be executed directly. Only for imports')
