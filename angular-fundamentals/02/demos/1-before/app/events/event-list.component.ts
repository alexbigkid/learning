import { Component } from '@angular/core'

@Component ({
    selector: 'event-list',
    templateUrl: 'app/events/event-list.component.html'
})

export class EventListComponent {
    event = {
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