$ ->
  $(".accordion-toggle").click ->
    element = $(this)
    collapse_to_show = element.attr("href")
    $(".profile_tabs").parent().removeClass "active"
    first_tab_button = $(collapse_to_show).find(".profile_tabs").first()
    $(first_tab_button).trigger('click')

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
        element.closest(".social_medium").fadeOut(300)
    false
  
  $("a[href*='#credit']").on 'click', (e)->
    $(".xpanel.in").collapse('hide')
    element = $("#collapseFour")
    element.collapse('show')
    $(".profile_tabs").parent().removeClass "active"
    first_tab_button = element.find(".profile_tabs").first()
    $(first_tab_button).trigger('click')
   
  $("a[href*='#appointment']").on 'click', (e)->
    $(".xpanel.in").collapse('hide')
    element = $("#collapseTwo")
    element.collapse('show')
    $(".profile_tabs").parent().removeClass "active"
    first_tab_button = element.find(".profile_tabs").first()
    $(first_tab_button).trigger('click')
      
  hash = window.location.hash
  switch hash 
    when "#credit"  
      $(".xpanel.in").collapse('hide')
      element = $("#collapseFour")
      element.collapse('show')
      $(".profile_tabs").parent().removeClass "active"
      first_tab_button = element.find(".profile_tabs").first()
      $(first_tab_button).trigger('click')
    when "#appointment"  
      $(".xpanel.in").collapse('hide')
      element = $("#collapseTwo")
      element.collapse('show')
      $(".profile_tabs").parent().removeClass "active"
      first_tab_button = element.find(".profile_tabs").first()
      $(first_tab_button).trigger('click')
    else
      $("#manage_profile").collapse('show')