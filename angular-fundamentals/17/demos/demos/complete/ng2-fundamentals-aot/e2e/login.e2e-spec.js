"use strict";
var protractor_1 = require('protractor');
var login_page_1 = require('./page-objects/login-page');
describe('Events', function () {
    var page;
    beforeEach(function () {
        page = new login_page_1.LoginPage();
    });
    it('should not show an error by default', function () {
        page.navigateTo();
        page.getErrorAlert().isPresent().then(function (present) {
            expect(present).toBe(false);
        });
    });
    it('should show an error if login info is invalid', function () {
        page.navigateTo();
        page.getUsernameTextbox().sendKeys('bupkis');
        page.getPasswordTextbox().sendKeys('asdf');
        page.getLoginButton().click();
        page.getErrorAlert().isPresent().then(function (present) {
            expect(present).toBe(true);
        });
    });
    it('should navigate to events page if login successful', function () {
        page.navigateTo();
        page.getUsernameTextbox().sendKeys('johnpapa');
        page.getPasswordTextbox().sendKeys('asdf');
        page.getLoginButton().click();
        protractor_1.browser.getCurrentUrl().then(function (url) {
            expect(url).toEqual('http://localhost:8808/events');
        });
    });
});
//# sourceMappingURL=login.e2e-spec.js.map