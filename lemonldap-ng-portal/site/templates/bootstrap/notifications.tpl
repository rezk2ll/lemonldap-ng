<TMPL_INCLUDE NAME="header.tpl">

<div class="container">
  <div id="color" class="message message-positive alert">
    <span id="msg" trspan='<TMPL_VAR NAME="MSG">'></span>
  </div>
  <TMPL_IF NAME="NOTIFICATIONS">
    <div class="card mb-3 border-secondary">
    <div class="card-body table-responsive">
    <table class="table table-hover">
      <thead>
        <tr>
          <th><span trspan="date">Date</span></th>
          <th><span trspan="reference">Reference</span></th>
          <th><span trspan="action">Action</span></th>
        </tr>
      </thead>
      <tbody>
        <TMPL_LOOP NAME="NOTIFICATIONS">
          <tr>
            <td class="data-epoch"><TMPL_VAR NAME="epoch"></td>
            <td class="align-middle"><TMPL_VAR NAME="reference"></td>
            <td>
              <span notif='<TMPL_VAR NAME="reference">' epoch='<TMPL_VAR NAME="epoch">' class="btn btn-success" role="button">
                <span id='icon-<TMPL_VAR NAME="reference">-<TMPL_VAR NAME="epoch">' class="fa fa-eye"></span>
                <span id='text-<TMPL_VAR NAME="reference">-<TMPL_VAR NAME="epoch">' class="verify" trspan="verify">Verify</span>
	            </span>
	          </td>
          </tr>
        </TMPL_LOOP>
      </tbody>
    </table>
    </div>
    </div>

    <div class="card mb-3 border-info" id='myNotification' hidden>
      <div class="card-header text-white bg-info">
        <h3 class="card-title"><span trspan="validationDate">Validation date</span>: <span id="notifEpoch"></span> - <span trspan="reference">Reference</span>: <span id="notifRef"></span></h3>
      </div>
      <div class="card-body">
        <div class="form">
          <span id='displayNotif'></span>
        </div>
      </div>
    </div>

  </TMPL_IF>
</div>

<div class="buttons">
  <a href="<TMPL_VAR NAME="PORTAL_URL">?cancel=1&skin=<TMPL_VAR NAME="SKIN">" class="btn btn-primary" role="button">
    <span class="fa fa-home"></span>
    <span trspan="goToPortal">Go to portal</span>
  </a>
</div>

<!-- //if:jsminified
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/notifications.min.js"></script>
//else -->
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/notifications.js"></script>
<!-- //endif -->

<TMPL_INCLUDE NAME="footer.tpl">

