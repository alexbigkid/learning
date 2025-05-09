import { Observable, Subject } from 'rxjs';
import { WeatherData } from './WeatherData';
import { DisplayCurrentConditions } from './DisplayCurrentConditions';
import { DisplayForecast } from './DisplayForecast';
import { DisplayStatistic } from './DisplayStatistic';


export class WeatherStation {
  private weatherDataSubject: Subject<WeatherData>;

  constructor() {
    this.weatherDataSubject = new Subject<WeatherData>();
  }

  updateWeatherData(data: WeatherData) {
    this.weatherDataSubject.next(data);
  }

  getWeatherDataObservable(): Observable<WeatherData> {
    return this.weatherDataSubject.asObservable();
  }
}


function main(): void {
  let exitCode = 0;

  try {
    const weatherStation = new WeatherStation();

    // Instantiate the weather displays with the weather data observable
    const currentConditions = new DisplayCurrentConditions(weatherStation.getWeatherDataObservable());
    const forecast = new DisplayForecast(weatherStation.getWeatherDataObservable());
    const statistics = new DisplayStatistic(weatherStation.getWeatherDataObservable());

    // Simulate weather data updates (for demonstration purposes)
    setInterval(() => {
      const newWeatherData: WeatherData = {
        temperature: Math.random() * 30 + 10,
        humidity: Math.random() * 50 + 50,
        pressure: Math.random() * 100 + 500,
      };
      weatherStation.updateWeatherData(newWeatherData);
    }, 2000); // Simulate updates every 2 seconds

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
