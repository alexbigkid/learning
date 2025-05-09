import sys

from WeatherData import WeatherData
from DisplayCurrentConditions import DisplayCurrentConditions
from DisplayForecast import DisplayForecast
from DisplayStatistic import DisplayStatistic


def main():
    exit_code = 0
    weather_data = WeatherData()
    current_conditions = DisplayCurrentConditions(weather_data)
    statistics = DisplayStatistic(weather_data)
    forecast = DisplayForecast(weather_data)

    try:
        weather_data.set_measurements(temperature=80, humidity=65, pressure=30.4)
        weather_data.set_measurements(temperature=82, humidity=70, pressure=29.2)
        weather_data.set_measurements(temperature=78, humidity=90)

        weather_data.unsubscribe(forecast)
        weather_data.set_measurements(temperature=62, pressure=28.1)

        weather_data.unsubscribe(current_conditions)
        weather_data.set_measurements(temperature=80, humidity=45, pressure=39.6)

        weather_data.unsubscribe(statistics)
        weather_data.set_measurements(temperature=56, humidity=85, pressure=42.0)

    except Exception as exception:
        print(f"ERROR: executing chapter 2 exercise")
        print(f"EXCEPTION: {exception}")
        exit_code = 1
    finally:
        sys.exit(exit_code)


if __name__ == '__main__':
    main()
