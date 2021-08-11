<TMPL_INCLUDE NAME="mail_header.tpl">

<p>
<span trspan="hello">Hello</span> <TMPL_VAR NAME="session_cn" ESCAPE=HTML>,<br />
<br />
<a href="<TMPL_VAR NAME="url" ESCAPE=HTML>" style="text-decoration:none;color:orange;">
<span trspan="host">Host</span> <b><TMPL_VAR NAME="host"></b></br>
<span trspan="date">Date</span> <b><TMPL_VAR NAME="newLocationDate"></b>
</a>
</p>

<TMPL_INCLUDE NAME="mail_footer.tpl">
