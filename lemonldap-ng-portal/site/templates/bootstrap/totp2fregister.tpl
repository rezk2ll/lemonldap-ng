<TMPL_INCLUDE NAME="header.tpl">

<div class="container">
  <div id="color" class="message message-positive alert"><span id="msg" trspan="yourNewTotpKey"></span></div>
</div>

  <main id="menucontent" class="container">
   <div class="panel panel-info">
    <div class="panel-body">
     <div>
      <canvas id="qr"></canvas>
      <pre id="serialized">
      </pre>
     </div>
     <div class="form-group">
       <b><span trspan="name">Name</span> : </b><input type="text" id="TOTPName" name="TOTPName" value="MyTOTP"/>
       &nbsp;&nbsp;&nbsp;&nbsp;
       <b><span trspan="code">Code</span> : </b><input id="code" name="code" type="number" />
     </div>
     <div class="buttons">
      <span id="changekey" class="btn btn-warning" role="button">
        <span class="glyphicon glyphicon-plus-sign"></span>&nbsp;
        <span trspan="changeKey">Change key</span>
      </span>
      &nbsp;&nbsp;
      <span id="verify" class="btn btn-success" role="button">
        <span class="glyphicon glyphicon-check"></span>&nbsp;
        <span trspan="register">Register</span>
      </span>
     </div>
    </div>
   </div>
  </main>
  
<div class="buttons">
  <a href="<TMPL_VAR NAME="PORTAL_URL">2fregisters" class="btn btn-warning" role="button">
    <span class="glyphicon glyphicon-pencil"></span>&nbsp;
    <span trspan="2FManagment">2F managment</span>
  </a>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <a id="goback" href="<TMPL_VAR NAME="PORTAL_URL"><TMPL_IF NAME="AUTH_URL">/?url=<TMPL_VAR NAME="AUTH_URL"></TMPL_IF>" class="btn btn-primary" role="button">
    <span class="glyphicon glyphicon-home"></span>&nbsp;
    <span trspan="goToPortal">Go to portal</span>
  </a>
</div>

<!-- //if:jsminified
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/qrious/dist/qrious.min.js"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/totpregistration.min.js"></script>
//else -->
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/qrious/dist/qrious.js"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/totpregistration.js"></script>
<!-- //endif -->
<TMPL_INCLUDE NAME="footer.tpl">
