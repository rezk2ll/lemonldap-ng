###
LemonLDAP::NG Notifications script
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
		console.log 'Returned error', res
		setMsg res, 'warning'

# Delete function (launched by "view" button)
viewNotif = (notif, epoch) ->
		console.log 'Ref:', notif, 'epoch:', epoch
		if notif and epoch
			console.log 'Send AJAX request'
			$.ajax
				type: "GET"
				url: "#{portal}mynotifs/#{notif}"
				data:
					epoch: epoch
				dataType: 'json'
				#error: displayError
				success: (resp) ->
					if resp.result
						console.log 'Notification:', resp.notification
						$('#displayNotif').html resp.notification
						$("#myNotification").removeAttr('hidden')
						$('#notifRef').text(notif)
						myDate = new Date(epoch * 1000)
						$('#notifEpoch').text(myDate.toLocaleString())
					else setMsg 'notifNotFound', 'warning'
				#error: displayError
		else setMsg 'retreiveNotifFailed', 'warning'

# Register "click" events
$(document).ready ->
	#$("#myNotification").hide()
	$('body').on 'click', '.btn-success', () -> viewNotif ( $(this).attr 'notif' ), ( $(this).attr 'epoch' )
	$('#goback').attr 'href', portal
	$(".data-epoch").each ->
		myDate = new Date($(this).text() * 1000)
		$(this).text(myDate.toLocaleString())
