  <!-- Menu bar -->
  <header id="navbar" role="banner">
    <nav class="navbar container navbar-default">
      <div class="container-fluid">
        <!-- XS buttons -->
        <div class="navbar-header">
          <span class="navbar-brand">
            <img ng-click="home()" class="link hidden-xs" height="32px" src="<TMPL_VAR NAME="STATIC_PREFIX">logos/llng.png"/>
            <img ng-click="home()" class="link visible-xs" height="32px" src="<TMPL_VAR NAME="STATIC_PREFIX">logos/llng-icon-32.png"/>
          </span>
          <button type="button" class="navbar-toggle" ng-click="showM=!showM">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <button type="button" class="navbar-toggle" ng-click="showT=!showT">
            <span class="link" ng-hide="showT" trspan="browseTree"></span>
            <span class="link" ng-show="showT" trspan="hideTree"></span>
          </button>
          <!-- Last buttons, available languages -->
        </div>
        <ul class="hidden-xs nav navbar-nav">
          <li ng-repeat="link in links"><a href="{{link.target}}">{{translate(link.title)}}</a></li>
        </ul>
        <ul class="hidden-xs nav navbar-nav navbar-right">
          <li ng-include="'languages.html'"/>
        </ul>
      </div>
    </nav>
  </header>
