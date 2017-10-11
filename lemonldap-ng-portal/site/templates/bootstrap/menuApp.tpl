<li title="<TMPL_VAR NAME="id">" class="<TMPL_VAR NAME="id">">
 <span>
  <TMPL_IF NAME="uri">
   <a href="<TMPL_VAR NAME="uri">"><TMPL_VAR NAME="name"></a>
  <TMPL_ELSE>
   <a><TMPL_VAR NAME="name"></a>
  </TMPL_IF>
 </span>
 <TMPL_IF NAME="subapp">
  <ul>
   <TMPL_VAR NAME="subapp">
  </ul>
 </TMPL_IF>
</li>
