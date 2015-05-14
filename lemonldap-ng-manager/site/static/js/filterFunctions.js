var filterFunctions = {
  'authParams': function($scope, $q, node) {
    /* Here, `node` is the root node (authParams) and `n` points to its
     * conditional subnodes. This subnodes have the property `show` that can
     * be set to true or false depending on what has to be displayed
     */

    /* 1. be sure to have all datas in main nodes */
    var wait = [];
    node.nodes.forEach(function(n) {
      wait.push($scope.getKey(n));
    });
    /* 2. then do the job */
    $q.all(wait).then(function() {
      /* 2.1. Get all modules needed */
      var all = false;
      var nToShow = [];
      if (node.nodes[0].data.match(/^(Choice|Multi)/)) {
        for (var i = 1; i < 3; i++) {
          node.nodes[i].data = node.nodes[0].data;
        }
        all = true;
      }
      node.nodes.forEach(function(n) {
        var tmp = n.data.toLowerCase();
        if (tmp == 'ad') {
          tmp = 'ldap';
        }
        nToShow.push(tmp + 'Params');
      });
      /* 2.2 Display modules */
      node.nodes_cond.forEach(function(n) {
        if (!all && nToShow.indexOf(n.id) == -1) {
          n.show = false
        } else {
          n.show = true;
        }
      });
    });
  }
}