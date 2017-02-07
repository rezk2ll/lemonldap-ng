<TMPL_INCLUDE NAME="header.tpl">

<div id="content">
 <div id="content-all">
  <div class="title">
  <TMPL_IF NAME="FAILED">
    <p><span class="text-error" trspan="u2fFailed"></span></p>
  </TMPL_IF>

  <TMPL_IF NAME="SUCCESS">
    <p><span class="text-error" trspan="u2fSuccess"></span></p>
  </TMPL_IF>

  <TMPL_IF NAME="CHALLENGE">
    <p><span class="text-error" trspan="touchU2fDevice"></span></p>
  </TMPL_IF>

  <hr class="solid" />

  <TMPL_IF NAME="CHALLENGE">
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

  <p>
    <img src="<TMPL_VAR NAME="SKIN_PATH">/<TMPL_VAR NAME="SKIN">/images/arrow.png" /><a href="<TMPL_VAR NAME="PORTAL_URL">" class="positive"><span trspan="goToPortal">Go to portal</span></a>
  </p>
 </div>
</div>

<TMPL_INCLUDE NAME="footer.tpl">
