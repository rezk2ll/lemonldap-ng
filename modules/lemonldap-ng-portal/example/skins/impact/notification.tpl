<TMPL_INCLUDE NAME="header.tpl">

  <div id="content">
    <div id="content-all">
      <div class="title">
        <img src="/skins/<TMPL_VAR NAME="SKIN">/images/logo-ok.png" />
        <lang en="You have some new messages" fr="Vous avez de nouveaux messages"/>
      </div>
      <p></p>

	<form action="#" method="post" class="login">
		<h3><lang en="New message(s)" fr="Nouveaux messages"/>&nbsp;:</h3>
		<table>
		<tr><td>
		<TMPL_VAR NAME="NOTIFICATION">
		<div class="buttons">
			<button type="submit" class="positive">
				<img src="/skins/common/accept.png" alt="" />
				<lang en="Accept" fr="Accepter" />
			</button>
		</div>
		</td></tr>
		</table>
	</form>

</div>

<TMPL_INCLUDE NAME="footer.tpl">
