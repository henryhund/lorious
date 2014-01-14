var request_app;

request_app = angular.module("requests", ["ngResource", "ui.bootstrap","truncate","ui.slider","localytics.directives","searchFilters"])
.
// Infinite scroll/pagination, this "directive" binds to the view
// in the application HTML, "when-scrolled" is hooked up to "whenScrolled" here
directive('whenScrolled', function() {
	
	return function(scope, elm, attr) {
      var raw = elm[0];
 
      // bind function to the 'scroll' event
      // we listen to the 'scroll' event and calculate when to call the method attached to "when-scrolled"
      // if you recall our HTML page, we have: when-scrolled="load_data()"
      // in our application script we defined "load_data()"
      elm.bind('scroll', function() {
        // calculating the time/space continuum needed to trigger the loading of the next pagination
        if (raw.scrollTop + raw.offsetHeight >= raw.scrollHeight) {
          // from the AngularJS documentation:
          // http://docs.angularjs.org/api/ng.$rootScope.Scope#$apply
          // $apply() is used to execute an expression in angular from outside 
          // of the angular framework. (For example from browser DOM events, setTimeout, 
          // XHR or third party libraries). Because we are calling into the angular 
          // framework we need to perform proper scope life-cycle of 
          // exception handling, executing watches.
          scope.$apply(attr.whenScrolled);
        }
      });
    };
})
.directive('onShow', function(){
	return function(scope, elm, attr) {	
		elm.on('shown.bs.modal', function() {
          	elm.find('#new_message_post').enableClientSideValidations();
          	elm.find('#new_message_post').resetClientSideValidations();
		})
	}
});

request_app.factory("Request", [
  "$resource", function($resource) {
    return $resource("/request_latest", 
	    { id: "@id" }, 
	    { update: { method: "PUT" }}
    );
  }
]);


this.RequestCtrl = [
  "$scope", "$resource", "$route", "$routeParams", "$location", "Request", function($scope, $resource, $route, $routeParams, $location, Request) {
    $scope.loading = false;
    $scope.pg_counter = 1;
	Request.get({id: "", page: $scope.pg_counter++}, function (new_requests) {
	  $scope.requests = new_requests.results;
	  $scope.problems = new_requests.problems;
	  $scope.tags = new_requests.tags;
	});	 
	
	$scope.load_data = function() {
	  if($scope.requests.length < 15){
      	return;
      }
      else{
		$scope.loading = true;
	  	Request.get({id: "", page: ++$scope.pg_counter}, function (new_requests) {
		  $scope.requests.push.apply($scope.requests, new_requests.results);
		  $scope.loading = false;
		});
	  }
    };
    
    $scope.generateSearchParams = function(pageId) {
	  var tag_list = [], problem_list = [];
	  
	  if( typeof $scope.selectedTags !== 'undefined' ) 
		tag_list = $scope.selectedTags;
		
	  if( typeof $scope.selectedProblems !== 'undefined' ) 
		problem_list = $scope.selectedProblems;
      
      $scope.params = {};
      $scope.params.id = "";
      $scope.params.tag_list = tag_list;
      $scope.params.problem_list = problem_list;
      
      return $scope.params;
      
	};
	
    $scope.getFilteredValues = function() {
    	$scope.pg_counter = 1;
    	
    	if( typeof $scope.selectedTags == 'undefined' ) 
			$scope.selectedTags = "";
		
		if( typeof $scope.selectedProblems == 'undefined' ) 
			$scope.selectedProblems = "";
		$scope.loading = true;
	  	Request.get({id: "", page: $scope.pg_counter++, problems: $scope.selectedProblems, tags: $scope.selectedTags}, function (new_requests) {
		  $scope.requests  = new_requests.results;
		  $scope.loading = false;
		});
    };
    
    //Create a watch to filter search 
	$scope.$watch('selectedProblems', function() { 
		if(typeof($scope.selectedProblems) != 'undefined') {	
			//Tags have changed need to get new filtered search result
			$scope.getFilteredValues();
		}
	}, true);
	
	$scope.$watch('selectedTags', function() { 
		if(typeof($scope.selectedTags) != 'undefined') {	
			//Tags have changed need to get new filtered search result
			$scope.getFilteredValues();
		}
	}, true);
    
  }
];