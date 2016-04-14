<TMPL_INCLUDE NAME="header.tpl">

<div id="logincontent">

  <TMPL_IF NAME="AUTH_ERROR">
  <div class="message <TMPL_VAR NAME="AUTH_ERROR_TYPE">"><ul><li><TMPL_VAR NAME="AUTH_ERROR"></li></ul></div>
  </TMPL_IF>

  <div class="loginlogo"></div>

  <TMPL_IF NAME="ID">
    <h3><span trspan="yourIdentityIs">Your identity is</span>:</h3>
    <p><TMPL_VAR NAME="ID"></p>
  </TMPL_IF>

  <TMPL_IF NAME="PORTAL_URL">
    <div id="logout">
      <TMPL_IF NAME="MSG"><TMPL_VAR NAME="MSG"></TMPL_IF>
      <div class="buttons">
        <a href="<TMPL_VAR NAME="PORTAL_URL">" class="positive">
          <img src="<TMPL_VAR NAME="SKIN_PATH">/common/accept.png" alt="" />
          <span trspan="goToPortal">Go to portal</span>
        </a>
      </div>
    </div>
  </TMPL_IF>
</div>

<TMPL_INCLUDE NAME="footer.tpl">
