import { Component, OnInit } from '@angular/core'
import { EventService } from './shared/event.service';

@Component ({
    selector: 'event-list',
    template: `
    <div>
        <h1>Upcoming Angular 2 Events</h1>
        <hr />
        <div class="row">
            <div class="col-md-5" *ngFor="let event of events">
                <event-thumbnail [event]="event"></event-thumbnail>
            </div>
        </div>
    </div>
    `
})

export class EventListComponent implements OnInit {
  events: any[];
  
  constructor(private eventService: EventService) {
  }

  ngOnInit() {
    this.events = this.eventService.getEvents();
  }
}