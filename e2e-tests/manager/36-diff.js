'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('36 Lemonldap::NG Manager', function() {

  describe('Diff interface', function() {

    it('should find key changed', function() {
      browser.get('/diff.html#!/5/6');
            browser.sleep(5000);

      element(by.id('t-generalParameters')).click();
      element(by.id('t-advancedParams')).click();
      element(by.id('t-security')).click();
      element(by.id('t-key')).click();
      expect(element(by.id('tdold')).getText()).toEqual('éà©®');
      expect(element(by.id('tdnew')).getText()).toEqual('qwertyui');
    });

  });
});