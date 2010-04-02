<TMPL_INCLUDE NAME="header.tpl">

  <div id="content">
    <div id="content-all">
      <div class="title">
        <img src="/skins/<TMPL_VAR NAME="SKIN">/images/logo-info.png" />
        <lang en="Confirmation" fr="Confirmation" />
      </div>
      <hr class="solid" />
      <p id="timer" class="text-error"><lang en="Automaticaly accept in 5 seconds" fr="Acceptation automatique dans 5 secondes"/></p>
      <form id="form" action="<TMPL_VAR NAME="URL">" method="get" class="login">
        <TMPL_VAR NAME="HIDDEN_INPUTS">
        <input type="hidden" name="url" value="<TMPL_VAR NAME="AUTH_URL">" />
        <input type="hidden" id="confirm" name="confirm" value="1" />
        <div id="content-all-info">
          <TMPL_VAR NAME="MSG">
        </div>
        <div class="panel-buttons">
          <button type="reset" class="negative" tabindex="4" onclick="stop();">
            <lang en="Wait" fr="Attendre" />
          </button>
          <button type="submit" class="positive" tabindex="3">
            <lang en="Continue" fr="Continuer" />
          </button>
        </div>
      </form>
    </div>
  </div>

  <script>
  var i=5;
  var _go=1;
  function stop() {
    _go=0;
    $('#timer').html("...");
  }
  function go() {
    if(_go)$("#form").submit();
  }
  function timer() {
    var h=$('#timer').html();
    i--;
    h=h.replace(/\d+/,i);
    $('#timer').html(h);
    window.setTimeout('timer()',1000);
  }
  $(document).ready(function(){
    window.setTimeout('go()',5000);
    window.setTimeout('timer()',1000);
  });
  </script>

<TMPL_INCLUDE NAME="footer.tpl">

