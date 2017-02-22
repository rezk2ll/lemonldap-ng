var filterFunctions = {
  'authParams': function(scope, $q, node) {
    /* Here, `node` is the root node (authParams) and `n` points to its
     * conditional subnodes. This subnodes have the property `show` that can
     * be set to true or false depending on what has to be displayed
     */

    /* 1. be sure to have all datas in main nodes */
    var wait = [];
    console.log('filterFunctions called');
    node.nodes.forEach(function(n) {
      wait.push(scope.getKey(n));
    });
    /* 2. then do the job */
    $q.all(wait).then(function() {
      /* 2.1. Get all modules needed */
      var all = false;
      var nToShow = [];
      var p = function(s) {
        var tmp = s.toLowerCase();
        if (tmp == 'ad') {
          tmp = 'ldap';
        }
        if (tmp == 'openidconnect') {
          tmp = 'oidc';
        }
        nToShow.push(tmp + 'Params');
      }
      if (node.nodes[0].data.match(/^Choice/)) {
        node.nodes[2].data = 'Choice';
      }

      node.nodes.forEach(function(n) {
        p(n.data);
      });
      /* Get choice or multi sub modules */
      node.nodes_cond.forEach(function(n) {
        var restart = 0;
        var nd = n._nodes ? n._nodes : n.nodes;
        if (node.nodes[0].data == 'Choice' && n.id == 'choiceParams') {
          console.log('Choice is selected');
          if (nd[1].cnodes) {
            restart++;
          }
          else {
            nd = nd[1]._nodes ? nd[1]._nodes : nd[1].nodes;
            nd.forEach(function(m) {
              m.data.forEach(function(s) {
                p(s);
              });
            });
          };
        }
        else if (node.nodes[0].data == 'Combination' && n.id == 'combinationParams') {
          console.log('Combination is selected');
          if (nd[1].cnodes) {
            restart++;
          }
          else {
            nd = nd[1]._nodes ? nd[1]._nodes : nd[1].nodes;
            nd.forEach(function(m) {
	      p(m.data.type);
            });
          }
        }
        if(restart==1) {
          scope.waiting = true;
          scope.download({
            '$modelValue': nd[1]
          }).then(function() {
            filterFunctions.authParams(scope, $q, node)
          });
          return;
        }
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
