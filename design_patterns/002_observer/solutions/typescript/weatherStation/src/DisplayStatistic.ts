import { IDisplay } from './IDisplay';
import { IObserver } from './IObserver';
import { IPublisher } from './IPublisher';
import { WeatherInfo } from './WeatherData';

export class DisplayStatistic implements IObserver, IDisplay {
  private _weather_data: IPublisher;
  private _max_temp: number = 0.0;
  private _min_temp: number = 200.0;
  private _temp_sum: number = 0.0;
  private _num_readings: number = 0;

  constructor(weather_data: IPublisher) {
    this._weather_data = weather_data;
    weather_data.subscribe(this);
  }

  update(updated_data: { [key: string]: any }): void {
    const current_temp = updated_data[WeatherInfo.TEMPERATURE];

    if (current_temp !== undefined) {
      this._temp_sum += current_temp;
      this._num_readings++;

      if (current_temp > this._max_temp) {
        this._max_temp = current_temp;
      }

      if (current_temp < this._min_temp) {
        this._min_temp = current_temp;
      }

      this.display();
    }
  }

  display(): void {
    const avgTemp = this._temp_sum / this._num_readings;
    console.log(`Avg/Max/Min temperature = ${avgTemp}/${this._max_temp}/${this._min_temp}`);
  }
}
