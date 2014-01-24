

  <div class="form-group">
    <input name="user" type="text" value="<TMPL_VAR NAME="LOGIN">" class="form-control" placeholder="<lang en="Login" fr="Identifiant"/>" required />
  </div>

  <div class="form-group">
    <input name="password" type="password" class="form-control" placeholder="<lang en="Password" fr="Mot de passe"/>" required />
  </div>

  <TMPL_IF NAME=CAPTCHA_IMG>
  <div class="form-group">
    <img src="<TMPL_VAR NAME=CAPTCHA_IMG>" class="img-thumbnail" />
  </div>
  <div class="form-group">
    <input type="text" name="captcha_user_code" size="<TMPL_VAR NAME=CAPTCHA_SIZE>" class="form-control" placeholder="Captcha" required />
    <input type="hidden" name="captcha_code" value="<TMPL_VAR NAME=CAPTCHA_CODE>" />
  </div>
  </TMPL_IF>

  <TMPL_IF NAME="CHECK_LOGINS">
  <div class="checkbox">
      <label for="checkLogins">
        <input type="checkbox" id="checkLogins" name="checkLogins" <TMPL_IF NAME="ASK_LOGINS">checked</TMPL_IF> />
        <lang en="Check my last logins" fr="Voir mes dernières connexions"/>
      </label>
  </div>
  </TMPL_IF>

  <button type="submit" class="btn btn-block btn-success" >
    <span class="glyphicon glyphicon-log-in"></span>
    <lang en="Connect" fr="Se connecter" />
  </button>

  <TMPL_IF NAME="DISPLAY_RESETPASSWORD">
  <a class="btn btn-block btn-info" href="<TMPL_VAR NAME="MAIL_URL"><TMPL_IF NAME="key">?<TMPL_VAR NAME="CHOICE_PARAM">=<TMPL_VAR NAME="key"></TMPL_IF>">
    <span class="glyphicon glyphicon-info-sign"></span>
    <lang en="Reset my password" fr="R&eacute;initialiser mon mot de passe"/>
  </a>
  </TMPL_IF>

