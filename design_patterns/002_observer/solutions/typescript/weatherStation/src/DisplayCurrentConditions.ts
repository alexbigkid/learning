import { IDisplay } from './IDisplay';
import { IObserver } from './IObserver';
import { WeatherData, WeatherInfo } from './WeatherData';

export class DisplayCurrentConditions implements IObserver, IDisplay {
  private _weather_data: WeatherData | null = null;
  private _temperature: number | null = null;
  private _humidity: number | null = null;

  constructor(weather_data: WeatherData) {
    this._weather_data = weather_data;
    weather_data.subscribe(this);
  }

  update(updated_data: { [key: string]: any }): void {
    if (updated_data.hasOwnProperty(WeatherInfo.TEMPERATURE)) {
      this._temperature = updated_data[WeatherInfo.TEMPERATURE];
    }
    if (updated_data.hasOwnProperty(WeatherInfo.HUMIDITY)) {
      this._humidity = updated_data[WeatherInfo.HUMIDITY];
    }
    this.display();
  }

  display(): void {
    if (this._temperature !== null && this._humidity !== null) {
      console.log(`Current conditions: ${this._temperature} F degrees and ${this._humidity}% humidity`);
    }
  }
}
