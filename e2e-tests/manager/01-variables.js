'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('01 Lemonldap::NG Manager', function() {
  describe('Tree display -> Variables', function() {
    it('Main => should display 12 main nodes', function() {
      browser.get('/');
      expect(element.all(by.repeater('node in data track by node.id')).count()).toEqual(12);
    });
    it('Variables should display 3 sub nodes', function() {
      element(by.id('a-variables')).click();
      expect(element.all(by.repeater('node in node.nodes track by node.id')).count()).toEqual(3);
    });
  });
});