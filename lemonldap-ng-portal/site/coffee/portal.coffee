###
LemonLDAP::NG Portal jQuery scripts
###

# Translation mechanism

translationFields = {}

translatePage = (lang) ->
	$.getJSON "#{window.staticPrefix}languages/#{lang}.json", (data) ->
		translationFields = data
		$("[trspan]").each ->
			args = $(this).attr('trspan').split(',')
			txt = translate args.shift()
			for v in args
				txt.replace /%[ds]/, v
			$(this).text txt
		$("[trmsg]").each ->
			$(this).text translate "PE#{$(this).attr 'trmsg'}"

translate = (str) ->
	return if translationFields[str] then translationFields[str] else str

window.translate = translate

# Initialization variables
getValues = () ->
	values = {}
	$("script[type='application/init']").each ->
		try
			tmp = JSON.parse $(this).text()
			for k of tmp
				values[k] = tmp[k]
		catch e
			console.log 'Parsing error', e
			console.log 'JSON', $(this).text()
	values

# Set default values

# Code from http://snipplr.com/view/29434/
# ----------------------------------------
setSelector = "#appslist"

# function that writes the list order to session
getOrder = ->
	$.ajax
		type: "POST"
		url: datas['scriptname']
		data:
			storeAppsListOrder: $(setSelector).sortable("toArray").join()
		dataType: 'json'

# function that restores the list order from session
restoreOrder = ->
	list = $(setSelector)
	return null unless list? and datas['appslistorder']

	# make array from saved order
	IDs = datas['appslistorder'].split ','

	# fetch current order
	items = list.sortable "toArray"

	# make array from current order
	rebuild = []
	for v in items
		rebuild[v] = v

	for itemID in IDs
		if itemID in rebuild

			# select item id from current order
			item = rebuild[itemID]

			# select the item according to current order
			child = $(setSelector + ".ui-sortable").children "#" + item

			# select the item according to the saved order
			savedOrd = $(setSelector + ".ui-sortable").children "#" + itemID

			# remove all the items
			child.remove()

			# add the items in turn according to saved order
			# we need to filter here since the "ui-sortable"
			# class is applied to all ul elements and we
			# only want the very first! You can modify this
			# to support multiple lists - not tested!
			$(setSelector + ".ui-sortable").filter(":first").append savedOrd
	1

# function boolean isHiddenFormValueSet(string option)
# Check if an hidden option is set
# @param option Option name
# @return true if option is set, false else
isHiddenFormValueSet = (option) ->
	return $('#lmhidden_' + option).length

# function void ping()
# Check if session is alive on server side
# @return nothing
ping = ->
	$.ajax
		type: "POST"
		url: datas['scriptname']
		data:
			ping: 1
		dataType: 'json'
		success: (data) ->
			if data.result? and data.result == 1
				setTimeout ping, datas['pingInterval']
			else
				location.reload true
		error: (j,t,e) ->
			location.reload true

window.ping = ping

getCookie = (cname) ->
	name = cname + "="
	ca = decodeURIComponent(document.cookie).split ';'
	re = new RegExp('^ *'+cname+'=')
	for c in ca
		if c.match re
			c = c.replace re, ''
			return c
	return ''

setCookie = (name, value, exdays) ->
	d = new Date()
	d.setTime d.getTime() + exdays*86400000
	document.cookie = "#{name}=#{value}; expires=#{d.toUTCString()}; path=/"

# Initialization
datas = {}
$(document).ready ->
	datas = getValues()
	# Export datas for other scripts
	window.datas = datas
	if datas['antiframe'] and top != self
		top.location.href = location.href

	$("#appslist").sortable
		axis: "y"
		cursor: "move"
		opacity: 0.5
		revert: true
		items: "> div.category"
		update: ->
			getOrder()

	restoreOrder()

	$("div.message").fadeIn 'slow'

	# Set timezone
	$("input[name=timezone]").val -(new Date().getTimezoneOffset() / 60)

	# Menu tabs
	menuTabs = $("#menu").tabs
		active: 0
	menuIndex = $('#menu a[href="#' + datas['displaytab'] + '"]').parent().index()
	menuIndex = 0 if menuIndex < 0
	menuTabs.tabs "option", "active", menuIndex

	# Authentication choice tabs
	authMenuTabs = $("#authMenu").tabs
		active: 0

	# TODO: cookie
	# $("#authMenu").tabs
	# 	cookie:
	# 		name: 'lemonldapauthchoice'
	if datas['choicetab']
		authMenuTabs.tabs "option", "active", $('#authMenu a[href="#' + datas['choicetab'] + '"]').parent().index()

	if datas['login']
		$("input[type=password]:first").focus()
	else
		# Focus on first visible input
		$("input[type!=hidden]:first").focus()

	# Open links in new windows
	if datas['newwindow']
		$('#appslist a').attr "target", "_blank"

	# Complete removeOther link
	if $("p.removeOther").length
		action = $("form.login").attr "action"
		method = $("form.login").attr "method"

		back_url = ""
		if action.indexOf("?") != -1
			action.substring(0, action.indexOf("?")) + "?"
		else
			back_url = action + "?"

		$("form.login input[type=hidden]").each (index) ->
			back_url +=  "&" + $(this).attr("name") + "=" + $(this).val()

		link = $("p.removeOther a").attr("href") + "&method=" + method + "&url=" + btoa(back_url)
		$("p.removeOther a").attr "href", link

	# Language detection
	lang = getCookie 'llnglanguage'
	if !lang
		if navigator
			langs = []
			langs2 = []
			nlangs = [ navigator.language ]
			if navigator.languages
				nlangs = navigator.languages
			for al in window.availableLanguages
				langdiv += "<img class=\"langicon\" src=\"#{window.staticPrefix}common/#{al}.png\" title=\"#{al}\"> "
				for nl in nlangs
					if al == nl
						langs.push al
					else if al.substring(0, 1) == nl.substring(0, 1)
						langs2.push al
			lang = if langs[0] then langs[0] else if langs2[0] then langs2[0] else 'en'
		else
			lang = 'en'
	setCookie 'llnglanguage', lang
	translatePage(lang)

	# Build language icons
	langdiv = ''
	for al in window.availableLanguages
		langdiv += "<img class=\"langicon\" src=\"#{window.staticPrefix}common/#{al}.png\" title=\"#{al}\"> "
	$('#languages').html langdiv
	$('.langicon').on 'click', () ->
		lang = $(this).attr 'title'
		setCookie 'llnglanguage', lang
		translatePage lang

	# Ping if asked
	if datas['pingInterval'] and datas['pingInterval'] > 0
		window.setTimeout ping, datas['pingInterval']

	# Set local dates (used to display history)
	$(".localeDate").each ->
		s = new Date($(this).attr("val")*1000)
		$(this).text s.toLocaleString()

