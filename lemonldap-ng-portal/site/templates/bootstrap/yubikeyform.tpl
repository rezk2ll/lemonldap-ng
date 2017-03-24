<div class="form">
  <div class="form-group input-group">
    <span class="input-group-addon"><i class="glyphicon glyphicon-chevron-right"></i> </span>
    <input name="yubikeyOTP" type="text" class="form-control" trplaceholder="enterYubikey" aria-required="true"/>
  </div>

  <TMPL_INCLUDE NAME="checklogins.tpl">

  <button type="submit" class="btn btn-success" >
    <span class="glyphicon glyphicon-log-in"></span>
    <span trspan="connect">Connect</span>
  </button>
</div>
