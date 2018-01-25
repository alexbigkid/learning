import { NgModule } from '@angular/core'
import { BrowserModule } from '@angular/platform-browser'

import { EventAppComponent } from './event-app.component';
import { EventListComponent } from './events/event-list.component';


@NgModule ({
    imports: [BrowserModule],
    declarations: [
        EventAppComponent,
        EventListComponent
    ],
    bootstrap: [EventAppComponent]
})

export class AppModule {

}