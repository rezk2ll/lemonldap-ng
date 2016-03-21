<TMPL_INCLUDE NAME="header.tpl">

  <title>LemonLDAP::NG Manager</title>
  <link rel="prefetch" href="<TMPL_VAR NAME="STATIC_PREFIX">forms/home.html" />
  <link rel="prefetch" href="<TMPL_VAR NAME="STATIC_PREFIX">struct.json" />
</head>

<body ng-app="llngConfDiff" ng-controller="DiffCtrl">

  <TMPL_INCLUDE NAME="menubar.tpl">

  <div id="content" class="row container-fluid">
  </div>

  <TMPL_INCLUDE NAME="scripts.tpl">

  <!-- //if:jsminified
    <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">js/conftree.min.js"></script>
    <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">js/diff.min.js"></script>
  //else -->
    <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">js/conftree.js"></script>
    <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">js/diff.js"></script>
  <!-- //endif -->

<TMPL_INCLUDE NAME="footer.tpl">
