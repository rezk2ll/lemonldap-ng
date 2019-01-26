'use strict';

describe('50 Lemonldap::NG Manager', function() {
  it('should display 2FA Sessions explorer', function() {
    //// Login attempt
    // browser.driver.get('http://auth.example.com:' + process.env.TESTWEBSERVERPORT + '/');
    // browser.driver.findElement(by.xpath("//input[@name='user']")).sendKeys('dwho');
    // browser.driver.findElement(by.xpath("//input[@name='password']")).sendKeys('dwho');
    // browser.driver.findElement(by.xpath("//button[@type='submit']")).click();

    browser.get('/');
    var links = element.all(by.repeater('l in links'));
    expect(links.count()).toEqual(4);
    expect(element.all(by.xpath("//a[@href='2ndfa.html']")).first().getCssValue("color")).toEqual('rgba(157, 157, 157, 1)');
    element.all(by.xpath("//a[@href='2ndfa.html']")).first().click();
  });
});

describe('50 Lemonldap::NG 2FA Sessions explorer', function() {
  it('Should display at least my persistent session', function() {
    browser.get('/2ndfa.html');
    expect(element(by.id('a-persistent')).getText()).toEqual('Explorateur sessions 2ndFA   ');
    expect(element.all(by.css("input[type=checkbox]")).count()).toEqual(3);
    expect(element.all(by.css("input[type=text]")).count()).toEqual(1);
    expect(element.all(by.repeater('node in data track by node.id')).count()).toEqual(1);
    element(by.id("a-d")).click();
    expect(element.all(by.repeater('node in data track by node.id')).count()).toEqual(1);
    element(by.id("s-5efe8af397fc3577e05b483aca964f1b")).click();
    browser.sleep(500);
  });

  it('Should display Dwho session', function() {
    expect(element(by.tagName('h1')).getText()).toEqual('Contenu de la session 5efe8af397fc3577e05b483aca964f1b');
    var titles = element.all(by.tagName('h2'));
    expect(titles.get(0).getText()).toEqual('Dates');
    expect(titles.get(1).getText()).toEqual("Seconds Facteurs d'Authentification");
    var nodes = element.all(by.className('glyphicon-minus-sign'));
    expect(nodes.count()).toEqual(3);
    nodes.get(0).click();
    expect(element.all(by.className('glyphicon-minus-sign')).count()).toEqual(2);
  });

  it('Should filter persistent sessions', function() {
    element(by.css('input[ng-model="U2FCheck"]')).click();
    expect(element.all(by.repeater('node in data track by node.id')).count()).toEqual(1);
    element(by.css('input[ng-model="UBKCheck"]')).click();
    expect(element.all(by.repeater('node in data track by node.id')).count()).toEqual(1);
    element(by.css('input[ng-model="TOTPCheck"]')).click();
    expect(element.all(by.repeater('node in data track by node.id')).count()).toEqual(0);
    expect(element.all(by.className('label-warning')).get(0).getText()).toEqual('Aucune donnée à afficher');
    element(by.css('input[ng-model="TOTPCheck"]')).click();
    expect(element.all(by.repeater('node in data track by node.id')).count()).toEqual(1);
    element(by.css('input[ng-model="searchString"]')).clear().sendKeys('dw');
    expect(element.all(by.repeater('node in data track by node.id')).count()).toEqual(1);
    expect(element(by.id("a-dw")));
    browser.sleep(500);
    element(by.css('input[ng-model="searchString"]')).clear().sendKeys('dwho');
    expect(element(by.id("a-dwho")));
    browser.sleep(500);
    element(by.css('input[ng-model="searchString"]')).clear().sendKeys('a');
    expect(element.all(by.repeater('node in data track by node.id')).count()).toEqual(0);
    expect(element.all(by.className('label-warning')).get(0).getText()).toEqual('Aucune donnée à afficher');
    browser.sleep(500);
    element(by.className('glyphicon-search')).click();
    expect(element.all(by.repeater('node in data track by node.id')).count()).toEqual(1);
    browser.sleep(500);
  });
});
