<TMPL_INCLUDE NAME="header.tpl">

	<div class="message <TMPL_VAR NAME="AUTH_ERROR_TYPE">"><ul><li><TMPL_VAR NAME="AUTH_ERROR"></li></ul></div>

	<div class="loginlogo"></div>

	<TMPL_IF NAME="DISPLAY_FORM">
	<form action="#" method="post" class="login">

		<h3><lang en="Please enter your credentials" fr="Merci de vous authentifier"/></h3>
		
		<TMPL_VAR NAME="HIDDEN_INPUTS">

	        <p><input type="hidden" name="url" value="<TMPL_VAR NAME="AUTH_URL">" /></p>
	        <p><input type="hidden" name="timezone" /></p>

		<table>
		<tr><th><lang en="Login" fr="Identifiant"/></th>
		<td><input name="user" type="text" value="<TMPL_VAR NAME="LOGIN">" tabindex="1" /></td>
		</tr>
		<tr><th><lang en="Password" fr="Mot de passe"/></th>
		<td><input name="password" type="password" tabindex="2" /></td>
		</tr>
		<tr><td colspan="2">
		<div class="buttons">
		<button type="reset" class="negative" tabindex="4">
			<img src="/skins/common/cancel.png" alt="" />
			<lang en="Cancel" fr="Annuler" />
		</button>
		<button type="submit" class="positive" tabindex="3">
			<img src="/skins/common/accept.png" alt="" />
			<lang en="Connect" fr="Se connecter" />
		</button>
		</div></td></tr>
        <TMPL_IF NAME="DISPLAY_RESETPASSWORD">
                <tr><td colspan="2">
                <div class="buttons">
		<button class="positive" tabindex="5" onclick="$(location).attr('href','<TMPL_VAR NAME="MAIL_URL">');return false">
                        <img src="/skins/common/email.png" alt="" />
                        <lang en="Reset my password" fr="R&eacute;initialiser mon mot de passe"/>
		</button>
                </div></td></tr>
        	</TMPL_IF>
                </table>

        </form>
        </TMPL_IF>

	<TMPL_IF NAME="DISPLAY_OPENID_FORM">
	<form action="#" method="post" class="login">

		<h3><lang en="Please enter your OpenID login" fr="Entrez votre identifiant OpenID"/></h3>
		
		<table>
		<tr>
		<td><input name="openIdUrl" type="text" /></td>
		</tr>
		<tr><td>
		<div class="buttons">
		<button type="reset" class="negative" tabindex="4">
			<img src="/skins/common/cancel.png" alt="" />
			<lang en="Cancel" fr="Annuler" />
		</button>
		<button type="submit" class="positive" tabindex="3">
			<img src="/skins/common/accept.png" alt="" />
			<lang en="Connect" fr="Se connecter" />
		</button>
		</div></td></tr>
                </table>
        </form>
        </TMPL_IF>


	<TMPL_INCLUDE NAME="password.tpl">

	<TMPL_IF NAME="PORTAL_URL">
	<div id="logout">
        <div class="buttons">
                <a href="<TMPL_VAR NAME="PORTAL_URL">" class="positive">
                        <img src="/skins/common/accept.png" alt="" />
                        <lang en="Go to portal" fr="Aller au portail" />
                </a>
	</div>
	</TMPL_IF>

	<TMPL_IF NAME="LOGOUT_URL">
	<div id="logout">
		<div class="buttons">
		<a href="<TMPL_VAR NAME="LOGOUT_URL">" class="negative">
			<img src="/skins/common/cancel.png" alt="" />
			<lang en="Logout" fr="Se d&eacute;connecter"/>
		</a>
		</div>
	</div>
	</TMPL_IF>

<TMPL_INCLUDE NAME="footer.tpl">
