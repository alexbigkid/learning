import { NgModule } from '@angular/core'
import { BrowserModule } from '@angular/platform-browser'

import { EventAppComponent } from './event-app.component';
import { EventListComponent } from './events/event-list.component';
import { EventThumbnailComponent } from './events/event-thumbnail.component';
import { NavBarComponent } from './nav/navbar.component';
import { EventService } from './events/shared/event.service';
import { ToastrService } from './common/toastr.service';



@NgModule ({
    imports: [BrowserModule],
    declarations: [
        EventAppComponent,
        EventListComponent,
        EventThumbnailComponent,
        NavBarComponent
    ],
    providers: [EventService, ToastrService],
    bootstrap: [EventAppComponent]
})

export class AppModule {

}