<TMPL_INCLUDE NAME="header.tpl">

<div class="container">
  <div id="color" class="message message-positive alert"><span id="msg" trspan="choose2f"></span></div>
  <TMPL_IF NAME="SFDEVICES">
    <div class="alert alert-info">
	<table class="table table-hover table-condensed table-responsive">
      <thead>
        <tr>
          <th><span trspan="type">Type</span></th>
          <th><span trspan="name">Name</span></th>
          <th><span trspan="date">Date</span></th>
          <th><span trspan="action">Action</span></th>
        </tr>
      </thead>
      <tbody>
        <TMPL_LOOP NAME="SFDEVICES">
          <tr id='delete-<TMPL_VAR NAME="epoch">'>
	          <td class="align-middle" ><TMPL_VAR NAME="type"></td><td class="align-middle"><TMPL_VAR NAME="name"></td><td class="data-epoch"><TMPL_VAR NAME="epoch"></td>
	          <td>
	           <span device='<TMPL_VAR NAME="type">' epoch='<TMPL_VAR NAME="epoch">' class="btn btn-danger" role="button">
	             <span class="glyphicon glyphicon-minus-sign"></span>&nbsp;
	             <span trspan="unregister">Unregister</span>
	           </span>
	          </td>
          </tr>
        </TMPL_LOOP>
      </tbody>
    </table>
    </div>
  </TMPL_IF>
  <br>
  <div class="buttons"> 
    <TMPL_LOOP NAME="MODULES">
	  &nbsp;&nbsp;
      <a href="<TMPL_VAR NAME="URL">" class="nodecor">
        <img src="<TMPL_VAR NAME="STATIC_PREFIX"><TMPL_VAR NAME="SKIN">/<TMPL_VAR NAME="LOGO">" alt="<TMPL_VAR NAME="CODE">2F" title="<TMPL_VAR NAME="CODE">2F" />
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

<!-- //if:jsminified
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/2fregistration.min.js"></script>
//else -->
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/2fregistration.js"></script>
<!-- //endif -->
<TMPL_INCLUDE NAME="footer.tpl">

