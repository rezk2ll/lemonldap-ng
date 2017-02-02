<TMPL_INCLUDE NAME="header.tpl">

<div id="notifcontent">
  
  <div class="message <TMPL_VAR NAME="AUTH_ERROR_TYPE">"><ul><li>
    <span trspan="gotNewMessages">You have some new messages</span>
  </li></ul></div>

  <div class="loginlogo"></div>

  <form action="/notifback" method="post" class="login">
    <TMPL_VAR NAME="HIDDEN_INPUTS">
    <TMPL_IF NAME="CHOICE_VALUE">
      <input type="hidden" id="authKey" name="<TMPL_VAR NAME="CHOICE_PARAM">" value="<TMPL_VAR NAME="CHOICE_VALUE">" />
    </TMPL_IF>
    <TMPL_IF NAME="AUTH_URL">
      <input type="hidden" name="url" value="<TMPL_VAR NAME="AUTH_URL">" />
    </TMPL_IF>
    <h3><span trspan="newMessages">New message(s)</span>&nbsp;:</h3>
    <table>
      <tr><td>
        <TMPL_VAR NAME="NOTIFICATION">
        <div class="buttons">
          <button type="submit" class="positive">
            <img src="<TMPL_VAR NAME="STATIC_PREFIX">common/accept.png" alt="" />
            <span trspan="accept">Accept</span>
          </button>
        </div>
      </td></tr>
    </table>
  </form>

</div>

<TMPL_INCLUDE NAME="footer.tpl">
