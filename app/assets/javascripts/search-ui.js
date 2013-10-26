$(function() {
    $(".merged input").on("focus blur", function() {
        $(this).prev().toggleClass("focusedInput")
    });
    
    var options = {
	    callback: function (value) { 
	    	try{
			   	angular.element(document.getElementById('AngularCtrl')).scope().$apply(function(scope){
			        scope.getFilteredValues();
			    });
			}
			catch(e){
				//do nothing
			}
	    },
	    wait: 750,
	    highlight: true,
	    captureLength: 0
	}
	
	$(".searchbox").typeWatch( options );
	
	var loc_options = {
	    callback: function (value) { 
	    	try{
    			if(value == ""){
    				angular.element(document.getElementById('AngularCtrl')).scope().$apply(function(scope){
				        scope.getFilteredValues();
				    });	
    			}
			}
			catch(e){
				//do nothing
			}
	    },
	    wait: 750,
	    highlight: true,
	    captureLength: 0
	}
	$(".locationbox").typeWatch( loc_options );
	
	$('.star').raty({
	  score: function() {
	    return $(this).attr('data-score');
	  },
	  readOnly: true,
	  width: 110
	});
});