<nav class="navbar navbar-inverse navbar-fixed-top" role="navigation">
  <div class="container-fluid">
    <div class="navbar-header">
      <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#manager-menu">
        <span class="sr-only">Toggle navigation</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </button>
      <a class="navbar-brand" href="<TMPL_VAR NAME="SCRIPT_NAME">">
	<img src="<TMPL_VAR NAME="DIR">/images/logo_lemonldap-ng.png" alt="LemonLDAP::NG" class="brand"/>
      </a>
    </div>
    <div class="collapse navbar-collapse" id="manager-menu">
      <ul class="nav navbar-nav">
        <li><a href="index.pl"><i class="glyphicon glyphicon-cog"></i> <lang en="Configuration" fr="Configuration"/></a></li>
        <li><a href="sessions.pl"><i class="glyphicon glyphicon-user"></i> <lang en="Sessions" fr="Sessions"/></a></li>
        <li><a href="notifications.pl"><i class="glyphicon glyphicon-bell"></i> <lang en="Notifications" fr="Notifications"/></a></li>
      </ul>
      <ul class="nav navbar-nav navbar-right">
        <li class="dropdown">
          <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false">Menu <span class="caret"></span></a>
          <ul class="dropdown-menu" role="menu">
            <li role="presentation" class="dropdown-header"><lang en="Organization" fr="Organisation" /></li>
            <li><a href="#"><span class="css-switch" alt="tree"><i class="glyphicon glyphicon-list"></i> <lang en="Tree" fr="Arbre" /></span></a></li>
            <li><a href="#"><span class="css-switch" alt="accordion"><i class="glyphicon glyphicon-align-justify"></i> <lang en="Accordion" fr="Accordéon" /></span></a></li>
            <li role="presentation" class="divider"></li>
            <li><a href="<TMPL_VAR NAME="PORTAL_URL">"><i class="glyphicon glyphicon-home"></i> <lang en="Portal" fr="Portail" /></a></li>
            <li><a href="<TMPL_VAR NAME="PORTAL_URL">?logout=1"><i class="glyphicon glyphicon-off"></i> <lang en="Logout" fr="Déconnexion" /></a></li>
            <TMPL_IF NAME="VERSION">
            <li role="presentation" class="divider"></li>
            <li role="presentation" class="dropdown-header"><i class="glyphicon glyphicon-info-sign"></i> Version <TMPL_VAR NAME="VERSION"></li>
            </TMPL_IF>
          </ul>
        </li>
      </ul>
    </div>
  </div>
</nav>
