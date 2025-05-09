from IDisplay import IDisplay
from IObserver import IObserver
from IPublisher import IPublisher
from WeatherData import WeatherData, WeatherInfo


class DisplayCurrentConditions(IObserver, IDisplay):
    _weather_data:WeatherData = None
    _temperature:float = None
    _humidity:float = None


    def __init__(self, weather_data:WeatherData) -> None:
        self._weather_data = weather_data
        weather_data.subscribe(self)


    def update(self, updated_data: dict) -> None:
        if temp := updated_data.get(WeatherInfo.TEMPERATURE):
            self._temperature = temp
        if humidity := updated_data.get(WeatherInfo.HUMIDITY):
            self._humidity = humidity
        self.display()


    def display(self) -> None:
        print(f'Current conditions: {self._temperature} F degrees and {self._humidity}% humidity')


if __name__ == '__main__':
    raise Exception(f'This module should not be executed directly. Only for imports')
