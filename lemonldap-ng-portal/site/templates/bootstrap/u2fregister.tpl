<TMPL_INCLUDE NAME="header.tpl">

<TMPL_IF NAME="CHALLENGE">
  <p trspan="touchU2fDevice">Please touch the flashing U2F device now.</p>
  <p trspan="u2fPermission">You may be prompted to allow the site permission to access your security keys. After granting permission, the device will start to blink.</p>
  <form id="bind-form" action="#" method="post">
    <input type="hidden" id="bind-data" name="registration" value="">
  </form>
  <script type="application/init">
{
  "challenge":"<TMPL_VAR NAME="CHALLENGE">",
  "appId": "<TMPL_VAR NAME="APPID">"
}
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
  <h3 trspan="u2fSuccess">Success</h3>
</TMPL_IF>

<TMPL_INCLUDE NAME="footer.tpl">
