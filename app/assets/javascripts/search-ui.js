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
});