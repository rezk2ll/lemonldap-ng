'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('08 Lemonldap::NG Manager', function() {

  describe('Apply mechanism', function() {

    it('should be able to add reload urls', function() {
      browser.get('/#!/confs/latest');
      browser.sleep(1000);
      element(by.id('a-generalParameters')).click();
      element(by.id('a-reloadParams')).click();
      element(by.id('t-reloadUrls')).click();
            element(by.id('a-reloadUrls')).click();

      browser.sleep(1000);
      //element(by.id('a-reloadUrls')).click();
      element(by.css('.glyphicon-plus-sign')).click();
      browser.sleep(1000);

      element(by.id('t-reloadUrls/n1')).click();
      browser.sleep(1000);
      element(by.id('hashkeyinput')).clear().sendKeys('auth.example.com');
      browser.sleep(1000);
      element(by.id('hashvalueinput')).clear().sendKeys('http://auth.example.com:19876/static/common/icons/ok.png');
      browser.sleep(1000);
      element(by.css('.glyphicon-plus-sign')).click();
      element(by.id('t-reloadUrls/n2')).click();
      element(by.id('hashkeyinput')).clear().sendKeys('manager.example.com');
      element(by.id('hashvalueinput')).clear().sendKeys('http://manager.example.com:19876/static/js/manager.js');
            browser.sleep(1000);

    });
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