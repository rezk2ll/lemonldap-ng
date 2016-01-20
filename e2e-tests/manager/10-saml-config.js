'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('Lemonldap::NG Manager', function() {

  describe('SAML configuration', function() {

    it('should enable SAML', function() {
      browser.get('/#/confs/latest');
      element(by.id('a-generalParameters')).click();
      element(by.id('a-issuerParams')).click();
      element(by.id('a-issuerDBSAML')).click();
      element(by.id('t-issuerDBSAMLActivation')).click();
      element(by.id('bopeOn')).click();
    });
    it('should generate a signature key', function() {
      element(by.id('a-samlServiceMetaData')).click()
      element(by.id('a-samlServiceSecurity')).click()
      var el = element(by.id('t-samlServiceSecuritySig'));
      el.click()
      element(by.css('.glyphicon-plus-sign')).click();
      element(by.id('passwordok')).click();
      browser.sleep(500);
    });
    it('should generate an encryption key', function() {
      var el = element(by.id('t-samlServiceSecurityEnc'));
      el.click()
      element(by.css('.glyphicon-plus-sign')).click();
      element(by.id('passwordok')).click();
      browser.sleep(500);
    });
    it('should configure organization dysplay name', function() {
      element(by.id('a-samlOrganization')).click();
      element(by.id('t-samlOrganizationDisplayName')).click();
      element(by.id('textinput')).clear().sendKeys('Org1');
    });
    it('should configure organization name', function() {
      element(by.id('t-samlOrganizationName')).click();
      element(by.id('textinput')).clear().sendKeys('Org1');
    });
    it('should save new configuration', function() {
      element(by.id('save')).click();
      element(by.id('longtextinput')).sendKeys('Activate SAML');
      element(by.id('saveok')).click();
      element(by.id('messageok')).click();
      expect(element(by.id('cfgnum')).getText()).toEqual('4');
    });
  });
});