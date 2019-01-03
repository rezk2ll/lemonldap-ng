exports.config = {
  allScriptsTimeout: 11000,

  specs: process.env.E2E_TESTS,
  //specs: ['handler/*.js', 'portal/*.js', 'manager/*.js' ],

    capabilities: {
    'browserName': 'chrome'
  },

  chromeOnly: true,

  baseUrl: 'http://manager.example.com:' + process.env.TESTWEBSERVERPORT + '/',

  framework: 'jasmine',

  jasmineNodeOpts: {
    defaultTimeoutInterval: 30000
  }
};