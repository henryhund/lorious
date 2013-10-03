$(function(){
  $('.navbar').data('size','big');
});

$(window).scroll(function(){
  var $nav = $('.navbar');
  if ($('body').scrollTop() > 0) {
    if ($nav.data('size') == 'big') {
      $nav.data('size','small').stop().animate({
        height:'40px',
        paddingTop: '0px'
      }, 600);
    }
  } else {
    if ($nav.data('size') == 'small') {
      $nav.data('size','big').stop().animate({
        height:'68px',
        paddingTop: '10px'
      }, 600);
    }
  }
});
