$(document).ready ->
  show_char_upto = 250
  ellipses_text = "..."
  more_text = "more"
  less_text = "less"
  $(".more").each ->
    content = $(this).html()
    if content.length > show_char_upto
      c = content.substr(0, show_char_upto)
      h = content.substr(show_char_upto - 1, content.length - show_char_upto)
      html = c + "<span class=\"moreellipses\">" + ellipses_text + "&nbsp;</span><span class=\"more_content\"><span>" + h + "</span>&nbsp;&nbsp;<a href=\"\" class=\"morelink\">" + more_text + "</a></span>"
      $(this).html html

  $(".morelink").click ->
    if $(this).hasClass("less")
      $(this).removeClass "less"
      $(this).html more_text
    else
      $(this).addClass "less"
      $(this).html less_text
    $(this).parent().prev().toggle()
    $(this).prev().toggle()
    false
