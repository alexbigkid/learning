// DisplayHeatIndex.ts
import { Observable } from 'rxjs';
import { WeatherData } from './WeatherData';

export class DisplayHeatIndex {
  private heatIndex: number = 0.0;
  private currentTemp: number = 74;
  private currentHumidity: number = 70;

  constructor(weatherDataObservable: Observable<WeatherData>) {
    weatherDataObservable.subscribe((weatherData: WeatherData) => {
      this.update(weatherData);
    });
  }

  update(weatherData: WeatherData): void {
    const currentTemp = weatherData.temperature;
    const currentHumidity = weatherData.humidity;

    if (currentTemp !== undefined) {
      this.currentTemp = currentTemp;
    }
    if (currentHumidity !== undefined) {
      this.currentHumidity = currentHumidity;
    }

    // Calculate heat index and display
    this.heatIndex = this.computeHeatIndex();
    this.display();
  }

  private computeHeatIndex(): number {
    const t = this.currentTemp;
    const rh = this.currentHumidity;

    // Calculation formula for heat index
    // This formula may need to be adjusted based on your specific requirements
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
    console.log(`Heat index: ${this.heatIndex}`);
  }
}
