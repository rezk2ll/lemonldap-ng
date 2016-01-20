'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('Lemonldap::NG Manager', function() {

  it('should be able to restore an old configuration', function() {
    browser.get('/#/confs/1');
    element(by.id('save')).click();
    element(by.id('longtextinput')).sendKeys('Restore conf 1');
    element(by.id('saveok')).click();
    browser.sleep(500);
    element(by.id('messageok')).click();
    browser.sleep(500);
    element(by.id('forcesave')).click();
    element(by.id('longtextinput')).sendKeys('Force to restore conf 1');
    element(by.id('saveok')).click();
    element(by.id('messageok')).click();
    expect(element(by.id('cfglog')).getText()).toEqual('Force to restore conf 1');
  });

});