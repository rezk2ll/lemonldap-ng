<TMPL_INCLUDE NAME="header.tpl">

<main id="logincontent" class="container">

<div class="message message-positive alert"><span trspan="enterTotpCode"></span></div>

<div class="card">

<form action="/totp2fcheck" method="post" class="password" role="form">
  <div class="form">
    <input type="hidden" id="token" name="token" value="<TMPL_VAR NAME="TOKEN">">
    <input type="hidden" id="checkLogins" name="checkLogins" value="<TMPL_VAR NAME="CHECKLOGINS">">
    <div class="form-group input-group">
        <span class="input-group-addon"><i class="glyphicon glyphicon-lock"></i> </span>
        <input name="code" value="" class="form-control" id="extcode" trplaceholder="code">
    </div>
  </div>
  <div class="buttons">
    <button type="submit" class="btn btn-success">
      <span class="glyphicon glyphicon-log-in"></span>
      <span trspan="connect">Connect</span>
    </button>
  </div>
  <br>
  <div class="buttons">
    <a href="<TMPL_VAR NAME="PORTAL_URL">?cancel=1" class="btn btn-primary" role="button">
      <span class="glyphicon glyphicon-home"></span>&nbsp;
      <span trspan="cancel">Cancel</span>
    </a>
  </div>
</form>
</div>
</main>

<TMPL_INCLUDE NAME="footer.tpl">
