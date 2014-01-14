angular.module('searchFilters', []).filter('rating_filter', function() {
  return function(experts, ratings) {
	if(typeof experts =='undefined'){
	  return experts;
    }
    var unfiltered_result = experts.slice();
  	var result = []; 
  	var rating_value = -1;
  	angular.forEach(ratings, function(value, key) {
  		if(value) {
  			for(var i=0; i < unfiltered_result.length; i++) {
  				expert = unfiltered_result[i];
  				
  				switch(key) {
  					case 'five':
  						rating_value = 5;
  						break;
  					case 'four':
  						rating_value = 4;
  						break;
  					case 'three':
  						rating_value = 3;
  						break;
  					case 'two':
  						rating_value = 2;
  						break;
  					case 'one':
  						rating_value = 1;
  						break;				
  				}
  				
  				if(rating_value == -1 || Math.ceil(expert.average_rating) == rating_value) {
					result.push(expert);
  				}
  			}
  		}
  		
  	})
  	if (rating_value != -1) 
  		return result;
  	else
    	return unfiltered_result;
  };
}).filter('slider_filter', function() {
  return function(experts, slider) {
	if(typeof experts =='undefined'){
	  return experts;
    }
    var result = experts.slice();
    
    for(var i=0; i < result.length; i++) {
		expert = result[i];
		if(expert.hourly_rate < slider[0] || expert.hourly_rate > slider[1]) {
			result.splice(i--,1);
		}
	}	
	return result;
  };
}).filter('duration_filter', function() {
  return function(requests, slider) {
	if(typeof requests =='undefined'){
	  return requests;
    }
    var result = requests.slice();
    
    for(var i=0; i < result.length; i++) {
		request = result[i];
		if(request.appt_length < parseFloat(slider[0])*60 || request.appt_length > parseFloat(slider[1])*60) {
			result.splice(i--,1);
		}
	}	
	return result;
  };
});


