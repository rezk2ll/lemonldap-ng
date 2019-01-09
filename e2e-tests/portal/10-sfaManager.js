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
      browser.driver.findElements(by.css('[role="button"]')).then(function(links) {
        expect(links.length).toEqual(4);
        expect(links[0].getText()).toEqual('Générer une nouvelle clef');
        expect(links[1].getText()).toEqual('Enregistrer');
        expect(links[2].getText()).toEqual('Gestionnaire 2ndFA');
        expect(links[3].getText()).toEqual('Aller au portail');
        links[3].click();
        browser.driver.findElement(by.xpath("//button[@type='button']")).click();
        browser.sleep(1000);
        expect(browser.driver.findElement(by.css('[trspan="yourApps"]')).getText()).toEqual('Vos applications');
      });
    });
  });
});
