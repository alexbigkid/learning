"use strict";
var protractor_1 = require('protractor');
var EventsPage = (function () {
    function EventsPage() {
    }
    EventsPage.prototype.navigateTo = function () {
        return protractor_1.browser.get('/events');
    };
    EventsPage.prototype.getPageHeadingText = function () {
        return protractor_1.element(protractor_1.by.css('h1')).getText();
    };
    EventsPage.prototype.getEventsList = function () {
        return protractor_1.element.all(protractor_1.by.css('event-thumbnail'));
    };
    EventsPage.prototype.getFirstEvent = function () {
        return this.getEventsList().first();
    };
    EventsPage.prototype.getEventHeading = function (event) {
        return event.element(protractor_1.by.css('h2')).getText();
    };
    return EventsPage;
}());
exports.EventsPage = EventsPage;
//# sourceMappingURL=events-page.js.map