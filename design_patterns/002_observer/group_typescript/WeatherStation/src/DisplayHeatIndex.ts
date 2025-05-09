import { IDisplay } from './IDisplay';
import { IObserver } from './IObserver';
import { IPublisher } from './IPublisher';
import { WeatherInfo } from './WeatherData';

export class DisplayHeatIndex implements IObserver, IDisplay {
  constructor(weather_data: IPublisher) {
  }

  update(updated_data: { [key: string]: any }): void {
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
