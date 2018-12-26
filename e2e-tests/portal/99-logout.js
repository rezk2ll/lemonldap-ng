'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('99 Lemonldap::NG auth mechanism', function() {

  it('should allow logout', function() {
    browser.driver.get('http://auth.example.com:' + process.env.TESTWEBSERVERPORT + '/?logout=1');
  });

});