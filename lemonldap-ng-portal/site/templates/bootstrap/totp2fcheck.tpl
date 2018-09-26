<TMPL_INCLUDE NAME="header.tpl">

<main id="logincontent" class="container">

<div class="message message-positive alert"><span trspan="enterTotpCode"></span></div>

<div class="card">

<form action="/totp2fcheck" method="post" class="password" role="form">
  <div class="form">
    <input type="hidden" id="token" name="token" value="<TMPL_VAR NAME="TOKEN">">
    <input type="hidden" id="checkLogins" name="checkLogins" value="<TMPL_VAR NAME="CHECKLOGINS">">
    <div class="input-group mb-3">
      <div class="input-group-prepend">
        <span class="input-group-text"><i class="fas fa-lock"></i> </span>
      </div>
      <input name="code" value="" class="form-control" id="extcode" trplaceholder="code">
    </div>
  </div>
  <div class="buttons mb-3">
    <button type="submit" class="btn btn-success">
      <span class="fas fa-sign-in-alt"></span>
      <span trspan="connect">Connect</span>
    </button>
  </div>
  <div class="buttons">
    <a href="<TMPL_VAR NAME="PORTAL_URL">?cancel=1" class="btn btn-primary" role="button">
      <span class="fas fa-home"></span>
      <span trspan="cancel">Cancel</span>
    </a>
  </div>
</form>
</div>
</main>

<TMPL_INCLUDE NAME="footer.tpl">
