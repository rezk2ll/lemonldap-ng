<TMPL_INCLUDE NAME="header.tpl">

<div id="logincontent" class="container">

  <form id="form" action="#" method="<TMPL_VAR NAME="FORM_METHOD">" class="confirm" role="form">

    <TMPL_VAR NAME="HIDDEN_INPUTS">
    <TMPL_IF NAME="AUTH_URL">
      <input type="hidden" name="url" value="<TMPL_VAR NAME="AUTH_URL">" />
    </TMPL_IF>
    <TMPL_IF NAME="CHOICE_VALUE">
      <input type="hidden" id="authKey" name="<TMPL_VAR NAME="CHOICE_PARAM">" value="<TMPL_VAR NAME="CHOICE_VALUE">" />
    </TMPL_IF>
    <TMPL_IF NAME="CONFIRMKEY">
      <input type="hidden" id="confirm" name="confirm" value="<TMPL_VAR NAME="CONFIRMKEY">" />
    </TMPL_IF>
    <input type="hidden" name="skin" value="<TMPL_VAR NAME="SKIN">" />

    <div class="panel panel-info">
      <div class="panel-heading">
        <h3 class="panel-title">
          <span trspan="selectIdP">Select your Identity Provider</span>
        </h3>
      </div>
      <div class="panel-body form">

      <input type="hidden" id="idp" name="idp"/>

      <div class="row">
      <TMPL_LOOP NAME="LIST">
        <div class="col-sm-6 <TMPL_VAR NAME="class">">
          <button type="submit" class="btn btn-info idploop" val="<TMPL_VAR NAME="VAL">">
          <TMPL_IF NAME="icon">
            <img src="<TMPL_VAR NAME="icon">" class="glyphicon" />
          <TMPL_ELSE>
            <i class="glyphicon glyphicon-chevron-right"></i>
          </TMPL_IF>
            <TMPL_VAR NAME="NAME">
          </button>
        </div>
      </TMPL_LOOP>
      </div>

      <TMPL_IF NAME="REMEMBER">
	  <p>&nbsp;</p>
      <div class="checkbox">
        <input type="checkbox" id="remember" name="cookie_type" value="1" aria-describedby="rememberlabel">
        <label id="rememberlabel" for="remember">
          <span trspan="rememberChoice">Remember my choice</span>
        </label>
      </div>
      </TMPL_IF>

      <!-- //if:jsminified
        <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">common/js/idpchoice.min.js"></script>
      //else -->
        <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">common/js/idpchoice.js"></script>
      <!-- //endif -->

      </div>
    </div>
    
	  <TMPL_IF NAME="PORTAL_URL">
	    <div id="logout">
	      <div class="buttons">
	        <a href="<TMPL_VAR NAME="PORTAL_URL">/?cancel=1<TMPL_IF NAME="AUTH_URL">&url=<TMPL_VAR NAME="AUTH_URL"><TMPL_ELSE>/?cancel=1</TMPL_IF>" class="btn btn-primary" role="button">
	          <span class="glyphicon glyphicon-home"></span>&nbsp;
	          <span trspan="cancel">Cancel</span>
	        </a>
	      </div>
	    </div>
	  </TMPL_IF>
	  
  </form>

</div>

<TMPL_INCLUDE NAME="footer.tpl">
