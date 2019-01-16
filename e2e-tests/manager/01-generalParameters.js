'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('01 Lemonldap::NG Manager', function() {
  describe('Tree display -> General Parameters', function() {
    it('Main => should display 12 main nodes', function() {
      browser.get('/');
      expect(element.all(by.repeater('node in data track by node.id')).count()).toEqual(12);
    });
    it('General Parameters should display 10 sub nodes', function() {
      element(by.id('a-generalParameters')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(10);
    });

    // Portal
    it('General Parameters > Portal -> Append 4 sub nodes', function() {
      element(by.id('a-portalParams')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(14);
    });
    it('General Parameters > Portal > URL => Match', function() {
      element(by.id('t-portal')).click();
      expect(element(by.id('textinput')).getAttribute('value')).toEqual('http://auth.example.com:' + process.env.TESTWEBSERVERPORT + '/');
    });
    it('General Parameters > Portal > Menu => Append 2 sub nodes', function() {
      element(by.id('a-portalMenu')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(16);
    });
    it('General Parameters > Portal > Menu > Module Activation => Append 5 sub nodes', function() {
      element(by.id('a-portalModules')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(21);
    });
    it('General Parameters > Portal > Menu > Cat. and Apps. => Append 11 sub nodes', function() {
      element(by.id('a-applicationList')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(32);
    });
    it('General Parameters > Portal > Customization => Append 8 sub nodes', function() {
      element(by.id('a-portalCustomization')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(40);
    });
    it('General Parameters > Portal > Customization > Buttons => Append 4 sub nodes', function() {
      element(by.id('a-portalButtons')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(44);
    });
    it('General Parameters > Portal > Customization > Password Management => Append 3 sub nodes', function() {
      element(by.id('a-passwordManagement')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(47);
    });
    it('General Parameters > Portal > Customization > Other => Append 6 sub nodes', function() {
      element(by.id('a-portalOther')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(53);
    });
    // Authentication Parameters
    it('Main => should display 12 main nodes', function() {
      browser.get('/');
      expect(element.all(by.repeater('node in data track by node.id')).count()).toEqual(12);
    });
    it('General Parameters should display 10 sub nodes', function() {
      element(by.id('a-generalParameters')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(10);
    });
    it('General Parameters > Authn. parameters => Append 4 sub nodes', function() {
      element(by.id('a-authParams')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(14);
    });
    it('General Parameters > Authn. parameters > Authn. modules => Should have 26 modules availabled with "Demonstration" selected', function() {
      element(by.id('t-authentication')).click();
      expect(element(by.css('option[selected="selected"]')).getAttribute('Value')).toEqual('Demo');
      expect(element.all(by.repeater('item in currentNode.select')).count()).toEqual(26);
    });
    it('General Parameters > Authn. parameters > Users modules => Should have 7 modules availabled with "Same" selected', function() {
      element(by.id('t-userDB')).click();
      browser.sleep(1000);
      expect(element(by.css('option[selected="selected"]')).getAttribute('Value')).toEqual('Same');
      expect(element.all(by.repeater('item in currentNode.select')).count()).toEqual(7);
    });
    it('General Parameters > Authn. parameters > Password modules => Should have 8 modules availabled with "Demo" selected', function() {
      element(by.id('t-passwordDB')).click();
      expect(element(by.css('option[selected="selected"]')).getAttribute('Value')).toEqual('Demo');
      expect(element.all(by.repeater('item in currentNode.select')).count()).toEqual(8);
    });
    it('General Parameters > Authn. parameters > Register modules => Should have 5 modules availabled with "Demo" selected', function() {
      element(by.id('t-registerDB')).click();
      expect(element(by.css('option[selected="selected"]')).getAttribute('Value')).toEqual('Demo');
      expect(element.all(by.repeater('item in currentNode.select')).count()).toEqual(5);
    });
    it('should have a hash form if a key is clicked', function() {
      element(by.id('a-demoParams')).click();
      element(by.id('a-demoExportedVars')).click();
      element(by.id('t-demoExportedVars/cn')).click();
      expect(element.all(by.id('hashkeyinput')).count()).toEqual(1);
    });
    // Issuer Modules
    it('Main => should display 12 main nodes', function() {
      browser.get('/');
      //var mainNodes = element.all(by.repeater('node in data track by node.id'));
      //expect(mainNodes.count()).toEqual(12);
      expect(element.all(by.repeater('node in data track by node.id')).count()).toEqual(12);
    });
    it('General Parameters should display 10 sub nodes', function() {
      element(by.id('a-generalParameters')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(10);
    });
    it('General Parameters > Issuer modules => Append 5 sub nodes', function() {
      element(by.id('a-issuerParams')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(15);
    });
    it('General Parameters > Issuer modules > SAML => Append 3 sub nodes', function() {
      element(by.id('a-issuerDBSAML')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(18);
    });
    it('General Parameters > Issuer modules > CAS => Append 3 sub nodes', function() {
      element(by.id('a-issuerDBCAS')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(21);
    });
    it('General Parameters > Issuer modules > OpenID => Append 4 sub nodes', function() {
      element(by.id('a-issuerDBOpenID')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(25);
    });
    it('General Parameters > Issuer modules > OpenIDConnect => Append 3 sub nodes', function() {
      element(by.id('a-issuerDBOpenIDConnect')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(28);
    });
    it('General Parameters > Issuer modules > GET => Append 4 sub nodes', function() {
      element(by.id('a-issuerDBGet')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(32);
    });
    // Logs
    it('Main => should display 12 main nodes', function() {
      browser.get('/');
      expect(element.all(by.repeater('node in data track by node.id')).count()).toEqual(12);
    });
    it('General Parameters should display 10 sub nodes', function() {
      element(by.id('a-generalParameters')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(10);
    });
    it('General Parameters > Logs => Append 3 sub nodes', function() {
      element(by.id('a-logParams')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(13);
    });
    // Cookies
    it('Main => should display 12 main nodes', function() {
      browser.get('/');
      expect(element.all(by.repeater('node in data track by node.id')).count()).toEqual(12);
    });
    it('General Parameters should display 10 sub nodes', function() {
      element(by.id('a-generalParameters')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(10);
    });
    it('General Parameters > Cookies => Append 6 sub nodes', function() {
      element(by.id('a-cookieParams')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(16);
    });
    // Sessions
    it('Main => should display 12 main nodes', function() {
      browser.get('/');
      expect(element.all(by.repeater('node in data track by node.id')).count()).toEqual(12);
    });
    it('General Parameters should display 10 sub nodes', function() {
      element(by.id('a-generalParameters')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(10);
    });
    it('General Parameters > Sessions => Append 8 sub nodes', function() {
      element(by.id('a-sessionParams')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(18);
    });
    it('General Parameters > Sessions > Opening conditions => New grant rule button + 2 rules', function() {
      element(by.id('t-grantSessionRules')).click();
      element(by.css('[ng-click="menuClick(button)"]')).click();
      element(by.css('[ng-click="menuClick(button)"]')).click();
      expect(element.all(by.repeater('s in currentNode.nodes')).count()).toEqual(2);
      expect(element.all(by.xpath('//tbody/tr')).count()).toEqual(2);
      expect(element.all(by.xpath('//tbody/tr/td/input')).count()).toEqual(6);
    });
    it('General Parameters > Sessions > Session storage => Append 4 sub nodes', function() {
      element(by.id('a-sessionStorage')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(24);
    });
    it('General Parameters > Sessions > Multiple sessions => Append 6 sub nodes', function() {
      element(by.id('a-multipleSessions')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(30);
    });
    it('General Parameters > Sessions > Persistent sessions => Append 2 sub nodes', function() {
      element(by.id('a-persistentSessions')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(32);
    });
    it('General Parameters > Sessions > Persistent storage options => Append 3 sub nodes', function() {
      element(by.id('t-persistentStorageOptions')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(35);
      expect(element.all(by.xpath('//tbody/tr')).count()).toEqual(3);
      expect(element.all(by.xpath('//tbody/tr/td/input')).count()).toEqual(6);
    });
    // Configuration reload
    it('Main => should display 12 main nodes', function() {
      browser.get('/');
      expect(element.all(by.repeater('node in data track by node.id')).count()).toEqual(12);
    });
    it('General Parameters should display 10 sub nodes', function() {
      element(by.id('a-generalParameters')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(10);
    });
    it('General Parameters > Configuration reload => Append 2 sub nodes', function() {
      element(by.id('a-reloadParams')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(12);
    });
    it('General Parameters > Configuration relaod > Reload URLs => "New entry" button + 2 new URLS', function() {
      element(by.id('t-reloadUrls')).click();
      element(by.css('[ng-click="menuClick(button)"]')).click();
      element(by.css('[ng-click="menuClick(button)"]')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(14);
      expect(element.all(by.xpath('//tbody/tr')).count()).toEqual(2);
      expect(element.all(by.xpath('//tbody/tr/td/input')).count()).toEqual(4);
    });
  });
});