'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('Lemonldap::NG Manager', function() {

  describe('Diff interface', function() {

    it('should find key changed', function() {
      browser.get('/diff.html#6/7');
      element(by.id('t-generalParameters')).click();
      element(by.id('t-advancedParams')).click();
      element(by.id('t-security')).click();
      element(by.id('t-key')).click();
      expect(element(by.id('tdold')).getText()).toEqual('éà©®');
      expect(element(by.id('tdnew')).getText()).toEqual('qwertyui');
    });

  });
});