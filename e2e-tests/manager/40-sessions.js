'use strict';

describe('40 Lemonldap::NG Manager', function() {

  it('should display other modules', function() {
    browser.get('/');
    var links = element.all(by.repeater('l in links'));
    expect(links.count()).toEqual(4);
    element.all(by.xpath("//a[@href='sessions.html']")).first().click();
  });

});

describe('40 Lemonldap::NG Sessions explorer', function() {

  var session, ip;

  it('Should display at least my session', function() {
    browser.get('/sessions.html');
    expect(element.all(by.xpath("//a[@href='sessions.html']")).first().getCssValue("color")).toEqual('rgba(157, 157, 157, 1)');
    var t = element.all(by.repeater('node in data track by node.id'));
    expect(t.count()).toBeGreaterThan(0);
    element(by.id("a-d")).click();
    t = element.all(by.repeater('node in node.nodes track by node.id'));
    expect(t.count()).toBeGreaterThan(0);
    element(by.id("a-dwho")).click();
    browser.manage().getCookie('lemonldap').then(function(cookie) {
      expect(cookie.value).toBeDefined();
      expect(cookie.value).not.toEqual('');
      session = cookie.value;
      element(by.id("s-" + session)).click();
      var t = element.all(by.repeater('node in currentSession.nodes'));
      expect(t.count()).toBeGreaterThan(0);
      ip = element(by.id("v-ipAddr"));
      expect(ip.getText()).toMatch(/^\d+\.\d+\.\d+\.\d+$/);
    });
  });

  it('Should display my IP address', function() {
    element(by.id('navsso')).click();
    element(by.id('a-ip')).click();
    var t = element.all(by.repeater('node in data track by node.id'));
    expect(t.count()).toBeGreaterThan(0);
    element(by.id("a-127")).click();
    element(by.id("a-127.0")).click();
    element(by.id("a-127.0.0")).click();
    element(by.id("a-127.0.0.1")).click();
    element(by.id("a-dwho")).click();
    element(by.id("s-" + session)).click();
    var t = element.all(by.repeater('node in currentSession.nodes'));
    expect(t.count()).toBeGreaterThan(0);
  });

});
