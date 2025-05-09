export interface IObserver {
  update(updated_data: { [key: string]: any }): void;
}
