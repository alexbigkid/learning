import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router'

import { EventListComponent } from "./events/event-list.component";
import { EventDetailsComponent } from "./events/event-details/event-details.component";

const appRoutes:Routes = [
    { path: 'events', component: EventListComponent },
    { path: 'events/:id', component: EventDetailsComponent },
    { path: '', redirectTo: '/events', pathMatch: 'full' },
    { path: '**', redirectTo: '/events', pathMatch: 'full' }
]

@NgModule({
    imports: [
        RouterModule.forRoot(appRoutes),
    ],
    declarations: [],
    exports: [
        RouterModule
    ]

})
export class AppRoutes {}
