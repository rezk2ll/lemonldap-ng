'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('Lemonldap::NG Manager', function() {

  describe('Form control, part 3 - authParams', function() {

    it('should display auth modules chosen', function() {
      browser.get('/#/confs/1');
      element(by.id('a-generalParameters')).click();
      element(by.id('a-authParams')).click();
      element(by.id('t-authentication')).click();
      expect(element(by.id('t-demoParams')).isDisplayed()).toBeTruthy();
      element(by.xpath("//option[@value='Apache']")).click();
      expect(element(by.id('t-apacheParams')).isDisplayed()).toBeTruthy();
    });

    it('should display auth modules chosen with authChoice', function() {
      element(by.xpath("//option[@value='Choice']")).click();
      expect(element(by.id('t-choiceParams')).isDisplayed()).toBeTruthy();
      element(by.id('a-choiceParams')).click();
      element(by.id('t-authChoiceModules')).click();
      element(by.css('.glyphicon-plus-sign')).click();
      element(by.id('a-authChoiceModules')).click();
      element(by.id('t-authChoiceModules/n1')).click();
      element(by.xpath("//option[@value='LDAP']")).click();
      expect(element(by.id('t-ldapParams')).isDisplayed()).toBeTruthy();
    });

    it('should display auth modules chosen with authCombination', function() {
      element(by.id('t-authentication')).click();
      element(by.xpath("//option[@value='Combination']")).click();
      expect(element(by.id('t-combinationParams')).isDisplayed()).toBeTruthy();
      element(by.id('a-combinationParams')).click();
      element(by.id('t-combModules')).click();
      element(by.css('.glyphicon-plus-sign')).click();
      element(by.xpath("//option[@value='DBI']")).click();
      expect(element(by.id('t-dbiParams')).isDisplayed()).toBeTruthy();
      element(by.xpath("//option[@value='LDAP']")).click();
      expect(element(by.id('t-ldapParams')).isDisplayed()).toBeTruthy();
    });
  });
});
