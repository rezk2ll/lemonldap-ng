<TMPL_INCLUDE NAME="header.tpl">

<main id="menucontent" class="container">

  <TMPL_IF NAME="AUTH_ERROR">
  <div class="message message-<TMPL_VAR NAME="AUTH_ERROR_TYPE"> alert"><span trmsg="<TMPL_VAR NAME="AUTH_ERROR">"></span></div>
  </TMPL_IF>

  <div id="menu">

  <div class="nav navbar-default">

    <div class="navbar-header">

    <button class="navbar-toggle" data-target=".navbar-collapse" data-toggle="collapse" type="button">
        <span class="sr-only">
            Toggle navigation
        </span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
    </button>
    <a class="navbar-brand" href="#">
      <span class="glyphicon glyphicon-home"></span>
    </a>

    </div>

    <TMPL_IF DISPLAY_MODULES>

    <div class="navbar-collapse collapse">
    <!-- Tabs list -->
      <ul class="nav navbar-nav">
        <TMPL_LOOP NAME="DISPLAY_MODULES">

          <TMPL_IF NAME="Appslist">
            <li><a href="#appslist"><span>
              <img src="<TMPL_VAR NAME="STATIC_PREFIX">common/icons/application_cascade.png" width="16" height="16" alt="appslist" />
              <span trspan="yourApps">Your applications</span>
            </span></a></li>
          </TMPL_IF>
          <TMPL_IF NAME="ChangePassword">
            <li><a href="#password"><span>
              <img src="<TMPL_VAR NAME="STATIC_PREFIX">common/icons/vcard_edit.png" width="16" height="16" alt="password" />
              <span trspan="password">Password</span>
            </span></a></li>
          </TMPL_IF>
          <TMPL_IF NAME="LoginHistory">
            <li><a href="#loginHistory"><span>
              <img src="<TMPL_VAR NAME="STATIC_PREFIX">common/icons/calendar.png" width="16" height="16" alt="login history" />
              <span trspan="loginHistory">Login history</span>
            </span></a></li>
          </TMPL_IF>
          <TMPL_IF NAME="OidcConsents">
            <li><a href="#oidcConsents"><span>
              <!-- TODO: change logo -->
              <img src="<TMPL_VAR NAME="STATIC_PREFIX">common/icons/calendar.png" width="16" height="16" alt="login history" />
              <span trspan="oidcConsents">OIDC Consent</span>
            </span></a></li>
          </TMPL_IF>
          <TMPL_IF NAME="Logout">
            <li><a href="#logout"><span>
              <img src="<TMPL_VAR NAME="STATIC_PREFIX">common/icons/door_out.png" width="16" height="16" alt="logout" />
              <span trspan="logout">Logout</span>
            </span></a></li>
          </TMPL_IF>
        </TMPL_LOOP>
      </ul>

      <ul class="user nav navbar-nav navbar-right">
        <li class="dropdown">
          <a href="#" class="dropdown-toggle" data-toggle="dropdown">
            <span trspan="connectedAs">Connected as</span> <TMPL_VAR NAME="AUTH_USER">
            <span class="caret"></span>
          </a>
          <ul class="dropdown-menu" role="menu">
            <li><a href="/refresh">
              <img src="<TMPL_VAR NAME="STATIC_PREFIX">common/icons/arrow_refresh.png" width="16" height="16" alt="refresh" />
              <span trspan="refreshrights">Refresh</span>
            </a></li>
          </ul>
        </li>
      </ul>

    </div>
    </TMPL_IF>

    </div>

    <!-- Tabs content -->
    <TMPL_LOOP NAME="DISPLAY_MODULES">

      <TMPL_IF NAME="Appslist">
        <div id="appslist">

          <TMPL_LOOP NAME="APPSLIST_LOOP">
          <!-- Template loops -->

            <TMPL_IF NAME="category">
            <!-- Category -->

              <div class="category cat-level-<TMPL_VAR NAME="catlevel"> <TMPL_VAR NAME="catid"> panel panel-info" id="sort_<TMPL_VAR NAME="__counter__">">

                <div class="panel-heading">
                <h3 class="catname panel-title"><TMPL_VAR NAME="catname"></h3>
                </div>

                  <TMPL_IF applications>
                  <div class="panel-body">
                    <!-- Applications -->

                    <div class="row">
                    <TMPL_LOOP NAME=applications>

                      <!-- Application -->
                      <div class="col-md-4">
                      <div class="application <TMPL_VAR NAME="appid"> panel panel-default">
                        <a class="btn btn-link" href="<TMPL_VAR NAME="appuri">" title="<TMPL_VAR NAME="appname">" role="button">

                        <div class="row">
                        <!-- Logo (optional) -->
                        <TMPL_IF NAME="applogo">
                          <div class="col-xs-3">
                          <img src="<TMPL_VAR NAME="STATIC_PREFIX">common/apps/<TMPL_VAR NAME="applogo">"
                            class="applogo <TMPL_VAR NAME="appid">"
                            alt="<TMPL_VAR NAME="appname">" />
                          </div>
                          <div class="col-xs-9">
                        <TMPL_ELSE>
                          <div class="col-xs-12">
                        </TMPL_IF>
                        
                        <!-- Name and link (mandatory) -->
                        <h4 class="appname <TMPL_VAR NAME="appid"> text-center">
                          <TMPL_VAR NAME="appname">
                        </h4>

                        <!-- Description (optional) -->
                        <TMPL_IF NAME="appdesc">
                          <p class="appdesc <TMPL_VAR NAME="appid"> hidden-xs">
                            <TMPL_VAR NAME="appdesc">
                          </p>
                        </TMPL_IF>

                          </div>
                        </div>
                        </a>

                      </div>
                      </div>


                    <!-- End of applications loop -->
                    </TMPL_LOOP>
                    </div>

                  </div>
                  </TMPL_IF>

                </div>

              <!-- End of categories loop -->
            </TMPL_IF>
          </TMPL_LOOP>

        </div>
      </TMPL_IF>

      <TMPL_IF NAME="ChangePassword">
        <div id="password">
            <div class="panel panel-info">
              <div class="panel-heading">
              <h3 class="panel-title" trspan="changePwd">Change your password</h3>
              </div>
              <div class="panel-body">
              <TMPL_INCLUDE NAME="password.tpl">
              </div>
            </div>
        </div>
      </TMPL_IF>

      <TMPL_IF NAME="LoginHistory">
        <div id="loginHistory">
            <TMPL_IF NAME="SUCCESS_LOGIN">
            <div class="panel panel-info">
              <div class="panel-heading">
              <h3 class="panel-title" trspan="lastLogins">Last logins</h3>
              </div>
              <div class="panel-body">
              <TMPL_VAR NAME="SUCCESS_LOGIN">
              </div>
            </div>
            </TMPL_IF>
            <TMPL_IF NAME="FAILED_LOGIN">
            <div class="panel panel-info">
              <div class="panel-heading">
              <h3 class="panel-title" trspan="lastFailedLogins">Last failed logins</h3>
              </div>
              <div class="panel-body">
              <TMPL_VAR NAME="FAILED_LOGIN">
              </div>
            </div>
            </TMPL_IF>
        </div>
      </TMPL_IF>

      <TMPL_IF NAME="OidcConsents">
        <div id="oidcConsents">
            <div class="panel panel-info">
              <div class="panel-heading">
              <h3 class="panel-title" trspan="oidcConsentsFull">OpenID-Connect Consents</h3>
              </div>
              <div class="panel-body">
              <TMPL_VAR NAME="OIDC_CONSENTS">
              </div>
            </div>
        </div>
      </TMPL_IF>

      <TMPL_IF NAME="Logout">
        <div id="logout">
          <div class="panel panel-info">
            <div class="panel-heading">
              <h3 class="panel-title" trspan="areYouSure">Are you sure ?</h3>
            </div>
            <div class="panel-body buttons">
            <a href="<TMPL_VAR NAME="LOGOUT_URL">" class="btn btn-success" role="button">
              <span class="glyphicon glyphicon-ok"></span>
              <span trspan="imSure">I'm sure</span>
            </a>
            </div>
          </div>
        </div>
      </TMPL_IF>

    </TMPL_LOOP>

  </div>

</main>

<TMPL_IF NAME="PING">
<!-- Keep session alive -->
</TMPL_IF>

<TMPL_INCLUDE NAME="footer.tpl">
