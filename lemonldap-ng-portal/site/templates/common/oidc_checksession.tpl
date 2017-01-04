<html>
  <head>
    <title>Check Session</title>
<!-- //if:usedebianlibs
    <script type="text/javascript" src="/javascript/cryptojs/components/sha256-min.js"></script>
    <script type="text/javascript" src="/javascript/cryptojs/components/enc-base64-min.js"></script>
 //elsif:jsminified
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/crypto-js/sha256.min.js"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/crypto-js/enc-base64.min.js"></script>
 //else -->
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/crypto-js/sha256.js"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/crypto-js/enc-base64.js"></script>
 <!-- //endif -->
    <script type="text/javascript">//<![CDATA[
function receiveMessage(e){
  var message = e.data;
  client_id = decodeURIComponent(message.split(' ')[0]);
  session_state = decodeURIComponent(message.split(' ')[1]);
  var salt = decodeURIComponent(session_state.split('.')[1]);
  var opbs = document.cookie.replace(/(?:(?:^|.*;\s*)<TMPL_VAR NAME="COOKIENAME">\s*\=\s*([^;]*).*$)|^.*$/, "$1");
  var hash = CryptoJS.SHA256(client_id + ' ' + opbs + ' ' + salt);
  var ss = hash.toString(CryptoJS.enc.Base64) + '.'  + salt;
  if (session_state == ss) {
    stat = 'unchanged';
  } else {
    stat = 'changed';
  }
  e.source.postMessage(stat,e.origin);
}@;
window.addEventListener("message", receiveMessage, false);
    //]]></script>
  </head>
  <body>
  </body>
</html>
