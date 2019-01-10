'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */
describe('10 Lemonldap::NG', function() {
  describe('Second Factor Manager', function() {
    it('Should have two links in dropDown menu', function() {
      // // Login attempt
      // browser.driver.get('http://auth.example.com:' + process.env.TESTWEBSERVERPORT + '/');
      // browser.driver.findElement(by.xpath("//input[@name='user']")).sendKeys('dwho');
      // browser.driver.findElement(by.xpath("//input[@name='password']")).sendKeys('dwho');
      // browser.driver.findElement(by.xpath("//button[@type='submit']")).click();

      // Toggle Menu bar
      // Need to be clicked twice ???
      browser.driver.findElement(by.xpath("//button[@type='button']")).click();
      browser.sleep(1000);
      browser.driver.findElement(by.css('[data-toggle="dropdown"]')).click();
      browser.sleep(1000);
      browser.driver.findElement(by.xpath("//button[@type='button']")).click();
      browser.sleep(1000);
      browser.driver.findElement(by.css('[data-toggle="dropdown"]')).click();
      //

      browser.driver.findElements(by.className('dropdown-item')).then(function(links) {
        expect(links.length).toEqual(2);
        links[0].click();
        browser.sleep(1000);
      });
    });
    it('Should submit TOTP form', function() {
      browser.driver.findElements(by.css('[role="button"]')).then(function(links) {
        expect(links.length).toEqual(4);
        expect(links[0].getText()).toEqual('Générer une nouvelle clef');
        expect(links[1].getText()).toEqual('Enregistrer');
        expect(links[2].getText()).toEqual('Gestionnaire 2ndFA');
        expect(links[3].getText()).toEqual('Aller au portail');
        expect(browser.driver.findElement(by.css('[trspan="yourNewTotpKey"]')).getText()).toEqual('Votre nouvelle clef TOTP. Testez-la et entrez le code');
        
        // Submit an empty form
        browser.driver.findElement(by.id('verify')).click();
        expect(browser.driver.findElement(by.css('[trspan="yourNewTotpKey"]')).getText()).toEqual('Remplissez le formulaire');
        browser.sleep(500);

        // Submit a bad TOTP code
        browser.driver.findElement(by.xpath("//input[@name='TOTPName']")).sendKeys('_TEST_');
        browser.driver.findElement(by.xpath("//input[@name='code']")).sendKeys('1234567');
        browser.driver.findElement(by.id('verify')).click();
        expect(browser.driver.findElement(by.css('[trspan="yourNewTotpKey"]')).getText()).toEqual('Mauvais code');
        browser.sleep(500);

        // Generate a new TOTP code
        browser.driver.findElement(by.id('changekey')).click();
        expect(browser.driver.findElement(by.css('[trspan="yourNewTotpKey"]')).getText()).toEqual('Votre nouvelle clef TOTP. Testez-la et entrez le code');
        browser.sleep(500);

        // Back to Portal
        links[3].click();
        browser.driver.findElement(by.xpath("//button[@type='button']")).click();
        browser.sleep(1000);
        expect(browser.driver.findElement(by.css('[trspan="yourApps"]')).getText()).toEqual('Vos applications');
      });
    });
  });
});
