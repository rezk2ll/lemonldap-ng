'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('11 Lemonldap::NG Manager', function() {

  describe('OIDC OP configuration', function() {

    it('should add an OIDC OP', function() {
      browser.get('/#/confs/latest');
      element(by.id('t-oidcOPMetaDataNodes')).click();
      element.all(by.css('.glyphicon-plus-sign')).first().click();
      element(by.id('promptok')).click();
      browser.sleep(500);
      element(by.id('a-oidcOPMetaDataNodes/new__op-example')).click();
      element(by.id('t-oidcOPMetaDataNodes/new__op-example/oidcOPMetaDataJSON')).click();
      element(by.id('filetext')).sendKeys('{"a":"b"}');
      element(by.id('t-oidcOPMetaDataNodes/new__op-example/oidcOPMetaDataJWKS')).click();
      element(by.id('filetext')).sendKeys('{"c":"d"}');
      element(by.id('t-oidcOPMetaDataNodes/new__op-example/oidcOPMetaDataExportedVars')).click();
      element.all(by.css('.glyphicon-plus-sign')).first().click();
      //element(by.id('a-oidcOPMetaDataNodes/new__op-example/oidcOPMetaDataExportedVars')).click();
      element(by.id('t-oidcOPMetaDataNodes/new__op-example/oidcOPMetaDataExportedVars/n1')).click();
      element(by.id('hashkeyinput')).clear().sendKeys('MyKey');
      element(by.id('hashvalueinput')).clear().sendKeys('MyValue');
      element(by.id('a-oidcOPMetaDataOptions')).click();
      element(by.id('a-oidcOPMetaDataOptionsConfiguration')).click();
      element(by.id('t-oidcOPMetaDataNodes/new__op-example/oidcOPMetaDataOptionsConfigurationURI')).click();
      element(by.id('textinput')).clear().sendKeys('http://my-partner.com');
    });
    it('should save new configuration', function() {
      element(by.id('save')).click();
      element(by.id('longtextinput')).sendKeys('Create OIDC OP');
      element(by.id('saveok')).click();
      element(by.id('messageok')).click();
      expect(element(by.id('cfgnum')).getText()).toEqual('5');
    });
    it('should restore configured values', function() {
      element(by.id('a-oidcOPMetaDataNodes')).click();
      element(by.id('a-oidcOPMetaDataNodes/op-example')).click();
      element(by.id('t-oidcOPMetaDataNodes/op-example/oidcOPMetaDataJSON')).click();
      expect(element(by.id('filetext')).getAttribute('value')).toEqual('{"a":"b"}');
      element(by.id('t-oidcOPMetaDataNodes/op-example/oidcOPMetaDataJWKS')).click();
      expect(element(by.id('filetext')).getAttribute('value')).toEqual('{"c":"d"}');
      element(by.id('a-oidcOPMetaDataNodes/op-example/oidcOPMetaDataExportedVars')).click();
      browser.sleep(500);
      element(by.id('t-oidcOPMetaDataNodes/op-example/oidcOPMetaDataExportedVars/1')).click();
      expect(element(by.id('hashkeyinput')).getAttribute('value')).toEqual('MyKey');
      expect(element(by.id('hashvalueinput')).getAttribute('value')).toEqual('MyValue');
      element(by.id('a-oidcOPMetaDataOptions')).click();
      element(by.id('a-oidcOPMetaDataOptionsConfiguration')).click();
      element(by.id('t-oidcOPMetaDataNodes/op-example/oidcOPMetaDataOptionsConfigurationURI')).click();
      expect(element(by.id('textinput')).getAttribute('value')).toEqual('http://my-partner.com');
    });
  });
});