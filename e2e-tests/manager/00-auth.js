'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('Lemonldap::NG', function() {

  describe('Auth mechanism', function() {

    it('should want to authenticate', function() {
      browser.driver.get('http://auth.example.com:' + process.env.TESTWEBSERVERPORT + '/');
      browser.driver.findElement(by.xpath("//input[@name='user']")).sendKeys('dwho');
      browser.driver.findElement(by.xpath("//input[@name='password']")).sendKeys('dwho');
      browser.driver.findElement(by.xpath("//button[@type='submit']")).click();
    });
  });
});