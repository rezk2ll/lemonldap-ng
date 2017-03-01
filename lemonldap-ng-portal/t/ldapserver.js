var ldap = require('ldapjs');

var server = ldap.createServer();

server.search('dc=example,dc=com', function(req, res, next) {
  var obj = [{
    dn: 'dc=example,dc=com',
    attributes: {
      objectclass: ['dcObject', 'organization'],
      o: 'example',
      dc: 'example'
    }
  }, {
    dn: 'uid=dwho,dc=example,dc=com',
    attributes: {
      objectclass: ['inetOrgPerson'],
      uid: 'dwho',
      cn: 'Dr Who',
      mail: 'dwho@badwolf.org'
    }
  }];

  for(var i=0; i<obj.length;i++) {
    console.log(obj[i]);
    if (req.filter.matches(obj[i])) res.send(obj);
  }
  res.end();
});

server.listen(1389, function() {
  console.log('LDAP server listening at %s', server.url);
});
