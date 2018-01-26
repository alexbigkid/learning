import { Component, Input, Output, EventEmitter } from '@angular/core';
// import { EventEmitter } from '@angular/core/src/facade/async';

@Component ({
    selector: 'event-thumbnail',
    template: `
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
    `
})
export class EventThumbnailComponent {
    @Input() event: any
    someProperty:any = "some value"
    
    logFoo() {
        console.log('foo')
    }
}
