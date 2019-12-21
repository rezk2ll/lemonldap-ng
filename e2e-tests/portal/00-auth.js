'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('00 Lemonldap::NG', function() {
  describe('Auth mechanism', function() {
  	it('Portal should display 12 lang flags', function() {
  	  browser.driver.get('http://auth.example.com:' + process.env.TESTWEBSERVERPORT + '/');
      browser.sleep(500);
      browser.driver.findElements(by.className('langicon')).then(function(elems) {
        expect(elems.length).toEqual(12);
      });
      browser.sleep(500);
      browser.driver.findElement(by.xpath("//img[@title='en']")).click();
      expect(browser.driver.findElement(by.css('[trmsg="9"]')).getText()).toEqual('Authentication required');
      expect(browser.driver.findElement(by.css('[trspan="createAccount"]')).getText()).toEqual('Create an account');
      expect(browser.driver.findElement(by.css('[trspan="resetPwd"]')).getText()).toEqual('Reset my password');
      browser.driver.findElement(by.xpath("//img[@title='it']")).click();
      expect(browser.driver.findElement(by.css('[trmsg="9"]')).getText()).toEqual('Autenticazione necessaria');
      expect(browser.driver.findElement(by.css('[trspan="createAccount"]')).getText()).toEqual('Crea un account');
      expect(browser.driver.findElement(by.css('[trspan="resetPwd"]')).getText()).toEqual('Reimpostare la password');
      browser.driver.findElement(by.xpath("//img[@title='fr']")).click();
      expect(browser.driver.findElement(by.css('[trspan="createAccount"]')).getText()).toEqual('Créer un compte');
      expect(browser.driver.findElement(by.css('[trspan="resetPwd"]')).getText()).toEqual('Réinitialiser mon mot de passe');
    });
    it('should create an account', function() {
      browser.driver.findElement(by.css('[trspan="createAccount"]')).click();
      expect(browser.driver.findElement(by.css('[trmsg="78"]')).getText()).toEqual('Merci de saisir vos informations');

      // A four inputs form + one captcha
      browser.driver.findElements(by.className('input-group')).then(function(elems) {
        expect(elems.length).toEqual(4);
      });
      browser.driver.findElements(by.className('img-thumbnail')).then(function(elems) {
        expect(elems.length).toEqual(1);
      });
      browser.driver.findElement(by.xpath("//input[@name='firstname']")).sendKeys('doctor');
      browser.driver.findElement(by.xpath("//input[@name='lastname']")).sendKeys('who');
      browser.driver.findElement(by.xpath("//input[@name='mail']")).sendKeys('dwho@badwolf.com');
      browser.driver.findElement(by.xpath("//input[@name='captcha']")).sendKeys('1234567');
      browser.driver.findElement(by.xpath("//button[@type='submit']")).click();
      expect(browser.driver.findElement(by.css('[trmsg="76"]')).getText()).toEqual('Erreur dans la saisie du captcha');
      browser.driver.findElement(by.css('[trspan="back2Portal"]')).click();
    });
    it('should reset my password', function() {
      browser.driver.findElement(by.css('[trspan="resetPwd"]')).click();
      expect(browser.driver.findElement(by.css('[trmsg="69"]')).getText()).toEqual('Merci de saisir votre adresse mail');
      expect(browser.driver.findElement(by.css('[trspan="sendPwd"]')).getText()).toEqual('Envoyez-moi un lien');

      // A one input form
      browser.driver.findElements(by.className('input-group')).then(function(elems) {
        expect(elems.length).toEqual(1);
      });
      browser.driver.findElement(by.xpath("//input[@name='mail']")).sendKeys('dwho@badwolf.com');
      browser.driver.findElement(by.xpath("//button[@type='submit']")).click();
      expect(browser.driver.findElement(by.css('[trmsg="72"]')).getText()).toEqual('Un mail de confirmation vous a été envoyé');
      expect(browser.driver.findElement(by.css('[trspan="mailSent2"]')).getText()).toEqual('Un message a été envoyé à votre adresse mail.');
      expect(browser.driver.findElement(by.css('[trspan="linkValidUntil"]')).getText()).toEqual("Ce message contient un lien pour réinitialiser votre mot de passe, ce lien est valide jusqu'au");
    });
    it('should authenticate with history', function() {
      expect(browser.driver.findElement(by.css('[trspan="back2Portal"]')).getText()).toEqual('Retourner au portail');
      browser.driver.findElement(by.css('[trspan="back2Portal"]')).click();

      // Failed login attempt
      browser.driver.findElement(by.xpath("//input[@name='user']")).sendKeys('dwho');
      browser.driver.findElement(by.xpath("//input[@name='password']")).sendKeys('ohwd');
      browser.driver.findElement(by.xpath("//input[@name='checkLogins']")).click();
      browser.driver.findElement(by.xpath("//button[@type='submit']")).click();
      expect(browser.driver.findElement(by.css('[trmsg="5"]')).getText()).toEqual('Identifiant ou mot de passe incorrect');
      //browser.driver.findElement(by.css('[trspan="goToPortal"]')).click();

      // Login attempt
      browser.driver.findElement(by.xpath("//input[@name='user']")).sendKeys('dwho');
      browser.driver.findElement(by.xpath("//input[@name='password']")).sendKeys('dwho');
      browser.driver.findElement(by.xpath("//input[@name='checkLogins']")).click();
      browser.driver.findElement(by.xpath("//button[@type='submit']")).click();

      // Change lang
      browser.driver.findElement(by.xpath("//img[@title='de']")).click();
      //expect(browser.driver.findElement(by.css('[trspan="info"]')).getText()).toEqual("Information");
    });
    it('should display history', function() {
      // Three entries
      browser.driver.findElements(by.xpath('//table/tbody/tr')).then(function(elems) {
        expect(elems.length).toEqual(3);
      });
      // Expect history with two logins and one failed login
      browser.driver.findElements(by.xpath("//div[@id='loginHistory']/div/div/h4")).then(function(elems) {
        expect(elems.length).toEqual(2);
        expect(elems[0].getText()).toEqual('Letzte Anmeldungen');
        expect(elems[1].getText()).toEqual('Letzte fehlgeschlagene Anmeldungen');
      });
      browser.driver.findElements(by.xpath('//table/thead/tr/th')).then(function(elems) {
      	expect(elems.length).toEqual(5);
      	expect(elems[0].getText()).toEqual('Datum');
      	expect(elems[2].getText()).toEqual('Datum');
      	expect(elems[4].getText()).toEqual('Fehlermeldung');
      });
      browser.driver.findElements(by.xpath('//table/tbody/tr/td')).then(function(elems) {
      	expect(elems.length).toEqual(7);
      	expect(elems[1].getText()).toEqual('127.0.0.1');
      	expect(elems[3].getText()).toEqual('127.0.0.1');
        expect(elems[5].getText()).toEqual('127.0.0.1');
        expect(elems[6].getText()).toEqual('Benutzername oder Passwort nicht korrekt');
      });
      expect(browser.driver.findElement(by.css('[trspan="PE5"]')).getText()).toEqual('Benutzername oder Passwort nicht korrekt');
      //expect(browser.driver.findElement(by.id('timer')).getText()).toMatch(/^Du wirst in \d{2} Sekunden umgeleitet$/);
      //browser.driver.findElement(by.xpath("//button[@type='reset']")).click();
      //expect(browser.driver.findElement(by.id('timer')).isDisplayed()).toEqual(false);
      //browser.driver.findElement(by.xpath("//button[@type='submit']")).click();
    });
  });
});
