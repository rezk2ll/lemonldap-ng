'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('02 Lemonldap::NG Manger', function() {
  describe('Menu', function() {
    it('should translate in english and french', function() {
      var tests = {
        "en": "General Parameters",
        "fr": "Paramètres généraux"
      };

      // // Login attempt
      // browser.driver.get('http://auth.example.com:' + process.env.TESTWEBSERVERPORT + '/');
      // browser.driver.findElement(by.xpath("//input[@name='user']")).sendKeys('dwho');
      // browser.driver.findElement(by.xpath("//input[@name='password']")).sendKeys('dwho');
      // browser.driver.findElement(by.xpath("//button[@type='submit']")).click();
      // browser.get('/');

      var els = element.all(by.css('[ng-click="getLanguage(lang)"]'));
      expect(els.count()).toEqual(14);
      els.each(function(el) {
        el.isDisplayed().then(function(isVisible) {
          if (isVisible) {
            el.getAttribute('src').then(function(lang) {
              lang = lang.replace(/^.*\/(\w+)\.png$/, '$1');
              el.click();
              var gp = element(by.id('t-generalParameters'));
              expect(gp.getText()).toEqual(tests[lang]);
            });
          }
        });
      });
    });

    it('Should display Menu -> Links', function() {
      element(by.id("mainlangmenu")).click();
      browser.sleep(500);
      var links = element.all(by.repeater('menulink in menulinks'));
      expect(links.count()).toEqual(4);
      expect(links.get(0).getText()).toEqual('Retour au portail');
      expect(links.get(1).getText()).toEqual('Déconnexion');
    });
  });
});
