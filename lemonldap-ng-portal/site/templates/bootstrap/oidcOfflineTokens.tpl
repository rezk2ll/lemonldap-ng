
<script type="application/init">
</script>
 <div class="card border-secondary">
            <div class="card-header text-white bg-secondary">
              <h4 class="card-title" trspan="oidcOfflineTokens">Oidc Offline tokens</h4>
            </div>
            <div class="card-body buttons">
            <table class="info">
              <thead>
                <tr>
                <th trspan="service">Service</th>
                <th trspan="scope">Scope</th>
                </tr>
              </thead>
              <tbody>
                <TMPL_LOOP NAME="sessions">
                <tr partner="<TMPL_VAR NAME="name">">
                  <td><TMPL_VAR NAME="id"></td>
                  <td><TMPL_VAR NAME="scope" ESCAPE=HTML></td>
                  <td>
                  </td>
                </tr>
                </TMPL_LOOP>
              </tbody>
              </table>
            </div>
          </div>
        </div>