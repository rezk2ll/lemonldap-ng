<TMPL_INCLUDE NAME="header.tpl">

<div class="container">
  <div class="message message-positive alert" trspan="choose2f"></div>
    <div class="alert alert-info">
	<table class="table table-hover table-condensed table-responsive">
      <thead>
        <tr>
          <th>TYPE</th>
          <th>NAME</th>
          <th>DATE</th>
          <th>ACTION</th>
        </tr>
      </thead>
      <tbody>
        <TMPL_LOOP NAME="SFDEVICES">
          <tr>
          <td><TMPL_VAR NAME="type"></td><td><TMPL_VAR NAME="name"></td><td><TMPL_VAR NAME="epoch"></td>
          <td><button type="button" name="sup" class="btn btn-danger">Supprimer</button></td>
          </tr>
        </TMPL_LOOP>
      </tbody>
    </table>
    </div>
  <div class="buttons"> 
    <TMPL_LOOP NAME="MODULES">
	  &nbsp;&nbsp;
      <a href="<TMPL_VAR NAME="URL">">
        <img src="<TMPL_VAR NAME="STATIC_PREFIX"><TMPL_VAR NAME="SKIN">/<TMPL_VAR NAME="LOGO">" alt="<TMPL_VAR NAME="CODE">2F" />
      </a>
      &nbsp;&nbsp;
    </TMPL_LOOP>
  </div>
</div>
<br>
<div class="buttons">
  <a href="<TMPL_VAR NAME="PORTAL_URL">" class="btn btn-primary" role="button">
    <span class="glyphicon glyphicon-home"></span>&nbsp;
    <span trspan="goToPortal">Go to portal</span>
  </a>
</div>

<TMPL_INCLUDE NAME="footer.tpl">

