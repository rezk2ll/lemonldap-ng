<div class="form">
  <div class="form-group input-group">
    <span class="input-group-addon"><i class="glyphicon glyphicon-user"></i> </span>
    <input name="user" type="text" class="form-control" value="<TMPL_VAR NAME="LOGIN">" trplaceholder="login" required />
  </div>

  <div class="form-group input-group">
    <span class="input-group-addon"><i class="glyphicon glyphicon-lock"></i> </span>
    <input name="password" type="password" class="form-control" trplaceholder="password" required />
  </div>

  <TMPL_IF NAME=CAPTCHA_SRC>
  <div class="form-group">
    <img src="<TMPL_VAR NAME=CAPTCHA_SRC>" class="img-thumbnail" />
  </div>
  <div class="form-group input-group">
    <span class="input-group-addon"><i class="glyphicon glyphicon-eye-open"></i> </span>
    <input type="text" name="captcha" size="<TMPL_VAR NAME=CAPTCHA_SIZE>" class="form-control" placeholder="Captcha" required />
  </div>
  </TMPL_IF>
  <TMPL_IF NAME="TOKEN">
    <input type!"hidden" name="token" value="<TMPL_IF NAME="TOKEN">" />
  </TMPL_IF>

  <TMPL_INCLUDE NAME="checklogins.tpl">

  <button type="submit" class="btn btn-success" >
    <span class="glyphicon glyphicon-log-in"></span>
    <span trspan="connect">Connect</span>
  </button>
</div>

<div class="actions">
  <TMPL_IF NAME="DISPLAY_RESETPASSWORD">
  <a class="btn btn-info" href="<TMPL_VAR NAME="MAIL_URL">?skin=<TMPL_VAR NAME="SKIN"><TMPL_IF NAME="key">&<TMPL_VAR NAME="CHOICE_PARAM">=<TMPL_VAR NAME="key"></TMPL_IF>">
    <span class="glyphicon glyphicon-info-sign"></span>
    <span trspan="resetPwd">Reset my password</span>
  </a>
  </TMPL_IF>

  <TMPL_IF NAME="DISPLAY_REGISTER">
  <a class="btn btn-warning" href="<TMPL_VAR NAME="REGISTER_URL">?skin=<TMPL_VAR NAME="SKIN"><TMPL_IF NAME="key">&<TMPL_VAR NAME="CHOICE_PARAM">=<TMPL_VAR NAME="key"></TMPL_IF>">
    <span class="glyphicon glyphicon-plus-sign"></span>
    <span trspan="createAccount">Create an account</span>
  </a>
  </TMPL_IF>
</div>
