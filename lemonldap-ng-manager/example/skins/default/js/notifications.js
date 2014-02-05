/* function displayNotification(string id)
 * Send an AJAX request to display an active notification
 * @param id concatenation of uid + '_' + ref
 * @return HTML code
 */
function displayNotification(id) {
	$.ajax({
		type: "POST",
		url: scriptname,
		data: {
			'notification': id
		},
		dataType: 'html',
		success: function(data) {
			$('#data').html(data);
		},
		error: function(xhr, ajaxOptions, thrownError) {
			$('#data').html('<h3>Request failed</h3> Error code: ' + xhr.status + ', ' + thrownError);
		}
	});
}

/* function displayNotificationDone(string id)
 * Send an AJAX request to display a done notification
 * @param id internal notification reference
 * @return HTML code
 */
function displayNotificationDone(id) {
	$.ajax({
		type: "POST",
		url: scriptname,
		data: {
			'notificationDone': id
		},
		dataType: 'html',
		success: function(data) {
			$('#data').html(data);
		},
		error: function(xhr, ajaxOptions, thrownError) {
			$('#data').html('<h3>Request failed</h3> Error code: ' + xhr.status + ', ' + thrownError);
		}
	});
}

/* function del(string id)
 * Send an AJAX request to delete a notification (mark as done)
 * @param id concatenation of uid + '_' + ref
 * @return HTML code
 */
function del(id) {
	$.ajax({
		type: "POST",
		url: scriptname,
		data: {
			'delete': id
		},
		dataType: 'html',
		success: function(data) {
			$('#data').html(data);
			$('#uid' + id).remove();
		},
		error: function(xhr, ajaxOptions, thrownError) {
			$('#data').html('<h3>Request failed</h3> Error code: ' + xhr.status + ', ' + thrownError);
		}
	});
}

/* function purge(string id)
 * Send an AJAX request to purge a notification (remove definitely)
 * @param id internal notification reference
 * @return HTML code
 */
function purge(id) {
	$.ajax({
		type: "POST",
		url: scriptname,
		data: {
			'purge': id
		},
		dataType: 'html',
		success: function(data) {
			$('#data').html(data);
		},
		error: function(xhr, ajaxOptions, thrownError) {
			$('#data').html('<h3>Request failed</h3> Error code: ' + xhr.status + ', ' + thrownError);
		}
	});
}
/* function newNotif()
 * Display notification creation form
 */
function newNotif() {
	var data = $("#newNotif").html();
	$('#data').html(data);
	$("#data input#date").datepicker({
		'dateFormat': 'yy-mm-dd'
	});
	return;
}

/* function sendNewNotif()
 * Send an AJAX request to create a notification
 * @return HTML code
 */
function sendNewNotif() {
	// Get data
	var uid = $("input#uid").val();
	var date = $("input#date").val();
	var ref = $("input#ref").val();
	var condition = $("input#condition").val();
	var xml = $("textarea#xml").val();

	// Reset CSS
	$("input#uid").css('border-width', '0');
	$("input#date").css('border-width', '0');
	$("input#ref").css('border-width', '0');
	$("textarea#xml").css('border-width', '0');

	// Check data
	if (!uid) {
		$("input#uid").css('border-color', 'red').css('border-width', '2px').focus();
		return false;
	}
	if (!date) {
		$("input#date").css('border-color', 'red').css('border-width', '2px').focus();
		return false;
	}
	if (!ref) {
		$("input#ref").css('border-color', 'red').css('border-width', '2px').focus();
		return false;
	}
	if (!xml) {
		$("textarea#xml").css('border-color', 'red').css('border-width', '2px').focus();
		return false;
	}

	// Send AJAX request
	$.ajax({
		type: "POST",
		url: scriptname,
		data: {
			'newNotif': {
				'uid': uid,
				'date': date,
				'ref': ref,
				'condition': condition,
				'xml': xml
			}
		},
		dataType: 'html',
		success: function(data) {
			$('#data').html(data);
		},
		error: function(xhr, ajaxOptions, thrownError) {
			$('#data').html('<h3>Request failed</h3> Error code: ' + xhr.status + ', ' + thrownError);
		}
	});
}
