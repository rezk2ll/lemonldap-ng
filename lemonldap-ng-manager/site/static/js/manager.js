/* LemonLDAP::NG Manager client
 *
 * This is the main app file. Other are:
 *  - struct.json and js/confTree.js that contains the full tree
 *  - translate.json that contains the keywords translation
 *
 *  This file contains:
 *   - a modal controller to display messages
 *   - the AngularJS controller
 */
(function() {
  'use strict';

  var llapp = angular.module('llngManager', ['ui.tree', 'ui.bootstrap', 'llApp']);

  /* Modal controller
   *
   * Used to display choices that can not be shown on #form
   */
  llapp.controller('ModalInstanceCtrl', function($scope, $modalInstance, elem, set) {
    var oldValue;
    $scope.elem = elem;
    $scope.set = set;
    $scope.result = '';
    $scope.staticPrefix = staticPrefix;
    var currentNode = elem('currentNode');
    $scope.translateP = elem('translateP');
    if (currentNode) {
      oldValue = currentNode.data;
      $scope.currentNode = currentNode;
    }

    $scope.ok = function() {
      set('result', $scope.result);
      $modalInstance.close(true);
    };

    $scope.cancel = function() {
      if (currentNode) $scope.currentNode.data = oldValue;
      $modalInstance.dismiss('cancel');
    };

    /* test if value is in select */
    $scope.inSelect = function(value) {
      for (var i = 0; i < $scope.currentNode.select.length; i++) {
        if ($scope.currentNode.select[i].k == value) return true;
      }
      return false;
    }

  });

  /* Main AngularJS controller
   *
   */
  llapp.controller('TreeCtrl', ['$scope', '$http', '$location', '$q', '$modal', '$translator', function($scope, $http, $location, $q, $modal, $translator) {

    $scope.links = links;
    $scope.staticPrefix = staticPrefix;
    $scope.formPrefix = formPrefix;
    $scope.availableLanguages = availableLanguages;
    $scope.waiting = true;
    $scope.showM = false;
    $scope.showT = false;
    $scope.form = 'home';
    $scope.currentCfg = {};
    $scope.confPrefix = confPrefix;
    $scope.message = {};
    $scope.result = '';
    $scope.helpUrl = 'start.html#configuration';

    var readError = function(j, e) {
      $scope.waiting = false;
      if (e == 403) {
        $scope.message.title = '__forbidden__';
        $scope.message.items = [];
      }
      else if (e == 401) {
        console.log('Authentication needed');
      }
      else if (e > 0) {
        $scope.message.title = 'serverError';
        $scope.message.items = [{
          message: j
        }];
      }
      else {
        $scope.message.title = 'networkProblem';
        $scope.message.items = [];
      }
      $scope.showModal('message.html');
    };

    /* Modal launcher */
    $scope.showModal = function(tpl) {
      var modalInstance = $modal.open({
        templateUrl: tpl,
        controller: 'ModalInstanceCtrl',
        size: 'lg',
        resolve: {
          elem: function() {
            return function(s) {
              return $scope[s];
            }
          },
          set: function() {
            return function(f, s) {
              $scope[f] = s;
            }
          }
        }
      });
      return modalInstance.result;
    }

    /* Set form menu */
    $scope.setButtons = function() {
      $scope.buttons = buttons;
    };

    /* Manage form menu clicks */
    $scope.menuClick = function(button) {
      if (button.popup) {
        window.open(button.popup);
      } else {
        if (!button.action) button.action = button.title;
        switch (typeof button.action) {
        case 'function':
          button.action($scope.currentNode, $scope);
          break;
        case 'string':
          $scope[button.action]();
          break;
        default:
          console.log(typeof button.action);
        };
      }
      $scope.showM = false;
    };

    $scope.home = function() {
      $scope.form = 'home';
      $scope.showM = false;
    }

    var _checkSaveResponse = function(data) {
      $scope.message = {
        'title': '',
        'message': '',
        'items': [],
      };
      if (data.message && data.message == '__needConfirmation__') {
        $scope.confirmNeeded = true;
      }
      if (data.message) $scope.message.message = data.message;
      if (data.details) {
        for (var m in data.details) {
          if (m != '__changes__') $scope.message.items.push({
            message: m,
            items: data.details[m]
          });
        };
      }
      $scope.waiting = false;
      if (data.result == 1) {
        /* Force reload */
        $location.path('/confs/');
        $scope.message.title = 'successfullySaved';
      } else {
        $scope.message.title = 'saveReport';
      }
      $scope.showModal('message.html');
    };

    $scope.save = function() {
      $scope.showModal('save.html').then(function() {
        $scope.waiting = true;
        $scope.data.push({
          "id": "cfgLog",
          "title": "cfgLog",
          "data": $scope.result
        });
        $http.post($scope.confPrefix + '?cfgNum=' + $scope.currentCfg.cfgNum + ($scope.forceSave ? "&force=1" : ''), $scope.data).success(function(data) {
          $scope.data.pop();
          _checkSaveResponse(data);
        }).error(function(j, e) {
          readError(j, e);
          $scope.data.pop();
        })
      },
      function() {
        console.log('Saving canceled');
      });
      $scope.showM = false;
    }

    $scope.saveRawConf = function($fileContent) {
      $scope.waiting = true;
      $http.post($scope.confPrefix + '/raw', $fileContent).success(function(data) {
        _checkSaveResponse(data);
      }).error(readError);
    };

    $scope.restore = function() {
      $scope.currentNode = null;
      $scope.form = 'restore';
    };

    $scope.cancel = function() {
      $scope.currentNode.data = null;
      $scope.getKey($scope.currentNode);
    };

    var id = 1;

    $scope._findContainer = function() {
      return $scope._findScopeContainer().$modelValue;
    };
    $scope._findScopeContainer = function() {
      var cs = $scope.currentScope;
      while (!cs.$modelValue.type.match(/Container$/)) {
        cs = cs.$parentNodeScope;
      }
      return cs;
    };

    $scope._findScopeByKey = function(k) {
      var cs = $scope.currentScope;
      while (! (cs.$modelValue.title === k)) {
        cs = cs.$parentNodeScope;
      }
      return cs;
    }

    /* Add grant rule entry */
    $scope.newGrantRule = function() {
      var node = $scope._findContainer();
      var l = node.nodes.length;
      var n = l > 0 ? l - 1 : 0;
      node.nodes.splice(n, 0, {
        "id": node.id + '/n' + (id++),
        "title": 'New rule',
        "re": '1',
        "comment": 'New rule',
        "data": 'Message',
        "type": "grant"
      });
    }

    /* Add rules entry */
    $scope.newRule = function() {
      var node = $scope._findContainer();
      var l = node.nodes.length;
      var n = l > 0 ? l - 1 : 0;
      node.nodes.splice(n, 0, {
        "id": node.id + '/n' + (id++),
        "title": 'New rule',
        "re": '^/new',
        "comment": 'New rule',
        "data": 'accept',
        "type": "rule"
      });
    }

    /* Add form replay */
    $scope.newPost = function() {
      var node = $scope._findContainer();
      node.nodes.push({
        "id": node.id + '/n' + (id++),
        "title": "https://my/form",
        "data": [],
        "type": "post"
      });
    }

    /* Add auth chain entry to authChoice */
    $scope.newAuthChoice = function() {
      var node = $scope._findContainer();
      node.nodes.push({
        "id": node.id + '/n' + (id++),
        "title": "1-key",
        "data": ['Null', 'Null', 'Null'],
        "type": "authChoice"
      });
      $scope.execFilters($scope._findScopeByKey('authParams'));
    };

    /* Add hash entry */
    $scope.newHashEntry = function() {
      var node = $scope._findContainer();
      node.nodes.push({
        "id": node.id + '/n' + (id++),
        "title": 'new',
        "data": '',
        "type": "keyText"
      });
    }

    /* Menu cat entry */
    $scope.newCat = function() {
      var cs = $scope.currentScope;
      if (cs.$modelValue.type == 'menuApp') cs = cs.$parentNodeScope;
      cs.$modelValue.nodes.push({
        "id": cs.$modelValue.id + '/n' + (id++),
        "title": "New category",
        "type": "menuCat",
        "nodes": []
      });
    };

    /* Menu app entry */
    $scope.newApp = function() {
      var cs = $scope.currentScope;
      if (cs.$modelValue.type == 'menuApp') cs = cs.$parentNodeScope;
      cs.$modelValue.nodes.push({
        "id": cs.$modelValue.id + '/n' + (id++),
        "title": "New application",
        "type": "menuApp",
        "data": {
          "description": "New app description",
          "uri": "https://newapp/",
          "logo": "logo.png",
          "display": "auto"
        }
      });
    };

    /* SAML attribute entry */
    $scope.addSamlAttribute = function() {
      var node = $scope._findContainer();
      node.nodes.push({
        "id": node.id + '/n' + (id++),
        "title": 'new',
        'type': 'samlAttribute',
        'data': [0, 'New', '', '']
      });
    };

    /* Nodes with template */
    $scope.addVhost = function() {
      var name = window.prompt($translator.translate('virtualHostName'));
      if (name) {
        var node = $scope.addTemplateNode(name, 'virtualHost');
        delete node._nodes[0].cnodes;
        node._nodes[0].nodes = [{
          "id": "virtualHosts/" + 'new__' + name + '/locationRules/default',
          "type": "rule",
          "title": "default",
          "comment": "",
          "re": "default",
          "data": "deny"
        }];
      }
    };

    $scope.addSamlIDP = function() {
      var name = window.prompt($translator.translate('samlPartnerName'));
      if (name) $scope.addTemplateNode(name, 'samlIDPMetaDataNode');
    };

    $scope.addSamlSP = function() {
      var name = window.prompt($translator.translate('samlPartnerName'));
      if (name) $scope.addTemplateNode(name, 'samlSPMetaDataNode');
    };

    $scope.addOidcOp = function() {
      var name = window.prompt($translator.translate('oidcOPName'));
      if (name) $scope.addTemplateNode(name, 'oidcOPMetaDataNode');
    };

    $scope.addOidcRp = function() {
      var name = window.prompt($translator.translate('oidcRPName'));
      if (name) $scope.addTemplateNode(name, 'oidcRPMetaDataNode');
    };

    $scope.addTemplateNode = function(name, type) {
      var cs = $scope.currentScope;
      while (cs.$modelValue.title != type + 's') {
        cs = cs.$parentNodeScope;
      }
      var t = {
        "id": type + "s/" + 'new__' + name,
        "title": name,
        "type": type,
        "_nodes": templates(type, 'new__' + name)
      };
      cs.$modelValue.nodes.push(t);
      return t;
    };

    $scope.del = function(a, i) {
      a.splice(i, 1);
    };

    $scope.deleteEntry = function() {
      var p = $scope.currentScope.$parentNodeScope;
      $scope.currentScope.remove();
      $scope.displayForm(p)
    };

    $scope.down = function() {
      var id = $scope.currentNode.id;
      var p = $scope.currentScope.$parentNodeScope.$modelValue;
      var ind = p.nodes.length;
      for (var i = 0; i < p.nodes.length; i++) {
        if (p.nodes[i].id == id) ind = i;
      }
      if (ind < p.nodes.length - 1) {
        var tmp = p.nodes[ind];
        p.nodes[ind] = p.nodes[ind + 1];
        p.nodes[ind + 1] = tmp;
      }
    };

    $scope.up = function() {
      var id = $scope.currentNode.id;
      var p = $scope.currentScope.$parentNodeScope.$modelValue;
      var ind = -1;
      for (var i = 0; i < p.nodes.length; i++) {
        if (p.nodes[i].id == id) ind = i;
      }
      if (ind > 0) {
        var tmp = p.nodes[ind];
        p.nodes[ind] = p.nodes[ind - 1];
        p.nodes[ind - 1] = tmp;
      }
    };

    /* Leaf title management */
    $scope.translateTitle = function(node) {
      return $translator.translateField(node, 'title');
    };

    $scope.translateP = $translator.translateP;
    $scope.translate = $translator.translate;

    /* test if value is in select */
    $scope.inSelect = function(value) {
      for (var i = 0; i < $scope.currentNode.select.length; i++) {
        if ($scope.currentNode.select[i].k == value) return true;
      }
      return false;
    }

    /* This is for rule form: title = comment if defined, else title = re */
    $scope.changeRuleTitle = function(node) {
      if (node.comment.length > 0) {
        node.title = node.comment;
      } else {
        node.title = node.re;
      }
    }

    /* Node opening
     */

    /* authParams mechanism: show used auth modules only (launched by stoggle) */
    $scope.filters = {};
    $scope.execFilters = function(scope) {
      scope = scope ? scope : $scope;
      for (var filter in $scope.filters) {
        if ($scope.filters.hasOwnProperty(filter)) {
          filterFunctions[filter](scope, $q, $scope.filters[filter]);
        }
      }
    };

    /* To avoid binding all the tree, nodes are pushed in DOM only when opened */
    $scope.stoggle = function(scope) {
      var node = scope.$modelValue;
      ['nodes', 'nodes_cond'].forEach(function(n) {
        if (node['_' + n]) {
          node[n] = [];
          node['_' + n].forEach(function(a) {
            node[n].push(a);
          });
          delete node['_' + n];
        }
      });
      /* Call execFilter for authParams */
      if (node._nodes_filter) {
        if (node.nodes) {
          node.nodes.forEach(function(n) {
            n.onChange = $scope.execFilters
          });
        }
        $scope.filters[node._nodes_filter] = node;
        $scope.execFilters();
      }
      scope.toggle();
    };

    /* Simple toggle management */
    $scope.toggle = function(scope) {
      scope.toggle();
    };

    /*
    $scope.collapseAll = function() {
      var scope = getRootNodesScope();
      scope.collapseAll();
    };

    $scope.expandAll = function() {
      var scope = getRootNodesScope();
      scope.expandAll();
    };*/

    /* cnodes management: hash keys/values are loaded when parent node is opened */
    $scope.download = function(scope) {
      var node = scope.$modelValue;
      var d = $q.defer();
      d.notify('Trying to get datas');
      $scope.waiting = true;
      $http.get($scope.confPrefix + $scope.currentCfg.cfgNum + '/' + node.cnodes).success(function(data) {
        /* Manage datas errors */
        if (!data) {
          d.reject('Empty response from server');
        } else if (data.error) {
          if (data.error.match(/setDefault$/)) {
            if (node.
          default) {
              node.nodes = node.
            default.slice(0);
            } else node.nodes = [];
            delete node.cnodes;
            d.resolve('Set data to default value');
          } else d.reject('Server return an error: ' + data.error);

          /* Store datas */
        } else {
          delete node.cnodes;
          if (!node.type) {
            node.type = 'keyTextContainer';
          }
          node.nodes = [];
          /* TODO: try/catch */
          data.forEach(function(a) {
            if (a.template) {
              a._nodes = templates(a.template, a.title);
            }
            node.nodes.push(a);
          });
          d.resolve('OK');
        }
        $scope.waiting = false;
      }).error(function(j, e) {
        readError(j, e);
        d.reject('');
      });
      return d.promise;
    };

    $scope.openCnode = function(scope) {
      $scope.download(scope).then(function() {
        scope.toggle();
      },
      function(reason) {
        if (typeof reason == 'string') {
          alert(reason);
        }
      });
    }

    var showHelp = function(scope) {
      while (!scope.$modelValue.help && scope.$parentNodeScope) {
        scope = scope.$parentNodeScope;
      }
      $scope.helpUrl = scope.$modelValue.help || 'start.html#configuration';
    }

    /* Form management
     *
     * `currentNode` contains the last select node
     *
     * method `diplayForm()`:
     *  - set the `form` property to the name of the form to download
     *    (`text` by default or `home` for node without `type` property)
     *  - launch getKeys to set `node.data`
     *  - hide tree when in XS size
     */
    $scope.displayForm = function(scope) {
      var node = scope.$modelValue;
      if (node.cnodes) $scope.download(scope);
      if (node._nodes) $scope.stoggle(scope);
      $scope.currentNode = node;
      $scope.currentScope = scope;
      var f;
      if (node.type) {
        f = node.type;
      } else {
        f = 'text';
      }
      if (node.nodes || node._nodes || node.cnodes) {
        $scope.form = f != 'text' ? f:
        'home';
      } else {
        $scope.form = f;
        /* Get datas */
        $scope.getKey(node);
        /* Hide tree in XS size */
      }
      if (node.type && node.type == 'simpleInputContainer') {
        node.nodes.forEach(function(n) {
          $scope.getKey(n);
        });
      }
      $scope.showT = false;
      showHelp(scope);
    };

    $scope.keyWritable = function(scope) {
      var node = scope.$modelValue;
      return node.type && node.type.match(/^(authChoice|keyText|virtualHost|rule|menuCat|menuApp|samlAttribute)$/) ? true : false;
    }

    /* method `newRSAKey`
     *
     */
    $scope.newRSAKey = function() {
      $scope.showModal('password.html').then(function() {
        $scope.waiting = true;
        var currentNode = $scope.currentNode;
        var password = $scope.result;
        $http.post($scope.confPrefix + '/newRSAKey', {
          "password": password
        }).success(function(data) {
          currentNode.data[0].data = data['private'];
          currentNode.data[1].data = password;
          currentNode.data[2].data = data['public'];
          $scope.waiting = false;
        }).error(readError);
      },
      function() {
        console.log('New key cancelled');
      });
    }

    $scope.newRSAKeyNoPassword = function() {
      $scope.waiting = true;
      var currentNode = $scope.currentNode;
      var password = $scope.result;
      $http.post($scope.confPrefix + '/newRSAKey', {
        "password": ''
      }).success(function(data) {
        currentNode.data[0].data = data['private'];
        currentNode.data[1].data = data['public'];
        $scope.waiting = false;
      }).error(readError);
    }

    /* method `getKey()`:
     *  - return a promise with the data:
     *    - from node when set
     *    - after downloading else
     */
    $scope.getKey = function(node) {
      var d = $q.defer();
      if (!node.data) {
        $scope.waiting = true;
        if (node.get && typeof(node.get) == 'object') {
          node.data = [];
          var tmp = [];
          for (var i = 0; i < node.get.length; i++) {
            node.data[i] = ({
              title: node.get[i],
              id: node.get[i]
            });
            tmp.push($scope.getKey(node.data[i]));
          };
          $q.all(tmp).then(function() {
            d.resolve(node.data);
          },
          function(j, e) {
            d.reject(e);
            $scope.waiting = false;
          });
        } else {
          $http.get($scope.confPrefix + $scope.currentCfg.cfgNum + '/' + (node.get ? node.get : node.title)).success(function(data) {
            /* Set default value if response is null or if asked by server */
            if ((data.value === null || (data.error && data.error.match(/setDefault$/))) && node.
          default !== null) {
              node.data = node.
            default;
            } else {
              node.data = data.value;
            }
            /* Cast int as int (remember that booleans are int for Perl) */
            if (node.type && node.type.match(/^(int|bool|trool)$/)) {
              node.data = parseInt(node.data);
              /* Split SAML types */
            } else if (node.type && node.type.match(/^(saml(Service|Assertion)|blackWhiteList)$/) && !(typeof node.data === 'object')) {
              node.data = node.data.split(';');
            }
            $scope.waiting = false;
            d.resolve(node.data);
          }).error(function(j, e) {
            d.reject(e);
            readError(j, e);
          });
        }
      } else {
        d.resolve(node.data);
      }
      return d.promise;
    };

    /* function `pathEvent(event, next; current)`:
     * Called when $location.path() change, launch getCfg() with the new
     * configuration number
     */
    var pathEvent = function(event, next, current) {
      var n = next.match(new RegExp('#/confs/(latest|[0-9]+)'));
      if (n === null) {
        $location.path('/confs/latest');
      } else {
        console.log('Trying to get cfg number ' + n[1]);
        $scope.getCfg(n[1]);
      }
    };
    $scope.$on('$locationChangeSuccess', pathEvent);

    /* function `getCfg(n)
     * Download configuration metadatas
     */
    $scope.getCfg = function(n) {
      if ($scope.currentCfg.cfgNum != n) {
        $http.get($scope.confPrefix + n).success(function(data) {
          $scope.currentCfg = data;
          var d = new Date($scope.currentCfg.cfgDate * 1000);
          $scope.currentCfg['date'] = d.toLocaleString();
          console.log('Metadatas of cfg ' + n + ' loaded');
          $location.path('/confs/' + n);
          $scope.init();
        }).error(readError);
      } else {
        $scope.waiting = false;
      }
    };

    /* method `getLanguage(lang)`
     * Launch init() after setting current language
     */
    $scope.getLanguage = function(lang) {
      $scope.lang = lang;
      // Force reload home
      $scope.form = 'white';
      $scope.init();
      $scope.showM = false;
    }

    /* Initialization */

    /* Load JSON files:
     *  - struct.json: the main tree
     *  - languages/<lang>.json: the chosen language datas
     */
    $scope.init = function() {
      var tmp;
      $scope.waiting = true;
      $scope.data = [];
      $scope.confirmNeeded = false;
      $scope.forceSave = false;
      $q.all([
      $translator.init($scope.lang), $http.get(staticPrefix + "struct.json").success(function(data) {
        tmp = data;
        console.log("Structure loaded");
      })]).then(function() {
        console.log("Starting structure binding");
        $scope.data = tmp;
        tmp = null;
        setScopeVars($scope);
        $scope.form = 'home';
        $scope.waiting = false;
      },
      readError);
    };
    var c = $location.path().match(new RegExp('^/confs/(latest|[0-9]+)'));
    if (!c) {
      console.log("Redirecting to /confs/latest");
      $location.path('/confs/latest');
    }

    /* Update currentNode.data (used for file form */
    $scope.replaceContent = function(node, $fileContent) {
      node.data = $fileContent;
    };
  }]);

})();
