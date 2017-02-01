<TMPL_LOOP NAME="notifications">
<input type="hidden" name="reference<TMPL_VAR NAME="id">" value="<TMPL_VAR NAME="reference">">
<TMPL_IF NAME="title">
<h2 class="notifText">Test title</h2>
</TMPL_IF>
<TMPL_IF NAME="subtitle">
<h3 class="notifText">Test subtitle</h3>
</TMPL_IF>
<TMPL_IF NAME="text">
<p class="notifText">This is a test text</p>
</TMPL_IF>
<TMPL_LOOP NAME="check">
<p class="notifCheck"><label for="check<TMPL_VAR NAME="id">"><input type="checkbox" name="check<TMPL_VAR NAME="id">" id="<TMPL_VAR NAME="id">" value="accepted"><TMPL_VAR NAME="value"></label></p>
</TMPL_LOOP>
</TMPL_LOOP>
