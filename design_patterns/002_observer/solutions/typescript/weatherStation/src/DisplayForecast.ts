import { IDisplay } from './IDisplay';
import { IObserver } from './IObserver';
import { IPublisher } from './IPublisher';
import { WeatherInfo } from './WeatherData';

export class DisplayForecast implements IObserver, IDisplay {
  private _weather_data: IPublisher | null = null;
  private _current_pressure: number = 29.92;
  private _last_pressure: number | null = null;

  constructor(weather_data: IPublisher) {
    this._weather_data = weather_data;
    this._weather_data.subscribe(this);
  }

  update(updated_data: { [key: string]: any }): void {
    const current_pressure = updated_data[WeatherInfo.PRESSURE];
    if (current_pressure !== undefined) {
      this._last_pressure = this._current_pressure;
      this._current_pressure = current_pressure;
      this.display();
    }
  }

  display(): void {
    let forecast: string;
    if (this._last_pressure === null) {
      forecast = 'No data for comparison';
    } else if (this._current_pressure > this._last_pressure) {
      forecast = 'Improving weather on the way!';
    } else if (this._current_pressure === this._last_pressure) {
      forecast = 'More of the same';
    } else {
      forecast = 'Watch out for cooler, rainy weather';
    }
    console.log(`Forecast: ${forecast}`);
  }
}
