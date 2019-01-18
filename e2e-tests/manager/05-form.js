'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('05 Lemonldap::NG Manager', function() {

  describe('Form control', function() {

    it('should display text form', function() {
      browser.get('/#/confs/1');
      element(by.id('a-generalParameters')).click();
      element(by.id('a-portalParams')).click();
      element(by.id('t-portal')).click();
      expect(element.all(by.id('textinput')).count()).toEqual(1);
    });
    it('should modify tree when input is modified', function() {
      element(by.id('a-virtualHosts')).click();
      element(by.id('a-virtualHosts/test1.example.com')).click();
      element(by.id('a-virtualHosts/test1.example.com/exportedHeaders')).click();
      var hdr = element(by.id('t-virtualHosts/test1.example.com/exportedHeaders/1'));
      hdr.click();
      var i = element.all(by.id('hashkeyinput'));
      expect(i.count()).toEqual(1);
      element(by.id('hashkeyinput')).clear().sendKeys('Hello');
      expect(hdr.getText()).toEqual('Hello');
    });
    it('should be able to add keys in hash', function() {
      browser.get('/#/confs/1');
      var els = element.all(by.css('[ng-click="getLanguage(lang)"]'));
      /* English version */
      els.each(function(el) {
        el.isDisplayed().then(function(isVisible) {
          if (isVisible) {
            el.getAttribute('src').then(function(lang) {
              lang = lang.replace(/^.*\/(\w+)\.png$/, '$1');
              if (lang == 'en') el.click();
            });
          }
        });
      });
      /* Variables */
      var id = 1;
      element(by.id('a-variables')).click();
      ['exportedVars', 'macros', 'groups'].forEach(function(type) {
        element(by.id('a-' + type)).click();
        element(by.id('t-' + type)).click();
        element.all(by.css('.glyphicon-plus-sign')).first().click();
        expect(element(by.id('t-' + type + '/n' + id)).getText()).toEqual('new');
        browser.sleep(3000);
        id++;
      });
      /* Virtual hosts */
      element(by.id('a-virtualHosts')).click();
      element(by.id('a-virtualHosts/test1.example.com')).click();
      element(by.id('a-virtualHosts/test1.example.com/locationRules')).click();
      element(by.id('a-virtualHosts/test1.example.com/exportedHeaders')).click();
      element(by.id('a-virtualHosts/test1.example.com/post')).click();
      for (var i = 0; i++; i < 3) {
        /* Rules */
        element(by.id('t-virtualHosts/test1.example.com/locationRules')).click();
        element.all(by.css('[ng-click="menuClick(button)"]')).each(function(el) {
          el.getText().then(function(text) {
            if (text == 'New rule') {
              el.click();
            }
          });
        });
        expect(element(by.id('t-virtualHosts/test1.example.com/locationRules/n' + id)).getText()).toEqual('New rule');
        id++;
        /* Headers */
        element(by.id('t-virtualHosts/test1.example.com/exportedHeaders')).click();
        element.all(by.css('[ng-click="menuClick(button)"]')).each(function(el) {
          el.getText().then(function(text) {
            if (text == 'New entry') {
              el.click();
            }
          });
        });
        expect(element(by.id('t-virtualHosts/test1.example.com/exportedHeaders/n' + id)).getText()).toEqual('new');
        id++;
        /* Form replay */
        element(by.id('t-virtualHosts/test1.example.com/post')).click();
        element.all(by.css('[ng-click="menuClick(button)"]')).each(function(el) {
          el.getText().then(function(text) {
            if (text == 'New form replay') {
              el.click();
            }
          });
        });
        expect(element(by.id('t-virtualHosts/test1.example.com/post/n' + id)).getText()).toMatch(/^https?:\/\//);
        id++;
      }
    });
  });
});
