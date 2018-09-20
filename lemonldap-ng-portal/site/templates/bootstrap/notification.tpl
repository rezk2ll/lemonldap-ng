<TMPL_INCLUDE NAME="header.tpl">

<div id="notifcontent" class="container">
  
  <form action="/notifback" method="post" class="notif" role="form">
    <TMPL_VAR NAME="HIDDEN_INPUTS">
    <TMPL_IF NAME="CHOICE_VALUE">
      <input type="hidden" id="authKey" name="<TMPL_VAR NAME="CHOICE_PARAM">" value="<TMPL_VAR NAME="CHOICE_VALUE">" />
    </TMPL_IF>
    <TMPL_IF NAME="AUTH_URL">
      <input type="hidden" name="url" value="<TMPL_VAR NAME="AUTH_URL">" />
    </TMPL_IF>
    <div class="card text-white bg-info">
      <div class="card-header">
        <h3 class="card-title" trspan="gotNewMessages">You have some new messages</h3>
      </div>
      <div class="card-body">
        <div class="form card.card-body">
        <TMPL_VAR NAME="NOTIFICATION">
        </div>
      </div>
    </div>

    <div class="buttons">
      <button type="submit" class="positive btn btn-success">
        <span class="glyphicon glyphicon-ok"></span>
        <span trspan="accept">Accept</span>
      </button>
    </div>

  </form>

</div>

<TMPL_INCLUDE NAME="footer.tpl">
