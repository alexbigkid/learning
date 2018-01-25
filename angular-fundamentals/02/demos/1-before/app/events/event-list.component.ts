import { Component } from '@angular/core'

@Component ({
    selector: 'event-list',
    template: `
    <div>
        <h1>Upcoming Angular 2 Events</h1>
        <hr>
        <div class="well hoverwell thumbnail">
            <h2>{{event.name}}</h2>
            <div>Date: {{event.date}}</div>
            <div>Time: {{event.time}}</div>
            <div>Price: \${{event.price}}</div>
            <div>
                <span>Location: {{event.location.address}}</span>
                <span>&nbsp;</span>
                <span>{{event.locatio.city}}, {{event.locatio.country}}</span>
            </div>
        </div>
    </div>
    `
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
            address: '1057 DT',
            city: 'London',
            country: 'England'
        }
    }
}