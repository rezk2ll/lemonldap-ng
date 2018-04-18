<TMPL_INCLUDE NAME="header.tpl">

<div class="container">
  <div class="message message-positive alert" trspan="choose2f"></div>
  <div class="buttons">
    <form action="/2fchoice" method="POST">
      <input type="hidden" name="token" id="token" value="<TMPL_VAR NAME="TOKEN">" />
      <TMPL_LOOP NAME="MODULES">
	  &nbsp;&nbsp;
        <button type="submit" name="sf" value="<TMPL_VAR NAME="CODE">">
          <img src="<TMPL_VAR NAME="STATIC_PREFIX"><TMPL_VAR NAME="SKIN">/<TMPL_VAR NAME="LOGO">" alt="<TMPL_VAR NAME="CODE">2F" title="<TMPL_VAR NAME="CODE">2F" />
        </button>
      &nbsp;&nbsp;
      </TMPL_LOOP>
    </form>
  </div>
</div>
<br>
<div class="buttons">
  <a href="<TMPL_VAR NAME="PORTAL_URL">" class="btn btn-primary" role="button">
    <span class="glyphicon glyphicon-home"></span>&nbsp;
    <span trspan="goToPortal">Go to portal</span>
  </a>
</div>

<TMPL_INCLUDE NAME="footer.tpl">

