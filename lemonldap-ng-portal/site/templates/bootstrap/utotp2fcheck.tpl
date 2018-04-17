<TMPL_INCLUDE NAME="header.tpl">

<main id="logincontent" class="container">

<TMPL_IF NAME="AUTH_ERROR">
  <div class="message message-<TMPL_VAR NAME="AUTH_ERROR_TYPE"> alert"><span trmsg="<TMPL_VAR NAME="AUTH_ERROR">"></span></div>
</TMPL_IF>

<div class="panel panel-default">

<TMPL_IF NAME="FAILED">
  <p trspan="u2fFailed"></p>
</TMPL_IF>

<TMPL_IF NAME="AUTH_ERROR">
  <div class="buttons">
    <a href="<TMPL_VAR NAME="PORTAL_URL">" class="btn btn-primary" role="button">
      <span class="glyphicon glyphicon-home"></span>&nbsp;
      <span trspan="goToPortal">Go to portal</span>
    </a>
  </div>
<TMPL_ELSE>
 <form id="verify-form" action="/utotp2fcheck" method="post">
  <input type="hidden" id="token" name="token" value="<TMPL_VAR NAME="TOKEN">">
  <TMPL_IF NAME="DATA">
   <div class="message message-positive alert">
    <span trspan="touchU2fDeviceOrEnterTotp"></span>
   </div>
    <input type="hidden" id="verify-data" name="signature" value="">
    <input type="hidden" id="verify-challenge" name="challenge" value="">
   <script type="application/init">
   <TMPL_VAR NAME="DATA">
   </script>
   <!-- //if:jsminified
     <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/u2f-api.min.js"></script>
     <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/u2fcheck.min.js"></script>
   //else -->
     <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/u2f-api.js"></script>
     <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/u2fcheck.js"></script>
   <!-- //endif -->
  <TMPL_ELSE>
   <div class="message message-positive alert">
       <span trspan="enterTotpCode"></span>
   </div>
  </TMPL_IF>
  <div class="form">
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
 </form>
</TMPL_IF>

</div>
</main>

<TMPL_INCLUDE NAME="footer.tpl">

