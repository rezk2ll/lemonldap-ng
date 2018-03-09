###
LemonLDAP::NG TOTP registration script
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

token=''

getKey = (reset) ->
	$.ajax
		type: "POST",
		url: "#{portal}/totpregister/getkey"
		dataType: 'json'
		data:
			newkey: reset
		error: displayError
		# Display key and QR code
		success: (data) ->
			# Generate OTP url
			s = "otpauth://totp/#{escape(data.portal)}:#{escape(data.user)}?secret=#{data.secret}&issuer=#{escape(data.portal)}"
			if data.digits != 6
				s += "&digits=#{data.digits}"
			if data.interval != 30
				s += "&period=#{data.interval}"
			# Generate QR code
			qr = new QRious
				element: document.getElementById('qr'),
				value: s
				size:150
			# Display serialized key
			$('#serialized').text(s)
			# Show message (warning level if key is new)
			if data.newkey
				setMsg 'yourNewTotpKey', 'warning'
			else
				setMsg 'yourTotpKey', 'success'
			token = data.token

verify = ->
	val = $('#code').val()
	unless val
		setMsg 'fillTheForm', 'warning'
	else
		$.ajax
			type: "POST",
			url: "#{portal}/totpregister/verify"
			dataType: 'json'
			data:
				token: token
				code: val
			error: displayError
			success: (data) ->
				if data.error
					if data.error.match /badCode/
						setMsg 'badCode', 'warning'
					else
						setMsg data.error, 'danger'
				else
					setMsg 'yourKeyIsRegistered', 'success'
					
unregister = ->
	$.ajax
		type: "POST",
		url: "#{portal}/totpregister/unregister"
		data: {}
		dataType: 'json'
		error: displayError
		success: (data) ->
		setMsg 'yourKeyIsUnregistered', 'success'					
					
$(document).ready ->
	getKey(0)
	$('#changekey').on 'click', () ->
		getKey(1)
	$('#verify').on 'click', () ->
		verify()
	$('#unregister').on 'click', () ->
		unregister()
