'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('00 Lemonldap::NG', function() {
  describe('Auth mechanism', function() {
  	it('Portal should display 10 lang flags', function() {
  	  browser.driver.get('http://auth.example.com:' + process.env.TESTWEBSERVERPORT + '/');
      browser.driver.findElements(by.className('langicon')).then(function(elems) {
        expect(elems.length).toEqual(11);
      });
      browser.driver.findElement(by.xpath("//img[@title='en']")).click();
      expect(browser.driver.findElement(by.css('[trmsg="9"]')).getText()).toEqual('Authentication required');
      expect(browser.driver.findElement(by.css('[trspan="createAccount"]')).getText()).toEqual('Create an account');
      browser.driver.findElement(by.xpath("//img[@title='it']")).click();
      expect(browser.driver.findElement(by.css('[trmsg="9"]')).getText()).toEqual('Autenticazione necessaria');
      expect(browser.driver.findElement(by.css('[trspan="createAccount"]')).getText()).toEqual('Crea un account');
      browser.driver.findElement(by.xpath("//img[@title='fr']")).click();
      expect(browser.driver.findElement(by.css('[trspan="createAccount"]')).getText()).toEqual('Créer un compte');
    });
    it('should want to crete an account', function() {
      browser.driver.findElement(by.css('[trspan="createAccount"]')).click();
      expect(browser.driver.findElement(by.css('[trmsg="78"]')).getText()).toEqual('Merci de saisir vos informations');

      // A four inputs form + one captcha
      browser.driver.findElements(by.className('input-group')).then(function(elems) {
        expect(elems.length).toEqual(4);
      });
      browser.driver.findElements(by.className('img-thumbnail')).then(function(elems) {
        expect(elems.length).toEqual(1);
      });
    });
    it('should want to authenticate', function() {
      expect(browser.driver.findElement(by.css('[trspan="back2Portal"]')).getText()).toEqual('Retourner au portail');
      browser.driver.findElement(by.css('[trspan="back2Portal"]')).click();
      browser.driver.findElement(by.xpath("//input[@name='user']")).sendKeys('dwho');
      browser.driver.findElement(by.xpath("//input[@name='password']")).sendKeys('dwho');
      browser.driver.findElement(by.xpath("//button[@type='submit']")).click();
    });
  });
});