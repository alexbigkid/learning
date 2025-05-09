import { IDisplay } from './IDisplay';
import { IObserver } from './IObserver';
import { IPublisher } from './IPublisher';
import { WeatherInfo } from './WeatherData';

export class DisplayHeatIndex implements IObserver, IDisplay {
  private _weather_data: IPublisher;
  private _heat_index: number = 0.0;
  private _current_temp: number = 74;
  private _current_humidity: number = 70;

  constructor(weather_data: IPublisher) {
    this._weather_data = weather_data;
    this._weather_data.subscribe(this);
  }

  update(updated_data: { [key: string]: any }): void {
    const current_temp = updated_data[WeatherInfo.TEMPERATURE];
    const current_humidity = updated_data[WeatherInfo.HUMIDITY];

    if (current_temp !== undefined) {
      this._current_temp = current_temp;
    }
    if (current_humidity !== undefined) {
      this._current_humidity = current_humidity;
    }

    // if temp or humidity changed, calculate heat_index and display
    if (current_temp !== undefined || current_humidity !== undefined) {
      this._heat_index = this._compute_heat_index();
      this.display();
    }
  }

  private _compute_heat_index(): number {
    const t = this._current_temp;
    const rh = this._current_humidity;
    return (
      16.923 +
      (0.185212 * t) +
      (5.37941 * rh) -
      (0.100254 * t * rh) +
      (0.00941695 * (t * t)) +
      (0.00728898 * (rh * rh)) +
      (0.000345372 * (t * t * rh)) -
      (0.000814971 * (t * rh * rh)) +
      (0.0000102102 * (t * t * rh * rh)) -
      (0.000038646 * (t * t * t)) +
      (0.0000291583 * (rh * rh * rh)) +
      (0.00000142721 * (t * t * t * rh)) +
      (0.000000197483 * (t * rh * rh * rh)) -
      (0.0000000218429 * (t * t * t * rh * rh)) +
      (0.000000000843296 * (t * t * rh * rh * rh)) -
      (0.0000000000481975 * (t * t * t * rh * rh * rh))
    );
  }

  display(): void {
    console.log(`Heat index: ${this._heat_index}`);
  }
}
