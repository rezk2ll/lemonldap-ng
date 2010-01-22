/**
 * Lemonldap::NG Portal jQuery scripts
 */

/* Used variables
 * - displaytab
 * - autocomplete
 * - login
 * - newwindow
 */

/* Set autocomplete real value */
if(autocomplete.match('1')){autocomplete='on';}
if(autocomplete.match('0')){autocomplete='off';}

/* jQuery */
$(document).ready(function(){
	$("div.message").fadeIn('slow');
	$("input[name=timezone]").val( -(new Date().getTimezoneOffset()/60) );
	$("#menu").tabs({ fx: { opacity: 'toggle' } });
	$("#menu").tabs("select",displaytab);
	$("input[type!=hidden]:first").focus();
	$("input[type='password']").attr("autocomplete",autocomplete);
	$("#appslist li[class!=catname]").hover(
		function(){
			var appid = $(this).attr("title");
			$("div.appsdesc").hide();
			$("div#" + appid).show();
		},
		function() {
			var appid = $(this).attr("title");
			// Show parent application if this was a sub application
			if ( $("#appslist li[title="+appid+"]").parent().parent().hasClass("appname") ) {
				var parentappid = $("#appslist li[title="+appid+"]").parent().parent().attr("title");
				$("div.appsdesc").hide();
				$("div#" + parentappid).show();
			}
		}
	);
	if(login){ $("input[type=password]:first").focus(); }
	if(newwindow){ $('#appslist a[href^="http://"]').attr("target", "_blank"); }
});
