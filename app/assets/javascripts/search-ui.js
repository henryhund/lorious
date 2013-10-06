$(function() {
    $(".merged input").on("focus blur", function() {
        $(this).prev().toggleClass("focusedInput")
    });
});