import { browser, element, by } from 'protractor';
import { LoginPage } from './page-objects/login-page';

describe('Events', () => {
  let page: LoginPage;

  beforeEach(() => {
    page = new LoginPage();
  });

  it('should not show an error by default', () => {
    page.navigateTo();

    page.getErrorAlert().isPresent().then(present => {
      expect(present).toBe(false);
    });
  });

  it('should show an error if login info is invalid', () => {
    page.navigateTo();

    page.getUsernameTextbox().sendKeys('bupkis');
    page.getPasswordTextbox().sendKeys('asdf');
    page.getLoginButton().click();

    page.getErrorAlert().isPresent().then(present => {
      expect(present).toBe(true);
    });
  });

  it('should navigate to events page if login successful', () => {
    page.navigateTo();

    page.getUsernameTextbox().sendKeys('johnpapa');
    page.getPasswordTextbox().sendKeys('asdf');
    page.getLoginButton().click();

    browser.getCurrentUrl().then(url => {
      expect(url).toEqual('http://localhost:8808/events');
    })
  });
});