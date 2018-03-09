<TMPL_INCLUDE NAME="header.tpl">

  <div class="container">
  <div id="color" class="message message-positive alert"><span id="msg" trspan="u2fWelcome"></span></div>
  </div>

  <main id="menucontent" class="container">
  <div class="panel panel-info">
  <div class="panel-body">
  <div id="u2fPermission" trspan="u2fPermission" class="alert alert-info">You may be prompted to allow the site permission to access your security keys. After granting permission, the device will start to blink.</div>

  <div class="buttons">
  <span id="register" class="btn btn-warning" role="button">
    <span class="glyphicon glyphicon-plus-sign"></span>&nbsp;
    <span trspan="register">Register</span>
  </span>
  <span id="verify" class="btn btn-success" role="button">
    <span class="glyphicon glyphicon-check"></span>&nbsp;
    <span trspan="verify">Verify</span>
  </span>
  <span id="unregister" class="btn btn-danger" role="button">
    <span class="glyphicon glyphicon-minus-sign"></span>&nbsp;
    <span trspan="unregister">Unregister</span>
  </span>
  </div>
  </div>
  </div>
  </main>

  <div class="buttons">
  <a id="goback" href="<TMPL_VAR NAME="PORTAL_URL"><TMPL_IF NAME="AUTH_URL">/?url=<TMPL_VAR NAME="AUTH_URL"></TMPL_IF>" class="btn btn-primary" role="button">
  <a id="goback" href="" class="btn btn-primary" role="button">
    <span class="glyphicon glyphicon-home"></span>&nbsp;
    <span trspan="goToPortal">Go to portal</span>
  </a>
  </div>

<!-- //if:jsminified
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/u2f-api.min.js"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/u2fregistration.min.js"></script>
//else -->
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/u2f-api.js"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/u2fregistration.js"></script>
<!-- //endif -->
<TMPL_INCLUDE NAME="footer.tpl">
