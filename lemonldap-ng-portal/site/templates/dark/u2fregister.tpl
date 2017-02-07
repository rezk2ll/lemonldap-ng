<TMPL_INCLUDE NAME="header.tpl">

<TMPL_IF NAME="FAILED">
  <div class="message message-warning alert"><span trspan="u2fFailed"></span></div>
</TMPL_IF>

<TMPL_IF NAME="CHALLENGE">
  <div class="message message-positive alert"><span trspan="touchU2fDevice"></span></div>
  <p trspan="u2fPermission">You may be prompted to allow the site permission to access your security keys. After granting permission, the device will start to blink.</p>
  <form id="bind-form" action="#" method="post">
    <input type="hidden" id="bind-data" name="registration" value="">
  </form>
  <script type="application/init">
  <TMPL_VAR NAME="CHALLENGE">
  </script>
<!-- //if:jsminified
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/u2f-api.min.js"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/u2fregistration.min.js"></script>
//else -->
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/u2f-api.js"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/u2fregistration.js"></script>
<!-- //endif -->
</TMPL_IF>

<TMPL_IF NAME="SUCCESS">
  <div class="message message-positive alert"><span trspan="u2fSuccess"></span></div>
</TMPL_IF>

<div class="buttons">
  <a href="<TMPL_VAR NAME="PORTAL_URL">" class="btn btn-primary" role="button">
    <span class="glyphicon glyphicon-home"></span>&nbsp;
    <span trspan="goToPortal">Go to portal</span>
  </a>
</div>

<TMPL_INCLUDE NAME="footer.tpl">
