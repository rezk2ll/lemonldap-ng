<TMPL_INCLUDE NAME="header.tpl">
</head>
<body>
  <div id="logincontent" class="container">


    <TMPL_IF NAME="AUTH_ERROR">
    <div class="message message-<TMPL_VAR NAME="AUTH_ERROR_TYPE"> alert"><TMPL_VAR NAME="AUTH_ERROR"></div>
    </TMPL_IF>

    <div class="panel panel-default">
      <form action="#" method="post" class="login" role="form">
        <!-- Hidden fields -->
        <TMPL_VAR NAME="HIDDEN_INPUTS">
        <input type="hidden" name="url" value="<TMPL_VAR NAME="AUTH_URL">" />
        <input type="hidden" name="timezone" />
        <TMPL_INCLUDE NAME="standardform.tpl">
      </form>

    </div>
  </div>

<TMPL_INCLUDE NAME="scripts.tpl">
<TMPL_INCLUDE NAME="footer.tpl">
