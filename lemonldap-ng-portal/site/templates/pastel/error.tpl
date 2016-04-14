<TMPL_INCLUDE NAME="header.tpl">

<div id="errorcontent">

  <TMPL_IF ERROR403>
    <div class="message negative"><ul><li><span trspan="accessDenied">You have no access authorization for this application</span></li></ul></div>
  </TMPL_IF>

  <TMPL_IF ERROR500>
    <div class="message negative"><ul><li><span trspan="serverError">Error occurs on the server</span></li></ul></div>
  </TMPL_IF>

  <TMPL_IF ERROR503>
    <div class="message warning"><ul><li><span trspan="maintenanceMode">This application is in maintenance, please try to connect later</span></li></ul></div>
  </TMPL_IF>

  <div class="loginlogo"></div>

  <div id="error">

    <TMPL_IF URL>
      <h3>
        <span trspan="redirectedFrom">You were redirect from </span>
        <a href="<TMPL_VAR NAME="URL">"><TMPL_VAR NAME="URL"></a>
      </h3>
    </TMPL_IF>

    <div class="buttons">
      <a href="<TMPL_VAR NAME="PORTAL_URL">" class="positive">
        <img src="<TMPL_VAR NAME="SKIN_PATH">/common/accept.png" alt="" />
        <span trspan="goToPortal">Go to portal</span>
      </a>
      <TMPL_IF NAME="LOGOUT_URL">
        <a href="<TMPL_VAR NAME="LOGOUT_URL">" class="negative">
          <img src="<TMPL_VAR NAME="SKIN_PATH">/common/cancel.png" alt="" />
          <span trspan="logout">Logout</span>
        </a>
      </TMPL_IF>
    </div>
  </div>
</div>

<TMPL_INCLUDE NAME="footer.tpl">
