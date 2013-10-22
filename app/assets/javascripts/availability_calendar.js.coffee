$ ->
  lorious.fn.highlight_availability_list = (availability_list)->
    _.each availability_list, (availability)->
      $('.availability_time_unit[data-end="' + availability.start_time + '"]').addClass("tile").attr("data-available", true)

  $("body").on "click", ".availability_time_unit", ()->

    element = $(this)
    if element.data("available")

    else
      element.addClass("tile").attr("data-available", true)
