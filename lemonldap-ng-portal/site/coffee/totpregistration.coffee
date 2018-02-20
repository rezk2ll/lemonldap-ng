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
		data:
			newkey: reset
		error: displayError
		# Display key and QR code
		success: (data) ->
			console.log data
			# Generate OTP url
			s = "otpauth://totp/#{escape(data.portal)}:#{escape(data.user)}?secret=#{data.secret}&issuer=#{escape(data.portal)}"
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
				setMsg 'yourTotpKey', 'info'
			token = data.token

$(document).ready ->
	getKey(0)
