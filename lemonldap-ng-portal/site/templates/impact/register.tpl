<TMPL_INCLUDE NAME="header.tpl">

  <div id="content">
    <div id="content-all">
      <div class="title">
        <img src="<TMPL_VAR NAME="STATIC_PREFIX">/<TMPL_VAR NAME="SKIN">/images/logo-ok.png" />
        <span trspan="createAccount">Create an account</span>
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
            <th><span trspan="firstName">First name</span></th>
            <td><input name="firstname" type="text" value="<TMPL_VAR NAME="FIRSTNAME">"/></td>
          </tr>
          <tr>
            <th><span trspan="lastName">Last name</span></th>
            <td><input name="lastname" type="text" value="<TMPL_VAR NAME="LASTNAME">"/></td>
          </tr>
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
                  <span trspan="submit">Submit</span>
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
      <TMPL_IF NAME="FIRSTNAME">
      <input type="hidden" value="<TMPL_VAR NAME="FIRSTNAME">" name="firstname">
      </TMPL_IF>
      <TMPL_IF NAME="LASTNAME">
      <input type="hidden" value="<TMPL_VAR NAME="LASTNAME">" name="lastname">
      </TMPL_IF>
      <TMPL_IF NAME="MAIL">
      <input type="hidden" value="<TMPL_VAR NAME="MAIL">" name="mail">
      </TMPL_IF>
      <div id="content-all-info">
        <p>
        <span trspan="registerRequestAlreadyIssued">A register request for this account was already issued on </span>
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

      <TMPL_IF NAME="DISPLAY_CONFIRMMAILSENT">
      <div id="content-all-info">
      <span trspan="mailSent2">A message has been sent to your mail address.</span>
      <span trspan="linkValidUntil">A confirmation link has been sent, this link is valid until </span>
      <TMPL_VAR NAME="EXPMAILDATE">.
      </div>
      </TMPL_IF>

      <TMPL_IF NAME="DISPLAY_MAILSENT">
      <div id="content-all-info">
      <span trspan="accountCreated">Your account has been created, your temporary password has been sent to your mail address.</span>
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
