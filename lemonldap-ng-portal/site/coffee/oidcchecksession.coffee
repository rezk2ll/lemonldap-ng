values = {}

$(document).ready ->
	# Import application/init variables
	$("script[type='application/init']").each ->
		try
			tmp = JSON.parse $(this).text()
			for k of tmp
				values[k] = tmp[k]
		catch e
			console.log 'Parsing error', e
	# Initialize JS communication channel
	window.addEventListener "message", receiveMessage, false

# Eval message response
receiveMessage (e) ->
	message = e.data
	client_id = decodeURIComponent message.split(' ')[0]
	session_state = decodeURIComponent message.split(' ')[1]
	salt = decodeURIComponent session_state.split('.')[1]
	ss = hash.toString(CryptoJS.enc.Base64) + '.'  + salt
	if session_state == ss
		stat = 'unchanged'
	else
		stat = 'changed'
	e.source.postMessage stat, e.origin
