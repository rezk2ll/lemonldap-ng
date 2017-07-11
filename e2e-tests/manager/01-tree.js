'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('Lemonldap::NG Manager', function() {

  describe('Tree display', function() {

    it('should display 9 main nodes', function() {
      browser.get('/');
      var mainNodes = element.all(by.repeater('node in data track by node.id'));
      expect(mainNodes.count()).toEqual(12);
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
    it('should find 19 auth/user modules but only Demo visible', function() {
      browser.get('/#/confs/1');
      element(by.id('a-generalParameters')).click();
      element(by.id('a-authParams')).click();
      /* todo */
    });
    it('should have a hash form if a key is clicked', function() {
      element(by.id('a-demoParams')).click();
      element(by.id('a-demoExportedVars')).click();
      element(by.id('t-demoExportedVars/cn')).click();
      var def = element.all(by.id('hashkeyinput'));
      expect(def.count()).toEqual(1);
    });
  });
});