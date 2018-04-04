###
LemonLDAP::NG 2F registration script
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

# Delete function (launched by "delete" button)
delete2F = (device, epoch) ->
		if device == 'U2F'
			device = 'u'
		else if device == 'UBK'
				device = 'yubikey'
			else if device == 'TOTP'
					device = 'totp'
				else setMsg 'u2fFailed', 'warning'
		
		$("#delete-#{epoch}").hide()
		
		$.ajax
			type: "POST"
			url: "#{portal}2fregisters/#{device}/delete"
			data:
				epoch: epoch
			dataType: 'json'
			error: displayError
			success: (resp) ->
				if resp.error
					setMsg 'notAuthorized', 'warning'
				else if resp.result
					setMsg 'yourKeyIsUnregistered', 'positive'
			error: displayError

# Register "click" events
$(document).ready ->
	$('body').on 'click', '.btn-danger', () -> delete2F ( $(this).attr 'device' ), ( $(this).attr 'epoch' )
	$('#goback').attr 'href', portal
	$('#data-epoch').each => hide()
