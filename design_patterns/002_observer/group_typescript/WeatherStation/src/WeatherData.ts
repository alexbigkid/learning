import { IObserver } from './IObserver';
import { IPublisher } from './IPublisher';

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

export class WeatherData implements IPublisher {
  private _observers: IObserver[];

  constructor() {
  }

  subscribe(observer: IObserver): void {
  }

  unsubscribe(observer: IObserver): void {
  }

  notify(data: { [key: string]: any }): void {
  }

  setMeasurements(data: WeatherInfoType): void {
  }
}
