import { Observable } from "rxjs";
import { IDisplay } from "./IDisplay";
import { WeatherInfoType } from "./WeatherData";

export class DisplayHeatIndex implements IDisplay {
  private heatIndex: number = 0.0;

  constructor(private weatherData: Observable<WeatherInfoType>) {
    this.weatherData.subscribe(data => this.update(data));
  }

  update(updatedData: WeatherInfoType): void {
    const currentTemp = updatedData.temperature;
    const currentHumidity = updatedData.humidity;

    if (currentTemp !== undefined && currentHumidity !== undefined) {
      this.heatIndex = this.computeHeatIndex(currentTemp, currentHumidity);
      this.display();
    }
  }

  private computeHeatIndex(temp: number, humidity: number): number {
    // Implementation of heat index calculation
    return 0;
  }

  display(): void {
    console.log(`Heat index: ${this.heatIndex}`);
  }
}
