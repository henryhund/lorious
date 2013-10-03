$ ->
  $('a[href="#edit_profile"]').on 'shown.bs.tab', (e)->
    $(".edit_user").resetClientSideValidations()
    