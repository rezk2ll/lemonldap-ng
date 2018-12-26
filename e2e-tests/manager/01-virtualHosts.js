'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('01 Lemonldap::NG Manager', function() {
  describe('Tree display', function() {
    it('Main => should display 12 main nodes', function() {
      browser.get('/');
      expect(element.all(by.repeater('node in data track by node.id')).count()).toEqual(12);
    });
    it('should find a rule', function() {
      browser.get('/#/confs/1');
      var vhs = element(by.id('a-virtualHosts'));
      vhs.click();
      var vh = element(by.id('a-virtualHosts/manager.example.com'));
      vh.click();
      var r = element(by.id('a-virtualHosts/manager.example.com/locationRules'));
      r.click();
      var def = element.all(by.id("t-virtualHosts/manager.example.com/locationRules/1"));
      expect(def.count()).toEqual(1);
    });
  });
});