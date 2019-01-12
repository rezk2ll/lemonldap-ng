'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('99 Lemonldap::NG auth mechanism', function() {
  it('should allow logout', function() {
	browser.driver.findElements(by.xpath('//li/a/span/img')).then(function(links) {
	  expect(links.length).toEqual(4);
	  links[3].click();
	  browser.sleep(1000);
	  expect(browser.driver.findElement(by.css('[trspan="areYouSure"]')).getText()).toEqual('Êtes-vous sûr ?');
	  browser.driver.findElement(by.css('[trspan="imSure"]')).click();
	  expect(browser.driver.findElement(by.css('[trmsg="47"]')).getText()).toEqual('Vous avez été déconnecté');
	  browser.sleep(500);
	  browser.driver.findElement(by.css('[trspan="goToPortal"]')).click();
	  expect(browser.driver.findElement(by.css('[trmsg="9"]')).getText()).toEqual('Veuillez vous authentifier');
	});
  });
});