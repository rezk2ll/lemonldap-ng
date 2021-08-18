<TMPL_INCLUDE NAME="mail_header.tpl">

<p>
<span trspan="hello">Hello</span> <TMPL_VAR NAME="session_cn" ESCAPE=HTML>,<br />
<br />
<h3>Your <a href="<TMPL_VAR NAME="url" ESCAPE=HTML>" style="text-decoration:none;color:orange;"> account was signed in to from a new location.</h3>
<span trspan="host">Host</span> <b><TMPL_VAR NAME="host"></b></br>
<span trspan="date">Date</span> <b><TMPL_VAR NAME="date"></b>
</a>
</p>

<TMPL_INCLUDE NAME="mail_footer.tpl">
