'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('Lemonldap::NG', function() {

  describe('Redirection mechanism', function() {

    it('should redirect to portal', function() {
      browser.ignoreSynchronization = true;
      browser.driver.get('http://test1.example.com:' + process.env.TESTWEBSERVERPORT + '/');
      expect(browser.getCurrentUrl()).toMatch(new RegExp('^http://auth.example.com(:' + process.env.TESTWEBSERVERPORT + ')?/\\?url=aHR0cDovL3Rlc3QxLmV4YW1wbGUuY29tOjE5ODc2Lw=='));
    });
    it('should accept authentication as dwho/dwho', function() {
      browser.driver.findElement(by.xpath("//input[@name='user']")).sendKeys('dwho');
      browser.driver.findElement(by.xpath("//input[@name='password']")).sendKeys('dwho');
      browser.driver.findElement(by.xpath("//button[@type='submit']")).click();
    });
    it('should redirect to test1.example.com', function() {
      expect(browser.getCurrentUrl()).toMatch(new RegExp('^http://test1.example.com(:' + process.env.TESTWEBSERVERPORT + ')?'));
    });
  });
});