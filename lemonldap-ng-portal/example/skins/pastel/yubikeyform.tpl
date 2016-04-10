<h3 trspan="enterYubikey">Please use your Yubikey</h3>

<table>
	<tr>
		<td><input name="yubikeyOTP" type="text" /></td>
	</tr>

	<TMPL_IF NAME="CHECK_LOGINS">
		<tr><td colspan="2"><div class="buttons">
			<label for="checkLogins">
				<input type="checkbox" id="checkLogins" name="checkLogins" <TMPL_IF NAME="ASK_LOGINS">checked</TMPL_IF>/>
				<span trspan="checkLastLogins">Check my last logins</span>
			</label>
		</div></td></tr>
	</TMPL_IF>

	<tr><td>
		<div class="buttons">
			<button type="reset" class="negative" tabindex="4">
				<img src="<TMPL_VAR NAME="SKIN_PATH">/common/cancel.png" alt="" />
				<span trspan="cancel">Cancel</span>
			</button>
			<button type="submit" class="positive" tabindex="3">
				<img src="<TMPL_VAR NAME="SKIN_PATH">/common/accept.png" alt="" />
				<span trspan="connect">Connect</span>
			</button>
		</div>
	</td></tr>

</table>

