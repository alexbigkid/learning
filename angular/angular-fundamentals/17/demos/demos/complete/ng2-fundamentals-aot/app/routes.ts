import { Routes } from '@angular/router'
import { 
  EventsListComponent, 
  EventDetailsComponent, 
  CreateEventComponent, 
  EventListResolver,
  CreateSessionComponent,
  EventResolver } from './events/index'
import { Error404Component } from './errors/404.component'
import { userRoutes } from './user/user.routes'

export const appRoutes : Routes = [
  { path: 'events/new', component: CreateEventComponent, canDeactivate: ['canDeactivateCreateEvent'] },
  { path: 'events', component: EventsListComponent, resolve: {events: EventListResolver}},
  { path: 'events/:id', component: EventDetailsComponent, resolve: {event: EventResolver}},
  { path: 'events/session/new', component: CreateSessionComponent },
  { path: '404', component: Error404Component },
  { path: '', redirectTo: '/events', pathMatch: 'full' },
  { 
    path: 'user', 
    children: userRoutes
    // loadChildren: 'app/user/user.module#UserModule' 
  }
]