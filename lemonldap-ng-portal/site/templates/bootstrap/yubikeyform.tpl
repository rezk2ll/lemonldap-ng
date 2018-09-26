<div class="form">
  <div class="input-group mb-3">
    <div class="input-group-prepend">
      <span class="input-group-text"><i class="fas fa-chevron-right"></i></span>
    </div>
    <input name="yubikeyOTP" type="text" class="form-control" trplaceholder="enterYubikey" aria-required="true"/>
  </div>

  <TMPL_INCLUDE NAME="checklogins.tpl">

  <button type="submit" class="btn btn-success" >
    <span class="fas fa-sign-in-alt"></span>
    <span trspan="connect">Connect</span>
  </button>
</div>
