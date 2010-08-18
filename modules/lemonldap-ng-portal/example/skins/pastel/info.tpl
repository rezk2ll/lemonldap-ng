<TMPL_INCLUDE NAME="header.tpl">

	<div class="message <TMPL_VAR NAME="AUTH_ERROR_TYPE">"><ul><li>
      <lang en="Information" fr="Information"/>
    </li></ul></div>

	<div class="loginlogo"></div>

	<form id="form" action="<TMPL_VAR NAME="URL">" method="get" class="login">
		<TMPL_VAR NAME="HIDDEN_INPUTS">
		<TMPL_VAR NAME="MSG">
		<p id="timer"><lang en="You'll be redirected in 10 seconds" fr="Vous allez &ecirc;tre redirig&eacute;(e) automatiquement dans 10 secondes"/></p>
		<table><tbody><tr><th>
		<div class="buttons">
			<button type="submit" class="positive">
				<img src="/skins/common/accept.png" alt="" />
				<lang en="Continue" fr="Continuer" />
			</button>
			<button type="reset" class="negative" onclick="stop();">
				<img src="/skins/common/cancel.png" alt="" />
				<lang en="Wait" fr="Attendre" />
			</button>
		</div>
		</th></tr></tbody></table>
	</form>
	<script>
	var i=10;
	var _go=1;
	function stop() {
		_go=0;
		$('#timer').html("...");
	}
	function go() {
		if(_go) {
				$("#form").submit();
			}
		}
	function timer() {
		var h=$('#timer').html();
		if(i>0){i--;}	
		h=h.replace(/\d+/,i);
		$('#timer').html(h);
		window.setTimeout('timer()',1000);
	}
	$(document).ready(function(){
		// Check if timer should be activated (true by default)
		var activeTimer = true;
		if (!<TMPL_VAR NAME="ACTIVE_TIMER">) {activeTimer = false;}

                if (activeTimer) {
		window.setTimeout('go()',10000);
		window.setTimeout('timer()',1000);
		} else {
			stop();
		}
	});
	</script>

<TMPL_INCLUDE NAME="footer.tpl">
