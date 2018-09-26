<TMPL_INCLUDE NAME="header.tpl">

  <main id="menucontent" class="container">

    <div id="color" class="message message-positive alert"><span id="msg" trspan="yourNewTotpKey"></span></div>

    <div class="card">
      <div class="card-body">

      <div class="row">
    
        <div class="col-md-6 text-center">
        <div id="divToHide">
          <canvas id="qr"></canvas>
          <pre id="serialized"></pre>
        </div>
        </div>

        <div class="col-md-6">

          <div class="form-group">
            <label for="TOTPName"><span trspan="name">Name</span></label>
            <input type="text" class="form-control" id="TOTPName" name="TOTPName" value="MyTOTP" trplaceholder="name" />
          </div>
          <div class="form-group">
            <label for="code"><span trspan="code">Code</span></label>
            <input id="code" class="form-control" name="code" type="number" />
          </div>

        </div>
      </div>

      <div class="buttons">
        <span id="changekey" class="btn btn-secondary" role="button">
          <span class="fas fa-sync-alt"></span>
          <span trspan="changeKey">Change key</span>
        </span>
        <span id="verify" class="btn btn-success" role="button">
          <span class="fas fa-check-circle"></span>
          <span trspan="register">Register</span>
        </span>
      </div>

      </div>
    </div>
  </main>
  
<div class="buttons">
  <a href="<TMPL_VAR NAME="PORTAL_URL">2fregisters" class="btn btn-secondary" role="button">
    <span class="fas fa-shield-alt"></span>
    <span trspan="sfaManager">sfaManager</span>
  </a>
  <a id="goback" href="<TMPL_VAR NAME="PORTAL_URL">?cancel=1<TMPL_IF NAME="AUTH_URL">&url=<TMPL_VAR NAME="AUTH_URL"></TMPL_IF>" class="btn btn-primary" role="button">
    <span class="fas fa-home"></span>
    <span trspan="goToPortal">Go to portal</span>
  </a>
</div>

<!-- //if:jsminified
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/qrious/dist/qrious.min.js"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/totpregistration.min.js"></script>
//else -->
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/qrious/dist/qrious.js"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">common/js/totpregistration.js"></script>
<!-- //endif -->
<TMPL_INCLUDE NAME="footer.tpl">
