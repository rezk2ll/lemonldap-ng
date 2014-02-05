function displaySession(id) {
	$.ajax({
		type: "POST",
		url: scriptname,
		data: {
			'session': id
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
			// Delete session from tree
			$('#uid' + id).remove();
			$('#ip' + id).remove();
		},
		error: function(xhr, ajaxOptions, thrownError) {
			$('#data').html('<h3>Request failed</h3> Error code: ' + xhr.status + ', ' + thrownError);
		}
	});
}
