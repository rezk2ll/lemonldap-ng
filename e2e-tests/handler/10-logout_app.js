'use strict';

describe('Lemonldap::NG', function() {
  describe('Logout_app', function() {
    it('should accept authentication as dwho/dwho', function() {
      browser.driver.get('http://auth.example.com:' + process.env.TESTWEBSERVERPORT + '/');
      browser.driver.findElement(by.xpath("//input[@name='user']")).sendKeys('dwho');
      browser.driver.findElement(by.xpath("//input[@name='password']")).sendKeys('dwho');
      browser.driver.findElement(by.xpath("//button[@type='submit']")).click();
    });
    it('should allow logout_app', function() {
      browser.driver.get('http://test1.example.com:' + process.env.TESTWEBSERVERPORT + '/index.pl?logout_app');
    });
    it('should keep session', function() {
      expect(browser.getCurrentUrl()).toMatch(new RegExp('^http://test1.example.com(:' + process.env.TESTWEBSERVERPORT + ')?/index.pl\\?foo=1'));
    });
  });
});