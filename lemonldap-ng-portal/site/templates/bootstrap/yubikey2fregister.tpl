<TMPL_INCLUDE NAME="header.tpl">

<div class="container">
  <div id="color" class="message message-positive alert"><span id="msg" trspan="clickOnYubikey"></span></div>
</div>
  <main id="menucontent" class="container">
    <div class="panel panel-info">
     <div class="panel-body">
      <form action="/2fregisters/yubikey/register" method="post">
       <div class="form-group">
		<b><span trspan="name">Name</span></b> : <input type="text" id="UBKName" name="UBKName" value="MyYubikey"/>
		&nbsp;&nbsp;&nbsp;&nbsp;
        <b><span trspan="id">Id</span></b></b> : <input type="text" id="otp" name="otp" />
        <input class ="hidden" type="submit" value="Submit">
       </div>
      </form>
     </div>
    </div>
  </main>
<div class="buttons">
  <a href="<TMPL_VAR NAME="PORTAL_URL">2fregisters" class="btn btn-warning" role="button">
    <span class="glyphicon glyphicon-pencil"></span>&nbsp;
    <span trspan="2FManagment">2F managment</span>
  </a>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <a id="goback" href="<TMPL_VAR NAME="PORTAL_URL">/?cancel=1<TMPL_IF NAME="AUTH_URL">&url=<TMPL_VAR NAME="AUTH_URL"></TMPL_IF>" class="btn btn-primary" role="button">
    <span class="glyphicon glyphicon-home"></span>&nbsp;
    <span trspan="goToPortal">Go to portal</span>
  </a>
</div>

<TMPL_INCLUDE NAME="footer.tpl">
