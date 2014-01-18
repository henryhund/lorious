$ ->
  # $(".accordion-toggle").click ->
  #   $(".xpanel.in").collapse('hide')
  #   element = $(this)
  #   collapse_to_show = element.attr("href")
  #   $(".profile_tabs").parent().removeClass "active"
  #   first_tab_button = $(collapse_to_show).find(".profile_tabs").first()
  #   $(first_tab_button).trigger('click')

  $('a[href*="#edit_profile"]').on 'shown.bs.tab', (e)->
    $(".edit_user").enableClientSideValidations()
    $(".edit_expert").enableClientSideValidations()

  $("body").on "click", ".social_media_remove", (e)->
    element = $(this)
    social_medium_id = element.data("id")
    $.ajax "/users/social_media/" + social_medium_id,
      type: "post"
      data:
        "_method": "delete"
      success: (response)->
        element.hide()
        replaceable_link = element.parent().find('.replaceable_link')
        new_href = replaceable_link.attr('data-href')
        replaceable_link.attr('href', new_href).removeAttr('target')
        replaceable_link.find("i").addClass("disabled").html("&nbsp;Add")
    false

  # $("a[href*='#credit']").on 'click', (e)->
  #   $(".xpanel.in").collapse('hide')
  #   element = $("#collapseFour")
  #   element.collapse('show')
  #   $(".profile_tabs").parent().removeClass "active"
  #   first_tab_button = element.find(".profile_tabs").eq(1)
  #   $(first_tab_button).trigger('click')

  $("a[href*='#appointment']").on 'click', (e)->
    $(".settings-nav").attr "style", "display: none"
    element = $('.appointments-nav')
    element.attr "style", "display: show"
    $(".profile_tabs").parent().removeClass "active"
    first_tab_button = element.find(".profile_tabs").eq(1)
    $(first_tab_button).trigger('click')

  # $("a[href*='#request']").on 'click', (e)->
  #   console.log("request")
  #   $(".xpanel.in").collapse('hide')
  #   element = $("#collapseThree")
  #   element.collapse('show')
  #   $(".profile_tabs").parent().removeClass "active"
  #   first_tab_button = element.find(".profile_tabs").first()
  #   $(first_tab_button).trigger('click')

  # $("a[href*='#profile']").on 'click', (e)->
  #   $(".xpanel.in").collapse('hide')
  #   $(".profile_tabs").parent().removeClass "active"
  #   $("#manage_profile").collapse('show').find(".profile_tabs").eq(1).trigger('click')

  hash = window.location.hash
  switch hash
    when "#manage_card"
      $(".xpanel.in").collapse('hide')
      element = $("#collapseFour")
      element.collapse('show')
      $(".profile_tabs").parent().removeClass "active"
      first_tab_button = element.find(".profile_tabs").eq(0)
      $(first_tab_button).trigger('click')
    when "#credit"
      $(".xpanel.in").collapse('hide')
      element = $("#collapseFour")
      element.collapse('show')
      $(".profile_tabs").parent().removeClass "active"
      first_tab_button = element.find(".profile_tabs").eq(1)
      $(first_tab_button).trigger('click')
    when "#appointment"
      $(".settings-nav").attr "style", "display: none"
      element = $('.appointments-nav')
      element.attr "style", "display: show"
      $(".profile_tabs").parent().removeClass "active"
      first_tab_button = element.find(".profile_tabs").eq(1)
      $(first_tab_button).trigger('click')
    when "#request"
      $(".xpanel.in").collapse('hide')
      element = $("#collapseThree")
      element.collapse('show')
      $(".profile_tabs").parent().removeClass "active"
      first_tab_button = element.find(".profile_tabs").first()
      $(first_tab_button).trigger('click')
    when "#profile"
      element = $("#manage_profile")
      element.collapse('show').find(".profile_tabs").eq(1).trigger('click')
    else
      $("#manage_profile").collapse('show')
