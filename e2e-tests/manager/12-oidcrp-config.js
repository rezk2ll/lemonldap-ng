'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('12 Lemonldap::NG Manager', function() {

  describe('OIDC RP configuration', function() {

    it('should add an OIDC RP', function() {
      browser.get('/#/confs/latest');
      element(by.id('t-oidcRPMetaDataNodes')).click();
      element.all(by.css('.glyphicon-plus-sign')).first().click();
      element(by.id('promptok')).click();
      browser.sleep(500);
      element(by.id('a-oidcRPMetaDataNodes/new__rp-example')).click();
      element(by.id('t-oidcRPMetaDataNodes/new__rp-example/oidcRPMetaDataExportedVars')).click();
      element.all(by.css('.glyphicon-plus-sign')).first().click();
      //element(by.id('a-oidcRPMetaDataNodes/new__rp-example/oidcRPMetaDataExportedVars')).click();
      element(by.id('t-oidcRPMetaDataNodes/new__rp-example/oidcRPMetaDataExportedVars/n1')).click();
      element(by.id('hashkeyinput')).clear().sendKeys('MyKey');
      element(by.id('hashvalueinput')).clear().sendKeys('MyValue');
      element(by.id('a-oidcRPMetaDataOptions')).click();
      element(by.id('a-oidcRPMetaDataOptionsAuthentication')).click();
      element(by.id('t-oidcRPMetaDataNodes/new__rp-example/oidcRPMetaDataOptionsClientID')).click();
      element(by.id('textinput')).clear().sendKeys('MyClientID');
      element(by.id('t-oidcRPMetaDataNodes/new__rp-example/oidcRPMetaDataOptionsExtraClaims')).click();
      element.all(by.css('.glyphicon-plus-sign')).first().click();
      //element(by.id('a-oidcRPMetaDataNodes/new__rp-example/oidcRPMetaDataOptionsExtraClaims')).click();
      element(by.id('t-oidcRPMetaDataNodes/new__rp-example/oidcRPMetaDataOptionsExtraClaims/n2')).click();
      element(by.id('hashkeyinput')).clear().sendKeys('MyClaim');
      element(by.id('hashvalueinput')).clear().sendKeys('MyAttribute');
    });
    it('should save new configuration', function() {
      element(by.id('save')).click();
      element(by.id('longtextinput')).sendKeys('Create OIDC RP');
      element(by.id('saveok')).click();
      element(by.id('messageok')).click();
      expect(element(by.id('cfgnum')).getText()).toEqual('6');
    });
    it('should restore configured values', function() {
      element(by.id('a-oidcRPMetaDataNodes')).click();
      element(by.id('a-oidcRPMetaDataNodes/rp-example')).click();
      element(by.id('a-oidcRPMetaDataNodes/rp-example/oidcRPMetaDataExportedVars')).click();
      browser.sleep(500);
      element(by.id('t-oidcRPMetaDataNodes/rp-example/oidcRPMetaDataExportedVars/1')).click();
      expect(element(by.id('hashkeyinput')).getAttribute('value')).toEqual('MyKey');
      expect(element(by.id('hashvalueinput')).getAttribute('value')).toEqual('MyValue');
      element(by.id('a-oidcRPMetaDataOptions')).click();
      element(by.id('a-oidcRPMetaDataOptionsAuthentication')).click();
      element(by.id('t-oidcRPMetaDataNodes/rp-example/oidcRPMetaDataOptionsClientID')).click();
      expect(element(by.id('textinput')).getAttribute('value')).toEqual('MyClientID');
      element(by.id('a-oidcRPMetaDataNodes/rp-example/oidcRPMetaDataOptionsExtraClaims')).click();
      browser.sleep(5000);
      element(by.id('t-oidcRPMetaDataNodes/rp-example/oidcRPMetaDataOptionsExtraClaims/1')).click();
      expect(element(by.id('hashkeyinput')).getAttribute('value')).toEqual('MyClaim');
      expect(element(by.id('hashvalueinput')).getAttribute('value')).toEqual('MyAttribute');
    });
  });
});