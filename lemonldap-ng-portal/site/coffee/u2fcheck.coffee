###
LemonLDAP::NG U2F verify script
###

check = ->
	registeredKey = [
		keyHandle: window.datas.keyHandle
		version: window.datas.version
	]
	console.log 'Key: ', registeredKey
	u2f.sign window.datas.appId, window.datas.challenge, registeredKey, (data) ->
		$('#verify-data').val JSON.stringify(data)
		$('#verify-challenge').val window.datas.challenge
		$('#verify-form').submit()

$(document).ready ->
	setTimeout check, 1000
