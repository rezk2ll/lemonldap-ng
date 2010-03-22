<TMPL_INCLUDE NAME="header.tpl">

  <div id="content">
    <div id="content-all">
      <div class="title">
        <img src="/skins/<TMPL_VAR NAME="SKIN">/images/logo-ok.png" />
        <TMPL_VAR NAME="AUTH_ERROR">
      </div>
      <hr class="solid" />
      <p>
        <span class="text-error"><lang en="Connected as" fr="Connect&eacute; en tant que" />: <u><TMPL_VAR NAME="AUTH_USER"></u></span>
      </p>
      <TMPL_IF NAME="DISPLAY_APPSLIST">
      <div id="content-all-info">
        <span class="text-label"><lang en="Choose an application your are allowed to access to" fr="Choisissez une application &agrave; laquelle vous &ecirc;tes autoris&eacute;es &agrave; acc&eacute;der" /> :</span>
        <p></p>
        <div id="appslist">
          <TMPL_VAR NAME="APPSLIST_MENU">
          <TMPL_VAR NAME="APPSLIST_DESC">
        </div>
      </div>
      </TMPL_IF>
      <ul class="nostyle" style="float:left;">
        <TMPL_IF NAME="DISPLAY_PASSWORD">
        <li><img src="/skins/<TMPL_VAR NAME="SKIN">/images/arrow.png" /><a href="#"><lang en="Reset password" fr="Changer de mot de passe" /></a></li>
        </TMPL_IF>
        <TMPL_IF NAME="DISPLAY_LOGOUT">
        <li><img src="/skins/<TMPL_VAR NAME="SKIN">/images/arrow.png" /><a href="#" onclick="showLogoutBox('<TMPL_VAR NAME="LOGOUT_URL">');"><lang en="Logout" fr="Se d&eacute;connecter" /></a></li>
        </TMPL_IF>
      </ul>
    </div>
  </div>

<TMPL_INCLUDE NAME="footer.tpl">

