import { WeatherData } from "./WeatherData";

export interface IDisplay {
  display(data: WeatherData): void;
}
