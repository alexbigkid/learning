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
        NavBarComponent,
    ],
    providers: [EventService, ToastrService],
    bootstrap: [EventAppComponent]
})

export class AppModule {

}