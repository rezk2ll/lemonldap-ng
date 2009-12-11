<!DOCTYPE html
	PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
<head>
<title>Lemonldap::NG Manager</title>
<link rel="stylesheet" type="text/css" href="<TMPL_VAR NAME="DIR">/manager.css" />
<script src="<TMPL_VAR NAME="DIR">/xlib.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/jquery.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/tree.js" type="text/JavaScript"></script>
<script type="text/JavaScript">//<![CDATA[
var scriptname='<TMPL_VAR NAME="SCRIPT_NAME">';var imagepath='<TMPL_VAR NAME="DIR">/';
//]]></script>
<script src="<TMPL_VAR NAME="DIR">/manager.js" type="text/JavaScript"></script>
<meta http-equiv="Content-Type" content="text/html; charset=utf8" />
</head>
<body>
<div class="clsTemporaryContainer">
 <div style="visibility: visible;" id="idSplitter3" class="clsSplitter">
  <div style="z-index: 2;" id="gauche" class="clsPane">
   <img style="padding:4px;padding-left:12px;" alt="Lemonldap::NG" src="<TMPL_VAR NAME="DIR">/logo_lemonldap-ng.png"/><br/>&nbsp;
   <TMPL_VAR NAME="MENU">
</div><!-- end Pane -->
<div style="overflow: hidden; z-index: 2;" id="droit" class="clsPane">
 <div style="visibility: visible;" id="idSplitter32" class="clsSplitter">
  <div style="z-index: 2;overflow:auto;height:500px;" id="haut" class="clsPane">
   <h2 id="content_title">Lemonldap::NG Manager</h2>
   <div id="buttons">
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
   <form action="#" onsubmit="return false">
   <div id="content">
    <div id="content_default" class="content">
    Default
    </div>
    <div id="content_text" class="hidden">
    <input type="text" id="text" onchange="setlmdata(currentId,this.value)"/>
    <button onclick="return false">Valider</button>
    </div>
    <div id="content_securedCookie" class="hidden">
    <input id="securedCookie0" type="radio" name="securedCookie" value="0" onclick="setlmdata('li_bGlfL3NlY3VyZWRDb29raWU1','0')" /> Cookie non sécurisé <br/>
    <input id="securedCookie1" type="radio" name="securedCookie" value="1" onclick="setlmdata('li_bGlfL3NlY3VyZWRDb29raWU1','1')" /> Cookie sécurisé <br/>
    <input id="securedCookie2" type="radio" name="securedCookie" value="2" onclick="setlmdata('li_bGlfL3NlY3VyZWRDb29raWU1','2')" /> 2 cookies <br/>
    <button onclick="return false">Valider</button>
    </div>
    <div id="content_int" class="hidden">
    <input type="text" id="int" onchange="setlmdata(currentId,this.value)"/>
    <button onclick="return false">Valider</button>
    </div>
    <div id="content_btext" class="hidden">
    <input type="text" id="btextKey" onchange="setlmtext(currentId,this.value)"/> <input type="text" id="btextValue" onchange="setlmdata(currentId,this.value)"/>
    <button onclick="return false">Valider</button>
    </div>
    <div id="content_rules" class="hidden">
    <textarea id="rulKey" cols="30" rows="2" onchange="setlmtext(currentId,this.value)"></textarea>&nbsp;<textarea id="rulValue" cols="50" rows="2" onchange="setlmdata(currentId,this.value)"></textarea>
    <button onclick="return false">Valider</button>
    </div>
   </div></form>
  </div><!-- end Pane -->
  <div style="z-index: 2;" id="bas" class="clsPane">
   <div id="help">
   </div>
  </div><!-- end Pane -->
  <div style="z-index: 1; cursor: n-resize;" id="barre2" class="clsDragBar clsDragBar-hframe">
   &nbsp;
  </div>
 </div><!-- end Splitter -->
</div><!-- end Pane -->
<div style="z-index: 1; cursor: n-resize;" id="barre3" class="clsDragBar clsDragBar-vframe">
</div>
</div><!-- end Splitter -->
</div><!-- end TemporaryContainer -->

</body>
</html>
