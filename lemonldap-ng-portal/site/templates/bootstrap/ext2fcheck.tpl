<TMPL_INCLUDE NAME="header.tpl">

<main id="logincontent" class="container">

<div class="message message-positive alert"><span trspan="enterExt2fCode"></span></div>

<div class="panel panel-default">

<form action="<TMPL_IF "TARGET"><TMPL_VAR "TARGET"><TMPL_ELSE>/ext2fcheck</TMPL_IF>" method="post" class="password" role="form">
  <div class="form">
    <input type="hidden" id="token" name="token" value="<TMPL_VAR NAME="TOKEN">">
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

</div>

</main>

<TMPL_INCLUDE NAME="footer.tpl">
