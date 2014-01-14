window.lorious = window.lorious || {fn: {}, data: {}}

lorious.data.total_minutes_in_week = 24 * 7 * 60

$ ->
  $(".chosen").chosen()
  
  $("body").on "click", ".login_check", ()->
    if $.cookie("signed_in")
      true
    else
      $("#login_modal").modal "show"
      false
