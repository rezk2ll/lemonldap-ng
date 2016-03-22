<TMPL_INCLUDE NAME="header.tpl">

  <title>LemonLDAP::NG Manager</title>
  <link rel="prefetch" href="<TMPL_VAR NAME="STATIC_PREFIX">forms/home.html" />
  <link rel="prefetch" href="<TMPL_VAR NAME="STATIC_PREFIX">struct.json" />
</head>

<body ng-app="llngConfDiff" ng-controller="DiffCtrl">

  <TMPL_INCLUDE NAME="menubar.tpl">

  <div id="content" class="row container-fluid">
    <div id="pleaseWait" ng-show="waiting"><span trspan="waitingForDatas"></span></div>
    <aside id="left" class="col-lg-4 col-md-4 col-sm-5 col-xs-12 scrollable " ng-class="{'hidden-xs':!showT}" role="complementary">
      <div class="region region-sidebar-first">
        <section id="block-superfish-1" class="block block-superfish clearfix">
          <div ui-tree data-drag-enabled="false" id="tree-root">
            <div ng-show="data.length==0" style="text-align:center;">
              <span class="label label-warning" trspan="noDatas"></span>
            </div>
            <ol ui-tree-nodes="" ng-model="data">
              <li ng-repeat="node in data" ui-tree-node ng-include="'nodes_renderer.html'" collapsed="true"></li>
            </ol>
          </div>
        </section>
      </div>
    </aside>

    <!-- Right div -->
    <div id="right" class="col-lg-8 col-md-8 col-sm-7 col-xs-12 scrollable" ng-class="{'hidden-xs':showT&&!showM}">
      <h1 ng-if="message">{{message}}</h1>
      <pre>
        {{data | json }}
      </pre>
    </div>
  </div>

  <script type="text/ng-template" id="nodes_renderer.html">
    <div ui-tree-handle class="tree-node tree-node-content panel-info">
      <span ng-include="'arrow.html'"></span>
      <span ng-click="toggle(this)">{{node.title}}</span>
    </div>
    <ol ui-tree-nodes="" ng-model="node" ng-class="{hidden: collapsed}" ng-include="'subnodes.html'">
    </ol>
  </script>
  <script type="text/ng-template" id="newnodes_renderer.html">
    <div ui-tree-handle class="tree-node tree-node-content panel-info">
      <span ng-include="'arrow.html'"></span>
      <span ng-click="toggle(this)" style="color:#0A0">{{node.title}}</span>
    </div>
    <ol ui-tree-nodes="" ng-model="node" ng-class="{hidden: collapsed}" ng-include="'subnodes.html'">
    </ol>
  </script>
  <script type="text/ng-template" id="oldnodes_renderer.html">
    <div ui-tree-handle class="tree-node tree-node-content panel-info">
      <span ng-include="'arrow.html'"></span>
      <span ng-click="toggle(this)" style="color:#A00">{{node.title}}</span>
    </div>
    <ol ui-tree-nodes="" ng-model="node" ng-class="{hidden: collapsed}" ng-include="'subnodes.html'">
    </ol>
  </script>

  <script type="text/ng-template" id="arrow.html">
    <span ng-if="node.nodes||node.newnodes||node.oldnodes">
      <a class="btn btn-node btn-sm" ng-click="toggle(this)">
        <span class="glyphicon" ng-class="{'glyphicon-chevron-right': collapsed,'glyphicon-chevron-down': !collapsed}"></span>
      </a>
    </span>
    <span ng-if="node.newvalue||node.oldvalue||node.value">
      <a class="btn btn-node btn-sm" ng-click="toggle(this)">
        <span class="glyphicon glyphicon-eye-open"></span>
      </a>
    </span>
  </script>

  <script type="text/ng-template" id="subnodes.html">
    <li ng-repeat="node in node.nodes" ui-tree-node ng-include="'nodes_renderer.html'" collapsed="true"></li>
    <li ng-repeat="node in node.newnodes" ui-tree-node ng-include="'newnodes_renderer.html'" collapsed="true"></li>
    <li ng-repeat="node in node.oldnodes" ui-tree-node ng-include="'oldnodes_renderer.html'" collapsed="true"></li>
  </script>

  <TMPL_INCLUDE NAME="scripts.tpl">

  <!-- //if:jsminified
    <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">js/conftree.min.js"></script>
    <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">js/diff.min.js"></script>
  //else -->
    <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">js/conftree.js"></script>
    <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">js/diff.js"></script>
  <!-- //endif -->

<TMPL_INCLUDE NAME="footer.tpl">
