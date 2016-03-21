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

	# Import translations functions
	$scope.translateTitle = (node) ->
		return $translator.translateField node, 'title'
	$scope.translateP = $translator.translateP
	$scope.translate = $translator.translate

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
		d.promise

	# Intialization function
	# Simply set $scope.waiting to false during $translator and tree root
	# initialization
	init = ->
		$scope.waiting = true
		$q.all [
			$translator.init $scope.lang
		]
		.then ->
			$scope.waiting = false
		, (resp) ->
			$scope.waiting = false

	#TODO: pathEvent
	pathEvent = (event, next, current) ->
		n = next.match(new RegExp('#/(latest|[0-9]+)(?:/(latest|[0-9]+))?$'))
		if n == null
			$location.path '/latest'
		else
			console.log n
			$q.all [
				getCfg 0, n[1]
				getCfg 1, n[2] if n[2]?
			]
			.then () ->
				if n[2]?
					init()
				else
					if $scope.cfg[0].prev
						getCfg 1, $scope.cfg[0].prev
						.then ->
							init()
					else
						console.log 'TODO'
		true

	$scope.$on '$locationChangeSuccess', pathEvent
]
