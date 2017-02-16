        <p>
          <span class="text-label"><span trspan="login">Login</span></span><br/>
          <input name="user" type="text" value="<TMPL_VAR NAME="LOGIN">" tabindex="1" /><br/>
        </p>
        <p>
          <span class="text-label"><span trspan="pwd">Password</span></span><br/>
          <input name="password" type="password" tabindex="2" /><br/>
        </p>

        <TMPL_IF NAME=CAPTCHA_SRC>
	<p>
          <img src="<TMPL_VAR NAME=CAPTCHA_SRC>" />
        </p>
        <p>
          <span class="text-label"><span trspan="captcha">Captcha</span></span><br />
          <input type="text" name="captcha" size="<TMPL_VAR NAME=CAPTCHA_SIZE>" tabindex="3" /><br />
        </p>
        </TMPL_IF>
        <TMPL_IF NAME="TOKEN">
          <input type="hidden" name="token" value="<TMPL_VAR NAME="TOKEN">" />
        </TMPL_IF>

        <TMPL_IF NAME="CHECK_LOGINS">
        <p>
        <label for="checkLogins">
            <input type="checkbox" id="checkLogins" name="checkLogins" <TMPL_IF NAME="ASK_LOGINS">checked</TMPL_IF> tabindex="4" />
            <span trspan="checkLastLogins">Check my last logins</span>
        </label>
        </p>
        </TMPL_IF>

        <hr class="solid" />
        <div class="panel-buttons">
          <button type="reset" class="negative" tabindex="10">
            <span trspan="cancel">Cancel</span>
          </button>
          <button type="submit" class="positive" tabindex="8">
            <span trspan="connect">Connect</span>
          </button>
        </div>

      <TMPL_IF NAME="DISPLAY_RESETPASSWORD">
      <p>
        <img src="<TMPL_VAR NAME="STATIC_PREFIX">/<TMPL_VAR NAME="SKIN">/images/arrow.png" /><a href="<TMPL_VAR NAME="MAIL_URL">?skin=<TMPL_VAR NAME="SKIN"><TMPL_IF NAME="key">&<TMPL_VAR NAME="CHOICE_PARAM">=<TMPL_VAR NAME="key"></TMPL_IF>"><span trspan="resetPwd">Reset my password</span></a>
      </p>
      </TMPL_IF>

      <TMPL_IF NAME="DISPLAY_REGISTER">
      <p>
        <img src="<TMPL_VAR NAME="STATIC_PREFIX">/<TMPL_VAR NAME="SKIN">/images/arrow.png" /><a href="<TMPL_VAR NAME="REGISTER_URL">?skin=<TMPL_VAR NAME="SKIN"><TMPL_IF NAME="key">&<TMPL_VAR NAME="CHOICE_PARAM">=<TMPL_VAR NAME="key"></TMPL_IF>"><span trspan="createAccount">Create an account</span></a>
      </p>
      </TMPL_IF>

