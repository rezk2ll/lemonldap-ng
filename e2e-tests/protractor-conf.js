exports.config = {
  allScriptsTimeout: 300000,

  // Specific test
   specs: process.env.E2E_TESTS,
  // All tests
  //specs: ['portal/*.js', 'handler/*.js', 'manager/*.js' ],

    capabilities: {
    //'browserName': 'firefox'
    'browserName': 'chrome'
  },

  chromeOnly: true,

  baseUrl: 'http://manager.example.com:' + process.env.TESTWEBSERVERPORT + '/',

  framework: 'jasmine',

  jasmineNodeOpts: {
    defaultTimeoutInterval: 60000
  }
};