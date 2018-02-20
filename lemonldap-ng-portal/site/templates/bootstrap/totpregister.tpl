<TMPL_INCLUDE NAME="header.tpl">

 <div class="container">
 <div id="color" class="message message-positive alert"><span id="msg"></span></div>
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
      <input id="code" name="code" type="number" />
     </div>
     <div class="buttons">
      <span id="changekey" class="btn btn-success" role="button">
        <span class="glyphicon glyphicon-check"></span>&nbsp;
        <span trspan="changeKey">Change key</span>
      </span>
      <span id="verify" class="btn btn-success" role="button">
        <span class="glyphicon glyphicon-check"></span>&nbsp;
        <span trspan="verify">Verify</span>
      </span>
     </div>
    </div>
   </div>
  </main>

 <div class="buttons">
  <a id="goback" href="" class="btn btn-primary" role="button">
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
