<!-- Tree CSS choice -->
<div id="css-switch" title="<lang en="Menu style" fr="Style de menu" />">
   <div id="organization">
   <p class="ui-widget-header ui-corner-all"><lang en="Organization" fr="Organisation" /></p>
   <button alt="tree"><lang en="Tree" fr="Arbre" /></button>
   <button alt="accordion"><lang en="Accordion" fr="Accordéon" /></button>
   </div>
   <div id="theme">
   <p class="ui-widget-header ui-corner-all"><lang en="Theme" fr="Thème" /></p>
   <button alt="ui-lightness"><lang en="Lightness" fr="Lumineux" /></button>
   <button alt="ui-darkness"><lang en="Darkness" fr="Obscur" /></button>
   </div>
</div>

<!-- Header -->
<div id="header">
   <a href="index.pl" class="configuration"><lang en="Configuration" fr="Configuration"/></a>
   <a href="sessions.pl" class="sessions"><lang en="Sessions" fr="Sessions"/></a>
   <a href="notifications.pl" class="notifications"><lang en="Notifications" fr="Notifications"/></a>
   <span id="css-switch-link"><lang en="Menu" fr="Menu" /></span>
   <a href="<TMPL_VAR NAME="PORTAL_URL">" class="portal"><lang en="Portal" fr="Portail" /></a>
   <a href="<TMPL_VAR NAME="PORTAL_URL">?logout=1" class="logout"><lang en="Logout" fr="Déconnexion" /></a>
<!-- Header -->
</div>

<TMPL_IF NAME="VERSION"><div id="version">Version <TMPL_VAR NAME="VERSION"></div></TMPL_IF>

