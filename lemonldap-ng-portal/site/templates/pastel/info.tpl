<TMPL_INCLUDE NAME="header.tpl">

<div id="logincontent">

  <div class="message warning"><ul><li><span trspan="info">Information</span></li></ul></div>

  <div class="loginlogo"></div>

  <form id="form" action="<TMPL_VAR NAME="URL">" method="<TMPL_VAR NAME="FORM_METHOD">" class="login">
    <TMPL_VAR NAME="HIDDEN_INPUTS">
    <TMPL_IF NAME="CHOICE_VALUE">
      <input type="hidden" id="authKey" name="<TMPL_VAR NAME="CHOICE_PARAM">" value="<TMPL_VAR NAME="CHOICE_VALUE">" />
    </TMPL_IF>
    <TMPL_VAR NAME="MSG">
    <p id="timer"><span trspan="redirectedIn">You'll be redirected in 10 seconds</span></p>
    <table><tbody><tr><td>
      <div class="buttons">
        <button type="submit" class="positive">
          <img src="<TMPL_VAR NAME="STATIC_PREFIX">common/accept.png" alt="" />
          <span trspan="continue">Continue</span>
        </button>
        <button id="wait" type="reset" class="negative">
          <img src="<TMPL_VAR NAME="STATIC_PREFIX">common/cancel.png" alt="" />
          <span trspan="wait">Wait</span>
        </button>
      </div>
    </td></tr></tbody></table>
  </form>
  <!-- //if:jsminified
    <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">common/js/info.min.js"></script>
  //else -->
    <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">common/js/info.js"></script>
  <!-- //endif -->

</div>

<TMPL_INCLUDE NAME="footer.tpl">
