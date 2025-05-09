from IObserver import IObserver
from IDisplay import IDisplay
from IPublisher import IPublisher
from WeatherData import WeatherInfo


class DisplayHeatIndex(IObserver, IDisplay):
    _weather_data:IPublisher
    _heat_index:float = 0.0
    _current_temp:float = 74
    _current_humidity:float = 70

    def __init__(self, weather_data:IPublisher) -> None:
        pass

    def update(self, updated_data: dict) -> None:
        pass

    def _compute_heat_index(self):
        t = self._current_temp
        rh = self._current_humidity
        return (
            (
                16.923 + (0.185212 * t)
                + (5.37941 * rh)
                - (0.100254 * t * rh)
                + (0.00941695 * (t * t))
                + (0.00728898 * (rh * rh))
                + (0.000345372 * (t * t * rh))
                - (0.000814971 * (t * rh * rh))
                + (0.0000102102 * (t * t * rh * rh))
                - (0.000038646 * (t * t * t))
                + (0.0000291583 * (rh * rh * rh))
                + (0.00000142721 * (t * t * t * rh))
                + (0.000000197483 * (t * rh * rh * rh))
                - (0.0000000218429 * (t * t * t * rh * rh))
                + 0.000000000843296 * (t * t * rh * rh * rh)
            ) - (0.0000000000481975 * (t * t * t * rh * rh * rh))
        )


    def display(self) -> None:
        print(f'Heat index: {self._heat_index}')


if __name__ == '__main__':
    raise Exception(f'This module should not be executed directly. Only for imports')
