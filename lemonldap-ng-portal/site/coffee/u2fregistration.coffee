###
LemonLDAP::NG U2F registration script
###

setMsg = (msg, level) ->
	$('#msg').html window.translate msg
	$('#color').removeClass 'message-positive message-warning alert-success alert-warning'
	$('#color').addClass "message-#{level}"
	level = 'success' if level == 'positive'
	$('#color').addClass "alert-#{level}"

displayError = (j, status, err) ->
	console.log 'Error', err
	res = JSON.parse j.responseText
	if res and res.error
		res = res.error.replace /.* /, ''
		console.log 'Returned error', res
		setMsg res, 'warning'

# Registration function (launched by "register" button)
register = ->
	# 1 get registration token
	$.ajax
		type: "POST",
		url: "#{portal}u2fregister/register"
		data: {}
		dataType: 'json'
		error: displayError
		success: (ch) ->
			# 2 build response
			request = [
				challenge: ch.challenge
				version: ch.version
			]
			setMsg 'touchU2fDevice', 'positive'
			$('#u2fPermission').show()
			u2f.register ch.appId, request, [], (data) ->
				$('#u2fPermission').hide()
				# Handle errors
				if data.errorCode
					setMsg 'unableToGetU2FKey', 'warning'
				else
					# 3 send response
					$.ajax
						type: "POST"
						url: "#{portal}u2fregister/registration"
						data:
							registration: JSON.stringify data
							challenge: JSON.stringify ch
						dataType: 'json'
						success: (resp) ->
							if resp.error
								setMsg 'u2fFailed', 'warning'
							else if resp.result
								setMsg 'u2fRegistered', 'positive'
						error: displayError

# Unregistration function (launched by "unregister" button)
unregister = ->
		$.ajax
			type: "POST"
			url: "#{portal}u2fregister/unregistration"
			data: {}
			dataType: 'json'
			error: displayError
			success: (resp) ->
				if resp.error
					setMsg 'u2fFailed', 'warning'
				else if resp.result
					setMsg 'u2fUnregistered', 'positive'
			error: displayError

# Verification function (launched by "verify" button)
verify = ->
	# 1 get challenge
	$.ajax
		type: "POST",
		url: "#{portal}u2fregister/verify"
		data: {}
		dataType: 'json'
		error: displayError
		success: (ch) ->
			# 2 build response
			request = [
				keyHandle: ch.keyHandle
				version: ch.version
			]
			setMsg 'touchU2fDevice', 'positive'
			u2f.sign ch.appId, ch.challenge, request, (data) ->
				# Handle errors
				if data.errorCode
					setMsg 'unableToGetU2FKey', 'warning'
				else
					# 3 send response
					$.ajax
						type: "POST"
						url: "#{portal}u2fregister/signature"
						data:
							signature: JSON.stringify data
						dataType: 'json'
						success: (resp) ->
							if resp.error
								setMsg 'u2fFailed', 'warning'
							else if resp.result
								setMsg 'u2fSuccess', 'positive'
						error: (j, status, err) ->
							console.log 'error', err

# Register "click" events
$(document).ready ->
	$('#u2fPermission').hide()
	$('#register').on 'click', register
	$('#unregister').on 'click', unregister
	$('#verify').on 'click', verify
	$('#goback').attr 'href', portal
