'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('08 Lemonldap::NG Manager', function() {

  describe('Apply mechanism', function() {

    it('should save new configuration', function() {
      element(by.id('save')).click();
      element(by.id('longtextinput')).sendKeys('Reload URLs test');
      element(by.id('saveok')).click();
      expect(element.all(by.repeater('item in item.items')).count()).toEqual(2);
            browser.sleep(1000);

      element(by.id('messageok')).click();
      expect(element(by.id('cfgnum')).getText()).toEqual('3');
    });
  });
});
