"""Weather Observable and SensorData"""
from dataclasses import dataclass
import random
from typing import Optional

from reactivex import Observer


@dataclass
class SensorInfo:
    """Class to hold sensor data"""
    temperature: Optional[float]
    pressure: Optional[float]
    humidity: Optional[float]


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
        return round(random.randint(1, 500) * 0.1, 2) if random.choice([True, False]) else None

    @staticmethod
    def _random_pressure() -> float | None:
        """Generate random pressure"""
        return round(random.randint(1, 10500) * 0.1, 2) if random.choice([True, False]) else None

    @staticmethod
    def _random_humidity() -> float | None:
        """Generate random humidity"""
        return round(random.randint(1, 1000) * 0.1, 2) if random.choice([True, False]) else None
