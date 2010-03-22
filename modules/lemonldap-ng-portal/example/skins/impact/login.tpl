<TMPL_INCLUDE NAME="header.tpl">

  <div id="content">
    <div id="content-left">
      <p><img src="/skins/<TMPL_VAR NAME="SKIN">/images/logo-lock.png" /></p>
      <h1>
        <lang en="Welcome on your secured authentication portal." fr="Bienvenue sur votre portail d'authentification s&eacute;curis&eacute;e." />
      </h1>
      <p>
        <lang en="This space allow you to open a SSO session. This will help you to securely access to all applications authorized by your profil." fr="Cet espace vous permet d'ouvrir une session SSO. Celle-ci vous aidera &agrave; acc&eacute;der de mani&egrave;re totalement s&eacute;curis&eacute;e &agrave; l'ensemble des applications autoris&eacute;es par votre profil utilisateur." />
      </p>
    </div>
    <div id="content-right">
      <h1><lang en="Open your SSO session" fr="Ouvrir une session SSO" /></h1>
      <hr class="solid" />
      <p><span class="text-error"><TMPL_VAR NAME="AUTH_ERROR"></span></p>
      <form action="#" method="post" class="login">
        <input type="hidden" name="url" value="" />
        <input type="hidden" name="timezone" />
        <p>
          <span class="text-label"><lang en="Login" fr="Identifiant de compte"/></span><br/>
          <input name="user" type="text" value="" tabindex="1" /><br/>
          <span class="text-help">(<lang en="for example: jdoe" fr="par exemple: toto"/>)</span>
        </p>
        <p>
          <span class="text-label"><lang en="Password" fr="Mot de passe"/></span><br/>
          <input name="password" type="password" tabindex="2" /><br/>
        </p>
        <hr class="solid" />
        <div class="panel-buttons">
          <button type="reset" class="negative" tabindex="4">
            <lang en="Cancel" fr="Annuler" />
          </button>
          <button type="submit" class="positive" tabindex="3">
            <lang en="Connect" fr="Se connecter" />
          </button>
        </div>
      </form>
      <TMPL_IF NAME="DISPLAY_RESETPASSWORD">
      <p>
        <img src="/skins/<TMPL_VAR NAME="SKIN">/images/arrow.png" /><a href="<TMPL_VAR NAME="MAIL_URL">"><lang en="Reset my password" fr="R&eacute;initialiser mon mot de passe"/></a>
      </p>
      </TMPL_IF>
    </div>
  </div>

<TMPL_INCLUDE NAME="footer.tpl">

