###
LemonLDAP::NG Notifications script
###

msg = $('#msg').attr 'trspan'

setMsg = (msg, level) ->
	$('#msg').html window.translate msg
	$('#color').removeClass 'message-positive message-warning alert-success alert-warning'
	$('#color').addClass "message-#{level}"
	level = 'success' if level == 'positive'
	$('#color').addClass "alert-#{level}"

displayError = (j, status, err) ->
	setMsg 'notificationRetreiveFailed', 'warning'

toggle = (button, verif) ->
		setMsg msg, 'positive'
		if verif
			$("#myNotification").attr('hidden', 'true')
			button.removeClass 'btn-danger'
			button.addClass 'btn-success'
		else
			$("#myNotification").removeAttr('hidden')
			$(".btn-danger").each ->
				$(this).removeClass 'btn-danger'
				$(this).addClass 'btn-success'
			button.removeClass 'btn-success'
			button.addClass 'btn-danger'

# viewNotif function (launched by "verify" button)
viewNotif = (notif, epoch, button) ->
		console.log 'Ref:', notif, 'epoch:', epoch
		if notif and epoch
			console.log 'Send AJAX request'
			$.ajax
				type: "GET"
				url: "#{portal}mynotifications/#{notif}"
				data:
					epoch: epoch
				dataType: 'json'
				error: displayError
				success: (resp) ->
					if resp.result
						console.log 'Notification:', resp.notification
						toggle button, 0
						$('#displayNotif').html resp.notification
						$('#notifRef').text(notif)
						myDate = new Date(epoch * 1000)
						$('#notifEpoch').text(myDate.toLocaleString())
					else setMsg 'notificationNotFound', 'warning'
		else setMsg 'notificationRetreiveFailed', 'warning'

# Register "click" events
$(document).ready ->
	$(".data-epoch").each ->
		myDate = new Date($(this).text() * 1000)
		$(this).text(myDate.toLocaleString())
	$('#goback').attr 'href', portal
	$('body').on 'click', '.btn-success', () -> viewNotif ( $(this).attr 'notif' ), ( $(this).attr 'epoch' ), $(this)
	$('body').on 'click', '.btn-danger', () -> toggle $(this), 1

