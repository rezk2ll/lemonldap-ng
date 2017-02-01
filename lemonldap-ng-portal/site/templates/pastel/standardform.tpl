<h3 trspan="enterCred">Please enter your credentials</h3>

<table>
  <tr><th><span trspan="login">Login</span></th>
    <td><input name="user" type="text" value="<TMPL_VAR NAME="LOGIN">" tabindex="1" /></td>
  </tr>
  <tr><th><span trspan="password">Password</span></th>
    <td><input name="password" type="password" tabindex="2" /></td>
  </tr>

  <TMPL_IF NAME="CAPTCHA_SRC">
    <tr><td></td><td>
      <img src="<TMPL_VAR NAME="CAPTCHA_SRC">" />
    </td></tr>
    <tr><th><span trspan="captcha">Captcha</span></th>
      <td><input type="text" name="captcha" size="<TMPL_VAR NAME="CAPTCHA_SIZE">" tabindex="3" /></td>
    </tr>
  </TMPL_IF>
  <TMPL_IF NAME="TOKEN">
    <input type="hidden" name="token" value="<TMPL_VAR NAME="TOKEN">" />
  </TMPL_IF>

  <TMPL_IF NAME="CHECK_LOGINS">
    <tr><td colspan="2"><div class="buttons">
      <label for="checkLogins">
        <input type="checkbox" id="checkLogins" name="checkLogins" <TMPL_IF NAME="ASK_LOGINS">checked</TMPL_IF> tabindex="4" />
        <span trspan="checkLastLogins">Check my last logins</span>
      </label>
    </div></td></tr>
  </TMPL_IF>

  <tr><td colspan="2">
    <div class="buttons">
      <button type="reset" class="negative" tabindex="10">
        <img src="<TMPL_VAR NAME="STATIC_PREFIX">common/cancel.png" alt="" />
        <span trspan="cancel">Cancel</span>
      </button>
      <button type="submit" class="positive" tabindex="8">
        <img src="<TMPL_VAR NAME="STATIC_PREFIX">common/accept.png" alt="" />
        <span trspan="connect">Connect</span>
      </button>
    </div>
  </td></tr>

  <TMPL_IF NAME="DISPLAY_RESETPASSWORD">
    <tr><td colspan="2">
      <div class="buttons">
        <a class="positive" tabindex="5" href="<TMPL_VAR NAME="MAIL_URL">?skin=<TMPL_VAR NAME="SKIN"><TMPL_IF NAME="key">&<TMPL_VAR NAME="CHOICE_PARAM">=<TMPL_VAR NAME="key"></TMPL_IF>">
          <img src="<TMPL_VAR NAME="STATIC_PREFIX">common/email.png" alt="" />
          <span trspan="resetPwd">Reset my password</span>
        </a>
      </div>
    </td></tr>
  </TMPL_IF>

  <TMPL_IF NAME="DISPLAY_REGISTER">
    <tr><td colspan="2">
      <div class="buttons">
        <a class="positive" tabindex="6" href="<TMPL_VAR NAME="REGISTER_URL">?skin=<TMPL_VAR NAME="SKIN"><TMPL_IF NAME="key">&<TMPL_VAR NAME="CHOICE_PARAM">=<TMPL_VAR NAME="key"></TMPL_IF>">
          <img src="<TMPL_VAR NAME="STATIC_PREFIX">common/vcard_edit.png" alt="" />
          <span trspan="createAccount">Create an account</span>
        </a>
      </div>
    </td></tr>
  </TMPL_IF>


</table>
