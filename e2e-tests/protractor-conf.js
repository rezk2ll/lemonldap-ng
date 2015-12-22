exports.config = {
  allScriptsTimeout: 11000,

  specs: ['manager/*.js'],

  capabilities: {
    'browserName': 'chrome'
  },

  chromeOnly: true,

  baseUrl: 'http://manager.example.com:' + process.env.WEBSERVERPORT + '/',

  framework: 'jasmine',

  jasmineNodeOpts: {
    defaultTimeoutInterval: 30000
  }
};