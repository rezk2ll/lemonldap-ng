<TMPL_INCLUDE NAME="header.tpl">

<div id="content">
 <div id="content-all">
  <div class="title">
   <p><span id="msg"></span></p>
  </div>
  <hr class="solid" />
  <p id="u2fPermission" trspan="u2fPermission">You may be prompted to allow the site permission to access your security keys. After granting permission, the device will start to blink.</p>
  <p id="register">
    <img src="<TMPL_VAR NAME="STATIC_PREFIX">/<TMPL_VAR NAME="SKIN">/images/arrow.png" />
    <span trspan="register">Register</span>
  </p>
  <p id="verify">
    <img src="<TMPL_VAR NAME="STATIC_PREFIX">/<TMPL_VAR NAME="SKIN">/images/arrow.png" />
    <span trspan="verify">Verify</span>
  </p>
  <p>
    <img src="<TMPL_VAR NAME="STATIC_PREFIX">/<TMPL_VAR NAME="SKIN">/images/arrow.png" />
    <a id="goback" href="" class="positive">
      <span trspan="goToPortal">Go to portal</span>
    </a>
  </p>
 </div>
</div>

  </script>
  <!-- //if:jsminified
    <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/u2f-api.min.js"></script>
    <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/u2fregistration.min.js"></script>
  //else -->
    <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/u2f-api.js"></script>
    <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/u2fregistration.js"></script>
  <!-- //endif -->

<TMPL_INCLUDE NAME="footer.tpl">
