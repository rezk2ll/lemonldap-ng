<TMPL_INCLUDE NAME="header.tpl">

  <div id="content">
    <div id="content-all">
      <div class="title">
        <img src="<TMPL_VAR NAME="STATIC_PREFIX">/<TMPL_VAR NAME="SKIN">/images/logo-warn.png" />
        <span trspan="warning">Warning</span>
      </div>
      <p></p>
      <div id="content-all-info">
        <TMPL_IF ERROR403>
          <h3 trspan="accessDenied">You have no access authorization for this application</h3>
        </TMPL_IF>
        <TMPL_IF ERROR500>
          <h3 trspan="serverError">Error occurs on the server</h3>
        </TMPL_IF>
        <TMPL_IF ERROR503>
          <h3 trspan="maintenanceMode">This application is in maintenance, please try to connect later</h3>
        </TMPL_IF>
        <TMPL_IF URL>
          <h3>
            <span trspan="redirectedFrom">You were redirect from </span>
            <a href="<TMPL_VAR NAME="URL">"><TMPL_VAR NAME="URL"></a>
          </h3>
        </TMPL_IF>
      </div>
      <div class="panel-buttons">
        <form>
          <button type="button" class="positive" tabindex="1" formaction="<TMPL_VAR NAME="PORTAL_URL">">
            <span trspan="goToPortal">Go to portal</span>
          </button>
        </form>
        <form>
          <button type="button" class="negative" tabindex="2" formaction="<TMPL_VAR NAME="LOGOUT_URL">">
            <span trspan="logout">Logout</span>
          </button>
        </form>
      </div>
    </div>
  </div>

<TMPL_INCLUDE NAME="footer.tpl">

