###
diff.html script
###

llapp = angular.module 'llngConfDiff', ['ui.tree', 'ui.bootstrap', 'llApp', 'ngCookies']

llapp.controller 'DiffCtrl', [ '$scope', '$http', '$q', '$translator', '$location', ($scope, $http, $q, $translator, $location) ->
	$scope.links = links
	$scope.menulinks = menulinks
	$scope.staticPrefix = staticPrefix
	$scope.scriptname = scriptname
	#$scope.formPrefix = formPrefix
	$scope.availableLanguages = availableLanguages
	$scope.waiting = true
	$scope.showM = false
	$scope.cfg = []
	$scope.data = {}

	# Import translations functions
	$scope.translateTitle = (node) ->
		return $translator.translateField node, 'title'
	$scope.translateP = $translator.translateP
	$scope.translate = $translator.translate

	$scope.toggle = (scope) ->
		scope.toggle()

	# Handle menu items
	$scope.menuClick = (button) ->
		if button.popup
			window.open button.popup
		else
			button.action = button.title unless button.action
			switch typeof button.action
				when 'function'
					button.action $scope.currentNode, $scope
				when 'string'
					$scope[button.action]()
				else
					console.log typeof button.action
		$scope.showM = false

	# Function to change interface language
	$scope.getLanguage = (lang) ->
		$scope.lang = lang
		$scope.init()
		$scope.showM = false

	# function `getCfg(b,n)`:
	# Download configuration metadatas
	#
	#@param b local conf (0 or 1)
	#@param n cfgNumber
	getCfg = (b,n) ->
		d = $q.defer()
		if not $scope.cfg[b]? or $scope.cfg[b] != n
			$http.get("#{confPrefix}#{n}").then (response) ->
				$scope.cfg[b] = response.data
				date = new Date response.data.cfgDate * 1000
				$scope.cfg[b].date = date.toLocaleString()
				console.log "Metadatas of cfg #{n} loaded"
				d.resolve 'OK'
			, (response) ->
				console.log response
				d.reject 'NOK'
		else
			d.resolve()
		return d.promise

	# Intialization function
	# Simply set $scope.waiting to false during $translator and tree root
	# initialization
	init = ->
		$scope.message = null
		d = $q.defer()
		$http.get("#{scriptname}diff/#{$scope.cfg[0].cfgNum}/#{$scope.cfg[1].cfgNum}").then (response) ->
			$scope.data = []
			$scope.data = readDiff(response.data[0],response.data[1])
			$scope.waiting = false
		, (response) ->
			$scope.message = "#{$scope.translate('error')} : #{response.statusLine}"

	readDiff = (c1,c2) ->
		res = []
		for k,v of c1
			tmp =
				title: k
			unless k.match /^cfg(?:Num|Log|Author(?:IP)?|Date)$/
				if typeof v == 'object'
					if v.constructor == 'array'
						tmp.oldvalue = v
						tmp.newvalue = c2[k]
					else if typeof c2[k] == 'object'
						tmp.nodes = readDiff c1[k],c2[k]
					else
						tmp.oldnodes = toNodes v, 'old'
				else
					tmp.oldvalue = v
					tmp.newvalue = c2[k]
				res.push tmp
		for k,v of c2
			unless (k.match /^cfg(?:Num|Log|Author(?:IP)?|Date)$/) or c1[k]?
				tmp =
					title: k
				if typeof v == 'object'
					if v.constructor == 'array'
						tmp.newvalue = v
					else
						tmp.newnodes = toNodes v, 'new'
				else
					tmp.newvalue = v
				res.push tmp
		return res

	toNodes = (c,s) ->
		res = []
		for k,v of c
			tmp =
				title:k
			if typeof v == 'object'
				if v.constructor == 'array'
					tmp["#{s}value"] = v
				else
					tmp["#{s}nodes"] = toNodes c[k], s
			else
				tmp["#{s}value"] = v
			res.push tmp
		return res

	pathEvent = (event, next, current) ->
		n = next.match(new RegExp('#/(latest|[0-9]+)(?:/(latest|[0-9]+))?$'))
		if n == null
			$location.path '/latest'
		else
			$scope.waiting = true
			$q.all [
				$translator.init $scope.lang
				getCfg 0, n[1]
				getCfg 1, n[2] if n[2]?
			]
			.then () ->
				if n[2]?
					init()
				else
					if $scope.cfg[0].prev
						$scope.cfg[1] = $scope.cfg[0]
						getCfg 0, $scope.cfg[0].prev
						.then ->
							init()
					else
						$scope.message = $scope.translate 'noDatas'
						$scope.waiting = false
		true

	$scope.$on '$locationChangeSuccess', pathEvent
]
