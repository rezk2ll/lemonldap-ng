<TMPL_INCLUDE NAME="header.tpl">

<div id="errorcontent" class="container">
<div class="message message-positive alert"><span trspan="<TMPL_VAR NAME="MSG">"></span></div>

<form id="checkuser" action="/checkuser" method="post" class="password" role="form">
  <!--
  <input type="hidden" name="confirm" value="<TMPL_VAR NAME="CONFIRMKEY">">
  <input type="hidden" name="url" value="<TMPL_VAR NAME="URL">">
  -->
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
    <input name="url" type="text" class="form-control" value="<TMPL_VAR NAME="URL">" trplaceholder="URL" aria-required="true"/>
  </div>
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
