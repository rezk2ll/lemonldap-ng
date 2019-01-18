'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('07u Lemonldap::NG Manager', function() {

  describe('Apply mechanism', function() {

    it('should be able to send UTF-8 chars', function() {
      browser.get('/#!/confs/latest');
      element(by.id('a-generalParameters')).click();
      element(by.id('a-advancedParams')).click();
      element(by.id('a-security')).click();
      element(by.id('t-key')).click();
      element(by.id('pwdinput')).clear().sendKeys('éà©®');
    });
    it('should save new configuration', function() {
      element(by.id('save')).click();
      element(by.id('longtextinput')).sendKeys('UTF-8 tests');
      element(by.id('saveok')).click();
            browser.sleep(2000);

      element(by.id('messageok')).click();
      expect(element(by.id('cfgnum')).getText()).toEqual('2');
    });
    it('should restitute UTF chars', function() {
      element(by.id('a-generalParameters')).click();
      element(by.id('a-advancedParams')).click();
      element(by.id('a-security')).click();
      element(by.id('t-key')).click();
      element(by.id('showp')).click();
      expect(element(by.id('pwdinput')).getAttribute('value')).toEqual('éà©®');
    });
  });
});