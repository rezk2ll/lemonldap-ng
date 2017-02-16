<TMPL_INCLUDE NAME="header.tpl">

<div id="menucontent">

  <TMPL_IF NAME="AUTH_ERROR">
  <div class="message <TMPL_VAR NAME="AUTH_ERROR_TYPE">"><ul><li trmsg="<TMPL_VAR NAME="AUTH_ERROR">"></li></ul></div>
  </TMPL_IF>

  <div id="menu">

    <div class="user"><span trspan="connectedAs">Connected as</span> <TMPL_VAR NAME="AUTH_USER"> <span id="languages"></span></div>

    <TMPL_IF DISPLAY_MODULES>
    <!-- Tabs list -->
      <ul>
        <TMPL_LOOP NAME="DISPLAY_MODULES">

          <TMPL_IF NAME="Appslist">
            <li><a href="#appslist"><span>
              <img src="<TMPL_VAR NAME="STATIC_PREFIX">/common/application_cascade.png" width="16" height="16" alt="appslist" />
              <span trspan="yourApps">Your applications</span>
            </span></a></li>
          </TMPL_IF>
          <TMPL_IF NAME="ChangePassword">
            <li><a href="#password"><span>
              <img src="<TMPL_VAR NAME="STATIC_PREFIX">/common/vcard_edit.png" width="16" height="16" alt="password" />
              <span trspan="password">Password</span>
            </span></a></li>
          </TMPL_IF>
          <TMPL_IF NAME="LoginHistory">
            <li><a href="#loginHistory"><span>
              <img src="<TMPL_VAR NAME="STATIC_PREFIX">/common/calendar.png" width="16" height="16" alt="login history" />
              <span trspan="loginHistory">Login history</span>
            </span></a></li>
          </TMPL_IF>
          <TMPL_IF NAME="Logout">
            <li><a href="#logout"><span>
              <img src="<TMPL_VAR NAME="STATIC_PREFIX">/common/door_out.png" width="16" height="16" alt="logout" />
              <span trspan="logout">Logout</span>
            </span></a></li>
          </TMPL_IF>
        </TMPL_LOOP>
      </ul>
    </TMPL_IF>

    <div class="menulogo"></div>
    <!-- Tabs content -->
    <TMPL_LOOP NAME="DISPLAY_MODULES">

      <TMPL_IF NAME="Appslist">
        <div id="appslist">

          <TMPL_LOOP NAME="APPSLIST_LOOP">
          <!-- Template loops -->

            <TMPL_IF NAME="category">
            <!-- Category -->

              <div class="category cat-level-<TMPL_VAR NAME="catlevel"> <TMPL_VAR NAME="catid">" id="sort_<TMPL_VAR NAME="__counter__">">
                <h3 class="catname"><TMPL_VAR NAME="catname"></h3>

                  <TMPL_IF applications>
                    <!-- Applications -->

                    <TMPL_LOOP NAME=applications>

                      <!-- Application -->

                      <div class="application <TMPL_VAR NAME="appid">">

                        <!-- Logo (optional) -->
                        <TMPL_IF NAME="applogo">
                          <img src="<TMPL_VAR NAME="STATIC_PREFIX">/common/apps/<TMPL_VAR NAME="applogo">"
                            class="applogo <TMPL_VAR NAME="appid">"
                            alt="<TMPL_VAR NAME="appname">" />
                        </TMPL_IF>

                        <!-- Name and link (mandatory) -->
                        <h4 class="appname <TMPL_VAR NAME="appid">">
                          <a href="<TMPL_VAR NAME="appuri">" title="<TMPL_VAR NAME="appname">">
                          <TMPL_VAR NAME="appname">
                          </a>
                        </h4>

                        <!-- Logo (optional) -->
                        <TMPL_IF NAME="appdesc">
                          <p class="appdesc <TMPL_VAR NAME="appid">">
                            <TMPL_VAR NAME="appdesc">
                          </p>
                        </TMPL_IF>

                        <div class="clearfix"></div>
                      </div>

                    <!-- End of applications loop -->
                    </TMPL_LOOP>
                  </TMPL_IF>

                  <TMPL_IF categories>
                    <!-- Sub categories -->

                    <TMPL_LOOP NAME=categories>
                      <div class="category cat-level-<TMPL_VAR NAME="catlevel">">
                        <h3 class="catname"><TMPL_VAR NAME="catname"></h3>

                        <TMPL_IF applications>
                          <!-- Applications in sub category -->

                          <TMPL_LOOP NAME=applications>

                            <!-- Application in sub category-->

                            <div class="application <TMPL_VAR NAME="appid">">

                              <!-- Logo (optional) -->
                              <TMPL_IF NAME="applogo">
                                <img src="<TMPL_VAR NAME="STATIC_PREFIX">/common/apps/<TMPL_VAR NAME="applogo">"
                                  class="applogo <TMPL_VAR NAME="appid">"
                                  alt="<TMPL_VAR NAME="appname">" />
                              </TMPL_IF>

                              <!-- Name and link (mandatory) -->
                              <h4 class="appname <TMPL_VAR NAME="appid">">
                                <a href="<TMPL_VAR NAME="appuri">" title="<TMPL_VAR NAME="appname">">
                                  <TMPL_VAR NAME="appname">
                                </a>
                              </h4>

                              <!-- Logo (optional) -->
                              <TMPL_IF NAME="appdesc">
                                <p class="appdesc <TMPL_VAR NAME="appid">">
                                  <TMPL_VAR NAME="appdesc">
                                </p>
                              </TMPL_IF>

                              <div class="clearfix"></div>
                            </div>

                            <!-- End of applications loop -->
                          </TMPL_LOOP>
                        </TMPL_IF>

                        <div class="clearfix"></div>
                      </div>

                    <!-- End of sub categories loop -->
                    </TMPL_LOOP>
                  </TMPL_IF>

                  <div class="clearfix"></div>
                </div>

              <!-- End of categories loop -->
            </TMPL_IF>
          </TMPL_LOOP>

        </div>
      </TMPL_IF>

      <TMPL_IF NAME="ChangePassword">
        <TMPL_INCLUDE NAME="password.tpl">
      </TMPL_IF>

      <TMPL_IF NAME="LoginHistory">
        <div id="loginHistory">
          <div class="form">
            <TMPL_IF NAME="SUCCESS_LOGIN">
              <h3 trspan="lastLogins">Last logins</h3>
              <TMPL_VAR NAME="SUCCESS_LOGIN">
            </TMPL_IF>
            <TMPL_IF NAME="FAILED_LOGIN">
              <h3 trspan="lastFailedLogins">Last failed logins</h3>
              <TMPL_VAR NAME="FAILED_LOGIN">
            </TMPL_IF>
          </div>
        </div>
      </TMPL_IF>

      <TMPL_IF NAME="Logout">
        <div id="logout">
          <h3 trspan="areYouSure">Are you sure ?</h3>
          <div class="buttons">
            <a href="<TMPL_VAR NAME="LOGOUT_URL">" class="positive">
              <span><img src="<TMPL_VAR NAME="STATIC_PREFIX">/common/accept.png" alt="ok"/> <span trspan="imSure">I'm sure</span></span>
            </a>
          </div>
        </div>
      </TMPL_IF>

    </TMPL_LOOP>

  </div>

</div>

<TMPL_IF NAME="PING">
<!-- Keep session alive -->
</TMPL_IF>

<TMPL_INCLUDE NAME="footer.tpl">
