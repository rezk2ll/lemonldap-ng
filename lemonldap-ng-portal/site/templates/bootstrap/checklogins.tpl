
    <TMPL_IF NAME="CHECK_LOGINS">
    <div class="checkbox">
      <label for="checkLogins">
        <input type="checkbox" id="checkLogins" name="checkLogins" <TMPL_IF NAME="ASK_LOGINS">checked</TMPL_IF> />
        <span trspan="checkLastLogins">Check my last logins</span>
      </label>
    </div>
    </TMPL_IF>
    <TMPL_IF NAME="STAYCONNECTED">
    <div class="checkbox">
      <label for="stayconnected">
        <input type="checkbox" id="stayconnected" name="stayconnected" />
        <span trspan="stayConnected">Stay connected on this device</span>
      </label>
    </div>
    </TMPL_IF>
