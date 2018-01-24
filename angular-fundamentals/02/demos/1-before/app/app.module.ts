import { NgModule } from '@angular/core'
import { BrowserModule } from '@angular/platform-browser'

import { EventAppComponent } from './event-app.component';


@NgModule ({
    imports: [BrowserModule],
    declarations: [EventAppComponent],
    bootstrap: [EventAppComponent]
})

export class AppModule {

}