import { browser, element, by, ElementFinder } from 'protractor';

export class LoginPage {
  navigateTo() {
    return browser.get('/user/login');
  }

  getErrorAlert() {
    return element(by.css('div.alert-danger'));
  }

  getUsernameTextbox() {
    return element(by.css('input[name=userName]'));
  }

  getPasswordTextbox() {
    return element(by.css('input[name=password]'));
  }

  getLoginButton() {
    return element(by.css('button[type=submit]'));
  }
}