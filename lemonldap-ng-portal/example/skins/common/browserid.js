/* Watch login and logout events */

navigator.id.watch({
  loggedInUser: null,
  onlogin: function(assertion) {
	  // Return on page with BrowserID assertion
	  var portalUrl = window.location.href;
	  var portalSearch = window.location.search;
	  if ( portalSearch ) {
		  portalUrl += '&browserIdAssertion='+assertion
	  } else {
		  portalUrl += '?browserIdAssertion='+assertion
	  }
	  window.location.assign(portalUrl);
  },
  onlogout: function() {
	  // Do nothing
  }
});
