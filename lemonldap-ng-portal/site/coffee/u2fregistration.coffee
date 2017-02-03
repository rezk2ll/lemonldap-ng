###
LemonLDAP::NG U2F registration script
###

register = ->
	request = [
		challenge: window.datas.challenge
		version: 'U2F_V2'
	]
	console.log 'Register: ', request
	u2f.register window.datas.appId, request, [], (data) ->
		$('#bind-data').val JSON.stringify data
		$('#bind-form').submit()

$(document).ready ->
	setTimeout register, 1000
