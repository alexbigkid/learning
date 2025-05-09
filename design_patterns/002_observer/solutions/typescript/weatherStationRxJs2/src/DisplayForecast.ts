import { Observable } from "rxjs";
import { IDisplay } from "./IDisplay";
import { WeatherInfoType } from "./WeatherData";

export class DisplayForecast implements IDisplay {
  private currentPressure: number = 29.92;
  private lastPressure: number | null = null;

  constructor(private weatherData: Observable<WeatherInfoType>) {
    this.weatherData.subscribe(data => this.update(data));
  }

  update(updatedData: WeatherInfoType): void {
    const currentPressure = updatedData.pressure;
    if (currentPressure !== undefined) {
      this.lastPressure = this.currentPressure;
      this.currentPressure = currentPressure;
      this.display();
    }
  }

  display(): void {
    let forecast: string;
    if (this.lastPressure === null) {
      forecast = 'No data for comparison';
    } else if (this.currentPressure > this.lastPressure) {
      forecast = 'Improving weather on the way!';
    } else if (this.currentPressure === this.lastPressure) {
      forecast = 'More of the same';
    } else {
      forecast = 'Watch out for cooler, rainy weather';
    }
    console.log(`Forecast: ${forecast}`);
  }
}
