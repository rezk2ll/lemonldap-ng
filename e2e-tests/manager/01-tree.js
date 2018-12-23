'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('01 Lemonldap::NG Manager', function() {

  describe('Tree display', function() {
    it('Main => should display 12 main nodes', function() {
      browser.get('/');
      var mainNodes = element.all(by.repeater('node in data track by node.id'));
      expect(mainNodes.count()).toEqual(12);
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
    it('General Parameters > Portal > Menu > Cat. and Apps. => Append 10 sub nodes', function() {
      element(by.id('a-applicationList')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(31);
    });
    it('General Parameters > Portal > Customization => Append 8 sub nodes', function() {
      element(by.id('a-portalCustomization')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(39);
    });
    it('General Parameters > Portal > Customization > Buttons => Append 4 sub nodes', function() {
      element(by.id('a-portalButtons')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(43);
    });
    it('General Parameters > Portal > Customization > Password Management => Append 3 sub nodes', function() {
      element(by.id('a-passwordManagement')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(46);
    });
    it('General Parameters > Portal > Customization > Other => Append 6 sub nodes', function() {
      element(by.id('a-portalOther')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(52);
    });

    // Authentication Parameters
    it('Main => should display 12 main nodes', function() {
      browser.get('/');
      var mainNodes = element.all(by.repeater('node in data track by node.id'));
      expect(mainNodes.count()).toEqual(12);
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
      var def = element.all(by.id('hashkeyinput'));
      expect(def.count()).toEqual(1);
    });

    // Issuer Modules
    it('Main => should display 12 main nodes', function() {
      browser.get('/');
      var mainNodes = element.all(by.repeater('node in data track by node.id'));
      expect(mainNodes.count()).toEqual(12);
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
      var mainNodes = element.all(by.repeater('node in data track by node.id'));
      expect(mainNodes.count()).toEqual(12);
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
      var mainNodes = element.all(by.repeater('node in data track by node.id'));
      expect(mainNodes.count()).toEqual(12);
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
      var mainNodes = element.all(by.repeater('node in data track by node.id'));
      expect(mainNodes.count()).toEqual(12);
    });
    it('General Parameters should display 10 sub nodes', function() {
      element(by.id('a-generalParameters')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(10);
    });
    it('General Parameters > Sessions => Append 8 sub nodes', function() {
      element(by.id('a-sessionParams')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(18);
    });











    // it('-Variables should display 3 sub nodes', function() {
    //   var gpv = element(by.id('a-variables'));
    //   gpv.click();
    //   var gpvNodes = element.all(by.repeater('node in node.nodes track by node.id'));
    //   expect(gpvNodes.count()).toEqual(17);
    // });

    // it('-Virtual Hosts should display 3 sub nodes', function() {
    //   var gvh = element(by.id('a-variables'));
    //   gvh.click();
    //   var gvhNodes = element.all(by.repeater('node in node.nodes track by node.id'));
    //   expect(gvhNodes.count()).toEqual(20);
    // });


    it('should find a rule', function() {
      browser.get('/#/confs/1');
      var vhs = element(by.id('a-virtualHosts'));
      vhs.click();
      var vh = element(by.id('a-virtualHosts/manager.example.com'));
      vh.click();
      var r = element(by.id('a-virtualHosts/manager.example.com/locationRules'));
      r.click();
      var def = element.all(by.id("t-virtualHosts/manager.example.com/locationRules/1"));
      expect(def.count()).toEqual(1);
    });


  });
});