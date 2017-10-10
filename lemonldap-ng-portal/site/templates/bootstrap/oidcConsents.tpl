<table class="info">
 <thead>
  <tr>
   <th trspan="service"></th>
  </tr>
 </thead>
 <tbody>
  <TMPL_LOOP NAME="partners">
   <tr partner="<TMPL_VAR NAME="name">">
    <td><TMPL_VAR NAME="name">
     <a partner="<TMPL_VAR NAME="name">" class="oidcConsent link text-danger glyphicon glyphicon-minus-sign"></a>
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
