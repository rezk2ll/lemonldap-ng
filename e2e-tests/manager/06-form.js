'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('06 Lemonldap::NG Manager', function() {

  describe('Form control, part 2', function() {

    it('should display portal skin choice', function() {
      browser.get('/#!/confs/lastest');
      element(by.id('a-generalParameters')).click();
      element(by.id('a-portalParams')).click();
      element(by.id('a-portalCustomization')).click();
      element(by.id('t-portalSkin')).click();
      element(by.css('[ng-click="showModal(\'portalSkinChoice.html\')"]')).click();
            browser.sleep(1000);

      var skinChoice = element.all(by.repeater('b in currentNode.select'));
      expect(skinChoice.count()).toEqual(1);
      element(by.css('[trspan="cancel"]')).click();
            browser.sleep(1000);

    });
  });
});
