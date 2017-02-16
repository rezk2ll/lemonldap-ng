<TMPL_INCLUDE NAME="header.tpl">

  <div id="content">

    <TMPL_IF AUTH_LOOP>

    <!-- Authentication loop -->
    <div id="content-left">

      <TMPL_INCLUDE NAME="authmessage.tpl">

      <TMPL_IF NAME="LOGIN_INFO">
      <div>
        <TMPL_VAR NAME="LOGIN_INFO">
      </div>
      </TMPL_IF>

    </div>

    <div id="content-right">

      <h1 trspan="openSSOSession">Open your SSO session</h1>
      <hr class="solid" />
      <TMPL_IF NAME="AUTH_ERROR">
      <p><span class="text-error" trmsg="<TMPL_VAR NAME="AUTH_ERROR">"></span> <span id="languages"></span></p>
      </TMPL_IF>

      <!-- tabs -->
      <div id="authMenu">
      <ul>
        <TMPL_LOOP NAME="AUTH_LOOP">
        <li title="<TMPL_VAR NAME="key">"><a href="#<TMPL_VAR NAME="key">"><TMPL_VAR NAME="name"></a></li>
        </TMPL_LOOP>
      </ul>

      <!-- Forms -->
      <TMPL_LOOP NAME="AUTH_LOOP">

      <div id="<TMPL_VAR NAME="key">">

      <form action="<TMPL_VAR NAME="url">" method="post" class="login <TMPL_IF NAME="module"><TMPL_VAR NAME="module"></TMPL_IF>">

      <!-- Hidden fields -->
      <TMPL_VAR NAME="HIDDEN_INPUTS">
      <input type="hidden" name="url" value="<TMPL_VAR NAME="AUTH_URL">" />
      <input type="hidden" name="timezone" />
      <input type="hidden" id="authKey" name="<TMPL_VAR NAME="CHOICE_PARAM">" value="<TMPL_VAR NAME="key">" />

      <TMPL_IF NAME="standardform">

      <TMPL_INCLUDE NAME="standardform.tpl">

      </TMPL_IF>

      <TMPL_IF NAME="openidform">

      <TMPL_INCLUDE NAME="openidform.tpl">

      </TMPL_IF>

      <TMPL_IF NAME="yubikeyform">

      <TMPL_INCLUDE NAME="yubikeyform.tpl">

      </TMPL_IF>

      <TMPL_IF NAME="logo">

        <TMPL_IF NAME="logoFile">
        <div class="authLogo">
        <img src="<TMPL_VAR NAME="STATIC_PREFIX">common/<TMPL_VAR NAME="logoFile">" alt="<TMPL_VAR NAME="module">" />
        </div>
        </TMPL_IF>

        <TMPL_IF NAME="CHECK_LOGINS">
        <p>
        <label for="checkLogins">
            <input type="checkbox" id="checkLogins" name="checkLogins" <TMPL_IF NAME="ASK_LOGINS">checked</TMPL_IF>/>
            <span trspan="checkLastLogins">Check my last logins</span>
        </label>
        </p>
        </TMPL_IF>

        <hr class="solid" />
        <div class="panel-buttons">
          <button type="reset" class="negative" tabindex="4">
            <span trspan="cancel">Cancel</span>
          </button>
          <button type="submit" class="positive" tabindex="3">
            <span trspan="connect">Connect</span>
          </button>
        </div>

      </TMPL_IF>

      </form>

      </div>

      </TMPL_LOOP>
      </div> <!-- end authloop -->

    </div>

      </TMPL_IF>

    <TMPL_IF NAME="DISPLAY_FORM">

    <div id="content-left">

      <TMPL_INCLUDE NAME="authmessage.tpl">

      <TMPL_IF NAME="LOGIN_INFO">
      <div>
        <TMPL_VAR NAME="LOGIN_INFO">
      </div>
      </TMPL_IF>

    </div>

    <div id="content-right">
      <h1 trspan="openSSOSession">Open your SSO session</h1>
      <hr class="solid" />
      <TMPL_IF NAME="AUTH_ERROR">
      <p><span class="text-error" trmsg="<TMPL_VAR NAME="AUTH_ERROR">"></span> <span id="languages"></span></p>
      </TMPL_IF>
      <form action="#" method="post" class="login">
        <TMPL_VAR NAME="HIDDEN_INPUTS">
        <input type="hidden" name="url" value="<TMPL_VAR NAME="AUTH_URL">" />
        <input type="hidden" name="timezone" />
        <TMPL_INCLUDE NAME="standardform.tpl">
      </form>
    </div>

    </TMPL_IF>

    <TMPL_IF NAME="DISPLAY_OPENID_FORM">

    <div id="content-left">

      <TMPL_INCLUDE NAME="authmessage.tpl">

      <TMPL_IF NAME="LOGIN_INFO">
      <div>
        <TMPL_VAR NAME="LOGIN_INFO">
      </div>
      </TMPL_IF>

    </div>

    <div id="content-right">
      <h1 trspan="openSSOSession">Open your SSO session</h1>
      <hr class="solid" />
      <TMPL_IF NAME="AUTH_ERROR">
      <p><span class="text-error" trmsg="<TMPL_VAR NAME="AUTH_ERROR">"></span> <span id="languages"></span></p>
      </TMPL_IF>
      <form action="#" method="post" class="login">
        <TMPL_VAR NAME="HIDDEN_INPUTS">
        <input type="hidden" name="url" value="<TMPL_VAR NAME="AUTH_URL">" />
        <input type="hidden" name="timezone" />
        <TMPL_INCLUDE NAME="openidform.tpl">
      </form>
    </div>

    </TMPL_IF>

    <TMPL_IF NAME="DISPLAY_YUBIKEY_FORM">

    <div id="content-left">

      <TMPL_INCLUDE NAME="authmessage.tpl">

      <TMPL_IF NAME="LOGIN_INFO">
      <div>
        <TMPL_VAR NAME="LOGIN_INFO">
      </div>
      </TMPL_IF>

    </div>

    <div id="content-right">
      <h1 trspan="openSSOSession">Open your SSO session</h1>
      <hr class="solid" />
      <TMPL_IF NAME="AUTH_ERROR">
      <p><span class="text-error" trmsg="<TMPL_VAR NAME="AUTH_ERROR">"></span> <span id="languages"></span></p>
      </TMPL_IF>
      <form action="#" method="post" class="login">
        <TMPL_VAR NAME="HIDDEN_INPUTS">
        <input type="hidden" name="url" value="<TMPL_VAR NAME="AUTH_URL">" />
        <input type="hidden" name="timezone" />
        <TMPL_INCLUDE NAME="yubikeyform.tpl">
      </form>
    </div>

    </TMPL_IF>

    <TMPL_IF NAME="DISPLAY_LOGO_FORM">

    <div id="content-left">

      <TMPL_INCLUDE NAME="authmessage.tpl">

      <TMPL_IF NAME="LOGIN_INFO">
      <div>
        <TMPL_VAR NAME="LOGIN_INFO">
      </div>
      </TMPL_IF>

    </div>

    <div id="content-right">
      <h1 trspan="openSSOSession">Open your SSO session</h1>
      <hr class="solid" />
      <TMPL_IF NAME="AUTH_ERROR">
      <p><span class="text-error" trmsg"<TMPL_VAR NAME="AUTH_ERROR">"></span> <span id="languages"></span></p>
      </TMPL_IF>
      <form action="#" method="post" class="login <TMPL_VAR NAME="module">">
        <TMPL_VAR NAME="HIDDEN_INPUTS">
        <input type="hidden" name="url" value="<TMPL_VAR NAME="AUTH_URL">" />
        <input type="hidden" name="timezone" />

        <table>
                <TMPL_IF NAME="module">
                <tr class="authLogo"><td>
                <img src="<TMPL_VAR NAME="STATIC_PREFIX">common/<TMPL_VAR NAME="module">.png" />
                </td></tr>
                </TMPL_IF>

                <TMPL_IF NAME="CHECK_LOGINS">
                <tr><td colspan="2"><div class="buttons">
                <label for="checkLogins">
                    <input type="checkbox" id="checkLogins" name="checkLogins" <TMPL_IF NAME="ASK_LOGINS">checked</TMPL_IF>/>
                    <span trspan="checkLastLogins:">Check my last logins</span>
                </label>
                </div></td></tr>
                </TMPL_IF>

                <tr><td>
                <div class="buttons">
                <button type="reset" class="negative" tabindex="4">
                        <img src="<TMPL_VAR NAME="STATIC_PREFIX">common/cancel.png" alt="" />
                        <span trspan="cancel">Cancel</span>
                </button>
                <button type="submit" class="positive" tabindex="3">
                        <img src="<TMPL_VAR NAME="STATIC_PREFIX">common/accept.png" alt="" />
                        <span trspan="connect">Connect</span>
                </button>
                </div></td></tr>

        </table>
      </form>
    </div>

    </TMPL_IF>

    <TMPL_IF NAME="DISPLAY_PASSWORD">

      <div id="content-all">
      <div class="title">
        <img src="<TMPL_VAR NAME="STATIC_PREFIX">/<TMPL_VAR NAME="SKIN">/images/logo-info.png" />
        <span trspan="pwdChange">Password change</span>
      </div>
      <hr class="solid" />
      <TMPL_IF NAME="AUTH_ERROR">
      <p class="text-error" trmsg="<TMPL_VAR NAME="AUTH_ERROR">"> <span id="languages"></span></p>
      </TMPL_IF>
      <TMPL_INCLUDE NAME="password.tpl">
      </div>

    </TMPL_IF>

    <TMPL_IF NAME="PORTAL_URL">
    <div id="content-all">
      <div class="title">
        <img src="<TMPL_VAR NAME="STATIC_PREFIX">/<TMPL_VAR NAME="SKIN">/images/logo-info.png" />
        <span trspan="SSOSessionInactive">SSO session inactive</span>
      </div>
      <hr class="solid" />
      <TMPL_IF NAME="AUTH_ERROR">
      <p class="text-error" trmsg="<TMPL_VAR NAME="AUTH_ERROR">"> <span id="languages"></span></p>
      </TMPL_IF>
      <TMPL_IF NAME="MSG">
      <div id="content-all-info">
        <TMPL_VAR NAME="MSG">
      </div>
      </TMPL_IF>
      <p>
        <img src="<TMPL_VAR NAME="STATIC_PREFIX">/<TMPL_VAR NAME="SKIN">/images/arrow.png" /><a href="<TMPL_VAR NAME="PORTAL_URL">" class="positive"><span trspan="goToPortal">Go to portal</span></a>
      </p>
    </div>
    </TMPL_IF>

    <TMPL_IF NAME="LOGOUT_URL">
    <div id="content-all">
      <div class="title">
        <img src="<TMPL_VAR NAME="STATIC_PREFIX">/<TMPL_VAR NAME="SKIN">/images/logo-info.png" />
        <span trspan="closeSSO">Close your SSO session</span>
      </div>
      <hr class="solid" />
      <TMPL_IF NAME="AUTH_ERROR">
      <p class="text-error" trmsg="<TMPL_VAR NAME="AUTH_ERROR">"> <span id="languages"></span></p>
      </TMPL_IF>
      <p>
        <img src="<TMPL_VAR NAME="STATIC_PREFIX">/<TMPL_VAR NAME="SKIN">/images/arrow.png" /><a href="<TMPL_VAR NAME="LOGOUT_URL">" class="negative"><span trspan="logout">Logout</span></a>
      </p>
    </div>
    </TMPL_IF>

  </div>

<TMPL_INCLUDE NAME="footer.tpl">

