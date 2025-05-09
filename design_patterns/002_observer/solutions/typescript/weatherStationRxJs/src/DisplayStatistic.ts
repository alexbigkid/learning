import { Observable, Subscription } from 'rxjs';
import { WeatherData } from './WeatherData';

export class DisplayStatistic {
  private _maxTemp: number = 0.0;
  private _minTemp: number = 200.0;
  private _tempSum: number = 0.0;
  private _numReadings: number = 0;
  private subscription: Subscription;

  constructor(weatherDataObservable: Observable<WeatherData>) {
    this.subscription = weatherDataObservable.subscribe((weatherData: WeatherData) => {
      this.update(weatherData);
    });
  }

  update(weatherData: WeatherData): void {
    const currentTemp = weatherData.temperature;

    if (currentTemp !== undefined) {
      this._tempSum += currentTemp;
      this._numReadings++;

      if (currentTemp > this._maxTemp) {
        this._maxTemp = currentTemp;
      }

      if (currentTemp < this._minTemp) {
        this._minTemp = currentTemp;
      }

      this.display();
    }
  }

  display(): void {
    const avgTemp = this._tempSum / this._numReadings;
    console.log(`Avg/Max/Min temperature = ${avgTemp}/${this._maxTemp}/${this._minTemp}`);
  }

  unsubscribe(): void {
    this.subscription.unsubscribe();
  }
}
