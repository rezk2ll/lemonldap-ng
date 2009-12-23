/**
* Lemonldap::NG Manager jQuery scripts
*/

var simpleTreeCollection;

$(document).ready(function(){
	/* Help div (require jQuery UI) */
	// Allow drag
	$("#help").draggable({ handle: 'h1', opacity: '0.70' });
	// Allow resize
	$("#help").resizable({ handles: 'all', alsoResize: '#help_content', ghost: 'true'});
	// Display/hide content with double click on title bar
	$("#help h1").dblclick(function(){
		$("#help_content").slideToggle('slow');
	});

	/* Simple Tree */
	simpleTreeCollection = $(".simpleTree").simpleTree({
		autoclose: false,
		drag: false,
		afterClick:function(node){
			var span=$('span:first',node);
			$('#help_content').load(scriptname+'?help='+span.attr('help'));
		},
		afterDblClick:function(node){
		//alert("text-"+$("span:first",node).text());
		},
		afterMove:function(destination, source, pos){
		//alert("destination-"+$("span:first",destination).text()+" source-"+$("span:first",source).text()+" pos-"+pos);
		},
		afterAjax:function() {
		//alert("Loaded");
		},
		animate:true
		//,docToFolderConvert:true
	});
});

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
	$('#newkb,#newrb,#delkb,#newkbr,#newrbr').css('display','none');
}
function none(id) {
	display('default','Lemonldap::NG Manager');
}
function hashRoot(){
	currentId=simpleTreeCollection[0].getSelected().attr('id');
	display('default','Lemonldap::NG Manager');
	$('#newkbr').css('display','');
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
	display('btext','Clef');
	$('#newkb,#delkb').css('display','');
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
function rules(id){
	currentId=id;
	var t=lmtext(id);
	$('#rulKey').attr('value',lmtext(id));
	$('#rulValue').attr('value',lmdata(id));
	display('rules',lmtext(lmparent(id)));
	if(t=='default'){$('#rulKey').attr('readonly','readonly')}
	else{
		$('#rulKey').attr('readonly','');
		$('#delkb').css('display','')
	}
	$('#newrb').css('display','');
}
function rulesRoot(id){
	display('default','Lemonldap::NG Manager');
	$('#newrbr').css('display','');
}
function reloadAuthParams() {
	setlmdata(currentId,$('#authText').attr('value'));
	$.ajax({
		type:"POST",
		url:scriptname,
		data:{node:'generalParameters/authParams',conf:'authentication userDB',cfgNum:lmdata('li_cm9vdA2'),authentication:lmdata('li_L3VzZXJEQg2'),userDB:lmdata('li_L3VzZXJEQg2')},
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
function uploadConf(){
	$.ajax({
		type:"POST",
		url:scriptname,
		data:{data: $('#li_cm9vdA2').html()},
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
			}
			if(typeof(data.warnings)!='undefined'){
				for(m in data.warnings){
					c+='<dt>'+m+'</dt><dd>'+data.warnings[m]+'</dd>';
				}
			}
			c+='</dl>';
			$('#help_content').html(c);
		},
		error:function(xhr, ajaxOptions, thrownError){
			$('#help_content').html('<h3>Request failed</h3> Error code: '+xhr.status+', '+thrownError);
		}
	});
}
