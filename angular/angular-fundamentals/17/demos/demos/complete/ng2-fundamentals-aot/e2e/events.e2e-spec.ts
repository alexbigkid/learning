import { browser, element, by } from 'protractor';
import { EventsPage } from './page-objects/events-page';

describe('Events', () => {
  let page: EventsPage;

  beforeEach(() => {
    page = new EventsPage();
  });

  it('should display the Page Heading Text', () => {
    page.navigateTo();
    expect(page.getPageHeadingText()).toEqual('Upcoming Angular 2 Events');
  });

  it('should display the first event heading text', () => {
    page.navigateTo();
    let eventHeading = page.getEventHeading(page.getFirstEvent());
    expect(eventHeading).toEqual('ANGULAR CONNECT');
  })

})