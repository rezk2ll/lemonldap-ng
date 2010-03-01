<TMPL_INCLUDE NAME="header.tpl">

	<div class="message <TMPL_VAR NAME="AUTH_ERROR_TYPE">"><ul><li>
		<lang en="Confirmation" fr="Confirmation"/>
	</li></ul></div>

	<div class="loginlogo"></div>

	<form id="form" action="<TMPL_VAR NAME="URL">" method="post" class="login">
		<p><input type="hidden" name="url" value="<TMPL_VAR NAME="AUTH_URL">" /></p>
		<input type="hidden" id="confirm" name="confirm" value="1" />
		<TMPL_VAR NAME="MSG">
		<p id="timer"><lang en="Automaticaly accept in 5 seconds" fr="Acceptation automatique dans 5 secondes"/></p>
		<table><tbody><tr><th>
		<div class="buttons">
			<button type="submit" class="positive">
				<img src="/skins/common/accept.png" alt="" />
				<lang en="Accept" fr="Accepter" />
			</button>
			<button type="submit" class="negative" onclick="$('#confirm').attr('value','-1');">
				<img src="/skins/common/cancel.png" alt="" />
				<lang en="Refuse" fr="Refuser" />
			</button>
		</div>
		</th></tr></tbody></table>
	</form>
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
