import { NgModule } from '@angular/core'
import { BrowserModule } from '@angular/platform-browser'
import { RouterModule } from '@angular/router';

import { EventAppComponent } from './event-app.component';
import { EventListComponent } from './events/event-list.component';
import { EventThumbnailComponent } from './events/event-thumbnail.component';
import { NavBarComponent } from './nav/navbar.component';
import { EventService } from './events/shared/event.service';
import { ToastrService } from './common/toastr.service';
import { EventDetailsComponent } from './events/event-details/event-details.component';
import { AppRoutes } from './routes'
import { CreateEventComponent } from './events/create-event.component';
import { Error404Component } from './error/404.component';
import { EventRouteActivator } from './events/event-details/event-route-activator.service';


@NgModule ({
    imports: [
        BrowserModule,
        AppRoutes
    ],
    declarations: [
        EventAppComponent,
        EventListComponent,
        EventThumbnailComponent,
        EventDetailsComponent,
        CreateEventComponent,
        NavBarComponent,
        Error404Component
    ],
    providers: [
        EventService,
        ToastrService,
        EventRouteActivator
    ],
    bootstrap: [EventAppComponent]
})

export class AppModule {

}