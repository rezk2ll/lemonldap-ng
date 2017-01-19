<TMPL_INCLUDE NAME="header.tpl">

  <div id="content">
    <div id="content-all">
      <div class="title">
        <img src="<TMPL_VAR NAME="SKIN_PATH">/<TMPL_VAR NAME="SKIN">/images/logo-info.png" />
        <span trspan="confirmation">Confirmation</span>
      </div>
      <hr class="solid" />

      <TMPL_UNLESS NAME="LIST"><TMPL_IF NAME="ACTIVE_TIMER">
      <p id="timer" class="text-error"><span trspan="autoAccept">Automaticaly accept in 5 seconds</span></p>
      <!-- //if:jsminified
        <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">common/js/info.min.js"></script>
      //else -->
        <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">common/js/info.js"></script>
      <!-- //endif -->
      </TMPL_IF></TMPL_UNLESS>

      <form id="form" action="#" method="<TMPL_VAR NAME="FORM_METHOD">" class="login">
        <TMPL_VAR NAME="HIDDEN_INPUTS">
        <TMPL_IF NAME="AUTH_URL">
        <input type="hidden" name="url" value="<TMPL_VAR NAME="AUTH_URL">" />
        </TMPL_IF>
        <TMPL_IF NAME="CHOICE_VALUE">
        <input type="hidden" id="authKey" name="<TMPL_VAR NAME="CHOICE_PARAM">" value="<TMPL_VAR NAME="CHOICE_VALUE">" />
        </TMPL_IF>
        <TMPL_IF NAME="CONFIRMKEY">
        <input type="hidden" id="confirm" name="confirm" value="<TMPL_VAR NAME="CONFIRMKEY">" />
        </TMPL_IF>

        <TMPL_IF NAME="MSG">
        <div id="content-all-info">
          <TMPL_VAR NAME="MSG">
        </div>
        </TMPL_IF>

        <TMPL_IF NAME="LIST">

        <h3 trspan="selectIdP">Select your Identity Provider</h3>
        <input type="hidden" id="idp" name="idp"/>
        <table class="margin0">
        <TMPL_LOOP NAME="LIST">
          <tr><td><div class="buttons">
            <button type="submit" class="idploop positive maxw" val="<TMPL_VAR NAME="VAL">">
              <TMPL_VAR NAME="NAME">
            </button>
          </div></td></tr>
    
        </TMPL_LOOP>

          <tr><td>
            <input type="checkbox" id="remember" name="cookie_type" value="1">
            <label for="remember"><span trspan="rememberChoice">Remember my choice</span></label>
          </td></tr>

        <TMPL_ELSE>

        <table class="margin0">
          <tr><td><div class="panel-buttons">
          <button id="refuse" type="submit" class="negative" tabindex="4" val="-<TMPL_VAR NAME="CONFIRMKEY">">
            <span trspan="refuse">Refuse</span>
          </button>
          <button type="submit" class="positive" tabindex="3">
            <span trspan="accept">Accept</span>
          </button>
          </div></td></tr>

        </TMPL_IF>

        <TMPL_IF NAME="CHECK_LOGINS">
        <tr><td>
          <input type="checkbox" id="checkLogins" name="checkLogins" <TMPL_IF NAME="ASK_LOGINS">checked</TMPL_IF>/>
          <label for="checkLogins">
            <span trspan="checkLastLogins">Check my last logins</span>
          </label>
        </td></tr>
        </TMPL_IF>

        </table>
      </form>
    </div>
  </div>

<TMPL_INCLUDE NAME="footer.tpl">

