<TMPL_INCLUDE NAME="header.tpl">

<div class="message message-positive alert"><span trspan="enterExt2fCode"></span></div>
<form action="/ext2fcheck" method="post" class="password" role="form">
  <div class="form">
    <div class="form-group input-group">
        <input name="code" value="" class="form-control">
        <input type="hidden" id="token" name="token" value="<TMPL_VAR NAME="TOKEN">">
    </div>
  </div>
  <div class="buttons">
    <button type="submit" class="btn btn-success">
      <span class="glyphicon glyphicon-log-in"></span>
      <span trspan="connect">Connect</span>
    </button>
  </div>
</form>

<TMPL_INCLUDE NAME="footer.tpl">


