<TMPL_IF NAME="FINDUSER">
<br>
<div class="card">
<br>
<form action="/finduser" method="post" role="form" class="login">
<div class="form">
  <TMPL_LOOP NAME="FIELDS">
    <div class="input-group mb-3">
      <div class="input-group-prepend">
        <span class="input-group-text"><label for="<TMPL_VAR NAME="key">" class="mb-0"><i class="fa fa-user"></i></label></span>
      </div>
      <input id="findUser<TMPL_VAR NAME="key">" name="<TMPL_VAR NAME="key">" type="text" autocomplete="off" class="form-control" placeholder="<TMPL_VAR NAME="value">" />
    </div>
  </TMPL_LOOP>
  <button type="submit" class="btn btn-info" >
    <span class="fa fa-eye"></span>
    <span trspan="searchAccount">Search an account</span>
  </button>
</div>
<br>
</form>
</div>
</TMPL_IF>
