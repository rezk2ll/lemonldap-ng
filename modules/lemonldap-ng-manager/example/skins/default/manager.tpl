<!DOCTYPE html
	PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
<head>
<title>Lemonldap::NG Manager</title>
<link rel="stylesheet" type="text/css" href="<TMPL_VAR NAME="DIR">/manager.css" />
<link rel="stylesheet" type="text/css" href="<TMPL_VAR NAME="DIR">/jquery-ui-1.7.2.custom.css" />
<script src="<TMPL_VAR NAME="DIR">/jquery-1.3.2.min.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/jquery-ui-1.7.2.custom.min.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/tree.js" type="text/JavaScript"></script>
<script type="text/JavaScript">//<![CDATA[
var scriptname='<TMPL_VAR NAME="SCRIPT_NAME">';var imagepath='<TMPL_VAR NAME="DIR">/';
//]]></script>
<script src="<TMPL_VAR NAME="DIR">/manager.js" type="text/JavaScript"></script>
<meta http-equiv="Content-Type" content="text/html; charset=utf8" />
</head>
<body>

<!-- Header -->
<div id="header">
   <img alt="Lemonldap::NG" src="<TMPL_VAR NAME="DIR">/logo_lemonldap-ng.png" class="logo" />
   <p><a href="index.pl"><lang en="Configuration management" fr="Gestion de la configuration"/></a></p>
   <p><a href="sessions.pl"><lang en="Sessions explorer" fr="Explorateur de sessions"/></a></p>
</div>

<!-- Main -->
<div id="page">

<!-- Menu (tree) -->
<div id="menu">
   <TMPL_VAR NAME="MENU">
</div>

<!-- Data -->
<div id="data">

   <!-- All buttons -->
   <div id="buttons">

    <h1>
     <lang en="Available actions" fr="Actions disponibles" />
    </h1>

    <button id="bsave" onclick="uploadConf()" >
     <lang en="Save" fr="Sauver" />
    </button>

    <button id="bapply" onclick="$.post(scriptname,{apply:1},function(data){return 1},'html');" >
     <lang en="Apply" fr="Appliquer" />
    </button>

    <button id="newkbr" style="display:none;" onclick="newKeyR();return false;">
     <lang en="New key" fr="Nouvelle clef" />
    </button>

    <button id="newrbr" style="display:none;" onclick="newRuleR();return false;">
     <lang en="New rule" fr="Nouvelle règle" />
    </button>

    <button id="newkb" style="display:none;" onclick="newKey();return false;">
     <lang en="New key" fr="Nouvelle clef" />
    </button>

    <button id="newrb" style="display:none;" onclick="newRule();return false;">
     <lang en="New rule" fr="Nouvelle règle" />
    </button>

    <button id="delkb" style="display:none;" onclick="delKey();return false;">
     <lang en="Delete key" fr="Effacer la clef" />
    </button>

   </div>

   <form id="edition" action="#" onsubmit="return false">

    <h1>
     <lang en="Values to edit" fr="Valeurs à éditer" />
    </h1>

   <!-- Form content -->
   <div id="content">

    <!-- Default text -->
    <div id="content_default" class="content">
     <lang en="No value" fr="Pas de valeur" />
    </div>

    <!-- Contextual text -->
    <div id="content_text" class="hidden">
     <input type="text" id="text" onchange="setlmdata(currentId,this.value)"/>
    </div>

    <!-- Specific to securedCookie (TODO push in _Struct.pm) -->
    <div id="content_securedCookie" class="hidden">
    <input id="securedCookie0" type="radio" name="securedCookie" value="0" onclick="setlmdata('li_bGlfL3NlY3VyZWRDb29raWU1','0')" /> <lang en="Non secured cookie" fr="Cookie non sécurisé"/><br/>
    <input id="securedCookie1" type="radio" name="securedCookie" value="1" onclick="setlmdata('li_bGlfL3NlY3VyZWRDb29raWU1','1')" /> <lang en="Secured cookie (HTTPS)" fr="Cookie sécurisé (HTTPS)"/><br/>
    <input id="securedCookie2" type="radio" name="securedCookie" value="2" onclick="setlmdata('li_bGlfL3NlY3VyZWRDb29raWU1','2')" /> Double cookie (HTTP and HTTPS)<br/>
    </div>

    <div id="content_int" class="hidden">
    <input type="text" id="int" onchange="setlmdata(currentId,this.value)"/>
    </div>

    <div id="content_btext" class="hidden">
    <input type="text" id="btextKey" onchange="setlmtext(currentId,this.value)"/> <input type="text" id="btextValue" onchange="setlmdata(currentId,this.value)"/>
    </div>

    <div id="content_rules" class="hidden">
    <textarea id="rulKey" cols="30" rows="2" onchange="setlmtext(currentId,this.value)"></textarea>&nbsp;<textarea id="rulValue" cols="50" rows="2" onchange="setlmdata(currentId,this.value)"></textarea>
    </div>

   </div>
  </form>  

</div>

  <hr style="width:0px;clear:both" />

</div>

<div id="help">
  <h1><lang en="Help" fr="Aide"/></h1>

  <div id="help_content">
  <!-- AJAX content -->
     <lang en="Click on the configuration tree to edit parameters" fr="Cliquer sur l'arbre de configuration pour éditer les paramètres" />
  </div>

</div>

</body>
</html>
