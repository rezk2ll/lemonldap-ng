# Timer for confirmation page

i = 5

go = () ->
	$("#form").submit()

timer = () ->
	h = $('#timer').html()
	i-- if i>0
	h = h.replace /\d+/, i
	$('#timer').html h
	setTimeout timer, 1000

$(document).ready ->
	setTimeout go, 5000
	setTimeout timer, 1000
	$(".idploop").on 'click', () ->
		$("#idp").val $(this).attr("val")
	$("#refuse").on 'click', () ->
		$("#confirm").attr "value", $(this).attr("val")
