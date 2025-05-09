import { browser, element, by, ElementFinder } from 'protractor';

export class EventsPage {
  navigateTo() {
    return browser.get('/events');
  }

  getPageHeadingText() {
    return element(by.css('h1')).getText();
  }

  getEventsList() {
    return element.all(by.css('event-thumbnail'));
  }

  getFirstEvent() {
    return this.getEventsList().first();
  }

  getEventHeading(event: ElementFinder) {
    return event.element(by.css('h2')).getText();
  }
}