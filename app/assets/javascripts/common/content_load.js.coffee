$ ->
  $("body").on "click", ".content-load", (event)->
    element = $(event.target)
    rest_link = element.data "content-url"
    content_handler = $(element.data("content-handler"))

    $.ajax rest_link,
      success: (response)->
        content_handler.html response
