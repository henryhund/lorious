$ ->

  lorious.fn.highlight_availability_list = (availability_list)->
    lorious.data.availability_list = availability_list
    _.each availability_list, (availability)->
      $('.availability_time_unit[data-start="' + availability.start_time + '"]').addClass("available").data("available", true)

  isMouseDown = false

  $("body").on "mousedown", "#edit_availability .availability_time_unit", ()->
      element = $(this)
      isMouseDown = true
      $(this).toggleClass "available"
      false #prevent text selection
  $("body").on "mouseover", "#edit_availability .availability_time_unit", ()->
    $(this).toggleClass "available" if isMouseDown

  $("body").on "mouseup", "#edit_availability .availability_time_unit", ()->
    isMouseDown = false


  # $("body").on "click", "#edit_calendar .availability_time_unit", ()->
  #   element = $(this)
  #   if element.data("available")
  #     element.removeClass("available").removeData("available")
  #   else
  #     element.addClass("available").data("available", true)

  $("body").on "submit", ".edit_availability", ()->
    available_elements = $(".available")
    available_timespans = _.map $(".available"), (element)->
      start_time: $(element).data("start")
      end_time: $(element).data("end")
    $("#availability_timespans").val JSON.stringify(available_timespans)

  #Clear the availability
  $("body").on "click", "#clear_availability", (e)->
    $(".available").removeClass("available")

  $("#time_zone_selector select").change ->
    selected_option_text = $(this).find("option:selected").text()
    lorious.fn.reset_calendar_with_new_timezone(selected_option_text)

  get_total_minutes_with_sign_from_timezone_text = (timezone_text)->
    matcher = timezone_text.match(/([\+\-])(\d{2})\:(\d{2})/)
    sign = matcher[1]
    hours = parseInt(matcher[2])
    minutes = parseInt(matcher[3])
    total_minutes = hours * 60 + minutes
    total_minutes = -total_minutes if sign == "-"
    total_minutes

  get_calendar_time_for_offset = (time, offset)->
    time = time + offset
    if time < 0
      time = lorious.data.total_minutes_in_week + time
    else if time >= lorious.data.total_minutes_in_week
      time = time - lorious.data.total_minutes_in_week
    time

  lorious.fn.reset_calendar_with_new_timezone = (timezone_text)->
    total_minutes_with_sign = get_total_minutes_with_sign_from_timezone_text(timezone_text)
    $(".availability_time_unit").removeClass("available")
    _.each lorious.data.availability_list, (availability)->
      new_start_time = get_calendar_time_for_offset(availability.start_time, total_minutes_with_sign)
      $('.availability_time_unit[data-start="' + new_start_time + '"]').addClass("available").data("available", true)
