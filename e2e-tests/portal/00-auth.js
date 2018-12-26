'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('00 Lemonldap::NG', function() {
  describe('Auth mechanism', function() {
  	it('Portal should display 11 lang flags', function() {
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
    it('should want to authenticate with history', function() {
      expect(browser.driver.findElement(by.css('[trspan="back2Portal"]')).getText()).toEqual('Retourner au portail');
      browser.driver.findElement(by.css('[trspan="back2Portal"]')).click();

      // Failed login attempt
      browser.driver.findElement(by.xpath("//input[@name='user']")).sendKeys('dwho');
      browser.driver.findElement(by.xpath("//input[@name='password']")).sendKeys('ohwd');
      browser.driver.findElement(by.xpath("//input[@name='checkLogins']")).click();
      browser.driver.findElement(by.xpath("//button[@type='submit']")).click();
      expect(browser.driver.findElement(by.css('[trmsg="5"]')).getText()).toEqual('Mot de passe ou identifiant incorrect');
      browser.driver.findElement(by.css('[trspan="goToPortal"]')).click();

      // Login attempt
      browser.driver.findElement(by.xpath("//input[@name='user']")).sendKeys('dwho');
      browser.driver.findElement(by.xpath("//input[@name='password']")).sendKeys('dwho');
      browser.driver.findElement(by.xpath("//input[@name='checkLogins']")).click();
      browser.driver.findElement(by.xpath("//button[@type='submit']")).click();
      browser.driver.findElement(by.xpath("//img[@title='de']")).click();
      expect(browser.driver.findElement(by.css('[trspan="info"]')).getText()).toEqual("Information");
      browser.driver.findElements(by.xpath('//table/tbody/tr')).then(function(elems) {
        expect(elems.length).toEqual(5);
      });

      // Expect history with one login and one failed login
      browser.driver.findElements(by.xpath('//form/div/div/h3')).then(function(elems) {
        expect(elems.length).toEqual(3);
        expect(elems[0].getText()).toEqual('Information');
        expect(elems[1].getText()).toEqual('Letzte Anmeldungen');
        expect(elems[2].getText()).toEqual('Letzte fehlgeschlagene Anmeldungen');
      });
      browser.driver.findElements(by.xpath('//table/thead/tr/th')).then(function(elems) {
      	expect(elems.length).toEqual(5);
      	expect(elems[0].getText()).toEqual('Datum');
      	expect(elems[2].getText()).toEqual('Datum');
      	expect(elems[4].getText()).toEqual('Fehlermeldung');
      });
      browser.driver.findElements(by.xpath('//table/tbody/tr/td')).then(function(elems) {
      	expect(elems.length).toEqual(11);
      	expect(elems[1].getText()).toEqual('127.0.0.1');
      	expect(elems[3].getText()).toEqual('127.0.0.1');
      });
      browser.sleep(5000);
      expect(browser.driver.findElement(by.css('[trspan="PE5"]')).getText()).toEqual('Benutzername oder Passwort nicht korrekt');
      expect(browser.driver.findElement(by.id('timer')).getText()).toMatch(/^Du wirst in \d{2} Sekunden umgeleitet$/);
      browser.driver.findElement(by.xpath("//button[@type='reset']")).click();
      expect(browser.driver.findElement(by.id('timer')).isDisplayed()).toEqual(false);
      browser.driver.findElement(by.xpath("//button[@type='submit']")).click();
    });
  });
});
