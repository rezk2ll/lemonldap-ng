<div class="form">
  <div class="form-group input-group">
    <span class="input-group-addon"><i class="glyphicon glyphicon-link"></i> </span>
    <input name="openid_identifier" type="text" class="form-control" trplaceholder="enterOpenIDLogin" aria-required="true"/>
  </div>

  <TMPL_INCLUDE NAME="checklogins.tpl">

  <button type="submit" class="btn btn-success" >
    <span class="glyphicon glyphicon-log-in"></span>
    <span trspan="connect">Connect</span>
  </button>
</div>
