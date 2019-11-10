<TMPL_INCLUDE NAME="header.tpl">

<div id="errorcontent" class="container">
  <div class="alert alert-warning alert"><div class="text-center"><span trspan="globalLogout">globalLogout</span></div></div>

  <div class="row">
    <TMPL_IF NAME="SESSIONS">
    <div class="card col border-secondary">
      <div class="text-center bg-light text-dark"><b><span trspan="activeSessions">ACTIVE SESSIONS</span>: <u><TMPL_VAR NAME="LOGIN"></u></b></div>
      <table class="table table-sm table-hover">
        <thead>
          <tr>
            <th scope="col"><span trspan="authLevel">authLevel</span></th>
            <th scope="col"><span trspan="ipAddr">ipAddr</span></th>
          </tr>
        </thead>
        <tbody>
          <TMPL_LOOP NAME="SESSIONS">
          <tr>
            <td scope="row"><TMPL_VAR NAME="authLevel"></td>
            <td scope="row"><TMPL_VAR NAME="ipAddr"></td>
          </tr>
          </TMPL_LOOP>
        </tbody>
      </table>
    </div>
    </TMPL_IF>
  </div>

  <form id="globallogout" action="/globallogout?all=1" method="post" class="password" role="form">
    <input type="hidden" name="token" value="<TMPL_VAR NAME="TOKEN">" />
    <div class="buttons">
      <button type="submit" class="btn btn-danger">
        <span class="fa fa-search"></span>
        <span trspan="all">All</span>
      </button>
      <a href="<TMPL_VAR NAME="PORTAL_URL">globallogout" class="btn btn-success" role="button">
        <span class="fa fa-home"></span>
        <span trspan="current">Current</span>
      </a>
      <a href="<TMPL_VAR NAME="PORTAL_URL">" class="btn btn-primary" role="button">
        <span class="fa fa-home"></span>
        <span trspan="goToPortal">Go to portal</span>
      </a>
  </div>
  </form>

</div>

<TMPL_INCLUDE NAME="footer.tpl">
