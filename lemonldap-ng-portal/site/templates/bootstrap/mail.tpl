<TMPL_INCLUDE NAME="header.tpl">

<div id="mailcontent" class="container">

  <TMPL_IF NAME="AUTH_ERROR">
  <div class="message message-<TMPL_VAR NAME="AUTH_ERROR_TYPE"> alert"><span trmsg="<TMPL_VAR NAME="AUTH_ERROR">"></span></div>
  </TMPL_IF>

  <div class="panel panel-default">

  <TMPL_IF NAME="DISPLAY_FORM">

    <form action="#" method="post" class="login" role="form">
    <div class="form">

    <input type="hidden" name="skin" value="<TMPL_VAR NAME="SKIN">" />
    <input type="hidden" name="url" value="<TMPL_VAR NAME="AUTH_URL">" />
    <TMPL_IF NAME="CHOICE_VALUE">
      <input type="hidden" id="authKey" name="<TMPL_VAR NAME="CHOICE_PARAM">" value="<TMPL_VAR NAME="CHOICE_VALUE">" />
    </TMPL_IF>

    <h3 trspan="forgotPwd">Forgot your password?</h3>

    <div class="form-group input-group">
      <span class="input-group-addon"><i class="glyphicon glyphicon-envelope"></i> </span>
      <input name="mail" type="text" value="<TMPL_VAR NAME="MAIL">" class="form-control" trplaceholder="mail" required />
    </div>

    <TMPL_IF NAME=CAPTCHA_SRC>
    <div class="form-group">
      <img src="<TMPL_VAR NAME=CAPTCHA_SRC>" class="img-thumbnail" />
    </div>
    <div class="form-group input-group">
      <span class="input-group-addon"><i class="glyphicon glyphicon-eye-open"></i> </span>
      <input type="text" name="captcha" size="<TMPL_VAR NAME=CAPTCHA_SIZE>" class="form-control" trplaceholder="captcha" required />
    </div>
    </TMPL_IF>
    <TMPL_IF NAME="TOKEN">
      <input type="hidden" name="token" value="<TMPL_VAR NAME="TOKEN">" />
    </TMPL_IF>

    <button type="submit" class="btn btn-success" >
      <span class="glyphicon glyphicon-send"></span>
      <span trspan="sendPwd">Send me a new password</span>
    </button>
    
    </div>
    </form>
  </TMPL_IF>

  <TMPL_IF NAME="DISPLAY_RESEND_FORM">

    <form action="#" method="post" class="login" role="form">
    <div class="form">

      <input type="hidden" name="skin" value="<TMPL_VAR NAME="SKIN">" />
      <input type="hidden" name="url" value="<TMPL_VAR NAME="AUTH_URL">" />
      <TMPL_IF NAME="CHOICE_VALUE">
        <input type="hidden" id="authKey" name="<TMPL_VAR NAME="CHOICE_PARAM">" value="<TMPL_VAR NAME="CHOICE_VALUE">" />
      </TMPL_IF>
      <TMPL_IF NAME="MAIL">
        <input type="hidden" value="<TMPL_VAR NAME="MAIL">" name="mail">
      </TMPL_IF>

      <h3 trspan="resendConfirmMail">Resend confirmation mail?</h3>

      <p class="alert alert-info">
        <span trspan="pwdResetAlreadyIssued">A password reset request was already issued on </span>
        <TMPL_VAR NAME="STARTMAILDATE">.
        <span trspan="resentConfirm">Do you want the confirmation mail to be resent?</span>
      </p>


      <div class="checkbox">
        <label>
          <input id="resendconfirmation" type="checkbox" name="resendconfirmation" aria-describedby="resendconfirmationlabel">
          <label for="resendconfirmation" id="resendconfirmationlabel" trspan="confirmPwd">Yes, resend the mail</label>
        </label>
      </div>

      <div class="form-group">
        <button type="submit" class="btn btn-success">
          <span trspan="submit">Submit</span>
        </button>
      </div>

    </div>
    </form>
  </TMPL_IF>

  <TMPL_IF NAME="DISPLAY_PASSWORD_FORM">
    <div id="password">
      <form action="#" method="post" class="password" role="form">
      <div class="form">

        <input type="hidden" name="skin" value="<TMPL_VAR NAME="SKIN">" />
        <input type="hidden" name="url" value="<TMPL_VAR NAME="AUTH_URL">" />
        <TMPL_IF NAME="CHOICE_VALUE">
          <input type="hidden" id="authKey" name="<TMPL_VAR NAME="CHOICE_PARAM">" value="<TMPL_VAR NAME="CHOICE_VALUE">" />
        </TMPL_IF>

        <TMPL_IF NAME="TOKEN">
          <input type="hidden" id="token" name="token" value="<TMPL_VAR NAME="TOKEN">" />
        </TMPL_IF>

        <h3 trspan="changePwd">Change your password</h3>

        <div class="form-group input-group">
          <span class="input-group-addon"><i class="glyphicon glyphicon-lock"></i> </span>
          <input name="newpassword" type="password" class="form-control" trplaceholder="newPassword" />
        </div>

        <div class="form-group input-group">
          <span class="input-group-addon"><i class="glyphicon glyphicon-lock"></i> </span>
          <input name="confirmpassword" type="password" class="form-control" trplaceholder="confirmPwd" />
        </div>

        <div class="checkbox">
          <label>
            <input id="reset" type="checkbox" name="reset" aria-describedby="resetlabel"/>
            <label for="reset" id="resetlabel" trspan="generatePwd">Generate the password automatically</label>
          </label>
        </div>

        <div class="form-group">
          <button type="submit" class="btn btn-success">
            <span trspan="submit">Submit</span>
          </button>
        </div>

      </div>
      </form>
    </div>
  </TMPL_IF>

  <TMPL_IF NAME="DISPLAY_CONFIRMMAILSENT">
    <form action="#" method="post" class="login" role="form">
    <div class="form">
      <h3>
        <span trspan="mailSent2">A message has been sent to your mail address.</span>
      </h3>
      <p class="alert alert-info">
        <span trspan="linkValidUntil">This message contains a link to reset your password, this link is valid until </span>
        <TMPL_VAR NAME="EXPMAILDATE">.
      </p>
    </div>
    </form>
  </TMPL_IF>

  <TMPL_IF NAME="DISPLAY_MAILSENT">
    <form action="#" method="post" class="login" role="form">
    <div class="form">
      <h3>
        <span trspan="newPwdSentTo">A confirmation has been sent to your mail address.</span>
      </h3>
    </div>
    </form>
  </TMPL_IF>

  </div>

  <div class="buttons">
    <a href="<TMPL_VAR NAME="PORTAL_URL">?skin=<TMPL_VAR NAME="SKIN"><TMPL_IF NAME="CHOICE_VLAUE">&<TMPL_VAR NAME="CHOICE_PARAM">=<TMPL_VAR NAME="CHOICE_VALUE"></TMPL_IF><TMPL_IF NAME="AUTH_URL">&url=<TMPL_VAR NAME="AUTH_URL"></TMPL_IF>" class="btn btn-primary" role="button">
      <span class="glyphicon glyphicon-home"></span>
      <span trspan="back2Portal">Go back to portal</span>
    </a>
  </div>

</div>

<TMPL_INCLUDE NAME="footer.tpl">
