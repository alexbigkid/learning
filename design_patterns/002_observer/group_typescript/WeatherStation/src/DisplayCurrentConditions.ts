import { IDisplay } from './IDisplay';
import { IObserver } from './IObserver';
import { WeatherData, WeatherInfo } from './WeatherData';

export class DisplayCurrentConditions implements IObserver, IDisplay {

  constructor(weather_data: WeatherData) {
  }

  update(updated_data: { [key: string]: any }): void {

  }

  display(): void {
  }
}
