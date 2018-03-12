'use strict';

describe('Lemonldap::NG handler', function() {

  describe('Header insertion mechanism', function() {
    it('should display headers', function() {
      browser.driver.get('http://test1.example.com:' + process.env.TESTWEBSERVERPORT + '/');
      expect(browser.driver.findElement(by.id('v-Auth-User')).getText()).toEqual('dwho');
      expect(browser.driver.findElement(by.id('v-Ip-Addr')).getText()).toMatch(/^\d+\.\d+\.\d+\.\d+$/);
      expect(browser.driver.findElement(by.id('v-Macro-Uri')).getText()).toMatch(/\w/);
    });
    it('should display custom functions results', function() {
      expect(browser.driver.findElement(by.id('v-Hello')).getText()).toEqual('Hello');
      expect(browser.driver.findElement(by.id('v-Uri')).getText()).toEqual('/');
      expect(browser.driver.findElement(by.id('v-Additional-Arg')).getText()).toEqual('header-added');
      expect(browser.driver.findElement(by.id('v-Base64')).getText()).toEqual('YTpi');
    });
  });
});