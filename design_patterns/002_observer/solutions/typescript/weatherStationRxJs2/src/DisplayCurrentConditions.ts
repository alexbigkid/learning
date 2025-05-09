import { Observable } from "rxjs";
import { IDisplay } from "./IDisplay";
import { WeatherInfoType } from "./WeatherData";

export class DisplayCurrentConditions implements IDisplay {
  private temperature: number | null = null;
  private humidity: number | null = null;

  constructor(private weatherData: Observable<WeatherInfoType>) {
    this.weatherData.subscribe(data => this.update(data));
  }

  update(updatedData: WeatherInfoType): void {
    if (updatedData.temperature !== undefined) {
      this.temperature = updatedData.temperature;
    }
    if (updatedData.humidity !== undefined) {
      this.humidity = updatedData.humidity;
    }
    this.display();
  }

  display(): void {
    if (this.temperature !== null && this.humidity !== null) {
      console.log(`Current conditions: ${this.temperature} F degrees and ${this.humidity}% humidity`);
    }
  }
}
