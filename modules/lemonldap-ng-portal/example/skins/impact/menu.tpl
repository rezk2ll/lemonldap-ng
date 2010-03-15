<TMPL_INCLUDE NAME="header.tpl">

  <div id="content">
    <div id="content-all">
      <div class="title">
        <img src="/skins/<TMPL_VAR NAME="SKIN">/images/logo-ok.png" />
        <TMPL_VAR NAME="AUTH_ERROR">
      </div>
      <p>
        <span class="text-error"><lang en="Connected as" fr="Connect&eacute; en tant que" />: <u><TMPL_VAR NAME="AUTH_USER"></u></span>
        <TMPL_IF NAME="DISPLAY_PASSWORD">
        -
        <a href="#password"><lang en="Reset password" fr="Changer de mot de passe" /></span></a>
        </TMPL_IF>
        <TMPL_IF NAME="DISPLAY_LOGOUT">
        -
        <a href="#logout"><lang en="Logout" fr="Se d&eacute;connecter" /></a>
        </TMPL_IF>
      </p>
      <p><lang en="Here are applications your are allowed to access to." fr="Voici la liste des applications auxquelles vous êtes autoris&eacute;es &agrave; acc&eacute;der." /></p>
      <TMPL_IF NAME="DISPLAY_APPSLIST">
      <div id="content-all-info">
        <div id="appslist">
          <TMPL_VAR NAME="APPSLIST_MENU">
          <!-- <TMPL_VAR NAME="APPSLIST_DESC"> -->
        </div>
      </div>
      </TMPL_IF>
    </div>
  </div>

<TMPL_INCLUDE NAME="footer.tpl">

