var filterFunctions;

filterFunctions = {
  // Here, `node` is the root node (authParams) and `n` points to its
  // conditional subnodes. This subnodes have the property `show` that can
  // be set to true or false depending on what has to be displayed

  authParams: function(scope, $q, node) {
    var i, len, found, n, wait, searchFor;
    // 1. be sure to have all datas in main nodes
    wait = [];
    searchFor = function (node, id) {
        var i, len;
        if (node.id == id) {
            return node;
        }
        if (node._nodes) {
            for (i = 0, len = node._nodes.length; i < len; i++) {
                found = searchFor(node._nodes[i], id)
                if(found) {
                    return found;
                }
            }
        }
        if (node.nodes) {
            for (i = 0, len = node.nodes.length; i < len; i++) {
                found = searchFor(node.nodes[i], id)
                if(found) {
                    return found;
                }
            }
        }
        if (node.nodes_cond) {
            for (i = 0, len = node.nodes_cond.length; i < len; i++) {
                found = searchFor(node.nodes_cond[i], id)
                if(found) {
                    return found;
                }
            }
        }
        return;
    };

    ['authentication', 'userDB', 'registerDB', 'passwordDB'].forEach( function (id) { 
        var found = searchFor(node, id);
        if (found) {
            wait.push(scope.getKey(found))
        }
    } ); 
    // 2. then do the job
    return $q.all(wait).then(function() {
      var all, j, k, l, len1, len2, len3, len4, len5, len6, m, nToShow, nd, o, p, q, r, ref1, ref2, ref3, ref4, restart, s, nodeToDownload;
      // Flag to see all nodes
      all = false;
      // Nodes to show
      nToShow = [];
      // Little function to select good node
      p = function(s) {
        var tmp;
        tmp = s.toLowerCase();
        if (tmp === 'openidconnect') {
          tmp = 'oidc';
        }
        nToShow.push(tmp + 'Params');
        if (tmp === 'ad') {
          return nToShow.push('ldapParams');
        }
      };

      // Show nodes configured as main auth methods
      ['authentication', 'userDB', 'registerDB', 'passwordDB'].forEach( function (id) { 
          var found = searchFor(node, id);
          if (found) {
              p(found.data);
          }
      } ); 

      restart = 0;

      // From choice
      var choiceModules = searchFor(node, "authChoiceModules");
      if (choiceModules) {
          if (choiceModules.cnodes) {
              nodeToDownload = choiceModules;
              restart++;
          } else if (choiceModules.nodes) {
            var i;
            for (i = 0; i < choiceModules.nodes.length; i++) {
                var choice = choiceModules.nodes[i];
                var j;
                for (j = 0; j < choice.data.length; j++) {
                    var s = choice.data[j];
                    if (typeof s === 'string') {
                        p(s);
                    }
                }
            }
          }
      }

      // From combination
      var combModules = searchFor(node, "combModules");
      if (combModules) {
          if (combModules.cnodes) {
              nodeToDownload = combModules;
              restart++;
          } else if (combModules.nodes) {
            var i;
            for (i = 0; i < combModules.nodes.length; i++) {
                var comb = combModules.nodes[i];
                if (comb.data) {
                    var s = comb.data.type;
                    if (typeof s === 'string') {
                        p(s);
                    }
                }
            }
          }
      }

      if (restart) {
        scope.waiting = true;
        scope.download({
          '$modelValue': nodeToDownload
        }).then(function() {
          return filterFunctions.authParams(scope, $q, node);
        });
        return;
      }

      ref4 = node.nodes_cond;
      for (r = 0, len6 = ref4.length; r < len6; r++) {
        n = ref4[r];
        if (!all && nToShow.indexOf(n.id) === -1) {
          n.show = false;
        } else {
          n.show = true;
        }
      }
    });
  }
};

window.filterFunctions = filterFunctions;
