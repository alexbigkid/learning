import { Observable, Subscription } from 'rxjs';
import { WeatherData } from './WeatherData';

export class DisplayForecast {
  private subscription: Subscription;

  constructor(private weatherDataObservable: Observable<WeatherData>) {
    this.subscribeToWeatherData();
  }

  private subscribeToWeatherData() {
    this.subscription = this.weatherDataObservable.subscribe((data: WeatherData) => {
      this.display(data);
    });
  }

  display(data: WeatherData): void {
    let predictedWeather: string;
    if (data.temperature > 25 && data.humidity < 70) {
      predictedWeather = 'Sunny';
    } else if (data.temperature <= 25 && data.humidity < 70) {
      predictedWeather = 'Partly Cloudy';
    } else {
      predictedWeather = 'Cloudy';
    }
    console.log('Forecast:');
    console.log(`Predicted Weather: ${predictedWeather}`);
  }

  unsubscribe() {
    this.subscription.unsubscribe();
  }
}
