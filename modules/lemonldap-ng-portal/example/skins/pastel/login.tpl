<TMPL_INCLUDE NAME="header.tpl">

	<div id="messages" class="<TMPL_VAR NAME="AUTH_ERROR_TYPE">"><ul><li><TMPL_VAR NAME="AUTH_ERROR"></li></ul></div>

	<div class="loginlogo"></div>

	<TMPL_IF NAME="DISPLAY_FORM">
	<form method="post" class="login">

		<h3>Please enter your credentials</h3>
		
	        <input type="hidden" name="url" value="<TMPL_VAR NAME="AUTH_URL">" />

		<table>
		<tr><th>Login</th>
		<td><input name="user" type="text" /></td>
		</tr>
		<tr><th>Password</th>
		<td><input name="password" type="password" autocomplete="off" /></td>
		</tr>
		<tr><td colspan="2">
		<div class="buttons">
		<button type="reset" class="negative">
			<img src="skins/pastel/error.png" alt="" />
			Cancel
		</button>
		<button type="submit" class="positive">
			<img src="skins/pastel/ok.png" alt="" />
			Submit
		</button>
		</div></td></tr>
		</table>

	</form>
	</TMPL_IF>

	<TMPL_IF NAME="LOGOUT_URL">
		<div class="buttons">
		<a href="<TMPL_VAR NAME="LOGOUT_URL">" class="negative">
			<img src="skins/pastel/stop.png" alt="" />
			Logout
		</a>
		</div>
	</TMPL_IF>

<TMPL_INCLUDE NAME="footer.tpl">
