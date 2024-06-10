###
LemonLDAP::NG WebAuthn verify script
###

setMsg = (msg, level) ->
	$('#msg').attr 'trspan', msg
	$('#msg').html window.translate msg
	$('#color').removeClass 'message-positive message-warning message-danger alert-success alert-warning alert-danger'
	$('#color').addClass "message-#{level}"
	level = 'success' if level == 'positive'
	$('#color').addClass "alert-#{level}"

check = ->
	if !webauthnJSON.supported()
		setMsg 'webAuthnUnsupported', 'warning'
		return

	e = jQuery.Event( "webauthnAttempt" )
	$(document).trigger e
	if !e.isDefaultPrevented()
		setMsg 'webAuthnBrowserInProgress', 'warning'
		request = { publicKey: window.datas.request }
		webauthnJSON.get request
		. then (response) ->
			e = jQuery.Event( "webauthnSuccess" )
			$(document).trigger e, [ response ]
			if !e.isDefaultPrevented()
				$('#credential').val JSON.stringify response
				$('#credential').closest('form').submit()
		. catch (error) ->
			e = jQuery.Event( "webauthnFailure" )
			$(document).trigger e, [ error ]
			if !e.isDefaultPrevented()
				setMsg 'webAuthnBrowserFailed', 'danger'

$(document).on "portalLoaded", { }, ( event, info ) ->
			$(document).ready ->
				$('#retrybutton').on 'click', check
				$('.webauthnclick').on 'click', check
				if window.datas.webauthn_autostart
					setTimeout check, 1000
