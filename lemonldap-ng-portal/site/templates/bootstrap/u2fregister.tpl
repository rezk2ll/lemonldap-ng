<TMPL_INCLUDE NAME="header.tpl">

  <div class="container">
    <div id="color" class="message message-positive alert"><span id="msg" trspan="u2fWelcome"></span></div>
  </div>

  <main id="menucontent" class="container">
    <div class="card">
     <div class="card-body">
       <div id="u2fPermission" trspan="u2fPermission" class="alert alert-info">You may be prompted to allow the site permission to access your security keys. After granting permission, the device will start to blink.
       </div>
       <div class="buttons">
		 <span class="form-group">
           <b><span trspan="name">Name</span></b> : <input type="text" id="keyName" name="keyName" value="MyU2FKey"/>
		 </span>
		 &nbsp;&nbsp;&nbsp;&nbsp;
         <span id="register" class="btn btn-warning" role="button">
           <span class="glyphicon glyphicon-plus-sign"></span>&nbsp;
           <span trspan="register">Register</span>
         </span>
         &nbsp;&nbsp;
         <span id="verify" class="btn btn-success" role="button">
           <span class="glyphicon glyphicon-check"></span>&nbsp;
           <span trspan="verify">Verify</span>
         </span>
       </div>
     </div>
    </div>
  </main>

<div class="buttons">
  <a href="<TMPL_VAR NAME="PORTAL_URL">2fregisters" class="btn btn-warning" role="button">
    <span class="glyphicon glyphicon-pencil"></span>&nbsp;
    <span trspan="sfaManager">sfaManager</span>
  </a>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <a id="goback" href="<TMPL_VAR NAME="PORTAL_URL">?cancel=1<TMPL_IF NAME="AUTH_URL">&url=<TMPL_VAR NAME="AUTH_URL"></TMPL_IF>" class="btn btn-primary" role="button">
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
