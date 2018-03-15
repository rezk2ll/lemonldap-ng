<TMPL_INCLUDE NAME="header.tpl">

<div class="container">
  <div class="message message-positive alert" trspan="choose2f"></div>
  <div class="buttons">
    <TMPL_LOOP NAME="MODULES">
      <a href="<TMPL_VAR NAME="URL">">
         <img src="<TMPL_VAR NAME="STATIC_PREFIX"><TMPL_VAR NAME="SKIN">/<TMPL_VAR NAME="LOGO">" alt="<TMPL_VAR NAME="CODE">2F" />
       </a>
      </TMPL_LOOP>
    </form>
  </div>
</div>

<div class="buttons">
  <a href="<TMPL_VAR NAME="PORTAL_URL">" class="btn btn-primary" role="button">
    <span class="glyphicon glyphicon-home"></span>&nbsp;
    <span trspan="goToPortal">Go to portal</span>
  </a>
</div>

<TMPL_INCLUDE NAME="footer.tpl">

