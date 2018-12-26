exports.config = {
  allScriptsTimeout: 11000,

  specs: ['handler/*.js', 'portal/*.js', 'manager/*.js' ],
  //specs: ['manager/*.js'],
  

  //specs: ['manager/00-auth.js', 'manager/01-tree.js'],
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