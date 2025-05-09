from reactivex import Observer
from SensorInfo import SensorInfo

class DisplayCurrentConditions(Observer):
    def on_next(self, value: SensorInfo) -> None:
        print(f"Temperature: {value.temperature}°C")
        print(f"Pressure: {value.pressure} bar")
        print(f"Humidity: {value.humidity}%")

