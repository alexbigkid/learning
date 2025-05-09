import { Observable, Subject } from "rxjs";

export enum WeatherInfo {
  TEMPERATURE = 'temperature',
  HUMIDITY = 'humidity',
  PRESSURE = 'pressure',
}

export type WeatherInfoType = {
  temperature?: number;
  humidity?: number;
  pressure?: number;
};

export class WeatherData extends Observable<WeatherInfoType> {
  private subject = new Subject<WeatherInfoType>();

  constructor() {
    super(subscriber => this.subject.subscribe(subscriber));
  }

  setMeasurements(data: WeatherInfoType): void {
    this.subject.next(data);
  }

  unsubscribe(): void {
    // Unsubscribe logic if needed
  }
}
