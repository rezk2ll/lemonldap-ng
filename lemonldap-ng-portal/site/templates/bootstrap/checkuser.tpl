<TMPL_INCLUDE NAME="header.tpl">

<div id="errorcontent" class="container">
  <!--
<div class="message message-positive alert"><span trspan="<TMPL_VAR NAME="MSG">"></span></div>
-->
<div class="alert <TMPL_VAR NAME="ALERTE"> alert"><span trspan="<TMPL_VAR NAME="MSG">"></span></div>
<form id="checkuser" action="/checkuser" method="post" class="password" role="form">

  <TMPL_IF NAME="TOKEN">
    <input type="hidden" name="token" value="<TMPL_VAR NAME="TOKEN">" />
  </TMPL_IF>

  <div class="input-group mb-3">
    <div class="input-group-prepend">
      <span class="input-group-text"><i class="fa fa-user"></i> </span>
    </div>
    <input name="user" type="text" class="form-control" value="<TMPL_VAR NAME="LOGIN">" trplaceholder="user" aria-required="true"/>
  </div>
  <div class="input-group mb-3">
    <div class="input-group-prepend">
      <span class="input-group-text"><i class="fa fa-link"></i> </span>
    </div>
    <input name="url" type="text" class="form-control" value="<TMPL_VAR NAME="URL">" trplaceholder="http://auth.example.com" aria-required="true"/>
  </div>


<TMPL_IF NAME="ALLOWED">
<div class="alert <TMPL_VAR NAME="ALERTE_AUTH">"><span trspan="<TMPL_VAR NAME="ALLOWED">"></span></div>
</TMPL_IF>
<TMPL_IF NAME="HEADERS">
  <div class="buttons">
    <button type="submit" class="btn btn-success">
      <span class="fa fa-sign-in"></span>
      <span trspan="checkUser">Check user</span>
    </button>
  </div>
  <div>&nbsp;</div>
  <div class="card mb-3 border-secondary">
  <div class="card-body table-responsive">
  <table class="table table-hover">
    <thead>
      <tr class="align-middle"><span trspan="headers">HEADERS</span></tr>
      <tr>
        <th class="align-middle"><span trspan="key">Key</span></th>
        <th class="align-middle"><span trspan="value">Value</span></th>
      </tr>
    </thead>
    <tbody>
      <TMPL_LOOP NAME="HEADERS">
        <tr>
          <td class="align-middle"><TMPL_VAR NAME="key"></td>
          <td class="align-middle"><TMPL_VAR NAME="value"></td>
        </tr>
      </TMPL_LOOP>
    </tbody>
  </table>
  </div>
  </div>
</TMPL_IF>

<TMPL_IF NAME="ATTRIBUTES">
  <div class="card mb-3 border-secondary">
  <div class="card-body table-responsive">
  <table class="table table-hover">
    <thead>
      <tr class="align-middle"><span trspan="attributes">ATTRIBUTES</span></tr>
      <tr>
        <th class="align-middle"><span trspan="key">Key</span></th>
        <th class="align-middle"><span trspan="value">Value</span></th>
      </tr>
    </thead>
    <tbody>
      <TMPL_LOOP NAME="ATTRIBUTES">
        <tr>
          <td class="align-middle"><TMPL_VAR NAME="key"></td>
          <td class="align-middle"><TMPL_VAR NAME="value"></td>
        </tr>
      </TMPL_LOOP>
    </tbody>
  </table>
  </div>
  </div>
</TMPL_IF>

  <div class="buttons">
    <button type="submit" class="btn btn-success">
      <span class="fa fa-sign-in"></span>
      <span trspan="checkUser">Check user</span>
    </button>
    <a href="<TMPL_VAR NAME="PORTAL_URL">" class="btn btn-primary" role="button">
      <span class="fa fa-home"></span>
      <span trspan="goToPortal">Go to portal</span>
    </a>
  </div>
</form>
</div>

<TMPL_INCLUDE NAME="footer.tpl">
