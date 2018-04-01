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
        <br>
	    <br>
        <b><span trspan="id">Id</span></b></b> : &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" id="otp" name="otp" />
        <input type="submit" value="Submit">
       </div>
      </form>
     </div>
    </div>
  </main>

  <div class="buttons">
  <a id="goback" href="<TMPL_VAR NAME="PORTAL_URL"><TMPL_IF NAME="AUTH_URL">/?url=<TMPL_VAR NAME="AUTH_URL"></TMPL_IF>" class="btn btn-primary" role="button">
    <span class="glyphicon glyphicon-home"></span>&nbsp;
    <span trspan="goToPortal">Go to portal</span>
  </a>
  </div>

<TMPL_INCLUDE NAME="footer.tpl">
