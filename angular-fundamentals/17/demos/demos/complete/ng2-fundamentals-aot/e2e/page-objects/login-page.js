"use strict";
var protractor_1 = require('protractor');
var LoginPage = (function () {
    function LoginPage() {
    }
    LoginPage.prototype.navigateTo = function () {
        return protractor_1.browser.get('/user/login');
    };
    LoginPage.prototype.getErrorAlert = function () {
        return protractor_1.element(protractor_1.by.css('div.alert-danger'));
    };
    LoginPage.prototype.getUsernameTextbox = function () {
        return protractor_1.element(protractor_1.by.css('input[name=userName]'));
    };
    LoginPage.prototype.getPasswordTextbox = function () {
        return protractor_1.element(protractor_1.by.css('input[name=password]'));
    };
    LoginPage.prototype.getLoginButton = function () {
        return protractor_1.element(protractor_1.by.css('button[type=submit]'));
    };
    return LoginPage;
}());
exports.LoginPage = LoginPage;
//# sourceMappingURL=login-page.js.map