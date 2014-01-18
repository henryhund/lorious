$(window).scroll(function(){
  if($('body').scrollTop() > 0) {
    $('.header-lg-center').addClass("smoke-break");
  } else {
    $('.header-lg-center').removeClass("smoke-break");
  }
});
// $(function() {
//   $('.input-group').on('focus', '.form-control', function () {
//       $(this).closest('.form-group, .navbar-search').addClass('focus');
//     }).on('blur', '.form-control', function () {
//       $(this).closest('.form-group, .navbar-search').removeClass('focus');
//     });
// });

// $(function() {
// $('.header-lg-center')
// });

// $(function(){
//   $('.navbar').data('size','big');
// });

// $(window).scroll(function(){
//   var $nav = $('.navbar');
//   if ($('body').scrollTop() > 0) {
//     if ($nav.data('size') == 'big') {
//       $nav.data('size','small').stop().animate({
//         height:'40px',
//         paddingTop: '0px'
//       }, 600);
//     }
//   } else {
//     if ($nav.data('size') == 'small') {
//       $nav.data('size','big').stop().animate({
//         height:'68px',
//         paddingTop: '10px'
//       }, 600);
//     }
//   }
// });
