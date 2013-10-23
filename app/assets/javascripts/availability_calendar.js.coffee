$ ->
  lorious.fn.highlight_availability_list = (availability_list)->
    _.each availability_list, (availability)->
      $('.availability_time_unit[data-start="' + availability.start_time + '"]').addClass("available").data("available", true)

  $("body").on "click", ".availability_time_unit", ()->
    element = $(this)
    if element.data("available")
      element.removeClass("available").removeData("available")
    else
      element.addClass("available").data("available", true)

  $("body").on "submit", ".edit_availability", ()->
    available_elements = $(".available")
    available_timespans = _.map $(".available"), (element)->
      start_time: $(element).data("start")
      end_time: $(element).data("end")
    $("#availability_timespans").val JSON.stringify(available_timespans)
