import { DisplayForecast } from './DisplayForecast';
import { DisplayCurrentConditions } from './DisplayCurrentConditions';
import { DisplayStatistic } from './DisplayStatistic';
import { WeatherData } from './WeatherData';


function main(): void {
  let exitCode = 0;
  const weatherData = new WeatherData();
  const currentConditions = new DisplayCurrentConditions(weatherData);
  const statistics = new DisplayStatistic(weatherData);
  const forecast = new DisplayForecast(weatherData);

  try {
    weatherData.setMeasurements({ temperature: 80, humidity: 65, pressure: 30.4 });
    weatherData.setMeasurements({ temperature: 82, humidity: 70, pressure: 29.2 });
    weatherData.setMeasurements({ temperature: 78, humidity: 90 });

    weatherData.unsubscribe(forecast);
    weatherData.setMeasurements({ temperature: 62, pressure: 28.1 });

    weatherData.unsubscribe(currentConditions);
    weatherData.setMeasurements({ temperature: 80, humidity: 45, pressure: 39.6 });

    weatherData.unsubscribe(statistics);
    weatherData.setMeasurements({ temperature: 56, humidity: 85, pressure: 42.0 });
  } catch (error) {
    console.error("ERROR: executing chapter 2 exercise");
    console.error(`EXCEPTION: ${error}`);
    exitCode = 1;
  } finally {
    process.exit(exitCode);
  }
}

if (require.main === module) {
  main();
}
