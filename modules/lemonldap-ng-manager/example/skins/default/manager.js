/**
* Lemonldap::NG Manager jQuery scripts
*/

/* Init simpleTreeCollection */
var simpleTreeCollection;

/* Convert boolean strings into javascript booleans */
if (treeautoclose.match('true')){ treeautoclose = true; } else { treeautoclose = false; }
if (treejquerycss.match('true')){ treejquerycss = true; } else { treejquerycss = false; }

$(document).ready(function(){
	/* Display/hide divs */
	$("#buttons h1").click(function(){
		$("#buttons_content").slideToggle('fast');
	});
	$("#edition h1").click(function(){
		$("#content").slideToggle('fast');
	});
	$("#help h1").click(function(){
		$("#help_content").slideToggle('fast');
	});

	/* Load default help */
	$('#help_content').load(scriptname+'?help=default');

	/* Simple Tree */
	simpleTreeCollection = $(".simpleTree").simpleTree({
		autoclose:treeautoclose,
		useClickToToggle:true,
		drag:false,
		afterClick:function(node){
			var span=$('span:first',node);
			$('#help_content').load(scriptname+'?help='+span.attr('help'));
			simpleTreeDefaultJqueryClasses();
			simpleTreeToggleJqueryClasses();
		},
		afterCloseNearby:function(node){
			simpleTreeDefaultJqueryClasses();
			simpleTreeToggleJqueryClasses();
		},
		afterNewNode:function(node){
			simpleTreeDefaultJqueryClasses();
			simpleTreeToggleJqueryClasses();
		},
		afterDblClick:function(node){
			simpleTreeDefaultJqueryClasses();
			simpleTreeToggleJqueryClasses();
		},
		afterSetTrigger:function(node){
			simpleTreeTriggerJqueryClasses();
		},
		afterMove:function(destination, source, pos){
		},
		afterAjax:function() {
			simpleTreeDefaultJqueryClasses();
			simpleTreeToggleJqueryClasses();
		},
		animate:true,
		docToFolderConvert:false
	});
	if(treejquerycss){simpleTreeDefaultJqueryClasses();}

	/* Menu CSS switch */
	if($.cookie("managermenu")) {
		simpleTreeSetMenuStyle($.cookie("managermenu"));
	}
	$("#css-switch a").click(function(){
		var style=$(this).attr("alt");
		$.cookie("managermenu",style, {expires: 365, path: '/'});
		simpleTreeSetMenuStyle(style);
		return false;
	});
});
function simpleTreeSetMenuStyle(style){
	if(style=="tree"){
		$("link[title=menu]").attr("href",imagepath+"tree.css");
		treejquerycss=false;
		simpleTreeCollection[0].option.autoclose=false;
	}else{
		$("link[title=menu]").attr("href",imagepath+"accordion.css");
		treejquerycss=true;
		simpleTreeCollection[0].option.autoclose=true;
	}
	simpleTreeDefaultJqueryClasses();
	simpleTreeToggleJqueryClasses();
}
/* Add jQuery UI CSS classes to simpleTree */
function simpleTreeDefaultJqueryClasses(){
	if (treejquerycss) {
		$(".simpleTree .root > span").addClass("ui-widget-header ui-corner-all");
		$(".simpleTree .folder-open > span").addClass("ui-state-default ui-corner-all");
		$(".simpleTree .folder-open-last > span").addClass("ui-state-default ui-corner-all");
		$(".simpleTree .folder-close > span").addClass("ui-state-default ui-corner-all");
		$(".simpleTree .folder-close-last > span").addClass("ui-state-default ui-corner-all");
		$(".simpleTree .doc > span").addClass("ui-state-default ui-corner-all");
		$(".simpleTree .doc-last > span").addClass("ui-state-default ui-corner-all");
	} else {
		$(".simpleTree span").removeClass("ui-widget-header ui-corner-all ui-state-default");
	}
	simpleTreeTriggerJqueryClasses();
}
function simpleTreeToggleJqueryClasses(){
	if (treejquerycss) {
		$(".simpleTree .folder-open > span").addClass("ui-state-focus");
		$(".simpleTree .folder-open-last > span").addClass("ui-state-focus");
		$(".simpleTree .folder-close > span").removeClass("ui-state-focus");
		$(".simpleTree .folder-close-last > span").removeClass("ui-state-focus");
		$(".simpleTree span.active").addClass("ui-state-active");
		$(".simpleTree span.text").removeClass("ui-state-active");
	} else {
		$(".simpleTree span").removeClass("ui-state-focus ui-state-active");
	}
}
function simpleTreeTriggerJqueryClasses(){
	if (treejquerycss) {
		$(".simpleTree .folder-open > img.trigger").addClass("ui-icon");
		$(".simpleTree .folder-open-last > img.trigger").addClass("ui-icon");
		$(".simpleTree .folder-close > img.trigger").addClass("ui-icon");
		$(".simpleTree .folder-close-last > img.trigger").addClass("ui-icon");

		$(".simpleTree .folder-open > img.trigger")
			.removeClass("ui-icon-triangle-1-e")
			.addClass("ui-icon-triangle-1-s");
		$(".simpleTree .folder-open-last > img.trigger")
			.removeClass("ui-icon-triangle-1-e")
			.addClass("ui-icon-triangle-1-s");
		$(".simpleTree .folder-close > img.trigger")
			.removeClass("ui-icon-triangle-1-s")
			.addClass("ui-icon-triangle-1-e");
		$(".simpleTree .folder-close-last > img.trigger")
			.removeClass("ui-icon-triangle-1-s")
			.addClass("ui-icon-triangle-1-e");
	} else {
		$(".simpleTree img.trigger").removeClass("ui-icon ui-icon-triangle-1-e ui-icon-triangle-1-s");
	}
}
var currentId;
function lmtext(id){
	return $('#text_'+id).attr('name');
}
function lmdata(id){
	return $('#text_'+id).attr('value');
}
function lmparent(id){
	return $('#'+id).parent().parent().attr('id');
}
function setlmtext(id,v){
	if(v.length==0){
		alert("Null value");
	}
	else {
	$('#text_'+id).attr('name',v);
	$('#text_'+id).text(v);
	}
}
function setlmdata(id,v){
	$('#text_'+id).attr('value',v);
}
function display(div,title) {
	var divs=$('#content').children();
	divs.toggleClass('hidden',true);
	divs.removeClass('content');
	$('#content_'+div).removeClass('hidden');
	$('#content_'+div).addClass('content');
	$('#content_title').html(title);
	$('#newkb,#newrb,#delkb,#newkbr,#newrbr,#bdelvh').hide();
}
function none(id) {
	currentId=id;
	display('default','');
}
function hashRoot(){
	currentId=simpleTreeCollection[0].getSelected().attr('id');
	display('default','');
	$('#newkbr').show();
}
function authParams(id) {
	currentId=id;
	$('#authText').attr('value',lmdata(id));
	display('authParams',lmtext(id));
}
function btext(id) {
	currentId=id;
	$('#btextKey').attr('value',lmtext(id));
	$('#btextValue').attr('value',lmdata(id));
	display('btext',lmtext(id));
	$('#newkb,#delkb').show();
}
function bool(id) {
	currentId=id;
	if(lmdata(id)==1){$('#On').attr('checked',true)}else{$('#Off').attr('checked',true)}
	display('bool',lmtext(id));
}
function int(id) {
	currentId=id;
	$('#int').attr('value',lmdata(id));
	display('int',lmtext(id));
}
function text(id) {
	currentId=id;
	$('#text').attr('value',lmdata(id));
	display('text',lmtext(id));
}
function securedCookieValues(id){
	currentId=id;
	$('#securedCookie'+lmdata(id)).attr('checked',1);
	display('securedCookie',lmtext(id));
}
function vhost(id){
	currentId=id;
	$('#vhost').attr('value',lmtext(id));
	display('vhost',lmtext(id));
	$('#bdelvh').show();
}
function cfgDatas(id){
	var span=$('#'+id+' span');
	$('#help_content').load(scriptname+'?help='+span.attr('help'));
	display('cfgDatas','');
	getCfgAttributes();
}
function delvh(id){
	var vhname = $('#text_'+id).attr('name');
	if(confirm('Delete '+vhname+' ?')){$('#'+id).remove();}
}
function rules(id){
	currentId=id;
	var t=lmtext(id);
	$('#rulKey').attr('value',lmtext(id));
	$('#rulValue').attr('value',lmdata(id));
	display('rules',lmtext(lmparent(id)));
	if(t=='default'){$('#rulKey').attr('readonly','readonly')}
	else{
		$('#rulKey').attr('readonly','');
		$('#delkb').show();
	}
	$('#newrb').show();
}
function rulesRoot(id){
	currentId=id;
	display('default','');
	$('#newrbr').show();
}
function reloadAuthParams() {
	setlmdata(currentId,$('#authText').attr('value'));
	$.ajax({
		type:"POST",
		url:scriptname,
		data:{node:'generalParameters/authParams',conf:'authentication userDB',cfgNum:lmdata('li_cm9vdA2'),authentication:lmdata('li_L2F1dGhlbnRpY2F0aW9u0'),userDB:lmdata('li_L3VzZXJEQg2')},
		dataType:'html',
		success:function(data){
			var node=$('#li_Z2VuZXJhbFBhcmFtZXRlcnMvYXV0aFBhcmFtcw2 >ul');
			node.html(data);
			simpleTreeCollection[0].setTreeNodes(node, true);
		},
		error:function(xhr, ajaxOptions, thrownError){
			$('#help_content').html('<h3>Request failed</h3> Error code: '+xhr.status+', '+thrownError);
		}
	});
}
var count=0;
var text4newKey='Key';
var value4newKey='Value';
function newId(c){
	if(!c){return false;}
	count++;
	c=c.replace(/^NewID_(.*)_\d+$/,'$1');
	return 'NewID_'+c+'_'+count;
}
function newKeyR(){
	var newIdValue=newId(currentId);
	simpleTreeCollection[0].addNode(newIdValue,text4newKey,function(d,s){
		$('>span',s).attr('onClick','btext("'+newIdValue+'")').attr('name',text4newKey).attr('value',value4newKey).attr('id','text_'+newIdValue);
		btext(newIdValue);
	});
	return false;
}
function newKey(){
	var newIdValue=newId(currentId);
	simpleTreeCollection[0].newNodeAfter(newIdValue,text4newKey,function(d,s){
		$('>span',s).attr('onClick','btext("'+newIdValue+'")').attr('name',text4newKey).attr('value',value4newKey).attr('id','text_'+newIdValue);
		btext(newIdValue);
	});
	return false;
}
function newRuleR(){
	var newIdValue=newId(currentId);
	simpleTreeCollection[0].addNode(newIdValue,text4newKey,function(d,s){
		$('>span',s).attr('onClick','rules("'+newIdValue+'")').attr('name',text4newKey).attr('value',value4newKey).attr('id','text_'+newIdValue);
		rules(newIdValue);
	});
	return false;
}
function newRule(){
	var newIdValue=newId(currentId);
	simpleTreeCollection[0].newNodeAfter(newIdValue,text4newKey,function(d,s){
		$('>span',s).attr('onClick','rules("'+newIdValue+'")').attr('name',text4newKey).attr('value',value4newKey).attr('id','text_'+newIdValue);
		rules(newIdValue);
	});
	return false;
}
function delKey(){
	$('#'+currentId).prev().remove();
	$('#'+currentId).remove();
}
function newVh(name){
	var vhId='li_'+myB64('/locationRules/'+name);
	simpleTreeCollection[0].newAjaxNodeIn($('#li_L3ZpcnR1YWxIb3N0cw2'),vhId,name,scriptname+'?type=new&node=virtualHosts/'+name,function(d,s){
		$('>span',s).attr('name',name).attr('help','default').attr('id','text_'+vhId).attr('onclick','vhost(\''+vhId+'\')');
	vhost(vhId);
	});
}
var cfgAttrDone=0;
function uploadConf(f){
	if(!(f==1))f=0;
	$.ajax({
		type:"POST",
		url:scriptname,
		data:{data: $('#li_cm9vdA2').html(),force: f},
		dataType:'json',
		success:function(data){
			var c='<h3>'+data.result.msg+'</h3><dl>';
			if(data.result.cfgNum<=0){
				if(typeof(data.errors)!='undefined'){
					for(m in data.errors){
						c+='<dt>'+m+'</dt><dd>'+data.errors[m]+'</dd>';
					}
				}
			}
			else{
				var tmp=lmtext('li_cm9vdA2');
				tmp=tmp.replace(/\d+/,data.result.cfgNum);
				setlmtext('li_cm9vdA2',tmp);
				setlmdata('li_cm9vdA2',data.result.cfgNum);
				$('#cfgNum').text(data.result.cfgNum);
				setCfgAttributes(data.cfgDatas);
				cfgAttrDone++;
			}
			if(typeof(data.warnings)!='undefined'){
				for(m in data.warnings){
					c+='<dt>'+m+'</dt><dd>'+data.warnings[m]+'</dd>';
				}
			}
			c+='</dl>'+data.result.other;
			$('#help_content').html(c);
		},
		error:function(xhr, ajaxOptions, thrownError){
			$('#help_content').html('<h3>Request failed</h3> Error code: '+xhr.status+', '+thrownError);
		}
	});
}
function getCfgAttributes() {
	if(cfgAttrDone>0)return;
	$.ajax({
		type:"POST",
		url:scriptname,
		data:{cfgNum:lmdata('li_cm9vdA2'),cfgAttr:1},
		dataType:'json',
		success:function(data){
			setCfgAttributes(data);
			cfgAttrDone++;
		},
		error:function(xhr, ajaxOptions, thrownError){
			setCfgAttributes({cfgAuthor:'unknown',cfgAuthorIP:'unknown',cfgDate:'unknown'});
		}
	});
}
function setCfgAttributes(data){
	var t = new Array('cfgAuthor','cfgAuthorIP','cfgDate');
	if(data.cfgDate.match(/^\d+$/)){
		var d=new Date(data.cfgDate*1000);
		data.cfgDate=d.toLocaleString();
	}
	for(i in t){
		$('#'+t[i]).text(data[t[i]]);
	}
}
/* Warning, it's not a real base64 */
function myB64(s) {
        var keyStr = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        var chr1, chr2, chr3, enc1, enc2, enc3, enc4;
        var i=0;
        var res="";
	var s2="";
        while (i < s.length) {
                chr1 = s.charCodeAt(i++);
                chr2 = s.charCodeAt(i++);
                chr3 = s.charCodeAt(i++);
                enc1 = chr1 >> 2;
                enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
                enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
                enc4 = chr3 & 63;
		res+=keyStr.charAt(enc1)+keyStr.charAt(enc2);
                if (isNaN(chr2)) {
			res+='2';
			break;
		}
		res+=keyStr.charAt(enc3);
		if (isNaN(chr3)) {
			res+='1';
			break;
		}
		res+=keyStr.charAt(enc4);
		if(i==s.length) {
			res+='0';
		}
        }
	return res;
}
