<TMPL_INCLUDE NAME="header.tpl">

	<div class="message <TMPL_VAR NAME="AUTH_ERROR_TYPE">"><ul><li><TMPL_VAR NAME="AUTH_ERROR"></li></ul></div>

	<div id="menu">
		<ul>
		<TMPL_IF NAME="DISPLAY_APPSLIST">
		<li><a href="#appslist"><span><lang en="Your applications" fr="Vos applications" /></span></a></li>
		</TMPL_IF>
		<TMPL_IF NAME="DISPLAY_PASSWORD">
		<li><a href="#password"><span><lang en="Password" fr="Mot de passe" /></span></a></li>
		</TMPL_IF>
		<TMPL_IF NAME="DISPLAY_LOGOUT">
		<li><a href="#logout"><span><lang en="Logout" fr="D&eacute;connexion" /></span></a></li>
		</TMPL_IF>
		</ul>

		<TMPL_IF NAME="DISPLAY_APPSLIST">
		<TMPL_VAR NAME="APPSLIST_DIV">
		</TMPL_IF>

		<TMPL_IF NAME="DISPLAY_PASSWORD">
		<div id="password">
		<form method="post" class="password">
		<h3><lang en="Change your password" fr="Changez votre mot de passe" /></h3>
		<table><tr><th><lang en="New password" fr="Nouveau mot de passe" /></th>
		<td><input name="newpassword" type="password" autocomplete="off" /></td></tr>
		<tr><th><lang en="Confirm password" fr="Confirmez le mot de passe" /></th>
		<td><input name="confirmpassword" type="password" autocomplete="off" /></td></tr>
		<tr><td colspan="2">
                <div class="buttons">
                <button type="reset" class="negative">
                        <img src="skins/pastel/error.png" alt="" />
                        <lang en="Cancel" fr="Annuler" />
                </button>
                <button type="submit" class="positive">
                        <img src="skins/pastel/ok.png" alt="" />
                        <lang en="Submit" fr="Soumettre" />
                </button>
		</div></td></tr>
		</table>
		</form>
		</div>
		</TMPL_IF>
		
		<TMPL_IF NAME="DISPLAY_LOGOUT">
		<div id="logout">
		<h3><lang en="Are you sure ?" fr="&Ecirc;tes vous s&ucirc;r ?" /></h3>
		<div class="buttons">
			<a href="<TMPL_VAR NAME="LOGOUT_URL">" class="positive">
			<lang en="I'm sure" fr="Je suis s&ucirc;r" />
			</a>
		</div>
		</div>
		</TMPL_IF>
	</div>

<TMPL_INCLUDE NAME="footer.tpl">
