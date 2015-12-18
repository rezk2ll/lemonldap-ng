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
        <div class="navbar-collapse">
          <ul class="nav navbar-nav">
            <li><a id="a-users" href="#"><i class="glyphicon glyphicon-user"></i> {{translate('users')}}</a></li>
            <li><a id="a-ip" href="#/ipAddr"><i class="glyphicon glyphicon-sort-by-order"></i> {{translate('ipAddresses')}}</a></li>
            <li><a id="a-multi" href="#/doubleIp"><i class="glyphicon glyphicon-exclamation-sign"></i> {{translate('multiIp')}}</a></li>
            <li><a id="a-multi" href="#/persistent"><i class="glyphicon glyphicon-exclamation-sign"></i> {{translate('persistent')}}</a></li>
          </ul>
        </div>
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
        <div class="panel-heading">
          <h1 class="panel-title text-center">{{translate("sessionTitle")}} {{currentSession.id}}</h1>
        </div>
        <div class="panel-body">
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
    <div class="panel panel-default" ng-if="node.nodes">
      <div class="panel-heading">
        <h2 class="panel-title text-center">{{translateP(node.title)}}</h2>
      </div>
      <table class="table table-striped" ng-model="node.nodes">
        <tr ng-repeat="node in node.nodes" ng-include="'session_attr.html'"></tr>
      </table>
    </div>
    <div ng-if="!node.nodes">
      <th>{{translate(node.title)}}</th>
      <td><tt>${{node.title}}</tt></td>
      <td><span id="v-{{node.title}}">{{node.value}}</td>
    </div>
  </script>

  <script type="text/ng-template" id="nodes_renderer.html">
    <div ui-tree-handle class="tree-node tree-node-content panel-info" ng-class="{'bg-info':this.$modelValue===currentScope.$modelValue,'tree-node-default':this.$modelValue!==currentScope.$modelValue}">
      <span ng-if="node.value">
        <a id="a-{{node.value}}" class="btn btn-node btn-sm" ng-click="stoggle(this)">
          <span class="glyphicon" ng-class="{'glyphicon-chevron-right': collapsed,'glyphicon-chevron-down': !collapsed}"></span>
        </a>
        <span id="s-{{node.value}}" ng-click="stoggle(this)">{{node.value}} <span class="badge">{{node.count}}</span></span>
      </span>
      <span ng-if="node.session">
        <a class="btn btn-node btn-sm" ng-click="displaySession(this)">
          <span class="glyphicon glyphicon-eye-open"></span>
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
