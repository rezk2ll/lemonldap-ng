'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('Lemonldap::NG', function() {

  describe('Form replay mechanism', function() {
    it('should redirect to index.pl', function() {
      browser.driver.get('http://test1.example.com:' + process.env.TESTWEBSERVERPORT + '/form.html');
      expect(browser.driver.findElement(by.id('field_postuid')).getText()).toEqual('dwho');
    });
  });
});