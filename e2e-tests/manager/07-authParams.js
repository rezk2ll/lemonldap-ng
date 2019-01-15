'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('07 Lemonldap::NG Manager', function() {

  describe('Form control, part 3 - authParams', function() {

    it('should display auth modules chosen', function() {
      browser.get('/#!/confs/latest');
            browser.sleep(2000);

      element(by.id('a-generalParameters')).click();
      browser.sleep(1000);
      element(by.id('a-authParams')).click();
      browser.sleep(1000);
      element(by.id('t-authentication')).click();
            browser.sleep(2000);

      expect(element(by.id('t-demoParams')).isDisplayed()).toBeTruthy();
      element(by.xpath("//option[@value='Apache']")).click();
      browser.sleep(2000);
      expect(element(by.id('t-apacheParams')).isDisplayed()).toBeTruthy();
    });

    it('should display auth modules chosen with authChoice', function() {
      element(by.xpath("//option[@value='Choice']")).click();
      browser.sleep(1000);
      expect(element(by.id('t-choiceParams')).isDisplayed()).toBeTruthy();
      element(by.id('a-choiceParams')).click();
      browser.sleep(1000);
      element(by.id('t-authChoiceModules')).click();
            browser.sleep(2000);

      //element(by.css('.glyphicon-plus-sign')).click();
      browser.sleep(2000);
      element(by.id('a-authChoiceModules')).click();
      browser.sleep(2000);
      element.all(by.css('.glyphicon-plus-sign')).first().click();
      element(by.id('t-authChoiceModules/n1')).click();
      browser.sleep(2000);
      element.all(by.xpath("//option[@value='LDAP']")).first().click();
      expect(element(by.id('t-ldapParams')).isDisplayed()).toBeTruthy();
    });

    it('should display auth modules chosen with authCombination', function() {
      element(by.id('t-authentication')).click();
      browser.sleep(1000);
      element(by.xpath("//option[@value='Combination']")).click();
      browser.sleep(1000);
      expect(element(by.id('t-combinationParams')).isDisplayed()).toBeTruthy();
      element(by.id('a-combinationParams')).click();
      browser.sleep(1000);
      element(by.id('t-combModules')).click();
            browser.sleep(2000);

      element(by.css('.glyphicon-plus-sign')).click();
      element(by.xpath("//option[@value='DBI']")).click();
      expect(element(by.id('t-dbiParams')).isDisplayed()).toBeTruthy();
      element.all(by.xpath("//option[@value='LDAP']")).first().click();
      expect(element(by.id('t-ldapParams')).isDisplayed()).toBeTruthy();
    });
  });
});