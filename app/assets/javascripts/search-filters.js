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
});