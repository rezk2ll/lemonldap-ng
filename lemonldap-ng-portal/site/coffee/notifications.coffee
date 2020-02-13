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

toggle = (button, notif, epoch) ->
		setMsg msg, 'positive'
		$(".btn-danger").each ->
			$(this).removeClass 'btn-danger'
			$(this).addClass 'btn-success'
		$(".fa-eye-slash").each ->
			$(this).removeClass 'fa-eye-slash'
			$(this).addClass 'fa-eye'
		$(".verify").each ->
			$(this).text window.translate 'verify'
			$(this).attr('trspan', 'verify')
		if notif and epoch
			$("#icon-#{notif}-#{epoch}").removeClass 'fa-eye'
			$("#icon-#{notif}-#{epoch}").addClass 'fa-eye-slash'
			$("#text-#{notif}-#{epoch}").text window.translate 'hide'
			$("#text-#{notif}-#{epoch}").attr('trspan', 'hide')
			button.removeClass 'btn-success'
			button.addClass 'btn-danger'
			$("#myNotification").removeAttr('hidden')
		else
			$("#icon-explorer-button").removeClass 'fa-eye'
			$("#icon-explorer-button").addClass 'fa-eye-slash'
			$("#myNotification").attr('hidden', 'true')
			$("#explorer-button").attr('hidden', 'true')

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
						toggle button, notif, epoch
						$('#displayNotif').html resp.notification
						$('#notifRef').text(notif)
						myDate = new Date(epoch * 1000)
						$('#notifEpoch').text(myDate.toLocaleString())
						$("#explorer-button").removeAttr('hidden')
					else setMsg 'notificationNotFound', 'warning'
		else setMsg 'notificationRetreiveFailed', 'warning'

# Register "click" events
$(document).ready ->
	$(".data-epoch").each ->
		myDate = new Date($(this).text() * 1000)
		$(this).text(myDate.toLocaleString())
	$('#goback').attr 'href', portal
	$('body').on 'click', '.btn-success', () -> viewNotif ( $(this).attr 'notif' ), ( $(this).attr 'epoch' ), $(this)
	$('body').on 'click', '.btn-danger', () -> toggle $(this)
	$('body').on 'click', '.btn-info', () ->
		if $('#explorer').is(':visible')
			$('#explorer').hide()
			$('#color').hide()
			$("#icon-explorer-button").removeClass 'fa-eye-slash'
			$("#icon-explorer-button").addClass 'fa-eye'
		else
			$('#explorer').show()
			$('#color').show()
			$("#icon-explorer-button").removeClass 'fa-eye'
			$("#icon-explorer-button").addClass 'fa-eye-slash'