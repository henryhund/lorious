$(function(){$(".navbar").data("size","big")}),$(window).scroll(function(){var a=$(".navbar");$("body").scrollTop()>0?"big"==a.data("size")&&a.data("size","small").stop().animate({height:"40px",paddingTop:"0px"},600):"small"==a.data("size")&&a.data("size","big").stop().animate({height:"68px",paddingTop:"10px"},600)});