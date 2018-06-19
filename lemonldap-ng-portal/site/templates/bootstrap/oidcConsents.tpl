<table class="info">
 <thead>
  <tr>
   <th trspan="service">Service</th>
   <th trspan="date">Date</th>
   <th trspan="scope">Scope</th>
   <th trspan="action">Action</th>
  </tr>
 </thead>
 <tbody>
  <TMPL_LOOP NAME="partners">
   <tr partner="<TMPL_VAR NAME="name">">
    <td><TMPL_VAR NAME="displayName"></td>
    <td class="localeDate" val="<TMPL_VAR NAME="time">"></td>
    <td><TMPL_VAR NAME="scope"></td>
    <td><a partner="<TMPL_VAR NAME="name">" title="delete" class="oidcConsent link nodecor text-danger glyphicon glyphicon-minus-sign"></a></td>
    </td>
   </tr>
  </TMPL_LOOP>
 </tbody>
</table>
<script type="application/init">
{
 "oidcConsents":"<TMPL_VAR NAME="consents">"
}
</script>
