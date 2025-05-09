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
    this._observers = [];
  }

  subscribe(observer: IObserver): void {
    this._observers.push(observer);
  }

  unsubscribe(observer: IObserver): void {
    console.log(`---- Unsubscribing: ${observer.constructor.name}`);
    const index = this._observers.indexOf(observer);
    if (index !== -1) {
      this._observers.splice(index, 1);
    }
  }

  notify(data: { [key: string]: any }): void {
    for (const observer of this._observers) {
      observer.update(data);
    }
  }

  setMeasurements(data: WeatherInfoType): void {
    const updatedMeasurements: { [key: string]: any } = {};
    const updatedList: WeatherInfo[] = [];

    if (data.temperature !== undefined) {
      updatedList.push(WeatherInfo.TEMPERATURE);
      updatedMeasurements[WeatherInfo.TEMPERATURE] = data.temperature;
    }
    if (data.humidity !== undefined) {
      updatedList.push(WeatherInfo.HUMIDITY);
      updatedMeasurements[WeatherInfo.HUMIDITY] = data.humidity;
    }
    if (data.pressure !== undefined) {
      updatedList.push(WeatherInfo.PRESSURE);
      updatedMeasurements[WeatherInfo.PRESSURE] = data.pressure;
    }

    console.log(`Updating: ${updatedList.map(updated => updated)}\n`);
    this.notify(updatedMeasurements);
  }
}
