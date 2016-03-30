window.translatePage = (lang) ->
	$("[trspan]").each ->
		this.text translate this.attr 'trspan'

$(document).ready ->
	translatePage(lang)

