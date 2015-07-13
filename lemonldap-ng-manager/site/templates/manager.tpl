<TMPL_INCLUDE NAME="header.tpl">

  <title>LemonLDAP::NG Manager</title>
  <link rel="prefetch" href="<TMPL_VAR NAME="STATIC_PREFIX">forms/home.html" />
  <link rel="prefetch" href="<TMPL_VAR NAME="STATIC_PREFIX">struct.json" />
</head>

<body ng-app="llngManager" ng-controller="TreeCtrl">

  <TMPL_INCLUDE NAME="menubar.tpl">

  <div id="content" class="row container-fluid">

    <TMPL_INCLUDE NAME="tree.tpl">

    <!-- Right(main) div -->
    <div id="right" class="col-lg-8 col-md-8 col-sm-7 col-xs-12 scrollable" ng-class="{'hidden-xs':showT}">
      <!-- Form container -->
      <div id="top">
        <!-- Menu buttons -->
        <div class="navbar navbar-default" ng-class="{'hidden-xs':!showM}">
          <div class="navbar-collapse" ng-class="{'collapse':!showM}" id="formmenu">
            <ul class="nav navbar-nav">
               <li><a class="link" ng-click="save()"><i class="glyphicon glyphicon-save"></i> <span trspan="save" /></a></li>
               <li><a class="link" ng-if="currentCfg.prev" ng-click="getCfg(currentCfg.prev)" title="Configuration {{currentCfg.prev}}"><i class="glyphicon glyphicon-arrow-left"></i> <span trspan="previous" /></a></li>
               <li><a class="link" ng-if="currentCfg.next" ng-click="getCfg(currentCfg.next)" title="Configuration {{currentCfg.next}}"><i class="glyphicon glyphicon-arrow-right"></i> <span trspan="next" /></a></a></li>
               <li><a class="link" ng-click="getCfg('latest')" title="Configuration {{currentCfg.cfgNum}}"><i class="glyphicon glyphicon-refresh"></i> <span trspan="latest" /></a></li>
              <li ng-repeat="button in buttons" ng-include="'menubutton.html'"></li>
              <li class="visible-xs" ng-include="'languages.html'"></li>
            </ul>
          </div>
        </div>
        <form class="form-group slide-animate-container" ng-include="formPrefix+form+'.html'" scope="$scope" onload="setButtons()" />
      </div>
      <!-- Help container -->
      <div id="bottom" class="hidden-xs">
        <div class="vresizer" resizer="horizontal" resizer-top="#top" resizer-bottom="#bottom"></div>
        <div class="scrollable-sm">
          <h3>Data binding</h3>
          <pre class="code">{{ data | json }}</pre>
        </div>
      </div>
    </div>
  </div>

  <!-- HTML recursive templates (used in `ng-repeat... ng-include="'template.html'") -->
  <!-- Tree nested node template -->
  <script type="text/ng-template" id="nodes_renderer.html">
    <div ui-tree-handle class="tree-node panel-info" ng-class="{'bg-info':this.$modelValue===currentNode,'tree-node-default':this.$modelValue!==currentNode}">
      <!-- Glyph icons -->
      <span ng-switch="node.nodes||node.nodes_cond?1:((node._nodes&&node._nodes.length>0)||(node._nodes_cond&&node._nodes_cond.length>0)?3:(node.cnodes&&node.cnodes.length>0?2:0))">
        <!-- Undownloaded nodes (hash data)-->
        <a class="btn btn-sm" id="a-{{node.id}}" ng-switch-when="2" ng-click="openCnode(this)">
          <span class="glyphicon glyphicon-chevron-right"></span>
        </a>
        <!-- Javascript nodes not yet bind to DOM -->
        <a class="btn btn-sm" id="a-{{node.id}}" ng-switch-when="3" ng-click="stoggle(this)">
          <span class="glyphicon" ng-class="{'glyphicon-chevron-right': collapsed, 'glyphicon-chevron-down': !collapsed}"></span>
        </a>
        <!-- Nodes already loaded and binded -->
        <a class="btn btn-sm" id="a-{{node.id}}" ng-switch-when="1" ng-click="toggle(this)">
          <span class="glyphicon" ng-class="{'glyphicon-chevron-right': collapsed, 'glyphicon-chevron-down': !collapsed}"></span>
        </a>
        <!-- Leaf -->
        <a class="btn btn-sm" ng-switch-default ng-click="displayForm(this)">
          <span class="glyphicon glyphicon-pencil"></span>
        </a>
      </span>
      <!-- Node text with/without translation -->
      <span id="t-{{node.id}}" ng-if="keyWritable(this)" ng-click="displayForm(this)">{{node.title}}</span>
      <span id="t-{{node.id}}" ng-if="!keyWritable(this)" ng-click="displayForm(this)" trspan="{{node.title}}" />
    </div>
    <!-- Subnodes -->
    <ol ui-tree-nodes="btn btn-sm" ng-model="node.nodes" ng-class="{hidden: collapsed}">
      <li ng-repeat="node in node.nodes track by node.id" ui-tree-node ng-include="'nodes_renderer.html'" collapsed="true"></li>
    </ol>
    <!-- Filtered subnodes (authParams mechanism) -->
    <ol ui-tree-nodes="btn btn-sm" ng-model="node.nodes_cond" ng-class="{hidden: collapsed}">
      <li ng-repeat="(name,node) in node.nodes_cond track by node.id" ng-if="node.show" ui-tree-node ng-include="'nodes_renderer.html'" collapsed="true"></li>
    </ol>
  </script>

  <!-- Message display -->
  <script type="text/ng-template" id="message.html">
    <div class="modal-header">
      <h3 class="modal-title" trspan="{{elem('message').title}}" />
    </div>
    <div class="modal-body">
      <div class="modal-p">{{translateP(elem('message').message)}}</div>
      <ul class="main-modal-ul" ng-model="elem('message').items">
        <li ng-repeat="item in elem('message').items" ng-include="'messageitem.html'"/>
      </ul>
    </div>
    <div class="modal-footer">
      <button class="btn btn-primary" ng-click="ok()" trspan="ok"></button>
      <button class="btn btn-warning" ng-click="cancel()" ng-if="message.displayCancel" trspan="cancel"></button>
    </div>
  </script>

  <script type="text/ng-template" id="messageitem.html">
    <div class="modal-p">{{translateP(item.message)}}</div>
    <ul class="modal-ul" ng-model="item.items">
      <li ng-repeat="item in item.items" ng-include="'messageitem.html'"/>
    </ul>
  </script>

  <!-- Password question -->
  <script type="text/ng-template" id="password.html">
    <div class="modal-header">
      <h3 class="modal-title" trspan="enterPassword" />
    </div>
    <div class="modal-body">
      <div class="input-group" style="width:100%;">
        <label class="input-group-addon" for="mdPwd" trspan="password"/>
        <input id="mdPwd" class="form-control" ng-model="result"/>
      </div>
    </div>
    <div class="modal-footer">
      <button class="btn btn-primary" ng-click="ok()" trspan="ok"></button>
      <button class="btn btn-warning" ng-click="cancel()" trspan="cancel"></button>
    </div>
  </script>

  <!-- Save confirm -->
  <script type="text/ng-template" id="save.html">
    <div class="modal-header">
      <h3 class="modal-title" trspan="savingConfirmation" />
    </div>
    <div class="modal-body">
      <div class="input-group" style="width:100%;">
        <label class="input-group-addon" for="longtextinput" trspan="cfgLog"/>
        <textarea id="longtextinput" rows="5" class="form-control" ng-model="result"/>
      </div>
    </div>
    <div class="modal-footer">
      <button class="btn btn-primary" ng-click="ok()" trspan="ok"></button>
      <button class="btn btn-warning" ng-click="cancel()" trspan="cancel"></button>
    </div>
  </script>

  <TMPL_INCLUDE NAME="scripts.tpl">

  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">js/conftree.js"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">js/filterFunctions.js"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">js/manager.js"></script>

<TMPL_INCLUDE NAME="footer.tpl">
