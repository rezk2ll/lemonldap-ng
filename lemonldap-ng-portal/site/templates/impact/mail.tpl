<TMPL_INCLUDE NAME="header.tpl">

  <div id="content">
    <div id="content-all">
      <div class="title">
        <img src="<TMPL_VAR NAME="SKIN_PATH">/<TMPL_VAR NAME="SKIN">/images/logo-ok.png" />
        <span trspan="forgotPwd">Forgot your password?</span>
      </div>
      <hr class="solid" />
      <TMPL_IF NAME="AUTH_ERROR">
      <p class="text-error" trmsg="<TMPL_VAR NAME="AUTH_ERROR">"></p>
      </TMPL_IF>

      <TMPL_IF NAME="DISPLAY_FORM">
      <form action="#" method="post" class="login">
      <input type="hidden" name="skin" value="<TMPL_VAR NAME="SKIN">" />
      <TMPL_IF NAME="CHOICE_VALUE">
      <input type="hidden" id="authKey" name="<TMPL_VAR NAME="CHOICE_PARAM">" value="<TMPL_VAR NAME="CHOICE_VALUE">" />
      </TMPL_IF>
      <div id="content-all-info">
        <table>
          <tr>
            <th><span trspan="mail">Mail</span></th>
            <td><input name="mail" type="text" value="<TMPL_VAR NAME="MAIL">" /></td>
          </tr>
          <TMPL_IF NAME=CAPTCHA_SRC>
          <tr><td></td><td>
            <img src="<TMPL_VAR NAME=CAPTCHA_SRC>" />
          </td></tr>
          <tr><th><span trspan="captcha">Captcha</span></th>
             <td><input type="text" name="captcha" size="<TMPL_VAR NAME=CAPTCHA_SIZE>" /></td>
          </tr>
          </TMPL_IF>
          <TMPL_IF NAME="TOKEN">
            <input type="hidden" name="token" value="<TMPL_VAR NAME="TOKEN">" />
          </TMPL_IF>
          <tr>
            <td colspan="2">
              <div class="buttons">
                <button type="submit" class="positive">
                  <span trspan="sendPwd">Send me a new password</span>
                </button>
              </div>
            </td>
          </tr>
        </table>
      </div>
      </form>
      </TMPL_IF>

      <TMPL_IF NAME="DISPLAY_RESEND_FORM">
      <form action="#" method="post" class="login">
      <input type="hidden" name="skin" value="<TMPL_VAR NAME="SKIN">" />
      <TMPL_IF NAME="CHOICE_VALUE">
      <input type="hidden" id="authKey" name="<TMPL_VAR NAME="CHOICE_PARAM">" value="<TMPL_VAR NAME="CHOICE_VALUE">" />
      </TMPL_IF>
      <TMPL_IF NAME="MAIL">
      <input type="hidden" value="<TMPL_VAR NAME="MAIL">" name="mail">
      </TMPL_IF>
      <div id="content-all-info">
        <p>
        <span trspan="pwdResetAlreadyIssued">A password reset request was already issued on </span>
        <TMPL_VAR NAME="STARTMAILDATE">.
        <span trspan="resentConfirm">Do you want the confirmation mail to be resent?</span>
        </p>
        <table>
          <tr>
            <th><input id="resendconfirmation" type="checkbox" name="resendconfirmation"></th>
            <td><span trspan="yesResendMail">Yes, resend the mail</span></td>
          </tr>
          <tr>
            <td colspan="2">
              <div class="buttons">
                <button type="submit" class="positive">
                  <span trspan="submit">Submit</span>
                </button>
              </div>
            </td>
          </tr>
        </table>
      </div>
      </form>
      </TMPL_IF>

      <TMPL_IF NAME="DISPLAY_PASSWORD_FORM">
      <form action="#" method="post" class="password">
      <input type="hidden" name="skin" value="<TMPL_VAR NAME="SKIN">" />
      <TMPL_IF NAME="CHOICE_VALUE">
      <input type="hidden" id="authKey" name="<TMPL_VAR NAME="CHOICE_PARAM">" value="<TMPL_VAR NAME="CHOICE_VALUE">" />
      </TMPL_IF>
      <TMPL_IF NAME="TOKEN">
      <input type="hidden" id="token" name="token" value="<TMPL_VAR NAME="TOKEN">" />
      </TMPL_IF>
      <div id="content-all-info">
        <table>
        <tr><th><span trspan="newPassword">New password</span></th>
        <td><input name="newpassword" type="password" tabindex="3" /></td></tr>
        <tr><th><span trspan="confirmPwd">Confirm password</span></th>
        <td><input name="confirmpassword" type="password" tabindex="4" /></td></tr>
        <tr><td colspan="2">
        <input id="reset" type="checkbox" name="reset" />
        <span trspan="generatePwd">Generate the password automatically</span>
        </td></tr>
        <tr><td colspan="2">
        <div class="buttons">
        <button type="reset" class="negative" tabindex="6">
                <span trspan="cancel">Cancel</span>
        </button>
        <button type="submit" class="positive" tabindex="5">
                <span trspan="submit">Submit</span>
        </button>
        </div>
        </td></tr></table>
      </div>
      </form>
      </TMPL_IF>

      <TMPL_IF NAME="DISPLAY_CONFIRMMAILSENT">
      <div id="content-all-info">
      <span trspan="mailSent2">A message has been sent to your mail address.</span>
      <span trspan="linkValidUntil">This message contains a link to reset your password, this link is valid until </span>
      <TMPL_VAR NAME="EXPMAILDATE">.
      </div>
      </TMPL_IF>

      <TMPL_IF NAME="DISPLAY_MAILSENT">
      <div id="content-all-info">
      <span trspan="newPwdSentTo">A confirmation has been sent to your mail address.</span>
      </div>
      </TMPL_IF>

      <div class="panel-buttons">
        <form>
          <button type="button" class="positive" tabindex="1" formaction="<TMPL_VAR NAME="PORTAL_URL">?skin=<TMPL_VAR NAME="SKIN">">
            <span trspan="goToPortal">Go to portal</span>
          </button>
        </form>
      </div>
    </div>
  </div>

<TMPL_INCLUDE NAME="footer.tpl">
