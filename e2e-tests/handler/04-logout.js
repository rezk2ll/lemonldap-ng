'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('Lemonldap::NG auth mechanism', function() {

  it('should allow logout', function() {
    browser.driver.get('http://test1.example.com:' + process.env.TESTWEBSERVERPORT + '/logout');
    expect(browser.getCurrentUrl()).toMatch(new RegExp('^http://auth.example.com(:' + process.env.TESTWEBSERVERPORT + ')?'));
  });

});