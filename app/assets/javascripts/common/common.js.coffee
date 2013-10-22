window.lorious = window.lorious || {fn: {}, data: {}}

$ ->
  $(".chosen").chosen()
  
  $("body").on "click", ".login_check", ()->
    if $.cookie("signed_in")
      true
    else
      $("#login_modal").modal "show"
      false
