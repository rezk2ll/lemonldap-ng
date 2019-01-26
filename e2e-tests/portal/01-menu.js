'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */
describe('0 Lemonldap::NG', function() {
  describe('Portal should display Menu', function() {
    it('Should have four buttons', function() {
      browser.driver.findElement(by.xpath("//img[@title='fr']")).click();
      browser.driver.findElement(by.xpath("//button[@type='button']")).click();

      // Change password form
      browser.driver.findElements(by.xpath('//li/a/span/img')).then(function(links) {
        expect(links.length).toEqual(4);
        links[1].click();
        browser.sleep(1000);
        browser.driver.findElement(by.xpath("//input[@name='oldpassword']")).sendKeys('dwho');
        browser.driver.findElement(by.xpath("//input[@name='newpassword']")).sendKeys('newpwd');
        browser.driver.findElement(by.xpath("//input[@name='confirmpassword']")).sendKeys('newpwd');
        browser.driver.findElement(by.xpath("//button[@type='submit']")).click();
        expect(browser.driver.findElement(by.css('[trmsg="35"]')).getText()).toEqual('Le mot de passe a été changé');
        browser.driver.findElement(by.css('[trspan="goToPortal"]')).click();
        browser.driver.findElement(by.xpath("//button[@type='button']")).click();
        browser.sleep(1000);
      });

      // History page
      browser.driver.findElements(by.xpath('//li/a/span/img')).then(function(links) {
        expect(links.length).toEqual(4);
        links[2].click();
        browser.sleep(1000);
        // Expect history with one login and one failed login
        browser.driver.findElements(by.xpath('//main/div/div/div/div/h4')).then(function(elems) {
          expect(elems.length).toEqual(7);
          expect(elems[4].getText()).toEqual('Dernières connexions');
          expect(elems[5].getText()).toEqual('Dernières connexions refusées');
        });
        browser.driver.findElements(by.xpath('//table/thead/tr/th')).then(function(elems) {
          expect(elems.length).toEqual(5);
          expect(elems[0].getText()).toEqual('Date');
          expect(elems[1].getText()).toEqual('Adresse IP');
          expect(elems[2].getText()).toEqual('Date');
          expect(elems[3].getText()).toEqual('Adresse IP');
          expect(elems[4].getText()).toEqual("Message d'erreur");
        });
        browser.driver.findElements(by.xpath('//table/tbody/tr/td')).then(function(elems) {
          expect(elems.length).toEqual(7);
          expect(elems[1].getText()).toEqual('127.0.0.1');
          expect(elems[3].getText()).toEqual('127.0.0.1');
          expect(elems[5].getText()).toEqual('127.0.0.1');
          expect(elems[6].getText()).toEqual('Mot de passe ou identifiant incorrect');
        });
        browser.driver.findElement(by.xpath("//button[@type='button']")).click();
        browser.sleep(1000);
      });

      // Logout page
      browser.driver.findElements(by.xpath('//li/a/span/img')).then(function(links) {
        expect(links.length).toEqual(4);
        links[3].click();
        browser.sleep(1000);
        expect(browser.driver.findElement(by.css('[trspan="areYouSure"]')).getText()).toEqual('Êtes-vous sûr ?');
        expect(browser.driver.findElement(by.css('[trspan="imSure"]')).getText()).toEqual('Je suis sûr');
        browser.driver.findElement(by.xpath("//button[@type='button']")).click();
        browser.sleep(1000);
      });

      // Applications page
      browser.driver.findElements(by.xpath('//li/a/span/img')).then(function(links) {
        expect(links.length).toEqual(4);
        links[0].click();
        browser.sleep(1000);
      });
    });
    it('Should have seven links', function() {
      browser.driver.findElements(by.xpath('//main/div/div/div/div/h4')).then(function(elems) {
        expect(elems.length).toEqual(7);
        expect(elems[0].getText()).toEqual('Sample applications');
        expect(elems[1].getText()).toEqual('Administration');
        expect(elems[2].getText()).toEqual('Documentation');
      });
      browser.driver.findElements(by.xpath('//main/div/div/div/div/div/div/div/a/div/div/div/h5')).then(function(elems) {
        expect(elems.length).toEqual(8);
        expect(elems[0].getText()).toEqual('Application Test 1');
        expect(elems[1].getText()).toEqual('Application Test 2');
        expect(elems[2].getText()).toEqual('WebSSO Manager');
        expect(elems[3].getText()).toEqual('Notifications explorer');
        expect(elems[4].getText()).toEqual('Sessions explorer');
        expect(elems[5].getText()).toEqual('2FA Sessions explorer');
        expect(elems[6].getText()).toEqual('Local documentation');
        expect(elems[7].getText()).toEqual('Official Website');
      });
      browser.driver.findElement(by.css('[alt="Application Test 1"]')).click();
      browser.sleep(1000);
      expect(browser.driver.findElement(by.id('v-Host')).getText()).toEqual('test1.example.com:' + process.env.TESTWEBSERVERPORT );
      browser.driver.get('http://auth.example.com:' + process.env.TESTWEBSERVERPORT + '/');

      browser.driver.findElement(by.css('[alt="Application Test 2"]')).click();
      browser.sleep(1000);
      expect(browser.driver.findElement(by.id('v-Host')).getText()).toEqual('test2.example.com:' + process.env.TESTWEBSERVERPORT );
      browser.driver.get('http://auth.example.com:' + process.env.TESTWEBSERVERPORT + '/');

      browser.driver.findElement(by.css('[alt="WebSSO Manager"]')).click();
      expect(element.all(by.xpath("//a[@href='manager.html']")).first().getCssValue("color")).toEqual('rgba(157, 157, 157, 1)');
      browser.sleep(1000);
      expect(browser.driver.findElement(by.css('[trspan="currentConfiguration"]')).getText()).toEqual('Configuration actuelle');
      browser.driver.get('http://auth.example.com:' + process.env.TESTWEBSERVERPORT + '/');

      browser.driver.findElement(by.css('[alt="Sessions explorer"]')).click();
      expect(element.all(by.xpath("//a[@href='sessions.html']")).first().getCssValue("color")).toEqual('rgba(157, 157, 157, 1)');
      browser.sleep(1000);
      expect(browser.driver.findElement(by.css('[trspan="session_s"]')).getText()).toEqual('session(s)');
      browser.driver.get('http://auth.example.com:' + process.env.TESTWEBSERVERPORT + '/');

      browser.driver.findElement(by.css('[alt="Notifications explorer"]')).click();
      expect(element(by.xpath("//a[@href='notifications.html']")).getCssValue("color")).toEqual('rgba(157, 157, 157, 1)');
      browser.sleep(1000);
      expect(browser.driver.findElement(by.css('[trspan="noDatas"]')).getText()).toEqual('Aucune donnée à afficher');
      browser.driver.get('http://auth.example.com:' + process.env.TESTWEBSERVERPORT + '/');

      browser.driver.findElement(by.css('[alt="2FA Sessions explorer"]')).click();
      expect(element.all(by.xpath("//a[@href='2ndfa.html']")).first().getCssValue("color")).toEqual('rgba(157, 157, 157, 1)');
      browser.sleep(1000);
      expect(browser.driver.findElement(by.id('a-persistent')).getText()).toEqual('Explorateur sessions 2ndFA   ');
      browser.driver.get('http://auth.example.com:' + process.env.TESTWEBSERVERPORT + '/');

      browser.driver.findElement(by.css('[alt="Local documentation"]')).click();
      browser.sleep(1000);
      expect(browser.driver.findElement(by.xpath("//body/div/h1")).getText()).toEqual('LemonLDAP::NG offline documentation');
      browser.driver.findElement(by.tagName('a')).click();
      expect(browser.driver.findElement(by.tagName('h1')).getText()).toEqual('Documentation for LemonLDAP::NG 2.0');
      browser.driver.get('http://auth.example.com:' + process.env.TESTWEBSERVERPORT + '/');
    });
  });
});
