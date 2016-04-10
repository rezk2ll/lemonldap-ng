        <p>
          <input name="yubikeyOTP" type="text" value="" tabindex="1" /><br/>
          <span class="text-help">(<span trspan="useYubikey">use your Yubikey</span>)</span>
        </p>

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

