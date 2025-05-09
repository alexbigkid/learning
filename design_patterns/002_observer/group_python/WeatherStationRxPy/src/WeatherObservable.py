import random
from reactivex import Observer
from SensorInfo import SensorInfo
 
class SensorData:
    """Class to emit sensor data"""

    @staticmethod
    def emit(observer: Observer, scheduler=None):
        """Emit sensor data"""
        for _ in range(0, 15):
            observer.on_next(
                SensorInfo(
                    temperature=SensorData._random_temperature(),
                    pressure=SensorData._random_pressure(),
                    humidity=SensorData._random_humidity()
                )
            )
        observer.on_completed()

    @staticmethod
    def _random_temperature() -> float | None:
        """Generate random temperature"""
        return round(random.randint(1, 50), 2) if random.choice([True, False]) else None

    @staticmethod
    def _random_pressure() -> float | None:
        """Generate random pressure"""
        return round(random.randint(1, 1050), 2) if random.choice([True, False]) else None

    @staticmethod
    def _random_humidity() -> float | None:
        """Generate random humidity"""
        return round(random.randint(1, 100), 2) if random.choice([True, False]) else None

