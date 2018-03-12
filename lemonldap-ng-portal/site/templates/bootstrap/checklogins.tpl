
    <TMPL_IF NAME="CHECK_LOGINS">
    <div class="form-group input-group">
      <span class="input-group-addon">
        <input type="checkbox" id="checkLogins" name="checkLogins" aria-describedby="checkLoginsLabel" <TMPL_IF NAME="ASK_LOGINS">checked</TMPL_IF> />
      </span>
      <p class="form-control">
        <label id="checkLoginsLabel" for="checkLogins" trspan="checkLastLogins">Check my last logins</label>
      </p>
    </div>
    </TMPL_IF>
    <TMPL_IF NAME="STAYCONNECTED">
    <div class="form-group input-group">
      <span class="input-group-addon">
        <input type="checkbox" id="stayconnected" name="stayconnected" aria-describedby="stayConnectedLabel" />
      </span>
      <p class="form-control">
        <label id="stayConnectedLabel" for="stayconnected" trspan="stayConnected">Stay connected on this device</label>
      </p>
    </div>
    </TMPL_IF>
