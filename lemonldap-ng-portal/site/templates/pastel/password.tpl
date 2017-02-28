<div id="password">

  <form action="#" method="post" class="password">
    <TMPL_VAR NAME="HIDDEN_INPUTS">

    <TMPL_IF NAME="CHOICE_VALUE">
      <input type="hidden" id="authKey" name="<TMPL_VAR NAME="CHOICE_PARAM">" value="<TMPL_VAR NAME="CHOICE_VALUE">" />
    </TMPL_IF>

    <TMPL_IF NAME="AUTH_URL">
      <input type="hidden" name="url" value="<TMPL_VAR NAME="AUTH_URL">" />
    </TMPL_IF>
    <input type="hidden" name="skin" value="<TMPL_VAR NAME="SKIN">" />

    <h3 trspan="changePwd">Change your password</h3>

    <table>

      <TMPL_IF NAME="LOGIN">
        <tr><th><span trspan="login">Login</span></th>
        <td><input name="user" type="hidden" value="<TMPL_VAR NAME=LOGIN>" tabindex="1" /><TMPL_VAR NAME=LOGIN></td></tr>
      </TMPL_IF>

      <TMPL_IF NAME="REQUIRE_OLDPASSWORD">

        <TMPL_IF NAME="HIDE_OLDPASSWORD">
          <input name="oldpassword" type="hidden" value="<TMPL_VAR NAME=OLDPASSWORD>">
        <TMPL_ELSE>
          <tr><th><span trspan="currentPwd">Current password</span></th>
            <td><input name="oldpassword" type="password" tabindex="2" value="<TMPL_VAR NAME=OLDPASSWORD>"/></td>
          </tr>
        </TMPL_IF>

      </TMPL_IF>

      <tr>
        <th><span trspan="newPassword">New password</span></th>
        <td><input name="newpassword" type="password" tabindex="3" /></td>
      </tr><tr>
        <th><span trspan="confirmPwd">Confirm password</span></th>
        <td><input name="confirmpassword" type="password" tabindex="4" /></td>
      </tr><tr>
        <td colspan="2">
          <div class="buttons">
            <button type="reset" class="negative" tabindex="6">
              <img src="<TMPL_VAR NAME="STATIC_PREFIX">common/cancel.png" alt="" />
              <span trspan="cancel">Cancel</span>
            </button>
            <button type="submit" class="positive" tabindex="5">
              <img src="<TMPL_VAR NAME="STATIC_PREFIX">common/accept.png" alt="" />
              <span trspan="submit">Submit</span>
            </button>
          </div>
        </td>
      </tr>

    </table>

  </form>

</div>
