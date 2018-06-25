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
        <TMPL_IF NAME="LIST">
          <span trspan="selectIdP">Select your Identity Provider</span>
        <TMPL_ELSE>
          <span trspan="confirmation">Confirmation</span>
        </TMPL_IF>
        </h3>
      </div>
      <div class="panel-body form">

      <TMPL_VAR NAME="MSG">

      <TMPL_IF NAME="LIST">

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

      <TMPL_ELSE>

      <TMPL_IF NAME="ACTIVE_TIMER">
        <div class="alert alert-info">
          <p id="timer" trspan="autoAccept">Automatically accept in 30 seconds</p>
        </div>
      </TMPL_IF>

      <div class="buttons">
        <button type="submit" class="positive btn btn-success">
          <span class="glyphicon glyphicon-ok"></span>
          <span trspan="accept">Accept</span>
        </button>
        <button id="refuse" type="submit" class="negative btn btn-danger" val="-<TMPL_VAR NAME="CONFIRMKEY">">
          <span class="glyphicon glyphicon-stop"></span>
          <span trspan="refuse">Refuse</span>
        </button>
      </div>

      </TMPL_IF>

      <!-- //if:jsminified
        <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">common/js/confirm.min.js"></script>
      //else -->
        <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">common/js/confirm.js"></script>
      <!-- //endif -->

      <hr />

      <TMPL_INCLUDE NAME="checklogins.tpl">

      </div>
    </div>
    
	  <TMPL_IF NAME="PORTAL_URL">
	    <div id="logout">
	      <div class="buttons">
	        <a href="<TMPL_VAR NAME="PORTAL_URL"><TMPL_IF NAME="AUTH_URL">/?url=<TMPL_VAR NAME="AUTH_URL"></TMPL_IF>" class="btn btn-primary" role="button">
	          <span class="glyphicon glyphicon-home"></span>&nbsp;
	          <span trspan="goToPortal">Go to portal</span>
	        </a>
	      </div>
	    </div>
	  </TMPL_IF>
	  
  </form>

</div>

<TMPL_INCLUDE NAME="footer.tpl">
