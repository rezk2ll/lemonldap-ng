 <!-- Load javascript common to all skins -->
 <!-- //if:usedebianlibs
  <script type="text/javascript" src="/javascript/jquery/jquery.min.js"></script>
  <script type="text/javascript" src="/javascript/jquery-ui/jquery-ui.min.js"></script>
  <script type="text/javascript" src="/javascript/jquery-cookie/jquery.cookie.min.js"></script>
//elsif:useexternallibs
  <script type="text/javascript" src="http://code.jquery.com/jquery-2.2.0.min.js"></script>
  <script type="text/javascript" src="http://code.jquery.com/ui/1.10.4/jquery-ui.min.js"></script>
  <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jquery-cookie/1.4.1/jquery.cookie.min.js"></script>
 //elsif:jsminified
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/jquery/dist/jquery.min.js"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/jquery-ui/jquery-ui.min.js"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/jquery.cookie/jquery.cookie.min.js"></script>
 //else -->
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/jquery/dist/jquery.js"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/jquery-ui/jquery-ui.js"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/jquery.cookie/jquery.cookie.js"></script>
 <!-- //endif -->
 <TMPL_IF NAME="browserIdEnabled">
   <script type="text/javascript" src="https://login.persona.org/include.js"></script>
  <!-- //endif -->
 </TMPL_IF>
 <TMPL_IF NAME="browserIdLoadLoginScript">
  <script type="application/init">
  {
  "browserIdSiteName":"<TMPL_VAR NAME="browserIdSiteName">",
  "browserIdSiteLogo":"<TMPL_VAR NAME="browserIdSiteLogo">",
  "browserIdBackgroundColor":"<TMPL_VAR NAME="browserIdBackgroundColor">",
  "browserIdAutoLogin":"<TMPL_VAR NAME="browserIdAutoLogin">"
  }
  </script>
  <!-- //if:jsminified
    <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">common/js/browserid.min.js"></script>
    <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">common/js/browseridlogin.min.js"></script>
  //else -->
    <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">common/js/browserid.js"></script>
    <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">common/js/browseridlogin.js"></script>
  <!-- //endif -->
 </TMPL_IF>
 <TMPL_IF NAME="browserIdLoadLogoutScript">
  <!-- //if:jsminified
    <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">common/js/browserid.min.js"></script>
    <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">common/js/browseridlogout.min.js"></script>
  //else -->
    <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">common/js/browserid.js"></script>
    <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">common/js/browseridlogout.js"></script>
  <!-- //endif -->
 </TMPL_IF>
 <script type="application/init">
 {
 "displaytab":"<TMPL_VAR NAME="DISPLAY_TAB">",
 "choicetab":"<TMPL_VAR NAME="CHOICE_VALUE">",
 "login":"<TMPL_VAR NAME="LOGIN">",
 "newwindow":"<TMPL_VAR NAME="NEWWINDOW">",
 "antiframe":"<TMPL_VAR NAME="ANTIFRAME">",
 "appslistorder":"<TMPL_VAR NAME="APPSLIST_ORDER">",
 "scriptname":"<TMPL_VAR NAME="SCRIPT_NAME">",
 "activeTimer":"<TMPL_VAR NAME="ACTIVE_TIMER">",
 "pingInterval":<TMPL_VAR NAME="PING">
 }
 </script>

