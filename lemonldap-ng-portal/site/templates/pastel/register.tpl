<TMPL_INCLUDE NAME="header.tpl">

<div id="mailcontent">

  <TMPL_IF NAME="AUTH_ERROR">
  <div class="message <TMPL_VAR NAME="AUTH_ERROR_TYPE">"><ul><li trmsg="<TMPL_VAR NAME="AUTH_ERROR">"></li></ul></div>
  </TMPL_IF>

  <div class="loginlogo"></div>

  <TMPL_IF NAME="DISPLAY_FORM">

    <form action="#" method="post" class="login">

      <input type="hidden" name="skin" value="<TMPL_VAR NAME="SKIN">" />
      <TMPL_IF NAME="CHOICE_VALUE">
        <input type="hidden" id="authKey" name="<TMPL_VAR NAME="CHOICE_PARAM">" value="<TMPL_VAR NAME="CHOICE_VALUE">" />
      </TMPL_IF>

      <h3 trspan="createAccount">Create an account</h3>

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
          <td><input name="mail" type="text" value="<TMPL_VAR NAME="MAIL">"/></td>
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
          <input type!"hidden" name="token" value="<TMPL_VAR NAME="TOKEN">" />
        </TMPL_IF>

        <tr><td colspan="2">
          <div class="buttons">
            <button type="submit" class="positive">
              <img src="<TMPL_VAR NAME="STATIC_PREFIX">common/accept.png" alt="" />
              <span trspan="submit">Submit</span>
            </button>
          </div>
        </td></tr>
      </table>
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

      <h3 trspan="resendConfirmMail">Resend confirmation mail?</h3>

      <p>
        <span trspan="registerRequestAlreadyIssued">A register request for this account was already issued on </span>
        <TMPL_VAR NAME="STARTMAILDATE">.
        <span trspan="resentConfirm">Do you want the confirmation mail to be resent?</span>
      </p>

      <table>
        <tr><th><input id="resendconfirmation" type="checkbox" name="resendconfirmation"></th>
          <td><span trspan="yesResendMail">Yes, resend the mail</span></td>
        </tr>
        <tr><td colspan="2">
          <div class="buttons">
            <button type="submit" class="positive">
              <img src="<TMPL_VAR NAME="STATIC_PREFIX">common/accept.png" alt="" />
              <span trspan="submit">Submit</span>
            </button>
          </div>
        </td></tr>
      </table>

    </form>
  </TMPL_IF>

  <TMPL_IF NAME="DISPLAY_CONFIRMMAILSENT">
    <form action="#" method="post" class="login">
      <h3>
        <span trspan="mailSent2">A message has been sent to your mail address.</span>
      </h3>
      <p>
        <span trspan="linkValidUntil">A confirmation link has been sent, this link is valid until </span>
        <TMPL_VAR NAME="EXPMAILDATE">.
      </p>
    </form>
  </TMPL_IF>

  <TMPL_IF NAME="DISPLAY_MAILSENT">
    <form action="#" method="post" class="login">
      <h3>
        <span trspan="accountCreated">Your account has been created, your temporary password has been sent to your mail address.</span>
      </h3>
    </form>
  </TMPL_IF>

  <div class="link">
    <a href="<TMPL_VAR NAME="PORTAL_URL">?skin=<TMPL_VAR NAME="SKIN">">
      <span trspan="goToPortal">Go back to portal</span>
    </a>
  </div>

</div>

<TMPL_INCLUDE NAME="footer.tpl">
