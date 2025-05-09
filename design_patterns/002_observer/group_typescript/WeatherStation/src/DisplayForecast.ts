import { IDisplay } from './IDisplay';
import { IObserver } from './IObserver';
import { IPublisher } from './IPublisher';
import { WeatherInfo } from './WeatherData';

export class DisplayForecast implements IObserver, IDisplay {
  constructor(weather_data: IPublisher) {
  }

  update(updated_data: { [key: string]: any }): void {
  }

  display(): void {
  }
}
