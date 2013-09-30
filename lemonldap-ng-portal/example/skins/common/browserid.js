/* Watch login and logout events */

navigator.id.watch({
  loggedInUser: null,
  onlogin: function(assertion) {
	  // POST assertion
	  $('form.login').append('<input type="hidden" name="browserIdAssertion" value="'+assertion+'" />').submit();
  },
  onlogout: function() {
	  // Do nothing
  }
});
