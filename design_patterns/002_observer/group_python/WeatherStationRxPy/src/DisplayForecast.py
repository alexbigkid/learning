from reactivex import Observer
from reactivex.typing import OnCompleted, OnError, OnNext
from SensorInfo import SensorInfo

class DisplayForecast(Observer):
    _last_pressure: float | None = None

    def on_next(self, value: SensorInfo) -> None:
        current_pressure = value.pressure
        if current_pressure is not None:
            if self._last_pressure is not None:
                if current_pressure > self._last_pressure:
                    print('Weather is going to be better ☀️')
                elif current_pressure == self._last_pressure:
                    print('Weather is going to be the same!')
                else:
                    print('Weather is going to be worse ☔️')
            else:
                print('Lack of information to predict weather conditions.')
            self._last_pressure = current_pressure
        else:
            print("Sensor data unavailable.")
