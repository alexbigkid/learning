import { IObserver } from './IObserver';

export interface IPublisher {
  subscribe(observer: IObserver): void;
  unsubscribe(observer: IObserver): void;
  notify(data: { [key: string]: any }): void;
}
