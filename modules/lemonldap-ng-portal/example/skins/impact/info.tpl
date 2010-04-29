<TMPL_INCLUDE NAME="header.tpl">

  <div id="content">
    <div id="content-all">
      <div class="title">
        <img src="/skins/<TMPL_VAR NAME="SKIN">/images/logo-info.png" />
        <lang en="Information" fr="Information" />
      </div>
      <hr class="solid" />
      <p id="timer" class="text-error"><lang en="You'll be redirected in 10 seconds" fr="Vous allez &ecirc;tre redirig&eacute;(e) automatiquement dans 10 secondes"/></p>
      <form id="form" action="<TMPL_VAR NAME="URL">" method="get" class="login">
      <TMPL_VAR NAME="HIDDEN_INPUTS">
      <div id="content-all-info">
        <TMPL_VAR NAME="MSG">
      </div>
        <div class="panel-buttons">
          <button type="reset" class="negative" tabindex="4" onclick="stop();">
            <lang en="Wait" fr="Attendre" />
          </button>
          <button type="submit" class="positive" tabindex="3">
            <lang en="Continuer" fr="Continuer" />
          </button>
        </div>
      </form>
    </div>
  </div>

  <script>
  var i=10;
  var _go=1;
  function stop() {
    _go=0;
    $('#timer').html("...");
    $('#form button[type=submit]').attr('disabled','');
  }
  function go() {
    if(_go) {
      if(isHiddenFormValueSet('HttpRedirect')){
        url=$("#form").attr('action');
        window.location=url;
      }else{
        $("#form").submit();
      }
    }
  }
  function timer() {
    var h=$('#timer').html();
    i--;
    h=h.replace(/\d+/,i);
    $('#timer').html(h);
    window.setTimeout('timer()',1000);
  }
  $(document).ready(function(){
    if(isHiddenFormValueSet('HideSubmitButton')){
      $('#form button[type=submit]').attr('disabled','disabled');
    }
    window.setTimeout('go()',10000);
    window.setTimeout('timer()',1000);
  });
  </script>

<TMPL_INCLUDE NAME="footer.tpl">

