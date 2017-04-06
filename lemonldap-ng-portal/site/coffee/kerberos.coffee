# Launch Kerberos request

$(document).ready ->
	$.ajax
		dataType: 'json'
		# Called if browser can't find Kerberos ticket will display
		# PE_BADCREDENTIALS
		statusCode:
			401: () ->
				$('#form').submit()
		# If request succeed, cookie is set, posting form to get redirection
		# or menu
		success: (data) ->
			$('#form').submit()
		# Case else, will display PE_BADCREDENTIALS or fallback to next auth
		# backend
		error: () ->
			$('#form').submit()
