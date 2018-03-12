'use strict';

describe('Lemonldap::NG', function() {
  describe('Logout_app', function() {
    it('should allow logout_app_sso', function() {
      browser.driver.get('http://test1.example.com:' + process.env.TESTWEBSERVERPORT + '/index.pl?logout_all');
    });
    it('should redirect after logout', function() {
      expect(browser.getCurrentUrl()).toMatch(new RegExp('^https://lemonldap-ng\.org/welcome'));
    });
    it('should redirect to portal', function() {
      browser.driver.get('http://test1.example.com:' + process.env.TESTWEBSERVERPORT + '/');
      expect(browser.getCurrentUrl()).toMatch(new RegExp('^http://auth.example.com(:' + process.env.TESTWEBSERVERPORT + ')?/\\?url=aHR0cDovL3Rlc3QxLmV4YW1wbGUuY29tOjE5ODc2Lw=='));
    });
  });
});