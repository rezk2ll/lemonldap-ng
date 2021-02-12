<TMPL_INCLUDE NAME="header.tpl">

<div id="errorcontent" class="container">
  <div class="alert <TMPL_VAR NAME="ALERTE"> alert"><div class="text-center"><span trspan="<TMPL_VAR NAME="MSG">"></span></div></div>
  <TMPL_IF NAME="HEADERS">
    <div class="row">
      <div class="card col border-secondary">
        <div class="text-center bg-light text-dark"><b><span trspan="headers">HEADERS</span></b></div>
        <div class="font-weight-bold">
          <TMPL_LOOP NAME="HEADERS">
            <TMPL_VAR NAME="key">: <TMPL_VAR NAME="value"><br/>
          </TMPL_LOOP>
        </div>
      </div>
    </div>
  </TMPL_IF>
  <form id="checkDevOps" action="/checkdevops" method="post" class="password" role="form">
    <pre><textarea id="checkDevOpsFile" name="checkDevOpsFile" class="form-control rounded-1" rows="6" trplaceholder="Paste your file here..." required><TMPL_VAR NAME="FILE"></textarea></pre>
    <TMPL_IF NAME="TOKEN">
      <input type="hidden" name="token" value="<TMPL_VAR NAME="TOKEN">" />
    </TMPL_IF>
    <div class="buttons">
      <button type="submit" class="btn btn-success">
        <span class="fa fa-check-circle"></span>
        <span trspan="verify">Verify</span>
      </button>
    </div>
  </form>
    <div class="buttons">
      <a href="<TMPL_VAR NAME="PORTAL_URL">" class="btn btn-primary" role="button">
        <span class="fa fa-home"></span>
        <span trspan="goToPortal">Go to portal</span>
      </a>
    </div>
  </div>
</div>

<TMPL_INCLUDE NAME="footer.tpl">
