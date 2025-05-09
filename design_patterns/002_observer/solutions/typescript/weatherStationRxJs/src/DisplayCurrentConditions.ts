import { Observable, Subscription } from 'rxjs';
import { WeatherData } from './WeatherData';

export class DisplayCurrentConditions {
  private subscription: Subscription;

  constructor(weatherDataObservable: Observable<WeatherData>) {
    this.subscription = weatherDataObservable.subscribe((weatherData: WeatherData) => {
      this.display(weatherData);
    });
  }

  display(data: WeatherData): void {
    console.log('Current Conditions:');
    console.log(`Temperature: ${data.temperature}°C`);
    console.log(`Humidity: ${data.humidity}%`);
  }

  unsubscribe(): void {
    this.subscription.unsubscribe();
  }
}

// Similarly adjust other display classes
