<TMPL_INCLUDE NAME="header.tpl">

  <div id="content">
    <div id="content-all">
      <div class="title">
        <img src="<TMPL_VAR NAME="STATIC_PREFIX">/<TMPL_VAR NAME="SKIN">/images/logo-info.png" />
        <span trspan="info">Information</span>
      </div>
      <hr class="solid" />
      <p id="timer" class="text-error"><span trspan="redirectedIn">You'll be redirected in 10 seconds</span></p>
      <form id="form" action="<TMPL_VAR NAME="URL">" method="<TMPL_VAR NAME="FORM_METHOD">" class="login">
      <TMPL_VAR NAME="HIDDEN_INPUTS">
      <TMPL_IF NAME="CHOICE_VALUE">
      <input type="hidden" id="authKey" name="<TMPL_VAR NAME="CHOICE_PARAM">" value="<TMPL_VAR NAME="CHOICE_VALUE">" />
      </TMPL_IF>
      <input type="hidden" name="skin" value="<TMPL_VAR NAME="SKIN">" />
      <div id="content-all-info">
        <TMPL_VAR NAME="MSG">
      </div>
        <div class="panel-buttons">
          <button id="wait" type="reset" class="negative" tabindex="4">
            <span trspan="wait">Wait</span>
          </button>
          <button type="submit" class="positive" tabindex="3">
            <span trspan="continue">Continue</span>
          </button>
        </div>
      </form>
    </div>
  </div>
 
  <!-- //if:jsminified
    <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">common/js/info.min.js"></script>
  //else -->
    <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">common/js/info.js"></script>
  <!-- //endif -->

<TMPL_INCLUDE NAME="footer.tpl">

