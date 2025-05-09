"""RxPy Weather station implementation"""
import reactivex
from DisplayCurrentConditions import DisplayCurrentConditions
from WeatherObservable import SensorData
from DisplayForecast import DisplayForecast


# Create an observable sequence for sensor data
sensor_observable = reactivex.create(SensorData.emit)

# Subscribe observers to the sensor observable
sensor_observable.subscribe(DisplayCurrentConditions())

sensor_observable.subscribe(DisplayForecast())
# sensor_observable.subscribe(DisplayStatistics())
