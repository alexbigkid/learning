from enum import Enum
from typing import List

from IObservable import IObservable
from IObserver import IObserver

class WeatherInfo(Enum):
    TEMPERATURE     = 'temperature'
    HUMIDITY        = 'humidity'
    PRESSURE        = 'pressure'


class WeatherData(IObservable):
    _observers: List[IObserver]

    def __init__(self) -> None:
        self._observers = []

    def substribe(self, observer: IObserver) -> None:
        print(f'---- Subscribing: {observer.__class__.__name__}')
        self._observers.append(observer)

    def unsubscribe(self, observer:IObserver) -> None:
        print(f'---- Unsubscribing: {observer.__class__.__name__}')
        self._observers.remove(observer)

    def notify(self, data:dict) -> None:
        for i in range(len(self._observers)):
            self._observers[i].update(data)

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
