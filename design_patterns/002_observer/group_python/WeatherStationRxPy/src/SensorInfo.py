from dataclasses import dataclass
from typing import Optional


@dataclass
class SensorInfo:
    """Class to hold sensor data"""
    temperature: Optional[float]
    pressure: Optional[float]
    humidity: Optional[float]