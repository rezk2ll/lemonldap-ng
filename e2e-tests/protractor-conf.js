exports.config = {
  allScriptsTimeout: 11000,

  // Specific test
  specs: process.env.E2E_TESTS,
  // All tests
  //specs: ['handler/*.js', 'portal/*.js', 'manager/*.js' ],

    capabilities: {
    //'browserName': 'firefox'
    'browserName': 'chrome'
  },

  chromeOnly: true,

  baseUrl: 'http://manager.example.com:' + process.env.TESTWEBSERVERPORT + '/',

  framework: 'jasmine',

  jasmineNodeOpts: {
    defaultTimeoutInterval: 30000
  }
};