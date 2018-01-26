import { Component } from '@angular/core'

@Component ({
    selector: 'event-list',
    template: `
    <div>
        <h1>Upcoming Angular 2 Events</h1>
        <hr />
        <event-thumbnail #thumbnail [event]="event1"></event-thumbnail>
        <button class="btn btn-primary" (click)="thumbnail.logFoo()">Log me some foo</button>
    </div>
    `
})

export class EventListComponent {
    event1 = {
        id: 1,
        name: 'Angular Connect',
        date: '01/25/20018',
        time: '12:55 pm',
        price: 599.99,
        imageUrl: '/app/assets/images/angularconnect-shield.png',
        location: {
            address: '10357 DT',
            city: 'London',
            country: 'England'
        }
    }

}