'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('Auth mechanism', function() {

  it('should allow logout', function() {
    browser.driver.get('http://auth.example.com/?logout=1');
  });

});