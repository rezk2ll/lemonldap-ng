
    <TMPL_IF NAME="CHECK_LOGINS">
    <div class="form-group input-group">
      <span class="input-group-addon">
        <input type="checkbox" id="checkLogins" name="checkLogins" <TMPL_IF NAME="ASK_LOGINS">checked</TMPL_IF> />
      </span>
      <p class="form-control">
        <span trspan="checkLastLogins">Check my last logins</span>
      </p>
    </div>
    </TMPL_IF>
    <TMPL_IF NAME="STAYCONNECTED">
    <div class="form-group input-group">
      <span class="input-group-addon">
        <input type="checkbox" id="stayconnected" name="stayconnected" />
      </span>
      <p class="form-control">
        <span trspan="stayConnected">Stay connected on this device</span>
      </p>
    </div>
    </TMPL_IF>
