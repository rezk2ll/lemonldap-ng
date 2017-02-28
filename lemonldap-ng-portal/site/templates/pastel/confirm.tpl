<TMPL_INCLUDE NAME="header.tpl">

<div id="logincontent">

  <div class="message warning"><ul><li><span trspan="confirmation">Confirmation</span></li></ul></div>

  <div class="loginlogo"></div>

  <form id="form" action="#" method="<TMPL_VAR NAME="FORM_METHOD">" class="login">

    <TMPL_VAR NAME="MSG">

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
    <input type="hidden" name="skin" value="<TMPL_VAR NAME="SKIN">" />

    <TMPL_IF NAME="LIST">

      <h3 trspan="selectIdP">Select your Identity Provider</h3>
      <input type="hidden" id="idp" name="idp"/>
      <table>
      <TMPL_LOOP NAME="LIST">
        <tr><td><div class="buttons">
          <button type="submit" class="idploop positive maxw" val="<TMPL_VAR NAME="VAL">">
            <TMPL_VAR NAME="NAME">
          </button>
        </div></td></tr>

      </TMPL_LOOP>
        <tr>
          <td><input type="checkbox" id="remember" name="cookie_type" value="1"><label for="remember"><span trspan="rememberChoice">Remember my choice</span></label>

    <TMPL_ELSE>

      <TMPL_IF NAME="ACTIVE_TIMER">
        <p id="timer"><span trspan="autoAccept">Automatically accept in 5 seconds</span></p>
        <!-- //if:jsminified
          <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">common/js/info.min.js"></script>
        //else -->
          <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">common/js/info.js"></script>
        <!-- //endif -->
      </TMPL_IF>

      <table><tr><td>
      <div class="buttons">
        <button type="submit" class="positive">
          <img src="<TMPL_VAR NAME="STATIC_PREFIX">common/accept.png" alt="" />
          <span trspan="accept">Accept</span>
        </button>
          <button id="refuse" type="submit" class="negative" tabindex="4" val="-<TMPL_VAR NAME="CONFIRMKEY">">
          <img src="<TMPL_VAR NAME="STATIC_PREFIX">common/cancel.png" alt="" />
          <span trspan="refuse">Refuse</span>
        </button>
      </div>

    </TMPL_IF>

    <TMPL_IF NAME="CHECK_LOGINS">
    <div class="buttons">
      <input type="checkbox" id="checkLogins" name="checkLogins" <TMPL_IF NAME="ASK_LOGINS">checked</TMPL_IF>/>
      <label for="checkLogins">
        <span trspan="checkLastLogins">Check my last logins</span>
      </label>
    </div>
    </TMPL_IF>

    </td></tr></table>
  </form>

</div>

<TMPL_INCLUDE NAME="footer.tpl">
