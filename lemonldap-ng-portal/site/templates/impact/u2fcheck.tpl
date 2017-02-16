<TMPL_INCLUDE NAME="header.tpl">

<div id="content">
 <div id="content-all">
  <div class="title">
  <TMPL_IF NAME="AUTH_ERROR">
      <img src="<TMPL_VAR NAME="STATIC_PREFIX">/<TMPL_VAR NAME="SKIN">/images/logo-ok.png" />
      <span trmsg="<TMPL_VAR NAME="AUTH_ERROR">"></span>
  </TMPL_IF>

  <TMPL_IF NAME="FAILED">
    <p trspan="u2fFailed"></p>
  </TMPL_IF>

  <TMPL_IF NAME="CHALLENGE">
    <div class="message message-positive alert"><span trspan="touchU2fDevice"></span></div>
    <form id="verify-form" action="/u2fcheck" method="post">
      <input type="hidden" id="verify-data" name="signature" value="">
      <input type="hidden" id="token" name="token" value="<TMPL_VAR NAME="TOKEN">">
    </form>
    <script type="application/init">
    <TMPL_VAR NAME="CHALLENGE">
    </script>
   <!-- //if:jsminified
     <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/u2f-api.min.js"></script>
     <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/u2fcheck.min.js"></script>
   //else -->
     <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/u2f-api.js"></script>
     <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/u2fcheck.js"></script>
    <!-- //endif -->
   </TMPL_IF>
  </div>
  <hr class="solid" />

  <p>
    <img src="<TMPL_VAR NAME="STATIC_PREFIX">/<TMPL_VAR NAME="SKIN">/images/arrow.png" /><a href="<TMPL_VAR NAME="PORTAL_URL">" class="positive"><span trspan="goToPortal">Go to portal</span></a>
  </p>
 </div>
</div>
<TMPL_INCLUDE NAME="footer.tpl">

