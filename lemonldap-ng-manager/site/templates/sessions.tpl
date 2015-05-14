<TMPL_INCLUDE NAME="header.tpl">

  <title>LemonLDAP::NG sessions explorer</title>
</head>

<body ng-app="llngSessionsExplorer" ng-controller="SessionsExplorerCtrl">

  <TMPL_INCLUDE NAME="menubar.tpl">

  <div id="content" class="row container-fluid">
    <div id="pleaseWait" ng-show="waiting"><span trspan="waitingForDatas"></span></div>

    <!-- Tree -->
    <aside id="left" class="col-lg-4 col-md-4 col-sm-5 col-xs-12 scrollable " ng-class="{'hidden-xs':!showT}" role="complementary">
      <div class="navbar navbar-default">
        <ul class="nav navbar-nav">
          <li><a id="a-users" href="#">{{translate('users')}}</a></li>
          <li><a id="a-ip" href="#/ipAddr">{{translate('ipAddresses')}}</a></li>
          <li><a id="a-multi" href="#/doubleIp">{{translate('multiIp')}}</a></li>
        </ul>
      </div>
      <div class="region region-sidebar-first">
        <section id="block-superfish-1" class="block block-superfish clearfix">
          <div ui-tree data-drag-enabled="false" id="tree-root">
            <div ng-show="data.length==0" style="text-align:center;">
              <span class="label label-warning" trspan="noDatas"></span>
            </div>
            <ol ui-tree-nodes="" ng-model="data">
              <li ng-repeat="node in data track by node.id" ui-tree-node ng-include="'nodes_renderer.html'" collapsed="true"></li>
            </ol>
          </div>
        </section>
      </div>
      <div class="hresizer hidden-xs" resizer="vertical" resizer-left="#left" resizer-right="#right"></div>
    </aside>

    <!-- Right(main) div -->
    <div id="right" class="col-lg-8 col-md-8 col-sm-7 col-xs-12 scrollable" ng-class="{'hidden-xs':showT}">
      <!-- Menu buttons -->
      <div class="navbar navbar-default" ng-class="{'hidden-xs':!showM}">
        <div class="navbar-collapse" ng-class="{'collapse':!showM}" id="formmenu">
          <ul class="nav navbar-nav">
            <li ng-if="currentSession" ng-repeat="button in menu.session" ng-include="'menubutton.html'"></li>
            <li ng-if="currentSession===null" ng-repeat="button in menu.home" ng-include="'menubutton.html'"></li>
            <li class="visible-xs" ng-include="'languages.html'"></li>
          </ul>
        </div>
      </div>
      <div class="panel panel-default" ng-hide="currentSession===null">
        <div class="panel panel-heading">
          <h1 class="panel-title text-center">{{translate("sessionTitle")}}</h1>
        </div>
        <div class="panel panel-body">
          <div class="alert alert-info">
            <strong>{{translate("sessionStartedAt")}}</strong>
            {{localeDate(currentSession._utime)}}
          </div>
          <div ng-model="currentSession.nodes">
            <div ng-repeat="node in currentSession.nodes" ng-include="'session_attr.html'"></div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <script type="text/ng-template" id="session_attr.html">
    <div ng-if="node.nodes">
      <h2>{{translateP(node.title)}}</h2>
      <ul ng-model="node.nodes">
        <li ng-repeat="node in node.nodes" ng-include="'session_attr.html'"></li>
      </ul>
    </div>
    <div ng-if="!node.nodes">
      <strong>{{translate(node.title)}}</strong>
      (<tt>${{node.title}}</tt>): <span id="v-{{node.title}}">{{node.value}}</span>
    </div>
  </script>

  <script type="text/ng-template" id="nodes_renderer.html">
    <div ui-tree-handle class="tree-node tree-node-content" ng-class="{'selected':this.$modelValue===currentScope.$modelValue}">
      <span ng-if="node.value">
        <a id="a-{{node.value}}" class="btn btn-node btn-xs" ng-click="stoggle(this)">
          <span class="glyphicon" ng-class="{'glyphicon-chevron-right': collapsed,'glyphicon-chevron-down': !collapsed}"></span>
        </a>
        <span id="s-{{node.value}}" ng-click="stoggle(this)">{{node.value}} <span class="badge">{{node.count}}</span></span>
      </span>
      <span ng-if="node.session">
        <a class="btn btn-node btn-xs" ng-click="displaySession(this)">
          <span class="glyphicon glyphicon-pencil"></span>
        </a>
        <span id="s-{{node.session}}" ng-click="displaySession(this)">{{localeDate(node.date)}}</span>
      </span>
    </div>
    <ol ui-tree-nodes="" ng-model="node.nodes" ng-class="{hidden: collapsed}">
      <li ng-repeat="node in node.nodes track by node.id" ui-tree-node ng-include="'nodes_renderer.html'" collapsed="true"></li>
    </ol>
  </script>

  <TMPL_INCLUDE NAME="scripts.tpl">

  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">js/sessions.js"></script>

<TMPL_INCLUDE NAME="footer.tpl">
