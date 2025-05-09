import { Observable } from "rxjs";
import { IDisplay } from "./IDisplay";
import { WeatherInfoType } from "./WeatherData";

export class DisplayStatistic implements IDisplay {
  private maxTemp: number = 0.0;
  private minTemp: number = 200.0;
  private tempSum: number = 0.0;
  private numReadings: number = 0;

  constructor(private weatherData: Observable<WeatherInfoType>) {
    this.weatherData.subscribe(data => this.update(data));
  }

  update(updatedData: WeatherInfoType): void {
    const currentTemp = updatedData.temperature;

    if (currentTemp !== undefined) {
      this.tempSum += currentTemp;
      this.numReadings++;

      if (currentTemp > this.maxTemp) {
        this.maxTemp = currentTemp;
      }

      if (currentTemp < this.minTemp) {
        this.minTemp = currentTemp;
      }

      this.display();
    }
  }

  display(): void {
    const avgTemp = this.tempSum / this.numReadings;
    console.log(`Avg/Max/Min temperature = ${avgTemp}/${this.maxTemp}/${this.minTemp}`);
  }
}
