$ ->
  lorious.fn.highlight_availability_list = (availability_list)->
    _.each availability_list, (availability)->
      $('.availability_time_unit[data-end="' + availability.start_time + '"]').addClass("tile")
