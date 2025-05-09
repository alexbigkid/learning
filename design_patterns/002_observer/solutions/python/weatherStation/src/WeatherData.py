from enum import Enum
from typing import List

from IObserver import IObserver
from IPublisher import IPublisher


class WeatherInfo(Enum):
    TEMPERATURE     = 'temperature'
    HUMIDITY        = 'humidity'
    PRESSURE        = 'pressure'


class WeatherData(IPublisher):
    _observers: List[IObserver]

    def __init__(self) -> None:
        self._observers = []
        super().__init__()


    def subscribe(self, observer: IObserver) -> None:
        self._observers.append(observer)


    def unsubscribe(self, observer:IObserver) -> None:
        print(f'---- Unsubscribing: {observer.__class__.__name__}')
        self._observers.remove(observer)


    def notify(self, data:dict) -> None:
        for observer in self._observers:
            observer.update(data)


    def set_measurements(self, temperature:float=None, humidity:float=None, pressure:float=None) -> None:
        updated_measurements:dict = {}
        updated_list = []
        if temperature is not None:
            updated_list.append(WeatherInfo.TEMPERATURE)
            updated_measurements[WeatherInfo.TEMPERATURE] = temperature
        if humidity is not None:
            updated_list.append(WeatherInfo.HUMIDITY)
            updated_measurements[WeatherInfo.HUMIDITY] = humidity
        if pressure is not None:
            updated_list.append(WeatherInfo.PRESSURE)
            updated_measurements[WeatherInfo.PRESSURE] = pressure
        print(f'Updating: {[updated.value for updated in updated_list]}')
        self.notify(updated_measurements)
        print('')


if __name__ == '__main__':
    raise Exception(f'This module should not be executed directly. Only for imports')
