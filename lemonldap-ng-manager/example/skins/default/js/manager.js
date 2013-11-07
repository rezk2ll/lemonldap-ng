/**
* Lemonldap::NG Manager jQuery scripts
*/

/* Help chapters */
var helpCh={
	'advanced':'/pages/documentation/current/start.html#advanced_features',
	'authApache':'/pages/documentation/current/authapache.html',
	'authBrowserID':'/pages/documentation/current/authbrowserid.html',
	'authDBI':'/pages/documentation/current/authdbi.html',
	'authDBIConnection':'/pages/documentation/current/authdbi.html#connection',
	'authDBILevel':'/pages/documentation/current/authdbi.html#authentication_level',
	'authDBIPassword':'/pages/documentation/current/authdbi.html#password',
	'authDBISchema':'/pages/documentation/current/authdbi.html#schema',
	'authCAS':'/pages/documentation/current/authcas.html',
	'authChoice':'/pages/documentation/current/authchoice.html',
	'authFacebook':'/pages/documentation/current/authfacebook.html',
	'authGoogle':'/pages/documentation/current/authgoogle.html',
	'authLDAP':'/pages/documentation/current/authldap.html',
	'authLDAPConnection':'/pages/documentation/current/authldap.html#connection',
	'authLDAPFilters':'/pages/documentation/current/authldap.html#filters',
	'authLDAPGroups':'/pages/documentation/current/authldap.html#groups',
	'authLDAPLevel':'/pages/documentation/current/authldap.html#authentication_level',
	'authLDAPPassword':'/pages/documentation/current/authldap.html#password',
	'authNull':'/pages/documentation/current/authnull.html',
	'authOpenID':'/pages/documentation/current/authopenid.html',
	'authParams':'/pages/documentation/current/start.html#authentication_users_and_password_databases',
	'authProxy':'/pages/documentation/current/authproxy.html',
	'authRemote':'/pages/documentation/current/authremote.html',
	'authSlave':'/pages/documentation/current/authslave.html',
	'authSSL':'/pages/documentation/current/authssl.html',
	'authTwitter':'/pages/documentation/current/authtwitter.html',
	'authWebID':'/pages/documentation/current/authwebid.html',
	'authYubikey':'/pages/documentation/current/authyubikey.html',
	'cookies':'/pages/documentation/current/ssocookie.html',
	'customfunctions':'/pages/documentation/current/customfunctions.html',
	'default':'/pages/documentation/current/start.html#configuration',
	'exportedVars':'/pages/documentation/current/exportedvars.html',
	'headers':'/pages/documentation/current/writingrulesand_headers.html#headers',
	'issuerdb':'/pages/documentation/current/start.html#identity_provider',
	'issuerdbCAS':'/pages/documentation/current/idpcas.html',
	'issuerdbOpenID':'/pages/documentation/current/idpopenid.html',
	'issuerdbSAML':'/pages/documentation/current/idpsaml.html',
	'loginHistory':'/pages/documentation/current/loginhistory.html',
	'logoutforward':'/pages/documentation/current/logoutforward.html',
	'logs':'/pages/documentation/current/logs.html',
	'macrosandgroups':'/pages/documentation/current/exportedvars.html#extend_variables_using_macros_and_groups',
	'menu':'/pages/documentation/current/portalmenu.html',
	'menuCatAndApp':'/pages/documentation/current/portalmenu.html#categories_and_applications',
	'notifications':'/pages/documentation/current/notifications.html',
	'password':'/pages/documentation/current/resetpassword.html',
	'portal':'/pages/documentation/current/ssocookie.html#portal_url',
	'portalcustom':'/pages/documentation/current/portalcustom.html',
	'portalParams':'/pages/documentation/current/portal.html',
	'portalRedirections':'/pages/documentation/current/redirections.html#portal_redirections',
	'post':'/pages/documentation/current/formreplay.html',
	'redirections':'/pages/documentation/current/redirections.html',
	'reloadUrls':'/pages/documentation/current/configlocation.html#configuration_reload',
	'rules':'/pages/documentation/current/writingrulesand_headers.html#rules',
	'samlIDP':'/pages/documentation/current/authsaml.html#register_partner_identity_provider_on_lemonldapng',
	'samlIDPExportedAttributes':'/pages/documentation/current/authsaml.html#exported_attributes',
	'samlIDPMetaDataXML':'/pages/documentation/current/authsaml.html#metadata',
	'samlIDPOptions':'/pages/documentation/current/authsaml.html#options',
	'samlService':'/pages/documentation/current/samlservice.html',
	'samlServiceAA':'/pages/documentation/current/samlservice.html#attribute_authority',
	'samlServiceAdvanced':'/pages/documentation/current/samlservice.html#advanced',
	'samlServiceAuthnContexts':'/pages/documentation/current/samlservice.html#authentication_contexts',
	'samlServiceEntityID':'/pages/documentation/current/samlservice.html#entry_identifier',
	'samlServiceIDP':'/pages/documentation/current/samlservice.html#identity_provider',
	'samlServiceNameIDFormats':'/pages/documentation/current/samlservice.html#nameid_formats',
	'samlServiceOrganization':'/pages/documentation/current/samlservice.html#organization',
	'samlServiceSecurity':'/pages/documentation/current/samlservice.html#security_parameters',
	'samlServiceSP':'/pages/documentation/current/samlservice.html#service_provider',
	'samlSP':'/pages/documentation/current/idpsaml.html#register_partner_service_provider_on_lemonldapng',
	'samlSPExportedAttributes':'/pages/documentation/current/idpsaml.html#exported_attributes',
	'samlSPMetaDataXML':'/pages/documentation/current/idpsaml.html#metadata',
	'samlSPOptions':'/pages/documentation/current/idpsaml.html#options',
	'securetoken':'/pages/documentation/current/securetoken.html',
	'security':'/pages/documentation/current/security.html#configure_security_settings',
	'sessions':'/pages/documentation/current/sessions.html',
	'sessionsdb':'/pages/documentation/current/start.html#sessions_database',
	'sympa':'/pages/documentation/current/applications/sympa.html',
	'userdbParams':'/pages/documentation/current/start.html#authentication_and_users_database',
	'vhostOptions':'/pages/documentation/current/configvhost.html#options',
	'virtualHosts':'/pages/documentation/current/configvhost.html',
	'zimbra':'/pages/documentation/current/applications/zimbra.html'
};

/* Init simpleTreeCollection */
var simpleTreeCollection;

/* Convert boolean strings into javascript booleans */
if (treeautoclose.match('true')){ treeautoclose = true; } else { treeautoclose = false; }
if (treejquerycss.match('true')){ treejquerycss = true; } else { treejquerycss = false; }

$(document).ready(function(){

	/* Menu height */
	resizeMenu();
	jQuery.event.add(window, "load", resizeMenu);
	jQuery.event.add(window, "resize", resizeMenu);
	
	/* Buttons */
	$('#header a').button({icons:{primary:"ui-icon-home"}});
	$('#header span#css-switch-link').button({icons:{primary:"ui-icon-image"}});
	$('#css-switch button[alt=tree]').button({icons:{primary:"ui-icon-grip-dotted-vertical"}});
	$('#css-switch button[alt=accordion]').button({icons:{primary:"ui-icon-grip-dotted-horizontal"}});
	$('#css-switch button[alt=ui-lightness]').button({icons:{primary:"ui-icon-lightbulb"}});
	$('#css-switch button[alt=ui-darkness]').button({icons:{primary:"ui-icon-star"}});
	$('#buttons button').button();
	$('#content button').button();
	$('button#bsave').button({icons:{primary:"ui-icon-disk"}});
	$('button[id*=new]').button({icons:{primary:"ui-icon-circle-plus"}});
	$('button[id*=del]').button({icons:{primary:"ui-icon-circle-minus"}});
	$('#query-switch a[alt=user]').button({icons:{primary:"ui-icon-person"}});
	$('#query-switch a[alt=ip]').button({icons:{primary:"ui-icon-gear"}});
	$('#query-switch a[alt=2ip]').button({icons:{primary:"ui-icon-alert"}});
	$('#query-switch a[alt=list]').button({icons:{primary:"ui-icon-mail-closed"}});
	$('#query-switch a[alt=listDone]').button({icons:{primary:"ui-icon-mail-open"}});
	$('#query-switch a[alt=newNotif]').button({icons:{primary:"ui-icon-circle-plus"}});
	$('#sendNewNotif').button({icons:{primary:"ui-icon-circle-plus"}});

	/* Display/hide divs */
	$("#buttons h1").click(function(){
		$('#buttons h1 img').toggle();
		$("#buttons_content").slideToggle('fast');
	});
	$("#edition h1").click(function(){
		$('#edition h1 img').toggle();
		$("#content").slideToggle('fast');
	});
	$("#help h1").click(function(){
		$('#help h1 img').toggle();
		$("#help_content").slideToggle('fast');
	});

	/* Skin selector dialog */
	$('#skinImagePicker').dialog({
		autoOpen: false,
		minWidth: 500,
		modal: true
	});
	$('#content_skin button.current').click(function(){
		$('#skinImagePicker').dialog( "open" );
		return false;
	});
	$('#skinImagePicker button').click(function(){
		var skin = $("img",this).attr('title');
		changeSkinImage(skin);
		$('#skinImagePicker').dialog( "close" );
		return false;
	});

	/* Apps logo selector dialog */
	$('#appsLogoPicker').dialog({
		autoOpen: false,
		minWidth: 300,
		modal: true
	});
	$('#content_applicationListApplication button.current').click(function(){
		$('#appsLogoPicker').dialog( "open" );
		return false;
	});
	$('#appsLogoPicker button').click(function(){
		var logo = $("img",this).attr('title');
		changeAppsLogo(logo+'.png');
		$('#appsLogoPicker').dialog( "close" );
		return false;
	});

	/* Display configuration datas */
	getCfgAttributes();
	display('cfgDatas','');

	/* Load Simple Tree */
	loadSimpleTree();

	/* Menu CSS switch */
	$('#css-switch').dialog({
		autoOpen: false,
		modal: true
	});
	$('span#css-switch-link').click(function(){
		// Open dialog
		$('#css-switch').dialog( "open" );
		// Fix focus
		$('#css-switch button').each(function(){
			$(this).removeClass('ui-state-focus');
		});
		if($.cookie("managermenu")){css_menu=$.cookie("managermenu");}
		if($.cookie("managertheme")){css_theme=$.cookie("managertheme");}
		$('#css-switch button[alt='+css_menu+']').addClass('ui-state-focus').focus();
		$('#css-switch button[alt='+css_theme+']').addClass('ui-state-focus');
		return false;
	});
	if($.cookie("managermenu")) {
		simpleTreeSetMenuStyle($.cookie("managermenu"));
	}
	if($.cookie("managertheme")) {
		$("link#csstheme").attr("href",themepath+$.cookie("managertheme")+'/jquery-ui-'+jqueryuiversion+'.custom.min.css');
	}
	$("#css-switch #organization button").click(function(){
		var style=$(this).attr("alt");
		$.cookie("managermenu",style, {expires: 365, path: '/'});
		simpleTreeSetMenuStyle(style);
		$('#css-switch').dialog( "close" );
		return false;
	});
	$("#css-switch #theme button").click(function(){
		var theme=$(this).attr("alt");
		$.cookie("managertheme",theme, {expires: 365, path: '/'});
		$("link#csstheme").attr("href",themepath+theme+'/jquery-ui-'+jqueryuiversion+'.custom.min.css');
		$('#css-switch').dialog( "close" );
		return false;
	});

	/* Load default help */
	loadHelp('default');

});
function loadSimpleTree(){

	/* Simple Tree */
	simpleTreeCollection = $(".simpleTree").simpleTree({
		autoclose:treeautoclose,
		useClickToToggle:true,
		drag:false,
		afterClick:function(node){
			var span=$('span:first',node);
			loadHelp(span.attr('help'));
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
		docToFolderConvert:true
	});
	if(treejquerycss){simpleTreeDefaultJqueryClasses();}


}
function simpleTreeSetMenuStyle(style){
	if(style=="tree"){
		$("link#cssmenu").attr("href",csspath+"tree.css");
		treejquerycss=false;
		treeautoclose=false;
		simpleTreeCollection[0].option.autoclose=treeautoclose;
	}else{
		$("link#cssmenu").attr("href",csspath+"accordion.css");
		treejquerycss=true;
		treeautoclose=true;
		simpleTreeCollection[0].option.autoclose=treeautoclose;
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
/* @function string safeSelector(string data)
 * Escape base64 special chars to be compliant with jquery selectors
 * @param data input data
 * @return escaped string
 */
function safeSelector(data){
	var escaped_data = data;
	escaped_data = escaped_data.replace(/\//g,'\\/');
	escaped_data = escaped_data.replace(/\+/g,'\\+');
	escaped_data = escaped_data.replace(/=/g,'\\=');
	return escaped_data;
}
function lmtext(id){
	return $('#text_'+safeSelector(id)).attr('name');
}
function lmdata(id){
	return unescape( $('#text_'+safeSelector(id)).attr('value') );
}
function lmparent(id){
	return $('#'+safeSelector(id)).parent().parent().attr('id');
}
function setlmtext(id,v,prefixvalue){
	if(!prefixvalue){prefixvalue="";}
	if(v.length==0){
		alert("Null value");
	}
	else {
		$('#text_'+safeSelector(id)).attr('name',prefixvalue+v);
		$('#text_'+safeSelector(id)).text(v);
	}
}
function setlminputtext(id,input,prefixvalue){
	var inputname=$(input).attr('id');
	var inputvalue=$(input).val();
	if(!prefixvalue){prefixvalue="";}
	if(inputvalue.length==0){
		alert('No '+inputname);
		return false;
	}
	setlmtext(id,inputvalue,prefixvalue);
}
function setlmdata(id,v){
	$('#text_'+safeSelector(id)).attr('value',escape(v));
}
function setlminputdata(id,input){
	var inputvalue=$(input).val();
	setlmdata(id,inputvalue);
}
function setlmrule(id,c,r,v){
	c=$(c).val();
	r=$(r).val();
	v=$(v).val();
	var re=r;
	var text=r;
	if(c.length>0){
		c=c.replace(/\)/g,']').replace(/\(/g,'[');
		re='(?#'+c+')'+r;
		text=c;
	}
	setlmdata(id,v);
	$('#text_'+safeSelector(id)).attr('name',re);
	$('#text_'+safeSelector(id)).text(text);
}
function setlmgrantsessionrule(id,c,r,v){
        c=$(c).val();
        r=$(r).val();
        v=$(v).val() || '#';
        var re=r;
        var text=r;
        if(c.length>0){
                re=r+'##'+c;
                text=c;
        }
        setlmdata(id,v);
        $('#text_'+safeSelector(id)).attr('name',re);
        $('#text_'+safeSelector(id)).text(text);
}
function setlmfile(id,input){
	var inputname=$(input).attr('id');
	if($(input).attr('value').length==0){
		alert('No '+inputname);
		return false;
	}
	$("#"+inputname+"-loadimg")
	.ajaxStart(function(){
		$(this).show();
	})
	.ajaxComplete(function(){
		$(this).hide();
	});
	$.ajaxFileUpload({
		url:scriptname,
		secureuri:false,
		fileElementId:inputname,
		dataType:'json',
		success:function(data,status){
			if(typeof(data.content.errors) != 'undefined' && data.content.errors != ''){
				popup('<h3>Request failed</h3><ul class="error"><li><strong>Error code:</strong> '+data.content.errors+'</li></ul>');
			}else{
				data.content = data.content.replace(/&lt;/g,'<').replace(/&gt;/g,'>');
				setlmdata(id,data.content);
				$('#filearea').val(lmdata(id));
				display('filearea',lmtext(id));
			}
		},
		error:function(xhr, ajaxOptions, thrownError){
			popup('<h3>Request failed</h3><ul class="error"><li><strong>Error code:</strong> '+xhr.status+', '+thrownError+'</li></ul>');
		}
	});
	/* Remove global event on loading image */
	$("#"+inputname+"-loadimg").unbind('ajaxStart');
	return false;
}
function setlmsamlassertion(id){
	var ind=$('#samlAssertionIndex').val();
	var bin=$('#samlAssertionBinding').val();
	var loc=$('#samlAssertionLocation').val();
	var def=$('input[type=radio][name=samlAssertionDefaultBoolean]:checked').attr("value");
	// Update default value in other assertions.
	var parentId=lmparent(id);
	var t=$('#'+parentId).find('span').get();
	for(i in t){
		if(def=='1'){
			var currentId=$(t[i]).attr('id').replace('text_','');
			if((currentId!=id)&&(currentId!=parentId)){
				var d=lmdata(currentId).split(';');
				d[0]='0';
				setlmdata(currentId,d.join(';'));
			}
		// If off, force on the first one.
		}else if(i<t.length-1){
			var currentId=$(t[t.length-1-i]).attr('id').replace('text_','');
			var d=lmdata(currentId).split(';');
			if(t.length-1-i>1){
				d[0]='0';
			}else{
				d[0]='1';
			}
			setlmdata(currentId,d.join(';'));
			if(currentId==id){
				def='1';
			}
		}
	}
	var v=def+';'+ind+';'+bin+';'+loc;
	setlmdata(id,v);
}
function setlmsamlattribute(id){
	var name=$('#samlAttributeName').val();
	var form=$('#samlAttributeFormat').val();
	var altr=$('#samlAttributeFriendlyName').val();
	var mand=$('input[type=radio][name=samlAttributeMandatoryBoolean]:checked').attr("value");
	var v=mand+';'+name+';'+form+';'+altr;
	setlmtext(id,$('#samlAttributeKey').val());
	setlmdata(id,v);
}
function setlmsamlservice(id){
	var bin=$('#samlServiceBinding').val();
	var loc=$('#samlServiceLocation').val();
	var rep=$('#samlServiceResponseLocation').val();
	var v=bin+';'+loc+';'+rep;
	setlmdata(id,v);
}
function setopenididplist(id){
	var type=$('input[type=radio][name=openIdServerlistBoolean]:checked').attr("value");
	var list=$('#openid_serverlist_text').val();
	setlmdata(id,type+';'+list);
}
function display(div,title) {
	var divs=$('#content').children();
	divs.toggleClass('hidden',true);
	divs.removeClass('content');
	$('#content_'+div).removeClass('hidden');
	$('#content_'+div).addClass('content');
	$('#content_title').html(title);
	$('#newkb,#newrb,#delkb,#newkbr,#newrbr,#newgsrb,#newgsrbr,#bdelvh,#bnewvh').hide();
	$('#newidpsamlmetadatab,#delidpsamlmetadatab').hide();
	$('#newspsamlmetadatab,#delspsamlmetadatab').hide();
	$('#newsamlattributeb,#delsamlattributeb').hide();
	$('#newsamlattributebr').hide();
	$('#newchoicer,#newchoice,#delchoice').hide();
	$('#newcategoryr,#delcategory').hide();
	$('#newapplicationr,#delapplication').hide();
	$('#newpostr,#delpost').hide();
	$('#newpostdatar,#delpostdata').hide();
	// Resize (or hide) Help window
	var height_menu=$('#menu').height();
	var height_buttons_edition=$('#buttons').height()+$('#edition').height();
	var help_height=height_menu-height_buttons_edition-50;
	if(help_height<1){$('#help h1 img').toggle();$('#help_content').toggle();}
	else{$('#help_content').height(help_height);}
}
function none(id) {
	currentId=id;
	display('default','');
}
function hashRoot(id){
	currentId=id;
	display('default','');
	$('#newkbr').show();
}
function vhostRoot(id){
	currentId=id;
	display('default','');
	$('#bnewvh').show();
}
function samlIdpRoot(id){
	currentId=id;
	display('default','');
	$('#newidpsamlmetadatab').show();
}
function samlSpRoot(id){
	currentId=id;
	display('default','');
	$('#newspsamlmetadatab').show();
}
/* @function splitModuleAndOptions(string data)
 * Split module and options from authentication or userDB string
 * @return module, options
 */
function splitModuleAndOptions(data) {

	var module = ''
	var options = '';

	if(data.match(' ')){
	       	module = data.substring(0,data.indexOf(' '));
	       	options = data.substring(data.indexOf(' ')+1);
	}else{
		module = data;
	}

	return Array(module,options);
}

function authParams(id) {
	currentId=id;

	var t=splitModuleAndOptions(lmdata(id));

	// Update options field
		$('#authOptions').val(t[1]);

	if(t[1].length>1){
		$('#authOptions').show();
	}else{
		$('#authOptions').hide();
	}

	// Check Multi
	$('#authText').unbind('change');
	$('#authText').change(function(){
		var isMulti=false;
		$('#content_authParams option:selected').each(function(){
			if($(this).val()=='Multi'){isMulti=true;}
		});
		if(isMulti){
			$('#authOptions').show();
		}else{
			$('#authOptions').hide();
		}
	});

	formateSelectAuth('authText',t[0]);
	display('authParams',lmtext(id));
}
function formateSelectAuth(id,value){
	// Handle "ldap" case for old versions
	if(value && value.toLowerCase()=="ldap"){
		value="LDAP";
	}
	formateSelect(id,[
		'Apache=Apache',
		'AD=Active Directory',
		'BrowserID=BrowserID (Mozilla Persona)',
		'Choice=Authentication choice',
		'CAS=Central Authentication Service (CAS)',
		'DBI=Database (DBI)',
		'Demo=Demonstration',
		'Facebook=Facebook',
		'Google=Google',
		'LDAP=LDAP',
		'Multi=Multiple',
		'Null=None',
		'OpenID=OpenID',
		'Proxy=Proxy',
		'Radius=Radius',
		'Remote=Remote',
		'SAML=SAML v2',
		'Slave=Slave',
		'SSL=SSL',
		'Twitter=Twitter',
		'WebID=WebID',
		'Yubikey=Yubikey'
		],value);
}
function userdbParams(id) {
	currentId=id;

	var t=splitModuleAndOptions(lmdata(id));

	// Update options field
	$('#authOptions').val(t[1]);

	if(t[1].length>1){
		$('#authOptions').show();
	}else{
	$('#authOptions').hide();
	}

	// Check Multi
	$('#authText').unbind('change');
	$('#authText').change(function(){
		var isMulti=false;
		$('#content_authParams option:selected').each(function(){
			if($(this).val()=='Multi'){isMulti=true;}
		});
		if(isMulti){
			$('#authOptions').show();
		}else{
			$('#authOptions').hide();
		}
	});

	formateSelectUser('authText',t[0]);
	display('authParams',lmtext(id));
}
function formateSelectUser(id,value){
	// Handle "ldap" case for old versions
	if(value && value.toLowerCase()=="ldap"){
		value="LDAP";
	}
	formateSelect(id,[
		'AD=Active Directory',
		'DBI=Database (DBI)',
		'Demo=Demonstration',
		'Facebook=Facebook',
		'Google=Google',
		'LDAP=LDAP',
		'Multi=Multiple',
		'Null=None',
		'OpenID=OpenID',
		'Proxy=Proxy',
		'Remote=Remote',
		'SAML=SAML v2',
		'Slave=Slave',
		'WebID=WebID'
		],value);
}
function passworddbParams(id) {
	currentId=id;
	$('#authOptions').hide();
	formateSelectPassword('authText',lmdata(id));
	display('authParams',lmtext(id));
}
function formateSelectPassword(id,value){
	// Handle "ldap" case for old versions
	if(value && value.toLowerCase()=="ldap"){
		value="LDAP";
	}
	formateSelect(id,[
		'AD=Active Directory',
		'DBI=Database (DBI)',
		'Demo=Demonstration',
		'LDAP=LDAP',
		'Null=None'
		],value);
}
function skinSelect(id) {
	currentId=id;
	changeSkinImage(lmdata(id));
	display('skin',lmtext(id));
}
/* Change current skin */
function changeSkinImage(skin) {
	// Set field value
	$('#skinText').val(skin);
	// Set skin to custom if not a registered skin
	// Custom field can the be edited
	if ((skin!='pastel') && (skin!='dark') && (skin!='impact')){
		skin = 'custom';
		$('#skinText').removeAttr('readonly');
	} else {
		$('#skinText').attr('readonly','readonly');
	}
	// Set image source
	var imgsrc = imagepath + 'portal-skins/' + skin + '.png';
	$('#content_skin img.current').attr('src', imgsrc);
	$('#content_skin img.current').attr('alt', skin);
}
function nameIdFormatParams(id) {
	currentId=id;
	formateSelect('select',[
		'=',
		'unspecified=Unspecified',
		'email=Email',
		'x509=X509 certificate',
		'windows=Windows',
		'kerberos=Kerberos',
		'entity=Entity',
		'persistent=Persistent',
		'transient=Transient',
		'encrypted=Encrypted'
		],lmdata(id));
	display('select',lmtext(id));
}
function bindingParams(id) {
	currentId=id;
	formateSelect('select',[
		'=',
		'http-post=POST',
		'http-redirect=REDIRECT',
		'http-soap=SOAP',
		'artifact-get=Artifact GET',
		'artifact-post=Artifact POST'
		],lmdata(id));
	display('select',lmtext(id));
}
function authnContextParams(id) {
	currentId=id;
	formateSelect('select',[
		'=',
		'kerberos=Kerberos',
		'password-protected-transport=Password protected transport',
		'password=Password',
		'tls-client=TLS client certificate',
		],lmdata(id));
	display('select',lmtext(id));
}
function encryptionModeParams(id) {
	currentId=id;
	formateSelect('select',[
		'none=None',
		'nameid=Name ID',
		'assertion=Assertion'
		],lmdata(id));
	display('select',lmtext(id));
}
function timeoutActivityParams(id) {
	currentId=id;
	formateSelect('select',[
		'0=None',
		'900=15 min',
		'1800=30 min',
		'2700=45 min',
		'3600=60 min'
		],lmdata(id));
	display('select',lmtext(id));
}
function zimbraByParams(id) {
	currentId=id;
	formateSelect('select',[
		'=',
		'name=User name',
		'id=User id',
		'foreignPrincipal=Foreign principal'
		],lmdata(id));
	display('select',lmtext(id));
}
function casAccessControlPolicyParams(id) {
	currentId=id;
	formateSelect('select',[
		'none=None',
		'error=Display error on portal',
		'faketicket=Send a fake service ticket'
		],lmdata(id));
	display('select',lmtext(id));
}
function btext(id) {
	currentId=id;
	$('#btextKey').val(lmtext(id));
	$('#btextValue').val(lmdata(id));
	display('btext',lmtext(id));
	$('#btextValue,#btextKey').elastic()
	$('#newkb,#delkb').show();
}
function bool(id) {
	currentId=id;
	if(lmdata(id)==1){$('#On').prop('checked',true)}else{$('#Off').prop('checked',true)}
	display('bool',lmtext(id));
}
function trool(id) {
	currentId=id;
	if(lmdata(id)==1){$('#TrOn').prop('checked',true)}
	else{if(lmdata(id)==0){$('#TrOff').prop('checked',true)}
	else{$('#TrDefault').prop('checked',true)}}
	display('trool',lmtext(id));
}
function int(id) {
	currentId=id;
	$('#int').val(lmdata(id));
	display('int',lmtext(id));
}
function text(id) {
	currentId=id;
	$('#text').val(lmdata(id));
	display('text',lmtext(id));
}
function textarea(id) {
	currentId=id;
	$('#textarea').val(lmdata(id));
	display('textarea',lmtext(id));
}
function filearea(id) {
	currentId=id;
	$('#urlinput').hide();
	$('#downloadfile').hide();
	$('#generatefile').hide();
	$('#filearea').val(lmdata(id));
	/* Only samlIDPMetaDataXML and samlSPMetaDataXML element could be loaded from URL */
	if(lmtext(id)=='samlIDPMetaDataXML'){$('#urlinput').show();}
	if(lmtext(id)=='samlSPMetaDataXML') {$('#urlinput').show();}
	/* Only samlServicePrivateKey* elements could generate keys */
	if(lmtext(id)=='samlServicePrivateKeySig'){$('#generatefile').show();}
	if(lmtext(id)=='samlServicePrivateKeyEnc'){$('#generatefile').show();}
	/* If data, then allow to download */
	if(lmdata(id).length){$('#downloadfile').show();}
	/* Set switchReadonly text */
	$('#switchreadonly span').text(text4edit);
	display('filearea',lmtext(id));
}
function samlAssertion(id) {
	currentId=id;
	var t=lmdata(id).split(';');

	// Reset text fields
	$('#samlAssertionIndex').removeAttr('value');
	$('#samlAssertionLocation').removeAttr('value');

	// Fill fields
	if(t[0]==1){
		$('#samlAssertionDefaultOn').prop('checked',true);
	}else{
		$('#samlAssertionDefaultOff').prop('checked',true);
	}
	$('#samlAssertionIndex').val(t[1]);
	formateSelect('samlAssertionBinding',[
		'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact=Artifact',
		'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST=HTTP POST',
		'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect=HTTP Redirect',
		'urn:oasis:names:tc:SAML:2.0:bindings:SOAP=SOAP'
		],t[2]);
	$('#samlAssertionLocation').val(t[3]);
	display('samlAssertion',lmtext(id));
}
function samlAttribute(id) {
	currentId=id;
	var t=lmdata(id).split(';');

	// Reset text fields
	$('#samlAttributeKey').removeAttr('value');
	$('#samlAttributeName').removeAttr('value');
	$('#samlAttributeFriendlyName').removeAttr('value');

	// Fill fields
	if(t[0]==1){
		$('#samlAttributeMandatoryOn').prop('checked',true);
	}else{
		$('#samlAttributeMandatoryOff').prop('checked',true);
	}
	$('#samlAttributeKey').val(lmtext(id));
	$('#samlAttributeName').val(t[1]);
	formateSelect('samlAttributeFormat',[
		'=',
		'urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified=Unspecified',
		'urn:oasis:names:tc:SAML:2.0:attrname-format:uri=URI',
		'urn:oasis:names:tc:SAML:2.0:attrname-format:basic=Basic'
		],t[2]);
	$('#samlAttributeFriendlyName').val(t[3]);
	display('samlAttribute',lmtext(id));
	$('#newsamlattributeb,#delsamlattributeb').show();
}
function samlAttributeRoot(id){
	currentId=id;
	display('default','');
	$('#newsamlattributebr').show();
}
function samlIdpMetaData(id){
	currentId=id;
	$('#samlIdpMetaData').val(lmtext(id));
	display('samlIdpMetaData',lmtext(id));
	if($('#li_'+myB64('/samlIDPMetaDataNode')).find('span').size()==1){
		$('#delidpsamlmetadatab').hide();
	}else{
		$('#delidpsamlmetadatab').show();
	}
	$('#newidpsamlmetadatab').show();
}
function samlSpMetaData(id){
	currentId=id;
	$('#samlSpMetaData').val(lmtext(id));
	display('samlSpMetaData',lmtext(id));
	if($('#li_'+myB64('/samlSPMetaDataNode')).find('span').size()==1){
		$('#delspsamlmetadatab').hide();
	}else{
		$('#delspsamlmetadatab').show();
	}
	$('#newspsamlmetadatab').show();
}
function samlService(id) {
	currentId=id;
	var t=lmdata(id).split(';');
	formateSelect('samlServiceBinding',[
		'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect=HTTP Redirect',
		'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST=HTTP POST',
		'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact=HTTP Artifact',
		'urn:oasis:names:tc:SAML:2.0:bindings:SOAP=SOAP'
		],t[0]);
	$('#samlServiceLocation').val(t[1]);
	$('#samlServiceResponseLocation').val(t[2]);
	display('samlService',lmtext(id));
}
function openididplist(id) {
	currentId=id;
	var t=lmdata(id).split(';');
	if(t[0]==1){
		$('#openid_serverlist_white').prop('checked',true);
	}else{
		$('#openid_serverlist_black').prop('checked',true);
	}
	$('#openid_serverlist_text').val(t[1]);
	display('openid_serverlist',lmtext(id));
}
function securedCookieValues(id){
	currentId=id;
	formateSelect('select',[
		'0='+text4securedCookie0,
		'1='+text4securedCookie1,
		'2='+text4securedCookie2,
		'3='+text4securedCookie3
		],lmdata(id));
	display('select',lmtext(id));
}
function vhost(id){
	currentId=id;
	$('#vhost').val(lmtext(id));
	display('vhost',lmtext(id));
	$('#bdelvh,#bnewvh').show();
}
function cfgDatas(id){
	var span=$('#'+id+' span');
	loadHelp(span.attr('help'));
	display('cfgDatas','');
	getCfgAttributes();
}
function delvh(id){
	var vhname = lmtext(id);
	if(confirm('Delete '+vhname+' ?')){delKey(id);}
}
function rules(id){
	currentId=id;
	var t=lmtext(id);
	var b=t.match(/^(?:\(\?#(.*?)\))?(.*)/);
	if(typeof(b[1])=='undefined')b[1]='';
	//$('#rulComment').val(b[1]);
	$('#rulComment').val(b[1]);
	$('#rulKey').val(b[2]);
	$('#rulValue').val(lmdata(id));
	display('rules',lmtext(lmparent(id)));
	$('#rulComment,#rulKey,#rulValue').elastic();
	if(t=='default'){
		$('#rulKey').attr('readonly','readonly');
		$('#rulCommentDiv').css('display','none');
	}
	else{
		$('#rulKey').removeAttr('readonly');
		$('#rulCommentDiv').css('display','block');
		$('#delkb').show();
	}
	$('#newrb').show();
}
function rulesRoot(id){
	currentId=id;
	display('default','');
	$('#newrbr').show();
}
function grantSessionRules(id){
	currentId=id;
	var t=lmtext(id);
	var b=t.match(/^(.*?)(?:|##(.*))$/);
	if(typeof(b[2])=='undefined')b[2]='';
	var v=lmdata(id);
	if(v=='#')v=''
	$('#grantSessionRulKey').val(b[1]);
	$('#grantSessionRulComment').val(b[2]);
	$('#grantSessionRulValue').val(v);
	display('grantSessionRules',lmtext(lmparent(id)));
	$('#grantSessionRulKey,#grantSessionRulComment,#grantSessionRulValue').elastic();
	$('#delkb').show();
	$('#newgsrb').show();
}
function grantSessionRulesRoot(id){
	currentId=id;
	display('default','');
	$('#newgsrbr').show();
}
function reloadAuthParams() {
	var value=$('#authText').val();
	if($('#authOptions').is(':visible')){
		value+=' '+$('#authOptions').val();
	}
	setlmdata(currentId,value);
	$.ajax({
		type:"POST",
		url:scriptname,
		data:{node:'generalParameters/authParams',conf:'authentication userDB passwordDB issuerDB',cfgNum:lmdata('li_cm9vdA2'),authentication:lmdata('li_L2F1dGhlbnRpY2F0aW9u0'),userDB:lmdata('li_L3VzZXJEQg2'),passwordDB:lmdata('li_L3Bhc3N3b3JkREI1'),issuerDB:lmdata('li_L2lzc3VlckRC0')},
		dataType:'html',
		success:function(data){
			if(data==null){networkPb()}
			else{
				var node=$('#li_Z2VuZXJhbFBhcmFtZXRlcnMvYXV0aFBhcmFtcw2 >ul');
				node.html(data);
				simpleTreeCollection[0].setTreeNodes(node, true);
				simpleTreeDefaultJqueryClasses();
				simpleTreeToggleJqueryClasses();
			}
		},
		error:function(xhr, ajaxOptions, thrownError){
			popup('<h3>Request failed</h3><ul class="error"><li><strong>Error code:</strong> '+xhr.status+', '+thrownError+'</li></ul>');
		}
	});
}
var count=0;
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
function newGrantSessionRuleR(){
        var newIdValue=newId(currentId);
        simpleTreeCollection[0].addNode(newIdValue,text4newCondition,function(d,s){
                $('>span',s).attr('onClick','grantSessionRules("'+newIdValue+'")').attr('name','##'+text4newCondition).removeAttr('value').attr('id','text_'+newIdValue);
                grantSessionRules(newIdValue);
        });
        return false;
}
function newGrantSessionRule(){
        var newIdValue=newId(currentId);
        simpleTreeCollection[0].newNodeAfter(newIdValue,text4newCondition,function(d,s){
                $('>span',s).attr('onClick','grantSessionRules("'+newIdValue+'")').attr('name','##'+text4newCondition).removeAttr('value').attr('id','text_'+newIdValue);
                grantSessionRules(newIdValue);
        });
        return false;
}
function delKey(id){
	if(!id){id=currentId;}
	$('#'+safeSelector(id)).prev().remove();
	$('#'+safeSelector(id)).remove();
}
function newVh(name){
	// Prompt for virtual host name
	var name = prompt(text4newVhost,'test25.example.com');
	if(!name){return false;}
	var vhId='li_'+myB64('/locationRules/'+name);
	simpleTreeCollection[0].newAjaxNodeIn($('#li_L3ZpcnR1YWxIb3N0cw2'),vhId,name,scriptname+'?type=new&node=virtualHosts/'+name,function(d,s){
		$('>span',s).attr('name',name).attr('help','default').attr('id','text_'+vhId).attr('onclick','vhost(\''+vhId+'\')');
	vhost(vhId);
	});
}
function delSamlAttribute(){
	delKey();
}
function delIdpSamlMetaData(id){
	var idpname = lmtext(id);
	if(confirm('Delete '+idpname+' ?')){
		delKey(id);
		samlIdpMetaData(id);
	}
}
function delSpSamlMetaData(id){
	var spname = lmtext(id);
	if(confirm('Delete '+spname+' ?')){
		delKey(id);
		samlSpMetaData(id);
	}
}
function newSamlAttribute(){
	var newIdValue=newId(currentId);
	simpleTreeCollection[0].newNodeAfter(newIdValue,text4newSamlAttribute,function(d,s){
		$('>span',s).attr('onClick','samlAttribute("'+newIdValue+'")').attr('name',text4newSamlAttribute).attr('value',value4newSamlAttribute).attr('id','text_'+newIdValue);
		samlAttribute(newIdValue);
	});
	return false;
}
function newSamlAttributeR(){
	var newIdValue=newId(currentId);
	simpleTreeCollection[0].addNode(newIdValue,text4newSamlAttribute,function(d,s){
		$('>span',s).attr('onClick','samlAttribute("'+newIdValue+'")').attr('name',text4newSamlAttribute).attr('value',value4newSamlAttribute).attr('id','text_'+newIdValue);
		samlAttribute(newIdValue);
	});
	return false;
}
function newIdpSamlMetaData(){
	var name = prompt(text4newSamlMetaData,'idp-example');
	if(!name){return false;}
	var idpId='li_'+myB64('/samlIDPMetaDataExportedAttributes/'+name);
	simpleTreeCollection[0].newAjaxNodeIn($('#li_L3NhbWxJRFBNZXRhRGF0YU5vZGU1'),idpId,name,scriptname+'?type=new&node=/samlIDPMetaDataNode/'+name,function(d,s){
		$('>span',s).attr('name',name).attr('help','default').attr('id','text_'+idpId).attr('onclick','samlIdpMetaData(\''+idpId+'\')');
		samlIdpMetaData(idpId);
	});
}
function newSpSamlMetaData(){
	var name = prompt(text4newSamlMetaData,'sp-example');
	if(!name){return false;}
	var spId='li_'+myB64('/samlSPMetaDataExportedAttributes/'+name);
	simpleTreeCollection[0].newAjaxNodeIn($('#li_L3NhbWxTUE1ldGFEYXRhTm9kZQ2'),spId,name,scriptname+'?type=new&node=/samlSPMetaDataNode/'+name,function(d,s){
		$('>span',s).attr('name',name).attr('help','default').attr('id','text_'+spId).attr('onclick','samlSpMetaData(\''+spId+'\')');
		samlSpMetaData(spId);
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
			if(data==null){networkPb()}
			else{
				var c='<h3>'+data.content.result.msg+'</h3>';
				if(data.content.result.cfgNum<=0){
					if(typeof(data.content.errors)!='undefined'){
						c+='<h4>Errors</h4>';
						c+='<ul class="error">';
						for(m in data.content.errors){
							c+='<li><strong>'+m+':</strong> '+data.content.errors[m]+'</li>';
						}
						c+='</ul>';
					}
				}
				else{
					// Update configuration attributes
					var cfgNum = data.content.result.cfgNum;
					$('#cfgNum').text(cfgNum);
					setCfgAttributes(data.content.cfgDatas);
					cfgAttrDone++;

					// Reload menu
					$.ajax({
						type:"POST",
						url:scriptname,
						data:{menu:cfgNum},
						dataType:'html',
						success:function(data){
							if(data==null){networkPb()}
							else{
								$("div#menu").html(data);
								loadSimpleTree();
								display('cfgDatas','');
							}
						}
					});


				}
				if(typeof(data.content.warnings)!='undefined'){
					c+='<h4>Warnings</h4>';
					c+='<ul class="warning">';
					for(m in data.content.warnings){
						c+='<li><strong>'+m+':</strong> '+data.content.warnings[m]+'</li>';
					}
						c+='</ul>';
				}
				c+='<p>'+data.content.result.other+'</p>';
				if(typeof(data.content.applyStatus)!='undefined'){
					c+='<h4>Application status</h4>';
					c+='<ul>';
					for(m in data.content.applyStatus){
						c+='<li><strong>'+m+':</strong> '+data.content.applyStatus[m]+'</li>';
					}
					c+='</ul>';
				}
				popup(c);
			}
		},
		error:function(xhr, ajaxOptions, thrownError){
			popup('<h3>Request failed</h3><ul class="error"><li><strong>Error code:</strong> '+xhr.status+', '+thrownError+'</li></ul>');
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
			if(data==null){networkPb()}
			else{
				setCfgAttributes(data.content);
				cfgAttrDone++;
			}
		},
		error:function(xhr, ajaxOptions, thrownError){
			var msg = 'Error code: '+xhr.status+', '+thrownError; 
			setCfgAttributes({cfgAuthor:msg,cfgAuthorIP:msg,cfgDate:msg});
		}
	});
}
function setCfgAttributes(data){
	var t = new Array('cfgAuthor','cfgAuthorIP','cfgDate');

	// Convert date to locale string
	var date = data.cfgDate.toString();
	if(date.match(/^\d+$/)){
		var d=new Date(date*1000);
		data.cfgDate=d.toLocaleString();
	}

	// Set configuration data
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
/* Function to download a file */
function downloadFile(id){
	var content=lmdata(id).replace(/"/g,'&#34;');
	var inputs = '';
	var filename = prompt(text4newFilename,'lemonldap-ng.txt');
	if(!filename){return false;}
	inputs+='<input type="hidden" name="filename" value="'+filename+'" />';
	inputs+='<textarea style="display:none;" name="file">'+content+'</textarea>';
	jQuery('<form action="'+ scriptname +'" method="post" enctype="multipart/form-data">'+inputs+'</form>')
	.appendTo('body').submit().remove();
}
/* Function to generate a file */
function generateFile(id){
	/* If samlServicePrivateKey* elements, then generate keys */
	if(lmtext(id)=='samlServicePrivateKeySig'||lmtext(id)=='samlServicePrivateKeyEnc'){
		var password = prompt(text4newGeneratedFile,'');
		$('#button-loadimg')
		.ajaxStart(function(){
			$(this).show();
		})
		.ajaxComplete(function(){
			$(this).hide();
		});
		$.ajax({
			type:'POST',
			url:scriptname,
			data:{request: 'generateKeys',password: password},
			dataType:'json',
			success:function(data){
				if(data==null){networkPb()}
				else{
					var _public;
					var _id;
					setlmdata(id,data.content.private);
					if(lmtext(id)=='samlServicePrivateKeySig'){_public='samlServicePublicKeySig';}
					if(lmtext(id)=='samlServicePrivateKeyEnc'){_public='samlServicePublicKeyEnc';}
					_id=$('#'+lmparent(id)+' span[name='+_public+']').attr('id').replace(/text_/,'');
					setlmdata(_id,data.content.public);
						_id=$('#'+lmparent(id)+' span[name='+lmtext(id)+'Pwd]').attr('id').replace(/text_/,'');
						setlmdata(_id,password);
					filearea(id);
				}
			},
			error:function(xhr, ajaxOptions, thrownError){
				popup('<h3>Request failed</h3><ul class="error"><li><strong>Error code:</strong> '+xhr.status+', '+thrownError+'</li></ul>');
			}
		});
		$('#button-loadimg').unbind('ajaxStart');
	}
}
/* Could not be called directly in _Struct.pm, required values */
function formateSelect(id,values,selectedValue) {
	var options='';
	for(i=0;i<values.length;i++){
		var key=values[i].substring(0,values[i].indexOf('='));
		var val=values[i].substring(values[i].indexOf('=')+1);
		options+='<option value="'+key+'"';
		if(selectedValue==key){options+=' selected';}
		options+='>'+val+'</option>';
	}
	$('#'+safeSelector(id)).empty().append(options);
}
/* Function to switch readOnly flag */
function switchReadonly(selector) {
	if ( $(selector).attr("readonly") ) {
		$("#switchreadonly span").text(text4protect);
		$(selector).removeAttr("readonly");
	} else {
		$("#switchreadonly span").text(text4edit);
		$(selector).attr("readonly","readonly");
	}
}
/* Increase or decrease integer */
function increase() {
	current = parseInt($("#int").val());
	if (current != NaN){
		$("#int").val(current+1)
	}
}
function decrease() {
	current = parseInt($("#int").val());
	if (current != NaN){
		$("#int").val(current-1)
	}
}
/* Authentication choice */
function authChoiceRoot(id){
	currentId=id;
	display('default','');
	$('#newchoicer').show();
}
function newChoiceR(){
	var newIdValue=newId(currentId);
	simpleTreeCollection[0].addNode(newIdValue,text4newKey,function(d,s){
		$('>span',s).attr('onClick','authChoice("'+newIdValue+'")').attr('name',text4newKey).attr('value','Null|Null|Null|').attr('id','text_'+newIdValue);
		authChoice(newIdValue);
	});
	return false;
}
function newChoice(){
	var newIdValue=newId(currentId);
	simpleTreeCollection[0].newNodeAfter(newIdValue,text4newKey,function(d,s){
		$('>span',s).attr('onClick','authChoice("'+newIdValue+'")').attr('name',text4newKey).attr('value','Null|Null|Null|').attr('id','text_'+newIdValue);
		authChoice(newIdValue);
	});
	return false;
}
function delChoice(){
	delKey();
}
function authChoice(id){
	currentId=id;
	var t=lmdata(id).split('|');
	$('#authChoiceKey').val(lmtext(id));
	formateSelectAuth('authChoiceAuth',t[0]);
	formateSelectUser('authChoiceUser',t[1]);
	formateSelectPassword('authChoicePassword',t[2]);
	$('#authChoiceURL').val(t[3]);
	display('authChoice',lmtext(id));
	$('#newchoice,#delchoice').show();
}
function setlmauthchoice(id){
	var key=$('#authChoiceKey').val();
	var auth=$('#authChoiceAuth').val();
	var user=$('#authChoiceUser').val();
	var password=$('#authChoicePassword').val();
	var url=$('#authChoiceURL').val();
	setlmtext(id,key);
	setlmdata(id,auth+'|'+user+'|'+password+'|'+url);
}

/* Application list */
function applicationListCategoryRoot(id){
	currentId=id;
	display('default','');
	$('#newcategoryr').show();
}

function newCategoryR(){
	var name = prompt(text4newCategory,'mycategory');
	if(!name){return false;}
	var newIdValue=newId(currentId);
	simpleTreeCollection[0].addNode(newIdValue,name,function(d,s){
		$('>span',s).attr('onClick','applicationListCategory("'+newIdValue+'")').attr('name',name).attr('value','My Category').attr('id','text_'+newIdValue);
		applicationListCategory(newIdValue);
	});
	return false;
}

function delCategory(){
	delKey();
}

function applicationListCategory(id){
	currentId=id;
	$('#applicationListCategoryKey').val(lmtext(id));
	$('#applicationListCategoryName').val(lmdata(id));
	display('applicationListCategory',lmtext(id));
	$('#delcategory,#newapplicationr').show();
}

function newApplicationR(){
	var name = prompt(text4newApplication,'myapplication');
	if(!name){return false;}
	var newIdValue=newId(currentId);
	simpleTreeCollection[0].addNode(newIdValue,name,function(d,s){
		$('>span',s).attr('onClick','applicationListApplication("'+newIdValue+'")').attr('name',name).attr('value','My application|http://www.example.com|This is a nice application|logo.png|auto').attr('id','text_'+newIdValue);
		applicationListApplication(newIdValue);
	});
	return false;
}

function delApplication(){
	delKey();
}

function setlmapplication(id){
	var key=$('#applicationListApplicationKey').val();
	var name=$('#applicationListApplicationName').val();
	var url=$('#applicationListApplicationURL').val();
	var desc=$('#applicationListApplicationDescription').val();
	var logo=$('#applicationListApplicationLogo').val();
	var display=$('#applicationListApplicationDisplay').val();
	setlmtext(id,key);
	setlmdata(id,name+'|'+url+'|'+desc+'|'+logo+'|'+display);
}

function applicationListApplication(id){
	currentId=id;
	$('#applicationListApplicationKey').val(lmtext(id));
	var t=lmdata(id).split('|');
	$('#applicationListApplicationName').val(t[0]);
	$('#applicationListApplicationURL').val(t[1]);
	$('#applicationListApplicationDescription').val(t[2]);
	changeAppsLogo(t[3]);
	formateSelect('applicationListApplicationDisplay',[
		'auto=Automatic',
		'on=On',
		'off=Off'
		],t[4]);
	display('applicationListApplication',lmtext(id));
	$('#delapplication').show();
}

/* Change current logo */
function changeAppsLogo(logo) {
	// Set field value
	$('#applicationListApplicationLogo').val(logo);
	// Set logo to custom if not a registered logo
	// Custom field can be edited
	if ((logo!='attach.png') && (logo!='bell.png') && (logo!='bookmark.png') && (logo!='configure.png') && (logo!='database.png') && (logo!='demo.png') && (logo!='docs.png') && (logo!='folder.png') && (logo!='gear.png') && (logo!='help.png') && (logo!='mailappt.png') && (logo!='money.png') && (logo!='network.png') && (logo!='terminal.png') && (logo!='thumbnail.png') && (logo!='tools.png') && (logo!='tux.png') && (logo!='web.png') && (logo!='wheels.png')){
		logo = 'custom.png';
		$('#applicationListApplicationLogo').removeAttr('readonly');
	} else {
		$('#applicationListApplicationLogo').attr('readonly','readonly');
	}
	// Set image source
	var imgsrc = imagepath + 'apps-logos/' + logo;
	$('#content_applicationListApplication img.current').attr('src', imgsrc);
	$('#content_applicationListApplication img.current').attr('alt', logo);
}

/* Post */
function postRoot(id){
	currentId=id;
	display('default','');
	$('#newpostr').show();
}

function newPostR(){
	var newIdValue=newId(currentId);
	var newPostKey = 'none';
	simpleTreeCollection[0].addNode(newIdValue,newPostKey,function(d,s){
		$('>span',s).attr('onClick','post("'+newIdValue+'")').attr('name',newPostKey).removeAttr('value').attr('id','text_'+newIdValue);
		post(newIdValue);
	});
	return false;
}

function newPostDataR(){
	var newIdValue=newId(currentId);
	var newPostKey = 'login';
	simpleTreeCollection[0].addNode(newIdValue,newPostKey,function(d,s){
		$('>span',s).attr('onClick','postData("'+newIdValue+'")').attr('name','postdata:'+newPostKey).attr('value','$uid').attr('id','text_'+newIdValue);
		postData(newIdValue);
	});
	return false;
}

function post(id){
	currentId=id;
	$('#postKey').val(lmtext(id));
	$('#postUrl').val(lmdata(id));
	display('post',lmtext(lmparent(id)));
	$('#delpost,#newpostdatar').show();
}

function postData(id){
	currentId=id;
	var cleankey = lmtext(id).replace('postdata:','');
	$('#postDataKey').val(cleankey);
	$('#postDataValue').val(lmdata(id));
	display('postdata',cleankey);
	$('#delpostdata').show();
}

function delPost(){
	delKey();
}

function delPostData(){
	delKey();
}

/* Popup */
function popup(html){
	$('#popup').html(html);
	$('#popup').dialog({
		show: 'fade',
		hide: 'explode',
		buttons: {
			Ok: function() {
			$( this ).dialog( "close" );
			}
		}
	});
}

function networkPb(){
	popup('<h3>Network problem</h3>');
}

/* Help management */
var lasthelp='';
function loadHelp(ch){
	var url;
	// Keep actual page if no help chapter
	if(!ch){return;}
	// Display default help if help chapter not defined
	if(typeof(helpCh[ch])!='string'){ch='default';}
	// Display new help only if not the last help
	if(ch!=lasthelp){
		url='/doc'+helpCh[ch];
		var html = '<iframe src="'+url+'" frameborder="0" />';
		$('#help_content').html(html);
		lasthelp=ch;
	}
}

/* Resize menu */
function resizeMenu(){
	// Window height
	var wh = $(window).height();
	// Header height
	var hh = $('#header').height();
	// Set menu and data height (include css margins)
	$('#menu').css('height',wh-hh-50);
	$('#data').css('height',wh-hh-40);
}

/* Boolean or Perl Expression */
function boolOrPerlExpr(id){
	currentId=id;
	$('#bopeValue').val('');
	$('#bopeValue').hide();
	if(lmdata(id)==1){
		$('#bopeOn').prop('checked',true);
	}else{
		if(lmdata(id)==0){
			$('#bopeOff').prop('checked',true);
		}else{
			$('#bopeExpr').prop('checked',true);
			$('#bopeValue').val(lmdata(id));
			$('#bopeValue').show();
		}
	}
	display('boolOrPerlExpr',lmtext(id));
}

function setlmbope(id){
	if($('input[type=radio][name=bope]:checked').attr("value")=='-1'){
		setlmdata(id,$('#bopeValue').val());
	}
}
