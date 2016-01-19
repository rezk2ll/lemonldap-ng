  <!-- Menu dropdown template -->
  <script type="text/ng-template" id="menubutton.html">
    <a class="link" ng-if="!button.buttons" ng-click="menuClick(button)"><i class="glyphicon glyphicon-{{button.icon}}" ng-if="button.icon"></i> {{translateTitle(button)}}</a>
    <a name="menu" ng-if="button.buttons" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"><span class="caret"></span> {{translateTitle(button)}} <span class="caret"></span></a>
    <ul class="dropdown-menu" role="menu">
      <li ng-repeat="button in button.buttons" ng-include="'menubutton.html'" />
    </ul>
  </script>

  <!-- Language choice -->
  <script type="text/ng-template" id="languages.html">
    <a name="languages" class="link">
      <span ng-repeat="lang in availableLanguages">
        <img ng-src="<TMPL_VAR NAME="STATIC_PREFIX">logos/{{lang}}.png" width="16px" height="11px" ng-click="getLanguage(lang)"/>
      </span>
    </a>
  </script>



<!-- Constants -->
<script type="text/JavaScript">
  var staticPrefix = '<TMPL_VAR NAME="STATIC_PREFIX">'.replace(/\/*$/,'/');
  var formPrefix = staticPrefix+'forms/';
  var scriptname='<TMPL_VAR NAME="SCRIPT_NAME">'.replace(/^$/,'.').replace(/\/*$/,'/');
  var confPrefix=scriptname+'confs/';
  var availableLanguages='<TMPL_VAR NAME="AVAILABLE_LANGUAGES">'.split(/[,;] */);
  var links=<TMPL_VAR NAME="LINKS">;
  var menulinks=<TMPL_VAR NAME="MENULINKS">;
</script>

<!-- //if:jsminified
<script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/jquery/dist/jquery.min.js"></script>
<script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/es5-shim/es5-shim.min.js"></script>
<script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/bootstrap/dist/js/bootstrap.min.js"></script>
<script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/angular/angular.min.js"></script>
<script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/angular-ui-tree/dist/angular-ui-tree.min.js"></script>
<script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">js/ui-bootstrap-tpls-0.12.1.min.js"></script>
<script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">js/llApp.min.js"></script>
//else -->
<script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/jquery/dist/jquery.js"></script>
<script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/es5-shim/es5-shim.js"></script>
<script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/bootstrap/dist/js/bootstrap.js"></script>
<script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/angular/angular.js"></script>
<script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/angular-ui-tree/dist/angular-ui-tree.js"></script>
<script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">js/ui-bootstrap-tpls-0.12.1.min.js"></script>
<script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">js/llApp.js"></script>
<!-- //endif -->
