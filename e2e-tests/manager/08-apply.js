'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('08 Lemonldap::NG Manager', function() {

  describe('Apply mechanism', function() {

    it('should be able to add reload urls', function() {
      browser.get('/#/confs/latest');
      element(by.id('a-generalParameters')).click();
      element(by.id('t-reloadParams')).click();
      element(by.id('t-reloadUrls')).click();
      element(by.css('.glyphicon-plus-sign')).click();
      element(by.id('a-reloadUrls')).click();
      element(by.id('t-reloadUrls/n1')).click();
      element(by.id('hashkeyinput')).clear().sendKeys('auth.example.com:19876');
      element(by.id('hashvalueinput')).clear().sendKeys('http://auth.example.com:19876/static/nothing');
      element(by.css('.glyphicon-plus-sign')).click();
      element(by.id('t-reloadUrls/n2')).click();
      element(by.id('hashkeyinput')).clear().sendKeys('manager.example.com:19876');
      element(by.id('hashvalueinput')).clear().sendKeys('http://auth.example.com:19876/static/js/manager.js');
    });
    it('should save new configuration', function() {
      element(by.id('save')).click();
      element(by.id('longtextinput')).sendKeys('Reload URLs test');
      element(by.id('saveok')).click();
      expect(element.all(by.repeater('item in item.items')).count()).toEqual(2);
      element(by.id('messageok')).click();
      expect(element(by.id('cfgnum')).getText()).toEqual('3');
    });
  });
});