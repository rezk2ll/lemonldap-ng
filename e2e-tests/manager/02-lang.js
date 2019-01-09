'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('02 Lemonldap::NG Manager', function() {

  describe('translation', function() {

    it('should translate in english and french', function() {
      var tests = {
        "en": "General Parameters",
        "fr": "Paramètres généraux"
      };
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
  });
});
